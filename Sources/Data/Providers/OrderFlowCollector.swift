import Foundation

/// Collects public Spot executions. Every venue keeps its own trade IDs and connection history.
public actor OrderFlowCollector {
    public static let shared = OrderFlowCollector()

    private let store: OrderFlowStore
    private let session = URLSession(configuration: .default)
    private var workers: [String: Task<Void, Never>] = [:]
    private var sockets: [String: URLSessionWebSocketTask] = [:]
    private var lastPrunedAt: Int64 = 0
    private var pending: [FlowTrade] = []
    private var flushTimer: Task<Void, Never>?

    public init(store: OrderFlowStore = .shared) {
        self.store = store
        try? store.closeInterruptedSessions()
    }

    public func watch(symbols: [String]) {
        if flushTimer == nil {
            flushTimer = Task { [weak self] in
                while !Task.isCancelled {
                    do { try await Task.sleep(for: .seconds(1)) } catch { break }
                    await self?.flushPending()
                }
            }
        }
        let valid = Set(symbols.map { $0.uppercased() }.filter {
            $0.hasSuffix("USDT") && $0.range(of: "^[A-Z0-9]{3,24}$", options: .regularExpression) != nil
        })
        let wanted = Set(valid.flatMap { symbol in
            FlowVenue.allCases.map { "\($0.rawValue)|\(symbol)" }
        })
        for key in workers.keys where !wanted.contains(key) {
            workers.removeValue(forKey: key)?.cancel()
            sockets.removeValue(forKey: key)?.cancel(with: .normalClosure, reason: nil)
        }
        for symbol in valid {
            for venue in FlowVenue.allCases {
                let key = "\(venue.rawValue)|\(symbol)"
                guard workers[key] == nil else { continue }
                workers[key] = Task { [weak self] in
                    guard let self else { return }
                    await self.run(venue: venue, symbol: symbol, key: key)
                }
            }
        }
        pruneIfNeeded()
    }

    private static var nowMs: Int64 { Int64(Date().timeIntervalSince1970 * 1000) }

    private func pruneIfNeeded() {
        let now = Self.nowMs
        guard now - lastPrunedAt > 6 * 3_600_000 else { return }
        do {
            try store.prune(nowMs: now)
            lastPrunedAt = now
        } catch {
            // Retention will be retried on the next batch.
        }
    }

    private func flushPending() {
        guard !pending.isEmpty else { return }
        do {
            try store.record(pending)
            pending.removeAll(keepingCapacity: true)
            pruneIfNeeded()
        } catch {
            // Keep the batch in memory for the next retry; the UI reads only persisted trades.
        }
    }

    private func run(venue: FlowVenue, symbol: String, key: String) async {
        var failures = 0
        while !Task.isCancelled {
            let urlString: String
            switch venue {
            case .binance:
                urlString = "wss://data-stream.binance.vision/ws/\(symbol.lowercased())@aggTrade"
            case .bybit:
                urlString = "wss://stream.bybit.com/v5/public/spot"
            }
            guard let url = URL(string: urlString) else { return }
            let socket = session.webSocketTask(with: url)
            sockets[key] = socket
            socket.resume()

            var sessionId: String?
            var lastTouchMs: Int64 = 0
            let heartbeat: Task<Void, Never>? = venue == .bybit ? Task {
                while !Task.isCancelled {
                    do { try await Task.sleep(for: .seconds(20)) } catch { break }
                    try? await socket.send(.string("{\"op\":\"ping\"}"))
                }
            } : nil
            do {
                if venue == .bybit {
                    let subscription = "{\"op\":\"subscribe\",\"args\":[\"publicTrade.\(symbol)\"]}"
                    try await socket.send(.string(subscription))
                }
                while !Task.isCancelled {
                    let message = try await socket.receive()
                    let text: String
                    switch message {
                    case .string(let value): text = value
                    case .data(let data): text = String(decoding: data, as: UTF8.self)
                    @unknown default: continue
                    }
                    guard let data = text.data(using: .utf8),
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { continue }
                    if sessionId == nil && (venue == .binance ? json["e"] as? String == "aggTrade" :
                                            json["op"] as? String == "subscribe" || json["topic"] as? String == "publicTrade.\(symbol)") {
                        sessionId = try store.beginSession(venue: venue, symbol: symbol, at: Self.nowMs)
                        failures = 0
                    }
                    if let sessionId, Self.nowMs - lastTouchMs >= 10_000 {
                        let now = Self.nowMs
                        try store.touchSession(id: sessionId, at: now)
                        lastTouchMs = now
                    }
                    pending.append(contentsOf: Self.parse(json, venue: venue, symbol: symbol))
                    if pending.count >= 100 { flushPending() }
                }
            } catch {
                // The interval will be marked as missing until this venue reconnects.
            }
            flushPending()
            if let sessionId { try? store.endSession(id: sessionId, at: Self.nowMs) }
            heartbeat?.cancel()
            socket.cancel(with: .normalClosure, reason: nil)
            if sockets[key] === socket { sockets.removeValue(forKey: key) }
            if Task.isCancelled { break }
            failures += 1
            let delay = min(30, 1 << min(failures, 5))
            try? await Task.sleep(for: .seconds(delay))
        }
    }

    private static func parse(_ json: [String: Any], venue: FlowVenue, symbol: String) -> [FlowTrade] {
        switch venue {
        case .binance:
            guard json["e"] as? String == "aggTrade", json["s"] as? String == symbol,
                  let id = (json["a"] as? NSNumber)?.stringValue,
                  let time = (json["T"] as? NSNumber)?.int64Value,
                  let priceString = json["p"] as? String, let price = Double(priceString),
                  let qtyString = json["q"] as? String, let qty = Double(qtyString),
                  let buyerIsMaker = json["m"] as? Bool else { return [] }
            return [FlowTrade(venue: venue, symbol: symbol, tradeId: id, timestampMs: time,
                              price: price, quantity: qty, isTakerBuy: !buyerIsMaker)]
        case .bybit:
            guard json["topic"] as? String == "publicTrade.\(symbol)",
                  let rows = json["data"] as? [[String: Any]] else { return [] }
            return rows.compactMap { row in
                guard row["s"] as? String == symbol,
                      let id = row["i"] as? String,
                      let time = (row["T"] as? NSNumber)?.int64Value,
                      let priceString = row["p"] as? String, let price = Double(priceString),
                      let qtyString = row["v"] as? String, let qty = Double(qtyString),
                      let side = row["S"] as? String, side == "Buy" || side == "Sell" else { return nil }
                return FlowTrade(venue: venue, symbol: symbol, tradeId: id, timestampMs: time,
                                 price: price, quantity: qty, isTakerBuy: side == "Buy")
            }
        }
    }
}

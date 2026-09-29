import Foundation

public protocol WebSocketDelegate: AnyObject, Sendable {
    func webSocketDidReceiveKline(candle: Candle, symbol: String, timeframe: Timeframe)
    func webSocketDidReceiveMiniTicker(symbol: String, price: Double, changePercent: Double, volume: Double)
    func webSocketDidChangeStatus(isConnected: Bool)
    func webSocketDidEncounterError(message: String)
}

public actor BinanceWebSocketManager {
    public static let shared = BinanceWebSocketManager()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession
    private var isConnected: Bool = false
    private var activeSubscriptions: Set<String> = []
    private var requestId: Int = 1
    
    private var currentTickerSymbols: Set<String> = []
    private var tickerSources: [String: Set<String>] = [:]
    
    private var reconnectAttempt: Int = 0
    private var connectionStartTime: Date?
    private var refreshTimerTask: Task<Void, Never>?
    
    private var klineHandler: (@Sendable (Candle, String, Timeframe) -> Void)?
    private var tickerHandler: (@Sendable (String, Double, Double, Double) -> Void)?
    private var statusHandler: (@Sendable (Bool) -> Void)?
    private var errorHandler: (@Sendable (String) -> Void)?
    
    public init() {
        let config = URLSessionConfiguration.default
        self.session = URLSession(configuration: config)
    }
    
    public func setHandlers(
        onKline: (@Sendable @escaping (Candle, String, Timeframe) -> Void),
        onTicker: (@Sendable @escaping (String, Double, Double, Double) -> Void),
        onStatus: (@Sendable @escaping (Bool) -> Void),
        onError: (@Sendable @escaping (String) -> Void)
    ) {
        self.klineHandler = onKline
        self.tickerHandler = onTicker
        self.statusHandler = onStatus
        self.errorHandler = onError
    }
    
    public func start() {
        connect()
    }
    
    private func connect() {
        guard !isConnected else { return }
        
        let url = URL(string: "wss://data-stream.binance.vision/ws")!
        let request = URLRequest(url: url)
        let task = session.webSocketTask(with: request)
        self.webSocketTask = task
        task.resume()
        
        self.isConnected = true
        self.connectionStartTime = Date()
        // reconnectAttempt is reset in handleIncomingText once data actually arrives,
        // otherwise exponential backoff never grows when the server keeps refusing.
        self.statusHandler?(true)
        
        // Listen for messages
        listen()
        
        // Re-subscribe any pending topics
        resubscribeAll()
        
        // Schedule 24h proactive reconnect
        scheduleProactiveRefresh()
    }
    
    private func scheduleProactiveRefresh() {
        refreshTimerTask?.cancel()
        refreshTimerTask = Task { [weak self] in
            // 23.5 hours = 84,600 seconds
            try? await Task.sleep(nanoseconds: 84_600 * 1_000_000_000)
            guard !Task.isCancelled else { return }
            await self?.proactiveReconnect()
        }
    }
    
    private func proactiveReconnect() {
        disconnect()
        connect()
    }
    
    public func disconnect() {
        refreshTimerTask?.cancel()
        refreshTimerTask = nil
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        isConnected = false
        statusHandler?(false)
    }
    
    // MARK: - Kline Multi-Stream Subscriptions
    public func subscribeKline(symbol: String, timeframe: Timeframe) {
        let stream = "\(symbol.lowercased())@kline_\(timeframe.intervalString)"
        subscribeStream(stream: stream)
    }
    
    public func unsubscribeKline(symbol: String, timeframe: Timeframe) {
        let stream = "\(symbol.lowercased())@kline_\(timeframe.intervalString)"
        unsubscribeStream(stream: stream)
    }
    
    // MARK: - Scoped Ticker Subscriptions
    public func updateTickerSubscriptions(source: String, symbols: [String]) {
        tickerSources[source] = Set(symbols.map { $0.uppercased() })
        reconcileTickerSubscriptions()
    }
    
    public func updateWatchlistSubscriptions(symbols: [String]) {
        updateTickerSubscriptions(source: "watchlist", symbols: symbols)
    }
    
    public func getActiveSubscriptions() -> Set<String> {
        return activeSubscriptions
    }
    
    private func reconcileTickerSubscriptions() {
        let unionSymbols = tickerSources.values.reduce(into: Set<String>()) { $0.formUnion($1) }
        let toRemove = currentTickerSymbols.subtracting(unionSymbols)
        let toAdd = unionSymbols.subtracting(currentTickerSymbols)
        
        for sym in toRemove {
            let stream = "\(sym.lowercased())@miniTicker"
            unsubscribeStream(stream: stream)
        }
        
        for sym in toAdd {
            let stream = "\(sym.lowercased())@miniTicker"
            subscribeStream(stream: stream)
        }
        
        self.currentTickerSymbols = unionSymbols
    }
    
    private func subscribeStream(stream: String) {
        activeSubscriptions.insert(stream)
        guard isConnected else { return }
        
        let msg = "{\"method\":\"SUBSCRIBE\",\"params\":[\"\(stream)\"],\"id\":\(requestId)}"
        requestId += 1
        webSocketTask?.send(.string(msg)) { _ in }
    }
    
    private func unsubscribeStream(stream: String) {
        activeSubscriptions.remove(stream)
        guard isConnected else { return }
        
        let msg = "{\"method\":\"UNSUBSCRIBE\",\"params\":[\"\(stream)\"],\"id\":\(requestId)}"
        requestId += 1
        webSocketTask?.send(.string(msg)) { _ in }
    }
    
    private func resubscribeAll() {
        guard isConnected, !activeSubscriptions.isEmpty else { return }
        let params = activeSubscriptions.map { "\"\($0)\"" }.joined(separator: ",")
        let msg = "{\"method\":\"SUBSCRIBE\",\"params\":[\(params)],\"id\":\(requestId)}"
        requestId += 1
        webSocketTask?.send(.string(msg)) { _ in }
    }
    
    private func listen() {
        guard let task = webSocketTask else { return }
        
        task.receive { [weak self] result in
            Task { [weak self] in
                guard let self = self else { return }
                switch result {
                case .success(let message):
                    switch message {
                    case .string(let text):
                        await self.handleIncomingText(text)
                    case .data(let data):
                        if let text = String(data: data, encoding: .utf8) {
                            await self.handleIncomingText(text)
                        }
                    @unknown default:
                        break
                    }
                    // Continue listening
                    await self.listen()
                    
                case .failure(let error):
                    await self.handleDisconnect(error: error)
                }
            }
        }
    }
    
    private func handleIncomingText(_ text: String) {
        reconnectAttempt = 0
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return
        }
        
        // Check for kline event
        if let eventType = json["e"] as? String, eventType == "kline",
           let symbol = json["s"] as? String,
           let k = json["k"] as? [String: Any] {
            
            guard let openTime = k["t"] as? Int64 ?? (k["t"] as? NSNumber)?.int64Value,
                  let openStr = k["o"] as? String, let open = Double(openStr),
                  let highStr = k["h"] as? String, let high = Double(highStr),
                  let lowStr = k["l"] as? String, let low = Double(lowStr),
                  let closeStr = k["c"] as? String, let close = Double(closeStr),
                  let volStr = k["v"] as? String, let volume = Double(volStr),
                  let intervalStr = k["i"] as? String,
                  let timeframe = Timeframe(rawValue: intervalStr) else {
                return
            }
            
            let closeTime = (k["T"] as? Int64 ?? (k["T"] as? NSNumber)?.int64Value) ?? 0
            let quoteVolStr = (k["q"] as? String) ?? "0"
            let trades = (k["n"] as? Int ?? (k["n"] as? NSNumber)?.intValue) ?? 0
            let isClosed = (k["x"] as? Bool) ?? false
            
            let candle = Candle(
                openTime: openTime,
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                closeTime: closeTime,
                quoteVolume: Double(quoteVolStr) ?? 0,
                trades: trades,
                isClosed: isClosed
            )
            
            klineHandler?(candle, symbol, timeframe)
        }
        // Check for 24hrMiniTicker event
        else if let eventType = json["e"] as? String, eventType == "24hrMiniTicker",
                let symbol = json["s"] as? String,
                let closeStr = json["c"] as? String, let close = Double(closeStr),
                let openStr = json["o"] as? String, let open = Double(openStr),
                let volStr = json["v"] as? String, let volume = Double(volStr) {
            
            let changePercent = open > 0 ? ((close - open) / open) * 100.0 : 0.0
            tickerHandler?(symbol, close, changePercent, volume)
        }
    }
    
    private func handleDisconnect(error: Error) {
        guard isConnected else { return }
        isConnected = false
        statusHandler?(false)
        errorHandler?("Mất kết nối WebSocket: \(error.localizedDescription)")
        
        let delay = min(pow(2.0, Double(reconnectAttempt)), 30.0)
        reconnectAttempt += 1
        
        Task {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            self.connect()
        }
    }
}

import Foundation
import GRDB

public enum FlowVenue: String, CaseIterable, Sendable, Identifiable {
    case binance = "Binance Spot"
    case bybit = "Bybit Spot"

    public var id: String { rawValue }
}

public struct FlowTrade: Sendable {
    public let venue: FlowVenue
    public let symbol: String
    public let tradeId: String
    public let timestampMs: Int64
    public let price: Double
    public let quantity: Double
    public let isTakerBuy: Bool
}

public struct FootprintLevel: Sendable, Identifiable {
    public let priceBin: Int64
    public let buyQuantity: Double
    public let sellQuantity: Double
    public var id: Int64 { priceBin }
    public var price: Double { pow(1.0005, Double(priceBin) + 0.5) }
    public var delta: Double { buyQuantity - sellQuantity }
}

public struct FlowCoverage: Sendable {
    public let venue: FlowVenue
    public let observedSeconds: Double
    public let windowSeconds: Double
    public let hasOpenSession: Bool
    public var fraction: Double { min(1, observedSeconds / max(1, windowSeconds)) }
}

public struct FootprintSnapshot: Sendable {
    public let startMs: Int64
    public let endMs: Int64
    public let levels: [FootprintLevel]
    public let coverage: [FlowCoverage]
}

/// Stores observed trades and minute/price aggregates. A missing interval is never filled with zero.
public final class OrderFlowStore: @unchecked Sendable {
    public static let shared = OrderFlowStore()
    private let queue: DatabaseQueue
    private static let binRatio = log(1.0005) // fixed logarithmic grid, about 0.05% per price row

    public init(database: DatabaseManager = .shared) {
        self.queue = database.dbQueue
    }

    public func record(_ trades: [FlowTrade]) throws {
        guard !trades.isEmpty else { return }
        try queue.write { db in
            for trade in trades where trade.price > 0 && trade.quantity > 0 && trade.price.isFinite && trade.quantity.isFinite {
                let minute = trade.timestampMs / 60_000 * 60_000
                let priceBin = Int64(floor(log(trade.price) / Self.binRatio))
                try db.execute(sql: """
                    INSERT OR IGNORE INTO flow_trades
                    (venue, symbol, tradeId, timestampMs, price, quantity, isTakerBuy)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """, arguments: [trade.venue.rawValue, trade.symbol, trade.tradeId,
                                      trade.timestampMs, trade.price, trade.quantity, trade.isTakerBuy])
                guard db.changesCount == 1 else { continue }
                try db.execute(sql: """
                    INSERT INTO flow_minutes (venue, symbol, minuteMs, priceBin, buyQuantity, sellQuantity)
                    VALUES (?, ?, ?, ?, ?, ?)
                    ON CONFLICT(venue, symbol, minuteMs, priceBin) DO UPDATE SET
                    buyQuantity = buyQuantity + excluded.buyQuantity,
                    sellQuantity = sellQuantity + excluded.sellQuantity
                    """, arguments: [trade.venue.rawValue, trade.symbol, minute, priceBin,
                                      trade.isTakerBuy ? trade.quantity : 0,
                                      trade.isTakerBuy ? 0 : trade.quantity])
            }
        }
    }

    public func beginSession(venue: FlowVenue, symbol: String, at timeMs: Int64) throws -> String {
        let id = UUID().uuidString
        try queue.write { db in
            try db.execute(sql: "INSERT INTO flow_sessions (id, venue, symbol, startMs, lastSeenMs) VALUES (?, ?, ?, ?, ?)",
                           arguments: [id, venue.rawValue, symbol, timeMs, timeMs])
        }
        return id
    }

    public func touchSession(id: String, at timeMs: Int64) throws {
        try queue.write { db in
            try db.execute(sql: "UPDATE flow_sessions SET lastSeenMs = ? WHERE id = ? AND endMs IS NULL",
                           arguments: [timeMs, id])
        }
    }

    public func endSession(id: String, at timeMs: Int64) throws {
        try queue.write { db in
            try db.execute(sql: "UPDATE flow_sessions SET endMs = MIN(?, lastSeenMs + 30_000) WHERE id = ? AND endMs IS NULL",
                           arguments: [timeMs, id])
        }
    }

    /// An interrupted process cannot have observed trades after its last persisted execution.
    public func closeInterruptedSessions() throws {
        try queue.write { db in
            try db.execute(sql: """
                UPDATE flow_sessions SET endMs = lastSeenMs
                WHERE endMs IS NULL
                """)
        }
    }

    public func snapshot(symbol: String, since startMs: Int64, until endMs: Int64,
                         venues: [FlowVenue] = FlowVenue.allCases) throws -> FootprintSnapshot {
        guard endMs > startMs else { return FootprintSnapshot(startMs: startMs, endMs: endMs, levels: [], coverage: []) }
        return try queue.read { db in
            var amounts: [Int64: (Double, Double)] = [:]
            var coverages: [FlowCoverage] = []
            for venue in venues {
                let rows = try Row.fetchAll(db, sql: """
                    SELECT priceBin, SUM(buyQuantity) AS buy, SUM(sellQuantity) AS sell
                    FROM flow_minutes WHERE venue = ? AND symbol = ? AND minuteMs >= ? AND minuteMs < ?
                    GROUP BY priceBin
                    """, arguments: [venue.rawValue, symbol, startMs / 60_000 * 60_000,
                                      (endMs + 59_999) / 60_000 * 60_000])
                for row in rows {
                    let bin: Int64 = row["priceBin"]
                    let existing = amounts[bin] ?? (0, 0)
                    let buy: Double = row["buy"]
                    let sell: Double = row["sell"]
                    amounts[bin] = (existing.0 + buy, existing.1 + sell)
                }
                let sessions = try Row.fetchAll(db, sql: """
                    SELECT startMs, lastSeenMs, endMs FROM flow_sessions
                    WHERE venue = ? AND symbol = ? AND startMs < ? AND (endMs IS NULL OR endMs > ?)
                    ORDER BY startMs
                    """, arguments: [venue.rawValue, symbol, endMs, startMs])
                var observedMs: Int64 = 0
                var coveredUntil = startMs
                var open = false
                for row in sessions {
                    let sessionStart: Int64 = row["startMs"]
                    let lastSeen: Int64 = row["lastSeenMs"]
                    let sessionEnd: Int64? = row["endMs"]
                    open = open || (sessionEnd == nil && endMs - lastSeen <= 30_000)
                    let lower = max(max(coveredUntil, sessionStart), startMs)
                    let upper = min(endMs, sessionEnd ?? (lastSeen + 30_000))
                    if upper > lower { observedMs += upper - lower; coveredUntil = upper }
                }
                coverages.append(FlowCoverage(venue: venue, observedSeconds: Double(observedMs) / 1000,
                                              windowSeconds: Double(endMs - startMs) / 1000,
                                              hasOpenSession: open))
            }
            let levels = amounts.map { FootprintLevel(priceBin: $0.key, buyQuantity: $0.value.0,
                                                       sellQuantity: $0.value.1) }
                .sorted { $0.priceBin > $1.priceBin }
            return FootprintSnapshot(startMs: startMs, endMs: endMs, levels: levels, coverage: coverages)
        }
    }

    public func prune(nowMs: Int64) throws {
        try queue.write { db in
            try db.execute(sql: "DELETE FROM flow_trades WHERE timestampMs < ?", arguments: [nowMs - 2 * 86_400_000])
            try db.execute(sql: "DELETE FROM flow_minutes WHERE minuteMs < ?", arguments: [nowMs - 60 * 86_400_000])
            try db.execute(sql: "DELETE FROM flow_sessions WHERE endMs IS NOT NULL AND endMs < ?",
                           arguments: [nowMs - 60 * 86_400_000])
        }
    }
}

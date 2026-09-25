import Testing
import Foundation
@testable import CryptoResearch

struct OrderFlowStoreTests {
    @Test func duplicateTradesAndMissingVenueDoNotInflateFootprint() throws {
        let store = OrderFlowStore(database: DatabaseManager(inMemory: true))
        let base: Int64 = 1_800_000_000_000
        let buy = FlowTrade(venue: .binance, symbol: "BTCUSDT", tradeId: "1", timestampMs: base,
                            price: 80_000, quantity: 2, isTakerBuy: true)
        let sell = FlowTrade(venue: .binance, symbol: "BTCUSDT", tradeId: "2", timestampMs: base + 1_000,
                             price: 80_000, quantity: 0.5, isTakerBuy: false)
        try store.record([buy, buy, sell])
        let session = try store.beginSession(venue: .binance, symbol: "BTCUSDT", at: base)
        try store.endSession(id: session, at: base + 30_000)

        let result = try store.snapshot(symbol: "BTCUSDT", since: base, until: base + 60_000)
        #expect(result.levels.count == 1)
        #expect(result.levels[0].buyQuantity == 2)
        #expect(result.levels[0].sellQuantity == 0.5)
        #expect(result.coverage.first(where: { $0.venue == .binance })?.fraction == 0.5)
        #expect(result.coverage.first(where: { $0.venue == .bybit })?.fraction == 0)
    }

    @Test func interruptedSessionEndsAtLastPersistedTrade() throws {
        let store = OrderFlowStore(database: DatabaseManager(inMemory: true))
        let base: Int64 = 1_800_000_000_000
        let session = try store.beginSession(venue: .bybit, symbol: "ETHUSDT", at: base)
        try store.record([FlowTrade(venue: .bybit, symbol: "ETHUSDT", tradeId: "a",
                                    timestampMs: base + 5_000, price: 2_000, quantity: 1,
                                    isTakerBuy: true)])
        try store.touchSession(id: session, at: base + 5_000)
        try store.closeInterruptedSessions()
        let result = try store.snapshot(symbol: "ETHUSDT", since: base, until: base + 60_000)
        #expect(result.coverage.first(where: { $0.venue == .bybit })?.observedSeconds == 5)
        #expect(result.coverage.first(where: { $0.venue == .bybit })?.hasOpenSession == false)
    }
}

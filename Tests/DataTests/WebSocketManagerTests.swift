import Testing
import Foundation
@testable import CryptoResearch

@Suite("WebSocketManagerTests")
struct WebSocketManagerTests {
    
    @Test("Test scoped ticker subscriptions union without cross cancellation")
    func testScopedTickerSubscriptions() async {
        let ws = BinanceWebSocketManager()
        
        // Source A (watchlist) subscribes BTC, ETH
        await ws.updateTickerSubscriptions(source: "watchlist", symbols: ["BTCUSDT", "ETHUSDT"])
        var subs = await ws.getActiveSubscriptions()
        #expect(subs.contains("btcusdt@miniTicker"))
        #expect(subs.contains("ethusdt@miniTicker"))
        #expect(subs.count == 2)
        
        // Source B (bot) subscribes SOL, SUI
        await ws.updateTickerSubscriptions(source: "bot", symbols: ["SOLUSDT", "SUIUSDT"])
        subs = await ws.getActiveSubscriptions()
        #expect(subs.contains("btcusdt@miniTicker"))
        #expect(subs.contains("ethusdt@miniTicker"))
        #expect(subs.contains("solusdt@miniTicker"))
        #expect(subs.contains("suiusdt@miniTicker"))
        #expect(subs.count == 4)
        
        // Source A updates to only ETH (removes BTC), bot tickers remain intact
        await ws.updateTickerSubscriptions(source: "watchlist", symbols: ["ETHUSDT"])
        subs = await ws.getActiveSubscriptions()
        #expect(!subs.contains("btcusdt@miniTicker"))
        #expect(subs.contains("ethusdt@miniTicker"))
        #expect(subs.contains("solusdt@miniTicker"))
        #expect(subs.contains("suiusdt@miniTicker"))
        #expect(subs.count == 3)
    }
    
    @Test("Test multiple kline subscriptions tracking")
    func testMultiKlineSubscriptions() async {
        let ws = BinanceWebSocketManager()
        
        // Pane 1 subscribes BTC 15m
        await ws.subscribeKline(symbol: "BTCUSDT", timeframe: .m15)
        var subs = await ws.getActiveSubscriptions()
        #expect(subs.contains("btcusdt@kline_15m"))
        
        // Pane 2 subscribes ETH 1h
        await ws.subscribeKline(symbol: "ETHUSDT", timeframe: .h1)
        subs = await ws.getActiveSubscriptions()
        #expect(subs.contains("btcusdt@kline_15m"))
        #expect(subs.contains("ethusdt@kline_1h"))
        #expect(subs.count == 2)
        
        // Unsubscribe Pane 1
        await ws.unsubscribeKline(symbol: "BTCUSDT", timeframe: .m15)
        subs = await ws.getActiveSubscriptions()
        #expect(!subs.contains("btcusdt@kline_15m"))
        #expect(subs.contains("ethusdt@kline_1h"))
        #expect(subs.count == 1)
    }
}

import Testing
import Foundation
@testable import CryptoResearch

@Suite("MultiExchangeOrderbookTests")
struct MultiExchangeOrderbookTests {
    
    @Test("Test ExchangeVenue properties and cases")
    func testExchangeVenueProperties() {
        let venues = ExchangeVenue.allCases
        #expect(venues.count == 3)
        #expect(venues.contains(.binance))
        #expect(venues.contains(.okx))
        #expect(venues.contains(.bybit))
        
        #expect(ExchangeVenue.binance.rawValue == "Binance")
        #expect(ExchangeVenue.okx.rawValue == "OKX")
        #expect(ExchangeVenue.bybit.rawValue == "Bybit")
    }
    
    @Test("Test AggregatedOrderbook creation and metrics")
    func testAggregatedOrderbookMetrics() {
        let bids: [OrderbookLevel] = [
            OrderbookLevel(price: 65000.0, amountToken: 1.0, amountUSD: 65000.0, exchange: .binance),
            OrderbookLevel(price: 64990.0, amountToken: 2.0, amountUSD: 129980.0, exchange: .okx),
            OrderbookLevel(price: 64950.0, amountToken: 1.5, amountUSD: 97425.0, exchange: .bybit)
        ]
        
        let asks: [OrderbookLevel] = [
            OrderbookLevel(price: 65010.0, amountToken: 1.0, amountUSD: 65010.0, exchange: .binance),
            OrderbookLevel(price: 65020.0, amountToken: 1.5, amountUSD: 97530.0, exchange: .okx),
            OrderbookLevel(price: 65050.0, amountToken: 2.0, amountUSD: 130100.0, exchange: .bybit)
        ]
        
        let bestBid = bids.first!.price
        let bestAsk = asks.first!.price
        let midPrice = (bestBid + bestAsk) / 2.0
        let spreadUSD = bestAsk - bestBid
        let spreadBps = (spreadUSD / midPrice) * 10_000.0
        
        let book = AggregatedOrderbook(
            symbol: "BTCUSDT",
            timestamp: Date(),
            bids: bids,
            asks: asks,
            bestBidPrice: bestBid,
            bestAskPrice: bestAsk,
            midPrice: midPrice,
            aggregatedSpreadUSD: spreadUSD,
            aggregatedSpreadBps: spreadBps,
            totalBidDepthUSD: bids.reduce(0.0) { $0 + $1.amountUSD },
            totalAskDepthUSD: asks.reduce(0.0) { $0 + $1.amountUSD },
            depth1PercentUSD: 200_000.0,
            depth2PercentUSD: 292_640.0,
            exchangeSummaries: [
                ExchangeDepthSummary(exchange: .binance, bidDepthUSD: 65000, askDepthUSD: 65010, spreadUSD: 10, spreadBps: 1.5, sharePercent: 35.0),
                ExchangeDepthSummary(exchange: .okx, bidDepthUSD: 129980, askDepthUSD: 97530, spreadUSD: 30, spreadBps: 4.6, sharePercent: 40.0),
                ExchangeDepthSummary(exchange: .bybit, bidDepthUSD: 97425, askDepthUSD: 130100, spreadUSD: 100, spreadBps: 15.3, sharePercent: 25.0)
            ]
        )
        
        #expect(book.bestBidPrice == 65000.0)
        #expect(book.bestAskPrice == 65010.0)
        #expect(book.midPrice == 65005.0)
        #expect(book.aggregatedSpreadUSD == 10.0)
        #expect(book.aggregatedSpreadBps > 0.0)
        #expect(book.exchangeSummaries.count == 3)
    }
    
    @Test("Test MarketImpact & TWAP simulation calculations")
    func testMarketImpactAndTWAP() {
        let asks: [OrderbookLevel] = [
            OrderbookLevel(price: 65000.0, amountToken: 5.0, amountUSD: 325_000.0, exchange: .binance),
            OrderbookLevel(price: 65010.0, amountToken: 10.0, amountUSD: 650_100.0, exchange: .okx),
            OrderbookLevel(price: 65030.0, amountToken: 10.0, amountUSD: 650_300.0, exchange: .bybit),
            OrderbookLevel(price: 65100.0, amountToken: 20.0, amountUSD: 1_302_000.0, exchange: .binance)
        ]
        
        let bids: [OrderbookLevel] = [
            OrderbookLevel(price: 64990.0, amountToken: 5.0, amountUSD: 324_950.0, exchange: .binance),
            OrderbookLevel(price: 64980.0, amountToken: 10.0, amountUSD: 649_800.0, exchange: .okx),
            OrderbookLevel(price: 64950.0, amountToken: 10.0, amountUSD: 649_500.0, exchange: .bybit)
        ]
        
        let book = AggregatedOrderbook(
            symbol: "BTCUSDT",
            timestamp: Date(),
            bids: bids,
            asks: asks,
            bestBidPrice: 64990.0,
            bestAskPrice: 65000.0,
            midPrice: 64995.0,
            aggregatedSpreadUSD: 10.0,
            aggregatedSpreadBps: 1.5,
            totalBidDepthUSD: 1_624_250.0,
            totalAskDepthUSD: 2_927_400.0,
            depth1PercentUSD: 4_500_000.0,
            depth2PercentUSD: 4_500_000.0,
            exchangeSummaries: []
        )
        
        let provider = MultiExchangeOrderbookProvider.shared
        let capital: Double = 500_000.0
        let simResult = provider.simulateExecution(capitalUSD: capital, side: .buy, book: book)
        
        #expect(simResult.capitalAmountUSD == capital)
        #expect(simResult.side == .buy)
        #expect(simResult.aggregatedFillPrice >= book.midPrice)
        #expect(simResult.aggregatedSlippagePercent >= 0.0)
        
        // TWAP checks
        let twap = simResult.twapPlan
        #expect(twap.numberOfSlices > 0)
        #expect(twap.sliceAmountUSD == capital / Double(twap.numberOfSlices))
        #expect(twap.estimatedTWAPSlippagePercent <= simResult.aggregatedSlippagePercent)
        #expect(twap.estimatedSlippageSavingsUSD >= 0.0)
        #expect(!twap.routingAllocations.isEmpty)
    }
}

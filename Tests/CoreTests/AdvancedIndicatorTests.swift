import Testing
import Foundation
@testable import CryptoResearch

struct AdvancedIndicatorTests {
    
    @Test func testVWAPCalculation() {
        let candles: [Candle] = [
            Candle(openTime: 1000, open: 100, high: 110, low: 90, close: 100, volume: 10), // TP = 100, Vol = 10, TPV = 1000, VWAP = 100
            Candle(openTime: 2000, open: 100, high: 120, low: 100, close: 110, volume: 20), // TP = 110, Vol = 20, TPV = 2200, CumTPV = 3200, CumVol = 30, VWAP = 3200/30 = 106.66666667
        ]
        
        let vwap = VWAP.calculate(candles: candles)
        #expect(vwap.count == 2)
        #expect(abs(vwap[0]! - 100.0) <= 1e-9)
        #expect(abs(vwap[1]! - (3200.0 / 30.0)) <= 1e-9)
    }
    
    @Test func testStochRSICalculation() {
        var prices = [Double]()
        for i in 0..<50 {
            prices.append(100.0 + sin(Double(i) * 0.2) * 10.0)
        }
        
        let result = StochasticRSI.calculate(values: prices, rsiPeriod: 14, stochPeriod: 14, kPeriod: 3, dPeriod: 3)
        #expect(result.kLine.count == 50)
        #expect(result.dLine.count == 50)
        
        // Ensure values are within [0, 100]
        for val in result.kLine.compactMap({ $0 }) {
            #expect(val >= -0.01 && val <= 100.01)
        }
    }
    
    @Test func testDrawingElementCreation() {
        let element = DrawingElement(
            symbol: "BTCUSDT",
            type: .trendline,
            startPoint: CandlePoint(openTime: 1700000000000, price: 80000.0),
            endPoint: CandlePoint(openTime: 1700003600000, price: 85000.0),
            isCompleted: true
        )
        
        #expect(element.symbol == "BTCUSDT")
        #expect(element.type == .trendline)
        #expect(element.isCompleted == true)
    }
    
    @Test func testTimeframeProperties() {
        let allTfs = Timeframe.allCases
        #expect(allTfs.count == 8)
        #expect(Timeframe.mo1.displayName == "1M")
        #expect(Timeframe.mo1.intervalString == "1M")
        #expect(Timeframe.mo1.shortcutNumber == 8)
        #expect(Timeframe.m1.displayName == "1m")
        #expect(Timeframe.d1.displayName == "1D")
        #expect(Timeframe.w1.displayName == "1W")
    }
}

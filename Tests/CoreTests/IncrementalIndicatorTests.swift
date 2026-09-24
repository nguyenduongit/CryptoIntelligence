import Testing
@testable import CryptoResearch

struct IncrementalIndicatorTests {
    
    @Test func testIncrementalEMAMatchesFullEMA() {
        let prices: [Double] = [
            100.0, 102.0, 101.5, 103.0, 105.0, 104.5, 106.0, 107.0, 106.5, 108.0,
            110.0, 109.0, 111.0, 112.5, 111.0, 113.0, 115.0, 114.0, 116.0, 118.0
        ]
        let period = 12
        let fullEMA = MovingAverage.calculateEMA(values: prices, period: period)
        
        var currentEMA = fullEMA[period - 1]!
        
        for i in period..<prices.count {
            currentEMA = MovingAverage.stepEMA(previousEMA: currentEMA, newPrice: prices[i], period: period)
            #expect(abs(currentEMA - fullEMA[i]!) <= 1e-12, "Incremental EMA mismatch at \(i)")
        }
    }
    
    @Test func testIncrementalRSIMatchesFullRSI() {
        let prices: [Double] = [
            44.34, 44.09, 44.15, 43.61, 44.33, 44.83, 45.10, 45.42, 45.84, 46.08,
            45.89, 46.03, 45.61, 46.28, 46.28, 46.00, 46.03, 46.41, 46.22, 45.64,
            46.21, 46.25, 45.71, 46.45, 45.78, 46.33, 46.66, 46.85, 47.00, 46.80
        ]
        let period = 14
        let fullRSI = RSI.calculate(values: prices, period: period)
        
        var gains = [Double](repeating: 0.0, count: prices.count)
        var losses = [Double](repeating: 0.0, count: prices.count)
        for i in 1...period {
            let diff = prices[i] - prices[i-1]
            if diff > 0 { gains[i] = diff } else { losses[i] = -diff }
        }
        var avgGain = gains[1...period].reduce(0, +) / Double(period)
        var avgLoss = losses[1...period].reduce(0, +) / Double(period)
        
        for i in (period + 1)..<prices.count {
            let diff = prices[i] - prices[i-1]
            let g = diff > 0 ? diff : 0.0
            let l = diff < 0 ? -diff : 0.0
            
            let step = RSI.stepRSI(
                previousAvgGain: avgGain,
                previousAvgLoss: avgLoss,
                currentGain: g,
                currentLoss: l,
                period: period
            )
            
            avgGain = step.newAvgGain
            avgLoss = step.newAvgLoss
            
            #expect(abs(step.rsi - fullRSI[i]!) <= 1e-12, "Incremental RSI mismatch at \(i)")
        }
    }
}

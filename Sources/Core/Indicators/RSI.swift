import Foundation

public struct RSIState: Sendable, Equatable {
    public var lastPrice: Double
    public var avgGain: Double
    public var avgLoss: Double
    public var count: Int
    
    public init(lastPrice: Double, avgGain: Double, avgLoss: Double, count: Int) {
        self.lastPrice = lastPrice
        self.avgGain = avgGain
        self.avgLoss = avgLoss
        self.count = count
    }
}

public struct RSI {
    /// Calculate RSI using Wilder's RMA (Smoothed Moving Average)
    public static func calculate(values: [Double], period: Int = 14) -> [Double?] {
        guard period > 0 else { return Array(repeating: nil, count: values.count) }
        var result = [Double?](repeating: nil, count: values.count)
        guard values.count > period else { return result }
        
        var gains = [Double](repeating: 0.0, count: values.count)
        var losses = [Double](repeating: 0.0, count: values.count)
        
        for i in 1..<values.count {
            let change = values[i] - values[i - 1]
            if change > 0 {
                gains[i] = change
                losses[i] = 0.0
            } else {
                gains[i] = 0.0
                losses[i] = -change
            }
        }
        
        // Initial average gain/loss is simple average of first `period` changes
        var sumGain: Double = 0.0
        var sumLoss: Double = 0.0
        for i in 1...period {
            sumGain += gains[i]
            sumLoss += losses[i]
        }
        
        var avgGain = sumGain / Double(period)
        var avgLoss = sumLoss / Double(period)
        
        if avgLoss == 0.0 {
            result[period] = 100.0
        } else if avgGain == 0.0 {
            result[period] = 0.0
        } else {
            let rs = avgGain / avgLoss
            result[period] = 100.0 - (100.0 / (1.0 + rs))
        }
        
        // Wilder's smoothing for remaining points
        for i in (period + 1)..<values.count {
            avgGain = (avgGain * Double(period - 1) + gains[i]) / Double(period)
            avgLoss = (avgLoss * Double(period - 1) + losses[i]) / Double(period)
            
            if avgLoss == 0.0 {
                result[i] = 100.0
            } else if avgGain == 0.0 {
                result[i] = 0.0
            } else {
                let rs = avgGain / avgLoss
                result[i] = 100.0 - (100.0 / (1.0 + rs))
            }
        }
        
        return result
    }
    
    /// Incremental step for Wilder's RSI calculation
    public static func stepRSI(
        previousAvgGain: Double,
        previousAvgLoss: Double,
        currentGain: Double,
        currentLoss: Double,
        period: Int
    ) -> (rsi: Double, newAvgGain: Double, newAvgLoss: Double) {
        let newAvgGain = (previousAvgGain * Double(period - 1) + currentGain) / Double(period)
        let newAvgLoss = (previousAvgLoss * Double(period - 1) + currentLoss) / Double(period)
        
        if newAvgLoss == 0.0 {
            return (100.0, newAvgGain, newAvgLoss)
        } else if newAvgGain == 0.0 {
            return (0.0, newAvgGain, newAvgLoss)
        } else {
            let rs = newAvgGain / newAvgLoss
            let rsi = 100.0 - (100.0 / (1.0 + rs))
            return (rsi, newAvgGain, newAvgLoss)
        }
    }
}

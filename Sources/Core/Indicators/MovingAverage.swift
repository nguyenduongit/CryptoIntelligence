import Foundation

public struct MovingAverage {
    /// Calculate Simple Moving Average for an array of values
    public static func calculateSMA(values: [Double], period: Int) -> [Double?] {
        guard period > 0 else { return Array(repeating: nil, count: values.count) }
        var result = [Double?](repeating: nil, count: values.count)
        guard values.count >= period else { return result }
        
        var sum: Double = 0.0
        for i in 0..<period {
            sum += values[i]
        }
        result[period - 1] = sum / Double(period)
        
        for i in period..<values.count {
            sum += values[i] - values[i - period]
            result[i] = sum / Double(period)
        }
        
        return result
    }
    
    /// Calculate Exponential Moving Average
    /// Initial value is the SMA of the first `period` elements.
    /// Multiplier alpha = 2 / (period + 1)
    public static func calculateEMA(values: [Double], period: Int) -> [Double?] {
        guard period > 0 else { return Array(repeating: nil, count: values.count) }
        var result = [Double?](repeating: nil, count: values.count)
        guard values.count >= period else { return result }
        
        let alpha = 2.0 / Double(period + 1)
        
        // Initial value = SMA of first `period` items
        var sum: Double = 0.0
        for i in 0..<period {
            sum += values[i]
        }
        var prevEMA = sum / Double(period)
        result[period - 1] = prevEMA
        
        for i in period..<values.count {
            let ema = values[i] * alpha + prevEMA * (1.0 - alpha)
            result[i] = ema
            prevEMA = ema
        }
        
        return result
    }
    
    /// Calculate incremental single EMA step given previous EMA value
    public static func stepEMA(previousEMA: Double, newPrice: Double, period: Int) -> Double {
        let alpha = 2.0 / Double(period + 1)
        return newPrice * alpha + previousEMA * (1.0 - alpha)
    }
}

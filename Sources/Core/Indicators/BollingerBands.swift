import Foundation

public struct BollingerResult: Sendable, Equatable {
    public let middle: [Double?]
    public let upper: [Double?]
    public let lower: [Double?]
    
    public init(middle: [Double?], upper: [Double?], lower: [Double?]) {
        self.middle = middle
        self.upper = upper
        self.lower = lower
    }
}

public struct BollingerBands {
    /// Calculates Bollinger Bands using SMA and Population Standard Deviation (divide by N)
    public static func calculate(values: [Double], period: Int = 20, multiplier: Double = 2.0) -> BollingerResult {
        guard period > 0 else {
            let nils = [Double?](repeating: nil, count: values.count)
            return BollingerResult(middle: nils, upper: nils, lower: nils)
        }
        
        var middle = [Double?](repeating: nil, count: values.count)
        var upper = [Double?](repeating: nil, count: values.count)
        var lower = [Double?](repeating: nil, count: values.count)
        
        guard values.count >= period else {
            return BollingerResult(middle: middle, upper: upper, lower: lower)
        }
        
        let sma = MovingAverage.calculateSMA(values: values, period: period)
        let pDouble = Double(period)
        
        for i in (period - 1)..<values.count {
            guard let mid = sma[i] else { continue }
            middle[i] = mid
            
            // Calculate population standard deviation: sqrt( sum( (x - mean)^2 ) / N )
            var sumSquaredDiff: Double = 0.0
            let start = i - period + 1
            for j in start...i {
                let diff = values[j] - mid
                sumSquaredDiff += diff * diff
            }
            let populationStdDev = (sumSquaredDiff / pDouble).squareRoot()
            
            upper[i] = mid + multiplier * populationStdDev
            lower[i] = mid - multiplier * populationStdDev
        }
        
        return BollingerResult(middle: middle, upper: upper, lower: lower)
    }
}

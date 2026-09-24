import Foundation

public struct MACDResult: Sendable, Equatable {
    public let macdLine: [Double?]
    public let signalLine: [Double?]
    public let histogram: [Double?]
    
    public init(macdLine: [Double?], signalLine: [Double?], histogram: [Double?]) {
        self.macdLine = macdLine
        self.signalLine = signalLine
        self.histogram = histogram
    }
}

public struct MACD {
    /// Calculate MACD (Moving Average Convergence Divergence)
    public static func calculate(
        values: [Double],
        fastPeriod: Int = 12,
        slowPeriod: Int = 26,
        signalPeriod: Int = 9
    ) -> MACDResult {
        let nils = [Double?](repeating: nil, count: values.count)
        guard fastPeriod > 0, slowPeriod > fastPeriod, signalPeriod > 0, values.count >= slowPeriod else {
            return MACDResult(macdLine: nils, signalLine: nils, histogram: nils)
        }
        
        let fastEMA = MovingAverage.calculateEMA(values: values, period: fastPeriod)
        let slowEMA = MovingAverage.calculateEMA(values: values, period: slowPeriod)
        
        var macdLine = [Double?](repeating: nil, count: values.count)
        for i in 0..<values.count {
            if let f = fastEMA[i], let s = slowEMA[i] {
                macdLine[i] = f - s
            }
        }
        
        // Calculate Signal Line: EMA(signalPeriod) on valid macdLine values
        var signalLine = [Double?](repeating: nil, count: values.count)
        var histogram = [Double?](repeating: nil, count: values.count)
        
        // Find valid MACD values start index (which is slowPeriod - 1)
        let startIndex = slowPeriod - 1
        let validMacdCount = values.count - startIndex
        
        guard validMacdCount >= signalPeriod else {
            return MACDResult(macdLine: macdLine, signalLine: signalLine, histogram: histogram)
        }
        
        var validMacdValues = [Double]()
        for i in startIndex..<values.count {
            if let v = macdLine[i] {
                validMacdValues.append(v)
            }
        }
        
        let signalEmaValues = MovingAverage.calculateEMA(values: validMacdValues, period: signalPeriod)
        
        for (offset, sig) in signalEmaValues.enumerated() {
            let actualIndex = startIndex + offset
            signalLine[actualIndex] = sig
            if let sigVal = sig, let macdVal = macdLine[actualIndex] {
                histogram[actualIndex] = macdVal - sigVal
            }
        }
        
        return MACDResult(macdLine: macdLine, signalLine: signalLine, histogram: histogram)
    }
}

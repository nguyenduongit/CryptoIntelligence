import Foundation

public struct StochRSIResult: Sendable, Equatable {
    public let kLine: [Double?]
    public let dLine: [Double?]
    
    public init(kLine: [Double?], dLine: [Double?]) {
        self.kLine = kLine
        self.dLine = dLine
    }
}

public struct StochasticRSI {
    /// Calculate Stochastic RSI (%K and %D lines)
    public static func calculate(
        values: [Double],
        rsiPeriod: Int = 14,
        stochPeriod: Int = 14,
        kPeriod: Int = 3,
        dPeriod: Int = 3
    ) -> StochRSIResult {
        let nils = [Double?](repeating: nil, count: values.count)
        guard values.count > (rsiPeriod + stochPeriod) else {
            return StochRSIResult(kLine: nils, dLine: nils)
        }
        
        // 1. Calculate standard RSI
        let rsiValues = RSI.calculate(values: values, period: rsiPeriod)
        
        // 2. Calculate raw Stoch RSI
        var rawStoch = [Double?](repeating: nil, count: values.count)
        
        for i in 0..<values.count {
            let startIdx = i - stochPeriod + 1
            guard startIdx >= 0 else { continue }
            
            var minRSI = Double.greatestFiniteMagnitude
            var maxRSI = -Double.greatestFiniteMagnitude
            var hasValidRSI = true
            
            for j in startIdx...i {
                guard let r = rsiValues[j] else {
                    hasValidRSI = false
                    break
                }
                if r < minRSI { minRSI = r }
                if r > maxRSI { maxRSI = r }
            }
            
            guard hasValidRSI, let currentRSI = rsiValues[i] else { continue }
            
            let span = maxRSI - minRSI
            if span > 0 {
                rawStoch[i] = ((currentRSI - minRSI) / span) * 100.0
            } else {
                rawStoch[i] = 50.0
            }
        }
        
        // 3. Calculate %K (SMA of raw Stoch)
        var validRaw = [Double]()
        var rawIndices = [Int]()
        for i in 0..<values.count {
            if let val = rawStoch[i] {
                validRaw.append(val)
                rawIndices.append(i)
            }
        }
        
        let kSMA = MovingAverage.calculateSMA(values: validRaw, period: kPeriod)
        var kLine = [Double?](repeating: nil, count: values.count)
        for (idx, kVal) in kSMA.enumerated() {
            let actualIndex = rawIndices[idx]
            kLine[actualIndex] = kVal
        }
        
        // 4. Calculate %D (SMA of %K)
        var validK = [Double]()
        var kIndices = [Int]()
        for i in 0..<values.count {
            if let val = kLine[i] {
                validK.append(val)
                kIndices.append(i)
            }
        }
        
        let dSMA = MovingAverage.calculateSMA(values: validK, period: dPeriod)
        var dLine = [Double?](repeating: nil, count: values.count)
        for (idx, dVal) in dSMA.enumerated() {
            let actualIndex = kIndices[idx]
            dLine[actualIndex] = dVal
        }
        
        return StochRSIResult(kLine: kLine, dLine: dLine)
    }
}

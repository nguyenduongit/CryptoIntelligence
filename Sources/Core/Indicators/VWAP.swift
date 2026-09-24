import Foundation

public struct VWAP {
    /// Calculate Volume-Weighted Average Price
    public static func calculate(candles: [Candle]) -> [Double?] {
        var result = [Double?](repeating: nil, count: candles.count)
        guard !candles.isEmpty else { return result }
        
        var cumulativeTPV: Double = 0.0
        var cumulativeVol: Double = 0.0
        
        for i in 0..<candles.count {
            let c = candles[i]
            let typicalPrice = (c.high + c.low + c.close) / 3.0
            let tpv = typicalPrice * c.volume
            
            cumulativeTPV += tpv
            cumulativeVol += c.volume
            
            if cumulativeVol > 0 {
                result[i] = cumulativeTPV / cumulativeVol
            } else {
                result[i] = typicalPrice
            }
        }
        
        return result
    }
}

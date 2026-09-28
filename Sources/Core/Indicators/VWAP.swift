import Foundation

public struct VWAP {
    /// Calculate Volume-Weighted Average Price
    /// - Parameters:
    ///   - candles: List of candles ordered chronologically.
    ///   - sessionReset: If true (default), resets cumulative volume and TPV at each UTC day boundary (00:00:00 UTC).
    public static func calculate(candles: [Candle], sessionReset: Bool = true) -> [Double?] {
        var result = [Double?](repeating: nil, count: candles.count)
        guard !candles.isEmpty else { return result }
        
        var cumulativeTPV: Double = 0.0
        var cumulativeVol: Double = 0.0
        var currentSessionDay: Int64 = -1
        
        for i in 0..<candles.count {
            let c = candles[i]
            
            if sessionReset {
                // 86,400,000 ms per UTC day
                let candleDay = c.openTime / 86_400_000
                if candleDay != currentSessionDay {
                    cumulativeTPV = 0.0
                    cumulativeVol = 0.0
                    currentSessionDay = candleDay
                }
            }
            
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

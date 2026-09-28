import Foundation

public struct VWAP {
    /// Calculate Volume-Weighted Average Price
    /// - Parameters:
    ///   - candles: List of candles ordered chronologically.
    ///   - timeframe: Timeframe of candles (e.g. .m15, .h1, .d1, .w1, .mo1).
    ///   - sessionReset: If true (default), resets cumulative volume and TPV at each UTC day boundary (00:00:00 UTC) for intraday timeframes.
    ///     For high timeframes (>= 1D: .d1, .w1, .mo1), session-based daily resetting is disabled to prevent collapsing into (H+L+C)/3;
    ///     instead, an Anchored Cumulative VWAP across the historical series is calculated.
    public static func calculate(
        candles: [Candle],
        timeframe: Timeframe? = nil,
        sessionReset: Bool = true
    ) -> [Double?] {
        var result = [Double?](repeating: nil, count: candles.count)
        guard !candles.isEmpty else { return result }
        
        let isHighTimeframe: Bool
        if let tf = timeframe {
            isHighTimeframe = (tf == .d1 || tf == .w1 || tf == .mo1 || tf.stepMs >= 86_400_000)
        } else if candles.count >= 2 {
            let step = abs(candles[1].openTime - candles[0].openTime)
            isHighTimeframe = step >= 86_400_000
        } else {
            isHighTimeframe = false
        }
        
        let shouldResetPerDay = sessionReset && !isHighTimeframe
        
        var cumulativeTPV: Double = 0.0
        var cumulativeVol: Double = 0.0
        var currentSessionDay: Int64 = -1
        
        for i in 0..<candles.count {
            let c = candles[i]
            
            if shouldResetPerDay {
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

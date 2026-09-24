import Foundation

public struct ATR {
    /// Calculate Average True Range using Wilder's RMA
    public static func calculate(candles: [Candle], period: Int = 14) -> [Double?] {
        guard period > 0 else { return Array(repeating: nil, count: candles.count) }
        var result = [Double?](repeating: nil, count: candles.count)
        guard candles.count >= period else { return result }
        
        var tr = [Double](repeating: 0.0, count: candles.count)
        if !candles.isEmpty {
            tr[0] = candles[0].high - candles[0].low
        }
        
        for i in 1..<candles.count {
            let h = candles[i].high
            let l = candles[i].low
            let prevC = candles[i - 1].close
            let hl = h - l
            let hpc = abs(h - prevC)
            let lpc = abs(l - prevC)
            tr[i] = max(hl, max(hpc, lpc))
        }
        
        // Initial ATR = SMA of first `period` TR values
        var sumTR: Double = 0.0
        for i in 0..<period {
            sumTR += tr[i]
        }
        var prevATR = sumTR / Double(period)
        result[period - 1] = prevATR
        
        for i in period..<candles.count {
            let currentATR = (prevATR * Double(period - 1) + tr[i]) / Double(period)
            result[i] = currentATR
            prevATR = currentATR
        }
        
        return result
    }
}

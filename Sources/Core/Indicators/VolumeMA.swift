import Foundation

public struct VolumeMA {
    /// Calculate Volume Moving Average
    public static func calculate(candles: [Candle], period: Int = 20) -> [Double?] {
        let volumes = candles.map { $0.volume }
        return MovingAverage.calculateSMA(values: volumes, period: period)
    }
}

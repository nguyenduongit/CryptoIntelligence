import Foundation

public struct Candle: Identifiable, Sendable, Codable, Equatable {
    public var id: Int64 { openTime }
    
    public let openTime: Int64
    public var open: Double
    public var high: Double
    public var low: Double
    public var close: Double
    public var volume: Double
    public var closeTime: Int64
    public var quoteVolume: Double
    public var trades: Int
    public var isClosed: Bool

    public init(
        openTime: Int64,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double,
        closeTime: Int64 = 0,
        quoteVolume: Double = 0,
        trades: Int = 0,
        isClosed: Bool = true
    ) {
        self.openTime = openTime
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
        self.closeTime = closeTime
        self.quoteVolume = quoteVolume
        self.trades = trades
        self.isClosed = isClosed
    }
    
    public var isBullish: Bool {
        close >= open
    }
    
    public var changePercent: Double {
        guard open > 0 else { return 0 }
        return ((close - open) / open) * 100.0
    }
}

import Foundation
import GRDB

public struct CandleRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "candles"
    
    public var symbol: String
    public var interval: String
    public var openTime: Int64
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
        symbol: String,
        interval: String,
        candle: Candle
    ) {
        self.symbol = symbol
        self.interval = interval
        self.openTime = candle.openTime
        self.open = candle.open
        self.high = candle.high
        self.low = candle.low
        self.close = candle.close
        self.volume = candle.volume
        self.closeTime = candle.closeTime
        self.quoteVolume = candle.quoteVolume
        self.trades = candle.trades
        self.isClosed = candle.isClosed
    }
    
    public func toModel() -> Candle {
        Candle(
            openTime: openTime,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume,
            closeTime: closeTime,
            quoteVolume: quoteVolume,
            trades: trades,
            isClosed: isClosed
        )
    }
}

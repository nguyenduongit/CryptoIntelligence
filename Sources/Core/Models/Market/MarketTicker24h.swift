import Foundation

public struct MarketTicker24h: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    
    public let symbol: String
    public let baseAsset: String
    public var price: Double
    public var priceChange: Double
    public var priceChangePercent: Double
    public var highPrice: Double
    public var lowPrice: Double
    public var volume: Double        // 24h Base Asset Volume (e.g. BTC)
    public var quoteVolume: Double   // 24h Quote Asset Volume (e.g. USDT Volume)
    public var tradesCount: Int
    public var sector: CryptoSector
    public var closeTime: Int64
    
    public var isBullish: Bool {
        priceChangePercent >= 0
    }
    
    public init(
        symbol: String,
        baseAsset: String,
        price: Double,
        priceChange: Double,
        priceChangePercent: Double,
        highPrice: Double,
        lowPrice: Double,
        volume: Double,
        quoteVolume: Double,
        tradesCount: Int,
        sector: CryptoSector,
        closeTime: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.price = price
        self.priceChange = priceChange
        self.priceChangePercent = priceChangePercent
        self.highPrice = highPrice
        self.lowPrice = lowPrice
        self.volume = volume
        self.quoteVolume = quoteVolume
        self.tradesCount = tradesCount
        self.sector = sector
        self.closeTime = closeTime
    }
}

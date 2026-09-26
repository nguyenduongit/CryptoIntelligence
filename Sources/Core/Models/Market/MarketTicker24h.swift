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
    
    public var estimatedMarketCap: Double {
        if let supply = EstimatedCirculatingSupply.supply(for: baseAsset) {
            return supply * price
        }
        // Fallback proxy: 24h quote volume * 12 (typical crypto market cap / volume ratio)
        return max(10_000_000, quoteVolume * 12.0)
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

public enum EstimatedCirculatingSupply {
    private static let supplies: [String: Double] = [
        "BTC": 19_780_000,
        "ETH": 120_400_000,
        "SOL": 470_000_000,
        "BNB": 145_000_000,
        "XRP": 56_000_000_000,
        "DOGE": 146_000_000_000,
        "ADA": 35_700_000_000,
        "AVAX": 405_000_000,
        "SUI": 2_850_000_000,
        "NEAR": 1_210_000_000,
        "LINK": 608_000_000,
        "TRX": 86_000_000_000,
        "DOT": 1_430_000_000,
        "SHIB": 589_000_000_000_000,
        "PEPE": 420_690_000_000_000,
        "WIF": 998_000_000,
        "BONK": 69_000_000_000_000,
        "APT": 500_000_000,
        "UNI": 600_000_000,
        "AAVE": 14_900_000,
        "FET": 2_500_000_000,
        "RENDER": 518_000_000,
        "TAO": 7_380_000,
        "TIA": 220_000_000,
        "ONDO": 1_430_000_000,
        "ARB": 3_600_000_000,
        "OP": 1_250_000_000,
        "FIL": 590_000_000,
        "INJ": 100_000_000,
        "SEI": 3_000_000_000,
        "FTM": 2_800_000_000,
        "HBAR": 37_000_000_000,
        "KAS": 24_000_000_000,
        "ALGO": 8_200_000_000,
        "ICP": 470_000_000,
        "LDO": 890_000_000,
        "PENDLE": 160_000_000,
        "GALA": 35_000_000_000,
        "SAND": 2_300_000_000,
        "AXS": 150_000_000,
        "MANA": 1_900_000_000,
        "JUP": 1_350_000_000,
        "RAY": 260_000_000,
        "CRV": 1_200_000_000,
        "MKR": 920_000,
        "FLOKI": 9_600_000_000_000,
        "POPCAT": 980_000_000,
        "NEIRO": 420_000_000_000,
        "MEW": 88_000_000_000
    ]
    
    public static func supply(for baseAsset: String) -> Double? {
        supplies[baseAsset.uppercased()]
    }
}

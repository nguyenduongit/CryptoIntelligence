import Foundation

public enum CoinTier: String, CaseIterable, Sendable, Codable, Identifiable {
    case core = "Core"
    case narrative = "Narrative"
    case moonshot = "Moonshot"
    case unassigned = "Chưa gán"
    
    public var id: String { rawValue }
}

public enum CoinStatus: String, CaseIterable, Sendable, Codable, Identifiable {
    case watching = "Theo dõi"
    case buyZone = "Vùng mua"
    case holding = "Đang nắm giữ"
    case ignored = "Loại bỏ"
    
    public var id: String { rawValue }
}

public struct WatchlistItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    
    public let symbol: String
    public let baseAsset: String
    public var tier: CoinTier
    public var status: CoinStatus
    public var sortOrder: Int
    public let addedAt: Date
    
    // Live ticker properties (not persisted directly in watchlist table, updated by stream)
    public var lastPrice: Double?
    public var priceChange24h: Double?
    public var volume24h: Double?
    
    public var customSector: CryptoSector?
    
    public var sector: CryptoSector {
        get {
            customSector ?? CryptoSector.categorize(baseAsset: baseAsset)
        }
        set {
            customSector = newValue
        }
    }
    
    public init(
        symbol: String,
        baseAsset: String,
        tier: CoinTier = .unassigned,
        status: CoinStatus = .watching,
        sortOrder: Int = 0,
        addedAt: Date = Date(),
        lastPrice: Double? = nil,
        priceChange24h: Double? = nil,
        volume24h: Double? = nil,
        customSector: CryptoSector? = nil
    ) {
        self.symbol = symbol.uppercased()
        self.baseAsset = baseAsset.uppercased()
        self.tier = tier
        self.status = status
        self.sortOrder = sortOrder
        self.addedAt = addedAt
        self.lastPrice = lastPrice
        self.priceChange24h = priceChange24h
        self.volume24h = volume24h
        self.customSector = customSector
    }
}

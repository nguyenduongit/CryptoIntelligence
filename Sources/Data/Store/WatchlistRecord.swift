import Foundation
import GRDB

public struct WatchlistRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "watchlist"
    
    public var symbol: String
    public var baseAsset: String
    public var tier: String
    public var status: String
    public var sortOrder: Int
    public var addedAt: Date
    
    public init(
        symbol: String,
        baseAsset: String,
        tier: String,
        status: String,
        sortOrder: Int,
        addedAt: Date
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.tier = tier
        self.status = status
        self.sortOrder = sortOrder
        self.addedAt = addedAt
    }
    
    public init(item: WatchlistItem) {
        self.symbol = item.symbol
        self.baseAsset = item.baseAsset
        self.tier = item.tier.rawValue
        self.status = item.status.rawValue
        self.sortOrder = item.sortOrder
        self.addedAt = item.addedAt
    }
    
    public func toModel() -> WatchlistItem {
        WatchlistItem(
            symbol: symbol,
            baseAsset: baseAsset,
            tier: CoinTier(rawValue: tier) ?? .unassigned,
            status: CoinStatus(rawValue: status) ?? .watching,
            sortOrder: sortOrder,
            addedAt: addedAt
        )
    }
}

import SwiftUI
import Observation
import GRDB

@Observable
public final class WatchlistViewModel: @unchecked Sendable {
    public var items: [WatchlistItem] = []
    public var selectedTierFilter: CoinTier? = nil
    public var selectedStatusFilter: CoinStatus? = nil
    public var searchText: String = ""
    
    public var availableSymbols: [SymbolInfo] = []
    public var searchResults: [SymbolInfo] = []
    public var isSearching: Bool = false
    public var isLoading: Bool = false
    
    private let dbManager: DatabaseManager
    private let candleProvider: BinanceCandleProvider
    
    public init(
        dbManager: DatabaseManager = .shared,
        candleProvider: BinanceCandleProvider = .shared
    ) {
        self.dbManager = dbManager
        self.candleProvider = candleProvider
        loadWatchlist()
    }
    
    public var filteredItems: [WatchlistItem] {
        items.filter { item in
            let matchesSearch = searchText.isEmpty ||
                item.symbol.localizedCaseInsensitiveContains(searchText) ||
                item.baseAsset.localizedCaseInsensitiveContains(searchText)
            
            let matchesTier = selectedTierFilter == nil || item.tier == selectedTierFilter
            let matchesStatus = selectedStatusFilter == nil || item.status == selectedStatusFilter
            
            return matchesSearch && matchesTier && matchesStatus
        }.sorted { $0.sortOrder < $1.sortOrder }
    }
    
    public func loadWatchlist() {
        do {
            let records = try dbManager.dbQueue.read { db in
                try WatchlistRecord.order(Column("sortOrder").asc).fetchAll(db)
            }
            
            if records.isEmpty {
                // Seed initial default items if empty
                let defaultSymbols = [
                    ("BTCUSDT", "BTC", CoinTier.core, CoinStatus.holding),
                    ("ETHUSDT", "ETH", CoinTier.core, CoinStatus.holding),
                    ("SOLUSDT", "SOL", CoinTier.narrative, CoinStatus.buyZone),
                    ("BNBUSDT", "BNB", CoinTier.core, CoinStatus.watching),
                    ("DOGEUSDT", "DOGE", CoinTier.moonshot, CoinStatus.watching)
                ]
                
                var seedItems = [WatchlistItem]()
                for (index, item) in defaultSymbols.enumerated() {
                    let wItem = WatchlistItem(
                        symbol: item.0,
                        baseAsset: item.1,
                        tier: item.2,
                        status: item.3,
                        sortOrder: index,
                        addedAt: Date()
                    )
                    seedItems.append(wItem)
                }
                
                try dbManager.dbQueue.write { db in
                    for item in seedItems {
                        let rec = WatchlistRecord(item: item)
                        try rec.insert(db)
                    }
                }
                self.items = seedItems
            } else {
                self.items = records.map { $0.toModel() }
            }
        } catch {
            print("Failed to load watchlist: \(error)")
        }
    }
    
    public func fetchAvailableSymbols() async {
        guard availableSymbols.isEmpty else { return }
        do {
            let symbols = try await candleProvider.fetchExchangeInfo()
            await MainActor.run {
                self.availableSymbols = symbols
            }
        } catch {
            print("Failed to fetch exchange info: \(error)")
        }
    }
    
    public func updateSearchQuery(_ query: String) {
        self.searchText = query
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            self.searchResults = []
            return
        }
        let q = query.uppercased().trimmingCharacters(in: .whitespaces)
        self.searchResults = Array(availableSymbols.filter {
            $0.symbol.contains(q) || $0.baseAsset.contains(q)
        }.prefix(20))
    }
    
    public func isInWatchlist(symbol: String) -> Bool {
        let clean = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        return items.contains(where: { $0.symbol.uppercased() == clean })
    }
    
    public func toggleWatchlist(symbol: String, baseAsset: String? = nil) {
        let clean = symbol.uppercased().trimmingCharacters(in: .whitespaces)
        if isInWatchlist(symbol: clean) {
            removeItem(symbol: clean)
        } else {
            let base = baseAsset ?? clean.replacingOccurrences(of: "USDT", with: "")
                                         .replacingOccurrences(of: "BUSD", with: "")
                                         .replacingOccurrences(of: "USDC", with: "")
            addItem(symbol: clean, baseAsset: base, tier: .narrative, status: .watching)
        }
    }
    
    public func addItem(symbol: String, baseAsset: String, tier: CoinTier = .unassigned, status: CoinStatus = .watching) {
        let cleanSymbol = symbol.uppercased()
        guard !items.contains(where: { $0.symbol == cleanSymbol }) else { return }
        
        let nextOrder = (items.map { $0.sortOrder }.max() ?? -1) + 1
        let newItem = WatchlistItem(
            symbol: cleanSymbol,
            baseAsset: baseAsset.uppercased(),
            tier: tier,
            status: status,
            sortOrder: nextOrder,
            addedAt: Date()
        )
        
        items.append(newItem)
        
        do {
            try dbManager.dbQueue.write { db in
                let rec = WatchlistRecord(item: newItem)
                try rec.insert(db)
            }
        } catch {
            print("Failed to insert watchlist item: \(error)")
        }
        
        // Update live subscription
        Task {
            let symbols = items.map { $0.symbol }
            await BinanceWebSocketManager.shared.updateWatchlistSubscriptions(symbols: symbols)
        }
    }
    
    public func removeItem(symbol: String) {
        items.removeAll { $0.symbol == symbol }
        
        do {
            try dbManager.dbQueue.write { db in
                _ = try WatchlistRecord.filter(Column("symbol") == symbol).deleteAll(db)
            }
        } catch {
            print("Failed to delete watchlist item: \(error)")
        }
        
        Task {
            let symbols = items.map { $0.symbol }
            await BinanceWebSocketManager.shared.updateWatchlistSubscriptions(symbols: symbols)
        }
    }
    
    public func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
        for i in 0..<items.count {
            items[i].sortOrder = i
        }
        
        do {
            try dbManager.dbQueue.write { db in
                for item in self.items {
                    let rec = WatchlistRecord(item: item)
                    try rec.update(db)
                }
            }
        } catch {
            print("Failed to save reordered watchlist: \(error)")
        }
    }
    
    public func updateItemTier(symbol: String, tier: CoinTier) {
        guard let idx = items.firstIndex(where: { $0.symbol == symbol }) else { return }
        items[idx].tier = tier
        
        do {
            try dbManager.dbQueue.write { db in
                let rec = WatchlistRecord(item: self.items[idx])
                try rec.update(db)
            }
        } catch {
            print("Failed to update tier: \(error)")
        }
    }
    
    public func updateItemStatus(symbol: String, status: CoinStatus) {
        guard let idx = items.firstIndex(where: { $0.symbol == symbol }) else { return }
        items[idx].status = status
        
        do {
            try dbManager.dbQueue.write { db in
                let rec = WatchlistRecord(item: self.items[idx])
                try rec.update(db)
            }
        } catch {
            print("Failed to update status: \(error)")
        }
    }
    
    public func updateTicker(symbol: String, price: Double, changePercent: Double, volume: Double) {
        guard let idx = items.firstIndex(where: { $0.symbol == symbol }) else { return }
        items[idx].lastPrice = price
        items[idx].priceChange24h = changePercent
        items[idx].volume24h = volume
    }
}

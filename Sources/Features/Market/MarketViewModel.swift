import SwiftUI
import Observation

public enum MarketViewMode: String, CaseIterable, Identifiable {
    case screener = "Bộ lọc & Radar tín hiệu"
    case heatmap = "Bản đồ nhiệt"
    case movers = "Bảng xếp hạng"
    case sectors = "Dòng vốn phân khúc"
    case macro = "Kinh tế Vĩ mô"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .screener: return "radar"
        case .heatmap: return "square.grid.3x3.fill"
        case .movers: return "list.number"
        case .sectors: return "chart.pie.fill"
        case .macro: return "globe.americas.fill"
        }
    }
}

public enum MarketSortOption: String, CaseIterable, Identifiable {
    case volume24h = "Khối lượng 24h"
    case changeDesc = "Tăng mạnh nhất"
    case changeAsc = "Giảm mạnh nhất"
    case price = "Mức giá"
    
    public var id: String { rawValue }
}

@Observable
public final class MarketViewModel: @unchecked Sendable {
    public var selectedViewMode: MarketViewMode = .heatmap
    public var selectedSector: CryptoSector = .all
    public var searchQuery: String = ""
    public var sortBy: MarketSortOption = .volume24h
    
    public var tickers: [MarketTicker24h] = []
    public var globalMetrics: MarketGlobalMetrics? = nil
    public var sectorPerformances: [SectorPerformance] = []
    public var derivativesMetrics: DerivativesMetrics? = nil
    
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var lastRefreshedAt: Date? = nil
    
    private let provider: MarketDataProvider
    private var refreshTask: Task<Void, Never>?
    
    public init(provider: MarketDataProvider = .shared) {
        self.provider = provider
    }
    
    public var filteredTickers: [MarketTicker24h] {
        var list = tickers
        
        // Filter by Sector
        if selectedSector != .all {
            list = list.filter { $0.sector == selectedSector }
        }
        
        // Filter by Search
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            let query = searchQuery.trimmingCharacters(in: .whitespaces).uppercased()
            list = list.filter {
                $0.symbol.uppercased().contains(query) || $0.baseAsset.uppercased().contains(query)
            }
        }
        
        // Sort
        switch sortBy {
        case .volume24h:
            list.sort { $0.quoteVolume > $1.quoteVolume }
        case .changeDesc:
            list.sort { $0.priceChangePercent > $1.priceChangePercent }
        case .changeAsc:
            list.sort { $0.priceChangePercent < $1.priceChangePercent }
        case .price:
            list.sort { $0.price > $1.price }
        }
        
        return list
    }
    
    public var topGainers: [MarketTicker24h] {
        tickers
            .filter { $0.quoteVolume > 100_000 }
            .sorted { $0.priceChangePercent > $1.priceChangePercent }
            .prefix(15)
            .map { $0 }
    }
    
    public var topLosers: [MarketTicker24h] {
        tickers
            .filter { $0.quoteVolume > 100_000 }
            .sorted { $0.priceChangePercent < $1.priceChangePercent }
            .prefix(15)
            .map { $0 }
    }
    
    public var topVolumes: [MarketTicker24h] {
        tickers
            .sorted { $0.quoteVolume > $1.quoteVolume }
            .prefix(15)
            .map { $0 }
    }
    
    public func loadData() {
        refreshTask?.cancel()
        refreshTask = Task { @MainActor in
            self.isLoading = true
            self.errorMessage = nil
            
            do {
                let (fetchedTickers, metrics, sectors) = try await provider.fetchMarketOverview()
                let deriv = await provider.fetchDerivativesMetrics(for: "BTCUSDT")
                self.tickers = fetchedTickers
                self.globalMetrics = metrics
                self.sectorPerformances = sectors
                self.derivativesMetrics = deriv
                self.lastRefreshedAt = Date()
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = "Không thể tải dữ liệu thị trường: \(error.localizedDescription)"
            }
        }
    }
    
    public func updateTicker(symbol: String, price: Double, changePercent: Double, volume: Double) {
        Task { @MainActor in
            if let index = self.tickers.firstIndex(where: { $0.symbol.uppercased() == symbol.uppercased() }) {
                self.tickers[index].price = price
                self.tickers[index].priceChangePercent = changePercent
            }
        }
    }
}

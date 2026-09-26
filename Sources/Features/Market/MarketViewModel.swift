import SwiftUI
import Observation

public enum MarketViewMode: String, CaseIterable, Identifiable, Sendable {
    case valuation = "Vốn hóa"
    case globalMacro = "Kinh tế"
    case heatmap = "Bản đồ & Ngành"
    case movers = "Biến động"
    case screener = "Bộ lọc"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .valuation: return "chart.pie.fill"
        case .globalMacro: return "globe.americas.fill"
        case .heatmap: return "square.grid.3x3.fill"
        case .movers: return "flame.fill"
        case .screener: return "line.3.horizontal.decrease.circle.fill"
        }
    }
}

public enum MarketHeatmapSection: String, CaseIterable, Identifiable, Sendable {
    case heatmap = "Bản Đồ Nhiệt (Heatmap)"
    case sectorFlow = "Dòng Tiền Phân Khúc (Sector Flow)"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .heatmap: return "square.grid.3x3.fill"
        case .sectorFlow: return "square.stack.3d.up.fill"
        }
    }
}

public enum MarketValuationSection: String, CaseIterable, Identifiable, Sendable {
    case overview = "Tổng quan"
    case kline = "Biểu đồ"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .kline: return "chart.line.uptrend.xyaxis"
        }
    }
}

public enum GlobalMacroSection: String, CaseIterable, Identifiable, Sendable {
    case all = "Toàn Cảnh Vĩ Mô"
    case centralBanks = "Ngân Hàng Trung Ương & Lãi Suất"
    case inflation = "Lạm Phát & Việc Làm"
    case intermarket = "Tương Quan Liên Thị Trường"
    case liquidityM2 = "Cung Tiền M2 & Thanh Khoản"
    case calendar = "Lịch Sự Kiện Kinh Tế"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .all: return "globe.americas.fill"
        case .centralBanks: return "building.columns.fill"
        case .inflation: return "gauge.with.dots.needle.50percent"
        case .intermarket: return "arrow.triangle.swap"
        case .liquidityM2: return "waveform.path.ecg"
        case .calendar: return "calendar"
        }
    }
}

public enum MoversCategorySelection: String, CaseIterable, Identifiable, Sendable {
    case all = "Tất Cả Bảng Xếp Hạng"
    case gainers = "Top 15 Tăng Giá (+%)"
    case losers = "Top 15 Giảm Giá (-%)"
    case volume = "Top 15 Khối Lượng (Vol)"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .all: return "list.bullet.rectangle.fill"
        case .gainers: return "arrow.up.right.circle.fill"
        case .losers: return "arrow.down.right.circle.fill"
        case .volume: return "chart.bar.fill"
        }
    }
}

public enum ScreenerPresetSelection: String, CaseIterable, Identifiable, Sendable {
    case all = "Tất Cả Tín Hiệu"
    case breakout = "Bứt Phá Đỉnh Giá"
    case oversold = "Quá Bán Sâu (RSI < 30)"
    case whale = "Gom Hàng Cá Voi / Vol Spike"
    case goldenCross = "Giao Cắt Vàng (MA Cross)"
    case largeCap = "Top 50 Vốn Hóa Lớn"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .all: return "line.3.horizontal.decrease.circle.fill"
        case .breakout: return "arrow.up.forward.app.fill"
        case .oversold: return "arrow.down.to.line.compact"
        case .whale: return "flame.fill"
        case .goldenCross: return "arrow.triangle.swap"
        case .largeCap: return "crown.fill"
        }
    }
}

public enum MarketHeatmapDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case bubbles = "Bong Bóng"
    case grid = "Lưới Ô"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .bubbles: return "circle.hexagongrid.fill"
        case .grid: return "square.grid.3x3.fill"
        }
    }
}

public enum BubbleSizingMetric: String, CaseIterable, Identifiable, Sendable {
    case marketCap = "Vốn Hóa"
    case volume24h = "Volume 24h"
    case priceChange = "% Biến Động"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .marketCap: return "chart.pie.fill"
        case .volume24h: return "flame.fill"
        case .priceChange: return "percent"
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
    public var selectedViewMode: MarketViewMode = .valuation
    public var selectedSector: CryptoSector = .all
    public var searchQuery: String = ""
    public var sortBy: MarketSortOption = .volume24h
    
    // Dedicated Navigation States
    public var selectedValuationSection: MarketValuationSection = .overview
    public var selectedMacroIndex: MacroIndexType = .total
    public var selectedKLineTimeframe: String = "1D"
    public var selectedGlobalMacroSection: GlobalMacroSection = .all
    public var selectedHeatmapSection: MarketHeatmapSection = .heatmap
    public var selectedMoversCategory: MoversCategorySelection = .all
    public var selectedScreenerPreset: ScreenerPresetSelection = .all
    
    // Heatmap & Bubbles Configuration
    public var heatmapDisplayMode: MarketHeatmapDisplayMode = .bubbles
    public var bubbleSizingMetric: BubbleSizingMetric = .marketCap
    public var bubbleCountLimit: Int = 100 // 50, 100, 150, 0 (all)
    public var isHeatmapSizingByVolume: Bool = false
    
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
    
    public var filteredHeatmapTickers: [MarketTicker24h] {
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
        
        // Dynamic sorting based on Sizing Mode: Volume 24h vs Market Cap
        if isHeatmapSizingByVolume {
            list.sort { $0.quoteVolume > $1.quoteVolume }
        } else {
            list.sort { $0.estimatedMarketCap > $1.estimatedMarketCap }
        }
        
        return list
    }
    
    public var filteredBubbleTickers: [MarketTicker24h] {
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
        
        // Sort according to bubbleSizingMetric
        switch bubbleSizingMetric {
        case .marketCap:
            list.sort { $0.estimatedMarketCap > $1.estimatedMarketCap }
        case .volume24h:
            list.sort { $0.quoteVolume > $1.quoteVolume }
        case .priceChange:
            list.sort { abs($0.priceChangePercent) > abs($1.priceChangePercent) }
        }
        
        if bubbleCountLimit > 0 && list.count > bubbleCountLimit {
            list = Array(list.prefix(bubbleCountLimit))
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

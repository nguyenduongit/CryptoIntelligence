import SwiftUI
import Observation

// MARK: - Market View Mode (Full Market Tab)
public enum MarketViewMode: String, CaseIterable, Identifiable, Sendable {
    case all = "Tất Cả Thị Trường"
    case topGainers = "Top Tăng Giá"
    case topLosers = "Top Giảm Giá"
    case topVolume = "Top Khối Lượng"
    case topCap = "Top Vốn Hóa"
    case highVolatility = "Biến Động Cao"
    case newListings = "Mới Niêm Yết"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .all:            return "list.bullet.rectangle.fill"
        case .topGainers:     return "arrow.up.right.circle.fill"
        case .topLosers:      return "arrow.down.right.circle.fill"
        case .topVolume:      return "chart.bar.fill"
        case .topCap:         return "crown.fill"
        case .highVolatility: return "waveform"
        case .newListings:    return "sparkles"
        }
    }
}

// MARK: - Market Table Sort
public enum MarketTableSortColumn: String, Sendable {
    case rank, symbol, price, change24h, volume, cap
}

public enum MarketSortDirection: Sendable {
    case ascending, descending
    
    var toggled: MarketSortDirection {
        self == .ascending ? .descending : .ascending
    }
}

// MARK: - Sidebar Macro Section (Kinh Tế Vĩ Mô)
public enum GlobalMacroSection: String, CaseIterable, Identifiable, Sendable {
    case all = "Toàn Cảnh Vĩ Mô"
    case valuation = "Vốn Hóa Thị Trường"
    case centralBanks = "Ngân Hàng Trung Ương & Lãi Suất"
    case inflation = "Lạm Phát & Việc Làm"
    case intermarket = "Tương Quan Liên Thị Trường"
    case liquidityM2 = "Cung Tiền M2 & Thanh Khoản"
    case calendar = "Lịch Sự Kiện Kinh Tế"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .all:           return "globe.americas.fill"
        case .valuation:     return "chart.pie.fill"
        case .centralBanks:  return "building.columns.fill"
        case .inflation:     return "gauge.with.dots.needle.50percent"
        case .intermarket:   return "arrow.triangle.swap"
        case .liquidityM2:   return "waveform.path.ecg"
        case .calendar:      return "calendar"
        }
    }
}

// MARK: - Screener preset
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
        case .all:          return "line.3.horizontal.decrease.circle.fill"
        case .breakout:     return "arrow.up.forward.app.fill"
        case .oversold:     return "arrow.down.to.line.compact"
        case .whale:        return "flame.fill"
        case .goldenCross:  return "arrow.triangle.swap"
        case .largeCap:     return "crown.fill"
        }
    }
}

// MARK: - Market Sort Option (legacy — still used by filteredTickers)
public enum MarketSortOption: String, CaseIterable, Identifiable {
    case volume24h = "Khối lượng 24h"
    case changeDesc = "Tăng mạnh nhất"
    case changeAsc = "Giảm mạnh nhất"
    case price = "Mức giá"

    public var id: String { rawValue }
}

// MARK: - MarketViewModel
@Observable
public final class MarketViewModel: @unchecked Sendable {
    // MARK: Legacy navigation (macro / screener)
    public var selectedValuationSection: MarketValuationSection = .overview
    public var selectedMacroIndex: MacroIndexType = .total
    public var selectedKLineTimeframe: String = "1D"
    public var selectedGlobalMacroSection: GlobalMacroSection = .all
    public var selectedScreenerPreset: ScreenerPresetSelection = .all

    // MARK: Market Tab State
    public var selectedMarketViewMode: MarketViewMode = .all
    public var selectedSector: CryptoSector = .all
    public var searchQuery: String = ""
    public var sortBy: MarketSortOption = .volume24h
    
    // MARK: Table Sort
    public var tableSortColumn: MarketTableSortColumn = .volume
    public var tableSortDirection: MarketSortDirection = .descending

    // MARK: Data
    public var tickers: [MarketTicker24h] = []
    public var globalMetrics: MarketGlobalMetrics? = nil
    public var sectorPerformances: [SectorPerformance] = []
    public var derivativesMetrics: DerivativesMetrics? = nil

    // MARK: Loading State
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    public var lastRefreshedAt: Date? = nil
    public var autoRefreshCountdown: Int = 30

    private let provider: MarketDataProvider
    private var refreshTask: Task<Void, Never>?
    private var autoRefreshTask: Task<Void, Never>?

    public init(provider: MarketDataProvider = .shared) {
        self.provider = provider
    }

    // MARK: - Computed: All rows for the Market Table (filtered + sorted)
    public var marketTableRows: [MarketTicker24h] {
        var list: [MarketTicker24h]

        switch selectedMarketViewMode {
        case .all:
            list = tickers
        case .topGainers:
            list = tickers.filter { $0.quoteVolume > 100_000 }
                .sorted { $0.priceChangePercent > $1.priceChangePercent }
        case .topLosers:
            list = tickers.filter { $0.quoteVolume > 100_000 }
                .sorted { $0.priceChangePercent < $1.priceChangePercent }
        case .topVolume:
            list = tickers.sorted { $0.quoteVolume > $1.quoteVolume }
        case .topCap:
            list = tickers.sorted { $0.estimatedMarketCap > $1.estimatedMarketCap }
        case .highVolatility:
            list = tickers.filter { $0.quoteVolume > 100_000 }
                .sorted { abs($0.priceChangePercent) > abs($1.priceChangePercent) }
        case .newListings:
            let sevenDaysAgoMs = Int64((Date().timeIntervalSince1970 - 7 * 86400) * 1000)
            list = tickers
                .filter { $0.closeTime > sevenDaysAgoMs }
                .sorted { $0.closeTime > $1.closeTime }
        }

        // Apply sector filter
        if selectedSector != .all {
            list = list.filter { $0.sector == selectedSector }
        }

        // Apply search
        let query = searchQuery.trimmingCharacters(in: .whitespaces).uppercased()
        if !query.isEmpty {
            list = list.filter {
                $0.symbol.uppercased().contains(query) || $0.baseAsset.uppercased().contains(query)
            }
        }

        // Apply table sort (only for .all mode — other modes already sorted by definition)
        if selectedMarketViewMode == .all {
            switch tableSortColumn {
            case .rank, .volume:
                list.sort { tableSortDirection == .descending ? $0.quoteVolume > $1.quoteVolume : $0.quoteVolume < $1.quoteVolume }
            case .symbol:
                list.sort { tableSortDirection == .descending ? $0.baseAsset > $1.baseAsset : $0.baseAsset < $1.baseAsset }
            case .price:
                list.sort { tableSortDirection == .descending ? $0.price > $1.price : $0.price < $1.price }
            case .change24h:
                list.sort { tableSortDirection == .descending ? $0.priceChangePercent > $1.priceChangePercent : $0.priceChangePercent < $1.priceChangePercent }
            case .cap:
                list.sort { tableSortDirection == .descending ? $0.estimatedMarketCap > $1.estimatedMarketCap : $0.estimatedMarketCap < $1.estimatedMarketCap }
            }
        }

        return list
    }

    // MARK: - Market Stats
    public var totalGainerCount: Int { tickers.filter { $0.priceChangePercent >= 0 }.count }
    public var totalLoserCount: Int { tickers.filter { $0.priceChangePercent < 0 }.count }
    public var totalQuoteVolume: Double { tickers.reduce(0) { $0 + $1.quoteVolume } }
    
    public var sectorStats: [(sector: CryptoSector, count: Int)] {
        CryptoSector.allCases.compactMap { sector in
            if sector == .all { return nil }
            let count = tickers.filter { $0.sector == sector }.count
            return count > 0 ? (sector: sector, count: count) : nil
        }.sorted { $0.count > $1.count }
    }

    // MARK: - Legacy computed (for backward compat with macro/screener)
    public var filteredTickers: [MarketTicker24h] {
        var list = tickers
        if selectedSector != .all {
            list = list.filter { $0.sector == selectedSector }
        }
        let query = searchQuery.trimmingCharacters(in: .whitespaces).uppercased()
        if !query.isEmpty {
            list = list.filter {
                $0.symbol.uppercased().contains(query) || $0.baseAsset.uppercased().contains(query)
            }
        }
        switch sortBy {
        case .volume24h:   list.sort { $0.quoteVolume > $1.quoteVolume }
        case .changeDesc:  list.sort { $0.priceChangePercent > $1.priceChangePercent }
        case .changeAsc:   list.sort { $0.priceChangePercent < $1.priceChangePercent }
        case .price:       list.sort { $0.price > $1.price }
        }
        return list
    }

    public var topGainers: [MarketTicker24h] {
        tickers.filter { $0.quoteVolume > 100_000 }
            .sorted { $0.priceChangePercent > $1.priceChangePercent }
            .prefix(15).map { $0 }
    }

    public var topLosers: [MarketTicker24h] {
        tickers.filter { $0.quoteVolume > 100_000 }
            .sorted { $0.priceChangePercent < $1.priceChangePercent }
            .prefix(15).map { $0 }
    }

    public var topVolumes: [MarketTicker24h] {
        tickers.sorted { $0.quoteVolume > $1.quoteVolume }
            .prefix(15).map { $0 }
    }

    // MARK: - Sort toggle helper
    public func toggleSort(column: MarketTableSortColumn) {
        if tableSortColumn == column {
            tableSortDirection = tableSortDirection.toggled
        } else {
            tableSortColumn = column
            tableSortDirection = .descending
        }
    }

    // MARK: - Data Loading
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

    // MARK: - Auto-refresh every 30s
    public func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                self.autoRefreshCountdown = 30
                for remaining in stride(from: 30, through: 1, by: -1) {
                    if Task.isCancelled { return }
                    self.autoRefreshCountdown = remaining
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                }
                if !Task.isCancelled {
                    self.loadData()
                }
            }
        }
    }

    public func stopAutoRefresh() {
        autoRefreshTask?.cancel()
        autoRefreshTask = nil
        autoRefreshCountdown = 30
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

// MARK: - MarketValuationSection (still used by Macro tab)
public enum MarketValuationSection: String, CaseIterable, Identifiable, Sendable {
    case overview = "Tổng quan"
    case kline = "Biểu đồ"

    public var id: String { rawValue }

    public var iconName: String {
        switch self {
        case .overview: return "chart.pie.fill"
        case .kline:    return "chart.line.uptrend.xyaxis"
        }
    }
}

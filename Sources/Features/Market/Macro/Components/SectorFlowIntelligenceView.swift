import SwiftUI

/// A dedicated, spacious, and comprehensive intelligence dashboard for
/// Capital Allocation & Money Flow across all crypto sectors.
public struct SectorFlowIntelligenceView: View {
    @Bindable var viewModel: MarketViewModel
    public var onSelectSymbol: ((String) -> Void)? = nil
    
    @State private var tokenSearchQuery: String = ""
    @State private var tokenFilterMode: TokenFilterMode = .all
    @State private var sortColumn: SectorTokenSortColumn = .volume
    @State private var sortAscending: Bool = false
    
    public init(viewModel: MarketViewModel, onSelectSymbol: ((String) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSelectSymbol = onSelectSymbol
    }
    
    private var totalMarketVolume: Double {
        viewModel.sectorPerformances.reduce(0.0) { $0 + $1.totalQuoteVolume }
    }
    
    private var leadingSector: SectorPerformance? {
        viewModel.sectorPerformances.max { $0.totalQuoteVolume < $1.totalQuoteVolume }
    }
    
    private var topGainerSector: SectorPerformance? {
        viewModel.sectorPerformances.max { $0.avgChangePercent < $1.avgChangePercent }
    }
    
    private var totalGainers: Int {
        viewModel.sectorPerformances.reduce(0) { $0 + $1.gainersCount }
    }
    
    private var totalLosers: Int {
        viewModel.sectorPerformances.reduce(0) { $0 + $1.losersCount }
    }
    
    private var totalTokensCount: Int {
        viewModel.sectorPerformances.reduce(0) { $0 + $1.tokenCount }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // ── 1. KPI Metric Overview Cards ──────────────────────────────────
            kpiSummaryCards
            
            // ── 2. Interactive Segmented Capital Allocation Treemap Bar ──────
            if totalMarketVolume > 0 {
                segmentedAllocationSection
            }
            
            // ── 3. Spacious Sector Cards Grid (3 Columns) ─────────────────────
            sectorCardsGrid
            
            // ── 4. Deep Dive Token Explorer for Selected Sector ───────────────
            sectorTokenExplorerSection
            
            // ── 5. Comparative Sector Rotation & Flow Matrix ──────────────────
            sectorRotationMatrixSection
        }
    }
    
    // MARK: - 1. KPI Summary Cards
    
    private var kpiSummaryCards: some View {
        HStack(spacing: 12) {
            // Card 1: Total Volume Flow
            kpiCard(
                title: "TỔNG DÒNG TIỀN 24H",
                value: Formatters.formatVolume(totalMarketVolume) + " USDT",
                subtitle: "\(viewModel.sectorPerformances.count) phân khúc • \(totalTokensCount) tài sản",
                icon: "chart.pie.fill",
                accentColor: AppTheme.cyan
            )
            
            // Card 2: Dominant Sector
            if let lead = leadingSector {
                let share = totalMarketVolume > 0 ? (lead.totalQuoteVolume / totalMarketVolume * 100) : 0
                kpiCard(
                    title: "DẪN ĐẦU VỀ THANH KHOẢN",
                    value: lead.sector.rawValue,
                    subtitle: "\(Formatters.formatVolume(lead.totalQuoteVolume)) USDT (\(String(format: "%.1f%%", share)))",
                    icon: lead.sector.iconName,
                    accentColor: lead.sector.color
                )
            }
            
            // Card 3: Top Performing Sector
            if let topG = topGainerSector {
                let sign = topG.avgChangePercent >= 0 ? "+" : ""
                kpiCard(
                    title: "TĂNG TRƯỞNG MẠNH NHẤT",
                    value: topG.sector.rawValue,
                    subtitle: "\(sign)\(String(format: "%.2f%%", topG.avgChangePercent)) • \(topG.gainersCount)▲ \(topG.losersCount)▼",
                    icon: "arrow.up.right.circle.fill",
                    accentColor: AppTheme.upGreen
                )
            }
            
            // Card 4: Market Breadth across Sectors
            let bullishRatio = totalTokensCount > 0 ? (Double(totalGainers) / Double(max(1, totalTokensCount)) * 100) : 50
            kpiCard(
                title: "ĐỘ RỘNG DÒNG TIỀN",
                value: "\(totalGainers)▲ / \(totalLosers)▼",
                subtitle: String(format: "%.1f%% danh mục đang trong sắc xanh", bullishRatio),
                icon: "waveform.path.ecg",
                accentColor: bullishRatio >= 50 ? AppTheme.upGreen : AppTheme.downRed
            )
        }
    }
    
    private func kpiCard(title: String, value: String, subtitle: String, icon: String, accentColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(accentColor)
                Text(title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            
            Text(subtitle)
                .font(.system(size: 10.5))
                .foregroundColor(.white.opacity(0.65))
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    // MARK: - 2. Segmented Capital Allocation Section
    
    private var segmentedAllocationSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("TỶ TRỌNG THANH KHOẢN THEO PHÂN KHÚC (VOLUME SHARE)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if viewModel.selectedSector != .all {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedSector = .all
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Xem tất cả phân khúc")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.accentBlue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(AppTheme.accentBlue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .contentShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Visual Bar
            GeometryReader { geo in
                let spacingTotal = CGFloat(max(0, viewModel.sectorPerformances.count - 1)) * 2.0
                let totalW = max(0, geo.size.width - spacingTotal)
                HStack(spacing: 2.0) {
                    ForEach(viewModel.sectorPerformances) { item in
                        let share = totalMarketVolume > 0 ? (item.totalQuoteVolume / totalMarketVolume) : 0
                        let segW = max(5.0, totalW * CGFloat(share))
                        let isSelected = viewModel.selectedSector == item.sector
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedSector = (viewModel.selectedSector == item.sector ? .all : item.sector)
                            }
                        }) {
                            Rectangle()
                                .fill(item.sector.color)
                                .frame(width: segW, height: 14)
                                .overlay(
                                    Rectangle()
                                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        .buttonStyle(.plain)
                        .help("\(item.sector.rawValue): \(Formatters.formatVolume(item.totalQuoteVolume)) USDT (\(String(format: "%.1f%%", share * 100)))")
                    }
                }
            }
            .frame(height: 14)
            
            // Legend Chips Multi-Row Responsive Grid (No horizontal scrolling)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 155), spacing: 8)], spacing: 8) {
                // All Pill
                legendFilterPill(
                    title: "Tất Cả",
                    icon: "square.grid.2x2.fill",
                    color: AppTheme.accentBlue,
                    sharePercent: 100.0,
                    volume: totalMarketVolume,
                    isSelected: viewModel.selectedSector == .all
                ) {
                    viewModel.selectedSector = .all
                }
                
                // Each Sector Pill
                ForEach(viewModel.sectorPerformances) { item in
                    let share = totalMarketVolume > 0 ? (item.totalQuoteVolume / totalMarketVolume * 100) : 0
                    legendFilterPill(
                        title: item.sector.rawValue,
                        icon: item.sector.iconName,
                        color: item.sector.color,
                        sharePercent: share,
                        volume: item.totalQuoteVolume,
                        isSelected: viewModel.selectedSector == item.sector
                    ) {
                        viewModel.selectedSector = (viewModel.selectedSector == item.sector ? .all : item.sector)
                    }
                }
            }
            .padding(.top, 2)
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func legendFilterPill(
        title: String,
        icon: String,
        color: Color,
        sharePercent: Double,
        volume: Double,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                action()
            }
        }) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 7.5, height: 7.5)
                
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                    .lineLimit(1)
                
                Spacer(minLength: 4)
                
                Text(String(format: "%.1f%%", sharePercent))
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(isSelected ? color : .white.opacity(0.7))
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1.5)
                    .background(color.opacity(isSelected ? 0.25 : 0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 3.5))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity)
            .background(isSelected ? color.opacity(0.18) : AppTheme.darkHeaderBg.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? color.opacity(0.85) : AppTheme.darkBorder.opacity(0.6), lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 3. Spacious Sector Cards Grid
    
    private var sectorCardsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.cyan)
                    Text("BẢNG ĐIỀU KHIỂN CHI TIẾT CÁC PHÂN KHÚC (SECTOR CARDS)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Bấm vào thẻ phân khúc để lọc chi tiết token bên dưới")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.45))
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 290), spacing: 12)], spacing: 12) {
                ForEach(viewModel.sectorPerformances) { item in
                    spaciousSectorCard(item)
                }
            }
        }
    }
    
    private func spaciousSectorCard(_ item: SectorPerformance) -> some View {
        let isSelected = viewModel.selectedSector == item.sector
        let sharePercent = totalMarketVolume > 0 ? (item.totalQuoteVolume / totalMarketVolume * 100) : 0
        let isBullish = item.avgChangePercent >= 0
        let topCoins = topCoinsInSector(item.sector, limit: 3)
        
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                if viewModel.selectedSector == item.sector {
                    viewModel.selectedSector = .all
                } else {
                    viewModel.selectedSector = item.sector
                }
            }
        }) {
            VStack(alignment: .leading, spacing: 10) {
                // Header: Icon + Title + Share Badge
                HStack(spacing: 8) {
                    Circle()
                        .fill(item.sector.color.opacity(0.18))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: item.sector.iconName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(item.sector.color)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.sector.rawValue)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text("\(item.tokenCount) mã theo dõi")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.45))
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 3) {
                        Text(String(format: "%.1f%%", sharePercent))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(item.sector.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2.5)
                            .background(item.sector.color.opacity(0.18))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        if isSelected {
                            Text("Đang chọn")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(item.sector.color)
                        }
                    }
                }
                
                // Volume & 24h Average Return
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Khối Lượng 24h")
                            .font(.system(size: 9.5))
                            .foregroundColor(.white.opacity(0.45))
                        Text(Formatters.formatVolume(item.totalQuoteVolume) + " USDT")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("Biến Động TB 24h")
                            .font(.system(size: 9.5))
                            .foregroundColor(.white.opacity(0.45))
                        HStack(spacing: 3) {
                            Image(systemName: isBullish ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 9, weight: .bold))
                            Text(String(format: "%@%.2f%%", isBullish ? "+" : "", item.avgChangePercent))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    }
                }
                
                // Breadth Progress Bar (Gainers vs Losers)
                VStack(spacing: 3) {
                    let totalCount = max(1, item.tokenCount)
                    let gRatio = CGFloat(item.gainersCount) / CGFloat(totalCount)
                    
                    GeometryReader { geo in
                        HStack(spacing: 1.5) {
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(AppTheme.upGreen)
                                .frame(width: max(3, geo.size.width * gRatio))
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(AppTheme.downRed)
                        }
                    }
                    .frame(height: 4.5)
                    
                    HStack {
                        Text("\(item.gainersCount) Tăng ▲")
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen.opacity(0.9))
                        
                        Spacer()
                        
                        if let topG = item.topGainerSymbol, let topP = item.topGainerChangePercent {
                            let cleanSym = topG.replacingOccurrences(of: "USDT", with: "")
                            let sign = topP >= 0 ? "+" : ""
                            Text("Top: \(cleanSym) \(sign)\(String(format: "%.1f%%", topP))")
                                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(topP >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                        
                        Spacer()
                        
                        Text("\(item.losersCount) Giảm ▼")
                            .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                            .foregroundColor(AppTheme.downRed.opacity(0.9))
                    }
                }
                
                Divider()
                    .background(AppTheme.darkBorder.opacity(0.6))
                
                // Top 3 Tokens preview
                HStack(spacing: 4) {
                    ForEach(topCoins, id: \.symbol) { coin in
                        let isCoinUp = coin.priceChangePercent >= 0
                        HStack(spacing: 2) {
                            Text(coin.baseAsset)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                            Text(String(format: "%@%.1f%%", isCoinUp ? "+" : "", coin.priceChangePercent))
                                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(isCoinUp ? AppTheme.upGreen : AppTheme.downRed)
                        }
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2.5)
                        .background(AppTheme.darkHeaderBg.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        if coin.symbol != topCoins.last?.symbol {
                            Spacer(minLength: 2)
                        }
                    }
                }
            }
            .padding(12)
            .background(isSelected ? item.sector.color.opacity(0.12) : AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? item.sector.color : AppTheme.darkBorder, lineWidth: isSelected ? 1.8 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 4. Deep Dive Token Explorer Section
    
    private var filteredSectorCoins: [MarketTicker24h] {
        let baseList: [MarketTicker24h] = (viewModel.selectedSector == .all)
            ? viewModel.tickers
            : viewModel.tickers.filter { $0.sector == viewModel.selectedSector }
        
        let queryFiltered = tokenSearchQuery.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        let matchingSearch = queryFiltered.isEmpty
            ? baseList
            : baseList.filter {
                $0.symbol.contains(queryFiltered) || $0.baseAsset.contains(queryFiltered)
            }
        
        let modeFiltered: [MarketTicker24h]
        switch tokenFilterMode {
        case .all:
            modeFiltered = matchingSearch
        case .gainersOnly:
            modeFiltered = matchingSearch.filter { $0.priceChangePercent > 0 }
        case .losersOnly:
            modeFiltered = matchingSearch.filter { $0.priceChangePercent < 0 }
        }
        
        return modeFiltered.sorted { a, b in
            let asc = sortAscending
            switch sortColumn {
            case .symbol:
                return asc ? a.baseAsset < b.baseAsset : a.baseAsset > b.baseAsset
            case .price:
                return asc ? a.price < b.price : a.price > b.price
            case .change24h:
                return asc ? a.priceChangePercent < b.priceChangePercent : a.priceChangePercent > b.priceChangePercent
            case .volume:
                return asc ? a.quoteVolume < b.quoteVolume : a.quoteVolume > b.quoteVolume
            case .marketCap:
                return asc ? a.estimatedMarketCap < b.estimatedMarketCap : a.estimatedMarketCap > b.estimatedMarketCap
            }
        }
    }
    
    private var sectorTokenExplorerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Title + Description + Search + Filter
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: viewModel.selectedSector.iconName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(viewModel.selectedSector == .all ? AppTheme.accentBlue : viewModel.selectedSector.color)
                    
                    Text("DANH MỤC TÀI SẢN CHI TIẾT: \(viewModel.selectedSector.rawValue.uppercased()) (\(filteredSectorCoins.count) mã)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Search box
                    HStack(spacing: 4) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                        TextField("Lọc mã trong phân khúc...", text: $tokenSearchQuery)
                            .font(.system(size: 11))
                            .textFieldStyle(.plain)
                            .frame(width: 140)
                        if !tokenSearchQuery.isEmpty {
                            Button(action: { tokenSearchQuery = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.darkSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
                    
                    // Filter Mode
                    Picker("", selection: $tokenFilterMode) {
                        Text("Tất cả").tag(TokenFilterMode.all)
                        Text("Chỉ mã Tăng").tag(TokenFilterMode.gainersOnly)
                        Text("Chỉ mã Giảm").tag(TokenFilterMode.losersOnly)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 210)
                }
                
                Text(sectorDescription(viewModel.selectedSector))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.55))
            }
            .padding(.horizontal, 14)
            .padding(.top, 12)
            
            // Coins Table
            VStack(spacing: 0) {
                // Table Column Header
                tableHeaderRow
                
                // Table Rows
                if filteredSectorCoins.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 24))
                            .foregroundColor(.white.opacity(0.3))
                        Text("Không có tài sản nào phù hợp với bộ lọc tìm kiếm")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 36)
                } else {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filteredSectorCoins.enumerated()), id: \.element.symbol) { idx, ticker in
                            tokenTableRow(rank: idx + 1, ticker: ticker)
                        }
                    }
                }
            }
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        }
    }
    
    private var tableHeaderRow: some View {
        HStack(spacing: 0) {
            Text("#")
                .frame(width: 36, alignment: .center)
            
            tableHeaderSortButton(title: "Tên / Phân Khúc", column: .symbol, width: 140, alignment: .leading)
            
            Spacer()
            
            tableHeaderSortButton(title: "Giá (USDT)", column: .price, width: 100, alignment: .trailing)
            tableHeaderSortButton(title: "24h %", column: .change24h, width: 90, alignment: .trailing)
            tableHeaderSortButton(title: "Vol 24h (USDT)", column: .volume, width: 130, alignment: .trailing)
            tableHeaderSortButton(title: "Vốn Hóa", column: .marketCap, width: 110, alignment: .trailing)
            
            Text("Chi Tiết")
                .frame(width: 60, alignment: .center)
        }
        .font(.system(size: 10.5, weight: .bold))
        .foregroundColor(.white.opacity(0.5))
        .padding(.horizontal, 10)
        .frame(height: 32)
        .background(AppTheme.darkHeaderBg)
        .overlay(Rectangle().fill(AppTheme.darkBorder).frame(height: 1), alignment: .bottom)
    }
    
    private func tableHeaderSortButton(title: String, column: SectorTokenSortColumn, width: CGFloat, alignment: Alignment) -> some View {
        Button(action: {
            if sortColumn == column {
                sortAscending.toggle()
            } else {
                sortColumn = column
                sortAscending = false
            }
        }) {
            HStack(spacing: 3) {
                if alignment == .trailing { Spacer() }
                Text(title)
                if sortColumn == column {
                    Image(systemName: sortAscending ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                }
                if alignment == .leading { Spacer() }
            }
            .frame(width: width, alignment: alignment)
            .background(Color.white.opacity(0.001))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private func tokenTableRow(rank: Int, ticker: MarketTicker24h) -> some View {
        let isBullish = ticker.priceChangePercent >= 0
        
        return Button(action: {
            onSelectSymbol?(ticker.symbol)
        }) {
            HStack(spacing: 0) {
                // Rank
                Text("\(rank)")
                    .font(.system(size: 11, weight: rank <= 3 ? .bold : .regular, design: .monospaced))
                    .foregroundColor(rank <= 3 ? AppTheme.cyan : .white.opacity(0.4))
                    .frame(width: 36, alignment: .center)
                
                // Symbol + Sector Badge
                HStack(spacing: 6) {
                    VStack(alignment: .leading, spacing: 1) {
                        HStack(spacing: 4) {
                            Text(ticker.baseAsset)
                                .font(.system(size: 12.5, weight: .bold))
                                .foregroundColor(.white)
                            Text("/USDT")
                                .font(.system(size: 9.5))
                                .foregroundColor(.white.opacity(0.35))
                        }
                        
                        Text(ticker.sector.rawValue)
                            .font(.system(size: 8.5, weight: .medium))
                            .foregroundColor(ticker.sector.color)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 0.5)
                            .background(ticker.sector.color.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
                .frame(width: 140, alignment: .leading)
                
                Spacer()
                
                // Price
                Text(Formatters.formatPrice(ticker.price))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .frame(width: 100, alignment: .trailing)
                
                // 24h %
                HStack(spacing: 2) {
                    Image(systemName: isBullish ? "arrow.up.right" : "arrow.down.right")
                        .font(.system(size: 8, weight: .bold))
                    Text(Formatters.formatPercentage(ticker.priceChangePercent))
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                }
                .foregroundColor(isBullish ? AppTheme.upGreen : AppTheme.downRed)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background((isBullish ? AppTheme.upGreen : AppTheme.downRed).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .frame(width: 90, alignment: .trailing)
                
                // Volume 24h
                Text("$\(Formatters.formatVolume(ticker.quoteVolume))")
                    .font(.system(size: 11.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.85))
                    .frame(width: 130, alignment: .trailing)
                
                // Estimated Market Cap
                Text(Formatters.formatMarketCap(ticker.estimatedMarketCap))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 110, alignment: .trailing)
                
                // Detail Action Icon
                Image(systemName: "chevron.right.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.accentBlue.opacity(0.8))
                    .frame(width: 60, alignment: .center)
            }
            .padding(.horizontal, 10)
            .frame(height: 38)
            .background(Color.white.opacity(0.001))
            .overlay(
                Rectangle()
                    .fill(AppTheme.darkBorder.opacity(0.4))
                    .frame(height: 0.5),
                alignment: .bottom
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 5. Sector Rotation & Flow Matrix
    
    private var sectorRotationMatrixSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.orange)
                    Text("BẢNG XẾP HẠNG & LUÂN CHUYỂN DÒNG TIỀN (SECTOR ROTATION MATRIX)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Cập nhật theo dữ liệu Ticker 24h Binance Realtime")
                    .font(.system(size: 10.5))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            VStack(spacing: 0) {
                // Table Header
                HStack(spacing: 0) {
                    Text("#").frame(width: 32, alignment: .center)
                    Text("Phân Khúc").frame(width: 140, alignment: .leading)
                    Text("Vol 24h (USDT)").frame(width: 120, alignment: .trailing)
                    Text("Thị Phần").frame(width: 80, alignment: .trailing)
                    Text("Biến Động TB").frame(width: 100, alignment: .trailing)
                    Text("Tỷ Lệ Tăng / Giảm").frame(width: 130, alignment: .center)
                    Text("Trạng Thái Dòng Tiền").frame(width: 130, alignment: .center)
                    Spacer()
                    Text("Top Mã Tăng").frame(width: 110, alignment: .trailing)
                }
                .font(.system(size: 10.5, weight: .bold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 12)
                .frame(height: 32)
                .background(AppTheme.darkHeaderBg)
                .overlay(Rectangle().fill(AppTheme.darkBorder).frame(height: 1), alignment: .bottom)
                
                // Rows
                ForEach(Array(viewModel.sectorPerformances.enumerated()), id: \.element.id) { idx, item in
                    let share = totalMarketVolume > 0 ? (item.totalQuoteVolume / totalMarketVolume * 100) : 0
                    let status = flowStatus(for: item, sharePercent: share)
                    let isBullish = item.avgChangePercent >= 0
                    
                    HStack(spacing: 0) {
                        Text("\(idx + 1)")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(idx == 0 ? AppTheme.accentBlue : .white.opacity(0.4))
                            .frame(width: 32, alignment: .center)
                        
                        HStack(spacing: 6) {
                            Image(systemName: item.sector.iconName)
                                .font(.system(size: 11))
                                .foregroundColor(item.sector.color)
                            Text(item.sector.rawValue)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 140, alignment: .leading)
                        
                        Text(Formatters.formatVolume(item.totalQuoteVolume))
                            .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 120, alignment: .trailing)
                        
                        Text(String(format: "%.1f%%", share))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(item.sector.color)
                            .frame(width: 80, alignment: .trailing)
                        
                        HStack(spacing: 2) {
                            Image(systemName: isBullish ? "arrow.up.right" : "arrow.down.right")
                                .font(.system(size: 8, weight: .bold))
                            Text(String(format: "%@%.2f%%", isBullish ? "+" : "", item.avgChangePercent))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                        }
                        .foregroundColor(isBullish ? AppTheme.upGreen : AppTheme.downRed)
                        .frame(width: 100, alignment: .trailing)
                        
                        Text("\(item.gainersCount)▲ / \(item.losersCount)▼")
                            .font(.system(size: 10.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 130, alignment: .center)
                        
                        Text(status.title)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(status.color)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(status.color.opacity(0.14))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(width: 130, alignment: .center)
                        
                        Spacer()
                        
                        if let topG = item.topGainerSymbol, let topP = item.topGainerChangePercent {
                            let cleanSym = topG.replacingOccurrences(of: "USDT", with: "")
                            let sign = topP >= 0 ? "+" : ""
                            Text("\(cleanSym) \(sign)\(String(format: "%.1f%%", topP))")
                                .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                                .foregroundColor(topP >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                .frame(width: 110, alignment: .trailing)
                        } else {
                            Text("--")
                                .font(.system(size: 10.5))
                                .foregroundColor(.white.opacity(0.3))
                                .frame(width: 110, alignment: .trailing)
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 36)
                    .background(idx % 2 == 0 ? AppTheme.darkCard : AppTheme.darkHeaderBg.opacity(0.4))
                    .overlay(Rectangle().fill(AppTheme.darkBorder.opacity(0.3)).frame(height: 0.5), alignment: .bottom)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helpers
    
    private func topCoinsInSector(_ sector: CryptoSector, limit: Int = 3) -> [MarketTicker24h] {
        let filtered = viewModel.tickers.filter { $0.sector == sector }
        return Array(filtered.sorted { $0.quoteVolume > $1.quoteVolume }.prefix(limit))
    }
    
    private func sectorDescription(_ sector: CryptoSector) -> String {
        switch sector {
        case .all:
            return "Toàn cảnh toàn bộ 100+ tài sản crypto được phân loại theo từng mảng sinh thái chuyên biệt."
        case .layer1:
            return "Blockchain lớp cơ sở (Base layer) xử lý giao dịch, tạo block và duy trì bảo mật mạng lưới (BTC, ETH, SOL, BNB, NEAR, SUI...)."
        case .layer2:
            return "Giải pháp mở rộng quy mô lớp 2: Rollups, ZK-Rollup và Sidechains giảm phí giao dịch (ARB, OP, MATIC, STRK, DYDX...)."
        case .defi:
            return "Tài chính phi tập trung: Sàn giao dịch phi tập trung (DEX), Giao thức cho vay/đi vay, Yield Farming và Liquid Staking (UNI, AAVE, MKR, PENDLE...)."
        case .ai:
            return "Trí tuệ nhân tạo (AI), Điện toán phi tập trung GPU/Cloud và Dữ liệu lớn Big Data (FET, RENDER, TAO, WLD, GRT...)."
        case .meme:
            return "Văn hóa Internet, trào lưu mạng xã hội và cộng đồng viral bán lẻ (DOGE, SHIB, PEPE, WIF, BONK, FLOKI...)."
        case .rwa:
            return "Tài sản thế giới thực được số hóa (Real World Assets): Trái phiếu, Bất động sản và Tín dụng tư nhân (ONDO, OM, CFG, TRAC...)."
        case .depin:
            return "Mạng lưới cơ sở hạ tầng vật lý phi tập trung, Lưu trữ đám mây & Mạng viễn thông IoT (FIL, AR, TIA, THETA, HNT, LINK...)."
        case .gaming:
            return "GameFi, Thế giới ảo Metaverse và Quyền sở hữu tài sản kỹ thuật số (GALA, AXS, SAND, RONIN, BEAM...)."
        case .cex:
            return "Token nền tảng sàn giao dịch tập trung và thanh khoản trung gian (BUSD, MX, OKB, KCS...)."
        case .others:
            return "Các token tiện ích, quản trị và dự án tiền mã hóa thuộc phân nhóm đặc thù khác."
        }
    }
    
    private func flowStatus(for item: SectorPerformance, sharePercent: Double) -> (title: String, color: Color) {
        if sharePercent >= 25.0 {
            return ("Dẫn Dắt Sóng", AppTheme.accentBlue)
        } else if item.avgChangePercent >= 3.0 && sharePercent >= 3.0 {
            return ("Thu Hút Vốn", AppTheme.upGreen)
        } else if item.avgChangePercent >= 0.0 {
            return ("Tích Lũy", AppTheme.cyan)
        } else if item.avgChangePercent < -2.0 {
            return ("Bị Rút Vốn", AppTheme.downRed)
        } else {
            return ("Cân Bằng", Color.white.opacity(0.65))
        }
    }
}

// MARK: - Enums for Filtering & Sorting

private enum TokenFilterMode: String, CaseIterable, Identifiable {
    case all = "Tất cả"
    case gainersOnly = "Mã Tăng"
    case losersOnly = "Mã Giảm"
    var id: String { rawValue }
}

private enum SectorTokenSortColumn {
    case symbol
    case price
    case change24h
    case volume
    case marketCap
}

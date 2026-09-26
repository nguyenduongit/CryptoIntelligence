import SwiftUI

public struct MarketOverviewView: View {
    @Bindable var router: NavigationRouter
    @Binding var selectedSymbol: String
    @Bindable var viewModel: MarketViewModel
    
    public init(
        router: NavigationRouter,
        selectedSymbol: Binding<String>,
        viewModel: MarketViewModel = MarketViewModel()
    ) {
        self.router = router
        self._selectedSymbol = selectedSymbol
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Top Subtabs Toolbar (Dynamic based on selected sidebar mode)
            marketSubtabsToolbar
            
            // 2. Error Banner (if any)
            if let err = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.warningYellow)
                    Text(err)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                    Spacer()
                    Button("Thử lại") {
                        viewModel.loadData()
                    }
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(AppTheme.accentBlue)
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(AppTheme.warningYellow.opacity(0.15))
            }
            
            // 3. Main View Mode Content
            Group {
                switch viewModel.selectedViewMode {
                case .valuation:
                    MarketValuationHubView(viewModel: viewModel)
                case .globalMacro:
                    MarketGlobalMacroHubView(viewModel: viewModel)
                case .heatmap:
                    if viewModel.selectedHeatmapSection == .heatmap {
                        MarketHeatmapView(
                            tickers: viewModel.filteredTickers,
                            onSelectSymbol: { sym in
                                navigateToCoin(symbol: sym)
                            }
                        )
                    } else {
                        SectorFlowView(
                            sectorPerformances: viewModel.sectorPerformances,
                            onSelectSector: { sector in
                                viewModel.selectedSector = sector
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectedHeatmapSection = .heatmap
                                }
                            }
                        )
                    }
                case .movers:
                    MarketMoversView(
                        topGainers: viewModel.topGainers,
                        topLosers: viewModel.topLosers,
                        topVolumes: viewModel.topVolumes,
                        selectedCategory: viewModel.selectedMoversCategory,
                        onSelectSymbol: { sym in
                            navigateToCoin(symbol: sym)
                        }
                    )
                case .screener:
                    MarketScreenerMainView(
                        router: router,
                        selectedSymbol: $selectedSymbol,
                        selectedPreset: viewModel.selectedScreenerPreset
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            if viewModel.tickers.isEmpty {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Dynamic Subtabs Toolbar
    @ViewBuilder
    private var marketSubtabsToolbar: some View {
        HStack(spacing: 12) {
            // Mode-specific Subtabs
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    switch viewModel.selectedViewMode {
                    case .valuation:
                        valuationSubtabs
                    case .globalMacro:
                        globalMacroSubtabs
                    case .heatmap:
                        heatmapAndSectorSubtabs
                    case .movers:
                        moversSubtabs
                    case .screener:
                        screenerSubtabs
                    }
                }
            }
            
            Spacer()
            
            // Right-side Status & Actions
            HStack(spacing: 10) {
                if let last = viewModel.lastRefreshedAt {
                    Text("Cập nhật: \(formatTime(last))")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                Button(action: {
                    viewModel.loadData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                }
                .buttonStyle(.plain)
                .help("Làm mới dữ liệu thị trường (Cmd+R)")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Subtab Groups per Mode
    
    // 1. Valuation Subtabs (Tổng quan vs Biểu đồ)
    @ViewBuilder
    private var valuationSubtabs: some View {
        ForEach(MarketValuationSection.allCases) { sec in
            let isSelected = (viewModel.selectedValuationSection == sec)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.selectedValuationSection = sec
                }
            }) {
                HStack(spacing: 5) {
                    Image(systemName: sec.iconName)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    Text(sec.rawValue == "Tổng quan" ? "Tổng Quan Vốn Hóa & Tỷ Trọng" : "Biểu Đồ Nến K-Line Chỉ Số")
                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                }
                .padding(.horizontal, 11)
                .padding(.vertical, 5.5)
                .background(isSelected ? AppTheme.cyan.opacity(0.2) : AppTheme.darkCard)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? AppTheme.cyan.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // 2. Global Macro Subtabs (6 sections)
    @ViewBuilder
    private var globalMacroSubtabs: some View {
        ForEach(GlobalMacroSection.allCases) { sec in
            let isSelected = (viewModel.selectedGlobalMacroSection == sec)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.selectedGlobalMacroSection = sec
                }
            }) {
                HStack(spacing: 5) {
                    Image(systemName: sec.iconName)
                        .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    Text(sec.rawValue)
                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(isSelected ? AppTheme.accentBlue.opacity(0.2) : AppTheme.darkCard)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? AppTheme.accentBlue.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // 3. Merged Heatmap & Sectors Subtabs
    @ViewBuilder
    private var heatmapAndSectorSubtabs: some View {
        HStack(spacing: 6) {
            // Main View Switcher (Heatmap vs Sector Flow)
            ForEach(MarketHeatmapSection.allCases) { sec in
                let isSelected = (viewModel.selectedHeatmapSection == sec)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.selectedHeatmapSection = sec
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: sec.iconName)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        Text(sec.rawValue)
                            .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5.5)
                    .background(isSelected ? Color.purple.opacity(0.25) : AppTheme.darkCard)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.purple.opacity(0.8) : AppTheme.darkBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            
            Divider()
                .frame(height: 18)
                .background(AppTheme.darkBorder)
                .padding(.horizontal, 2)
            
            // Sub-filters depending on active heatmap section
            if viewModel.selectedHeatmapSection == .heatmap {
                ForEach(CryptoSector.allCases) { sector in
                    let isSelected = (viewModel.selectedSector == sector)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedSector = sector
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: sector.iconName)
                                .font(.system(size: 9.5))
                            Text(sector.rawValue)
                                .font(.system(size: 10.5, weight: isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4.5)
                        .background(isSelected ? AppTheme.accentBlue.opacity(0.2) : AppTheme.darkCard.opacity(0.6))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelected ? AppTheme.accentBlue.opacity(0.6) : AppTheme.darkBorder.opacity(0.6), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            } else {
                ForEach(MarketSortOption.allCases) { sort in
                    let isSelected = (viewModel.sortBy == sort)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.sortBy = sort
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: sortIcon(sort))
                                .font(.system(size: 9.5))
                            Text(sort.rawValue)
                                .font(.system(size: 10.5, weight: isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4.5)
                        .background(isSelected ? AppTheme.orange.opacity(0.2) : AppTheme.darkCard.opacity(0.6))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelected ? AppTheme.orange.opacity(0.6) : AppTheme.darkBorder.opacity(0.6), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    // 4. Movers Subtabs (All, Gainers, Losers, Volume)
    @ViewBuilder
    private var moversSubtabs: some View {
        ForEach(MoversCategorySelection.allCases) { cat in
            let isSelected = (viewModel.selectedMoversCategory == cat)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.selectedMoversCategory = cat
                }
            }) {
                HStack(spacing: 5) {
                    Image(systemName: cat.iconName)
                        .font(.system(size: 10.5))
                    Text(cat.rawValue)
                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(isSelected ? AppTheme.upGreen.opacity(0.2) : AppTheme.darkCard)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? AppTheme.upGreen.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // 5. Screener Subtabs (Preset Signals)
    @ViewBuilder
    private var screenerSubtabs: some View {
        ForEach(ScreenerPresetSelection.allCases) { preset in
            let isSelected = (viewModel.selectedScreenerPreset == preset)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.selectedScreenerPreset = preset
                }
            }) {
                HStack(spacing: 5) {
                    Image(systemName: preset.iconName)
                        .font(.system(size: 10.5))
                    Text(preset.rawValue)
                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5.5)
                .background(isSelected ? Color.yellow.opacity(0.2) : AppTheme.darkCard)
                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.yellow.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private func sortIcon(_ sort: MarketSortOption) -> String {
        switch sort {
        case .volume24h: return "flame.fill"
        case .changeDesc: return "arrow.up.right"
        case .changeAsc: return "arrow.down.right"
        case .price: return "dollarsign.circle"
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func navigateToCoin(symbol: String) {
        selectedSymbol = symbol
        router.selectedTab = .coin
    }
}

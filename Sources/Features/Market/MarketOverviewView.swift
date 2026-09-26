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
            // 1. Top Sub-header & Subtab Switcher Bar
            marketToolbar
            
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
            
            // 3. Main View Mode Content (Full Height, Uncluttered)
            Group {
                switch viewModel.selectedViewMode {
                case .valuation:
                    MarketValuationHubView(viewModel: viewModel)
                case .globalMacro:
                    MarketGlobalMacroHubView(viewModel: viewModel)
                case .heatmap:
                    MarketHeatmapView(
                        tickers: viewModel.filteredTickers,
                        onSelectSymbol: { sym in
                            navigateToCoin(symbol: sym)
                        }
                    )
                case .sectors:
                    SectorFlowView(
                        sectorPerformances: viewModel.sectorPerformances,
                        onSelectSector: { sector in
                            viewModel.selectedSector = sector
                            viewModel.selectedViewMode = .heatmap
                        }
                    )
                case .movers:
                    MarketMoversView(
                        topGainers: viewModel.topGainers,
                        topLosers: viewModel.topLosers,
                        topVolumes: viewModel.topVolumes,
                        onSelectSymbol: { sym in
                            navigateToCoin(symbol: sym)
                        }
                    )
                case .screener:
                    MarketScreenerMainView(
                        router: router,
                        selectedSymbol: $selectedSymbol
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
    
    @ViewBuilder
    private var marketToolbar: some View {
        HStack(spacing: 12) {
            // MARK: - Top-Bar Segmented View Modes Switcher
            HStack(spacing: 4) {
                ForEach(MarketViewMode.allCases) { mode in
                    let isSelected = (viewModel.selectedViewMode == mode)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedViewMode = mode
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.6))
                            
                            Text(mode.rawValue)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                                .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            isSelected ? AppTheme.accentBlue.opacity(0.18) : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? AppTheme.accentBlue.opacity(0.6) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(2)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
            
            Spacer()
            
            // Refresh & Time status
            HStack(spacing: 8) {
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

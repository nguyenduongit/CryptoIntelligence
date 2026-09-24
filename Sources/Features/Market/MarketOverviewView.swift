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
            // 1. Top Sub-header & Filters Bar
            marketToolbar
            
            // 2. Macro Metrics Bar (Volume, BTC.D, ETH.D, Fear & Greed)
            MarketMacroMetricsBarView(
                metrics: viewModel.globalMetrics,
                isLoading: viewModel.isLoading,
                onRefresh: { viewModel.loadData() }
            )
            
            // 2.5 Derivatives & Funding Rates Bar
            if let deriv = viewModel.derivativesMetrics {
                DerivativesOverviewBarView(metrics: deriv)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 4)
                    .background(AppTheme.darkHeaderBg.opacity(0.85))
                    .overlay(
                        Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
                        alignment: .bottom
                    )
            }
            
            // 3. Error Banner (if any)
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
            
            // 4. Main View Mode Content
            Group {
                switch viewModel.selectedViewMode {
                case .screener:
                    MarketScreenerMainView(
                        router: router,
                        selectedSymbol: $selectedSymbol
                    )
                case .heatmap:
                    MarketHeatmapView(
                        tickers: viewModel.filteredTickers,
                        onSelectSymbol: { sym in
                            navigateToCoin(symbol: sym)
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
                case .sectors:
                    SectorFlowView(
                        sectorPerformances: viewModel.sectorPerformances,
                        onSelectSector: { sector in
                            viewModel.selectedSector = sector
                            viewModel.selectedViewMode = .heatmap
                        }
                    )
                case .macro:
                    GlobalMacroView()
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
            // Active Mode Title Pill
            HStack(spacing: 6) {
                Image(systemName: viewModel.selectedViewMode.iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.accentBlue)
                Text(viewModel.selectedViewMode.rawValue)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                if viewModel.selectedViewMode != .macro && viewModel.selectedSector != .all {
                    Text("•")
                        .foregroundColor(.white.opacity(0.4))
                    Text(viewModel.selectedSector.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.cyan.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            Spacer()
            
            // Search Box (for coin search)
            if viewModel.selectedViewMode != .macro {
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.4))
                        .font(.system(size: 11))
                    TextField("Tìm coin...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11))
                        .frame(width: 140)
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
            }
            
            // Refresh Button
            Button(action: { viewModel.loadData() }) {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 10))
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                    Text("Làm mới")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.darkCard)
                .foregroundColor(.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func navigateToCoin(symbol: String) {
        selectedSymbol = symbol
        router.selectedTab = .coin
        router.selectedSubtab = .chart
    }
}

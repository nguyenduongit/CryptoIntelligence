import SwiftUI

public struct OnChainView: View {
    public let symbol: String
    @State private var viewModel: OnChainViewModel
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: OnChainViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tải dữ liệu On-chain cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Top Section Filter Selector Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(OnChainSectionFilter.allCases) { sec in
                                Button {
                                    viewModel.selectedSection = sec
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: iconForSection(sec))
                                            .font(.system(size: 10))
                                        Text(sec.rawValue)
                                            .font(.system(size: 11, weight: viewModel.selectedSection == sec ? .bold : .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(viewModel.selectedSection == sec ? AppTheme.accentBlue : AppTheme.darkCard)
                                    .foregroundColor(viewModel.selectedSection == sec ? .white : .white.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(viewModel.selectedSection == sec ? AppTheme.accentBlue : AppTheme.darkBorder, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 1. On-Chain Health & Summary Banner
                    OnChainHealthBannerView(profile: profile)
                    
                    // 2. MVRV Z-Score & Valuation Cycle Model
                    if let cycle = profile.cycleMetrics,
                       viewModel.selectedSection == .all || viewModel.selectedSection == .cycle {
                        MVRVCycleGaugeCardView(metrics: cycle)
                    }
                    
                    // 3. US Spot ETF Inflows Tracker (For BTC / ETH)
                    if let etf = profile.spotETFFlows,
                       viewModel.selectedSection == .all || viewModel.selectedSection == .etf {
                        SpotETFFlowsCardView(summary: etf)
                    }
                    
                    // 4. LTH vs STH Supply Distribution
                    if let lth = profile.lthSupply,
                       viewModel.selectedSection == .all || viewModel.selectedSection == .supply {
                        LTHSupplyDistributionCardView(metrics: lth)
                    }
                    
                    // 5. Entity Attribution & Whale Directory (Arkham-grade)
                    if let entities = profile.entityHoldings,
                       viewModel.selectedSection == .all || viewModel.selectedSection == .entities {
                        EntityWhaleHoldingsCardView(entities: entities)
                    }
                    
                    // 6. Exchange Flow & Network Activity Cards Grid
                    if viewModel.selectedSection == .all || viewModel.selectedSection == .exchangeFlows {
                        HStack(alignment: .top, spacing: 14) {
                            ExchangeFlowCardView(metrics: profile.exchangeFlow)
                                .frame(maxWidth: .infinity)
                            
                            NetworkActivityCardView(metrics: profile.networkActivity)
                                .frame(maxWidth: .infinity)
                        }
                        
                        // Holder Concentration Card
                        HolderConcentrationCardView(metrics: profile.holderConcentration)
                        
                        // Whale Transactions Table
                        WhaleTransactionsTableView(
                            transactions: viewModel.filteredWhaleTransactions,
                            selectedFilter: $viewModel.selectedTxFilter
                        )
                    }
                } else if let err = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.warningYellow)
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        Button("Thử lại") {
                            viewModel.loadData()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .frame(maxWidth: .infinity, minHeight: 250)
                }
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: symbol) { _, newSym in
            viewModel.setSymbol(newSym)
        }
    }
    
    private func iconForSection(_ sec: OnChainSectionFilter) -> String {
        switch sec {
        case .all: return "square.grid.2x2.fill"
        case .cycle: return "gauge.with.needle.fill"
        case .etf: return "chart.bar.xaxis"
        case .supply: return "chart.pie.fill"
        case .entities: return "building.columns.fill"
        case .exchangeFlows: return "arrow.triangle.swap"
        }
    }
}

import SwiftUI

public struct TokenomicsView: View {
    public let symbol: String
    @State private var viewModel: TokenomicsViewModel
    @State private var selectedSectionId: String = "supply"
    
    private let sections: [SubtabSectionItem] = [
        SubtabSectionItem(id: "supply", title: "Nguồn Cung & Vốn Hóa", iconName: "dollarsign.circle.fill"),
        SubtabSectionItem(id: "onchainValuation", title: "Định Giá On-Chain (MVRV)", iconName: "gauge.with.needle.fill"),
        SubtabSectionItem(id: "vesting", title: "Lịch Mở Khóa & Vesting", iconName: "lock.open.trianglebadge.exclamationmark.fill")
    ]
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: TokenomicsViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tải dữ liệu Định giá & Tokenomics cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Header Status Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Định Giá, Nguồn Cung & Lịch Mở Khóa (\(symbol))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Thẩm định vốn hóa thực tế, rủi ro pha loãng, định giá on-chain MVRV và lộ trình phát thải.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .liveBinance, text: "FDV Live Binance")
                        DataSourceBadge(type: .liveCoinGecko, text: "CoinGecko & Glassnode Model")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // Sub-navigation Section Selector
                    SubtabSectionSelector(items: sections, selectedId: $selectedSectionId)
                    
                    // Dynamic Content based on selected section
                    switch selectedSectionId {
                    case "supply":
                        // 1. Supply & Valuation Summary Cards
                        SupplyValuationCardsView(
                            metrics: profile.supplyMetrics,
                            tokenStandard: profile.tokenStandard,
                            useCases: profile.primaryUseCases
                        )
                        
                        // 2. Token Allocation Breakdown (Donut + Legend)
                        TokenAllocationDonutView(
                            allocations: profile.allocations,
                            selectedAllocation: $viewModel.selectedAllocation
                        )
                        
                        // 3. Token Utility & Deflationary Matrix
                        TokenUtilityMatrixCardView(utility: profile.utilityInfo)
                        
                    case "onchainValuation":
                        // 1. On-Chain Valuation (Realized Price & MVRV)
                        let curPrice = profile.supplyMetrics.circulatingSupply > 0
                            ? (profile.supplyMetrics.marketCapUSD / profile.supplyMetrics.circulatingSupply)
                            : 0.0
                        OnChainValuationCardsView(
                            metrics: profile.supplyMetrics,
                            currentPrice: curPrice
                        )
                        
                        // 2. Summary of Supply Context
                        SupplyValuationCardsView(
                            metrics: profile.supplyMetrics,
                            tokenStandard: profile.tokenStandard,
                            useCases: profile.primaryUseCases
                        )
                        
                    case "vesting":
                        // 1. 5-Year Vesting Emission Curve
                        if !profile.vestingSchedule.isEmpty {
                            VestingEmissionCurveView(schedule: profile.vestingSchedule)
                        }
                        
                        // 2. Upcoming Unlocks Timeline & Cliff Details
                        UpcomingUnlocksTimelineView(
                            unlocks: profile.upcomingUnlocks,
                            vestingNotes: profile.vestingNotes
                        )
                        
                    default:
                        EmptyView()
                    }
                } else if let err = viewModel.errorMessage {
                    DataUnavailableView(
                        title: "Định Giá & Tokenomics",
                        symbol: symbol,
                        iconName: "chart.pie.fill",
                        message: err,
                        onRetry: { viewModel.loadData() }
                    )
                } else {
                    DataUnavailableView(
                        title: "Định Giá & Tokenomics",
                        symbol: symbol,
                        iconName: "chart.pie.fill",
                        onRetry: { viewModel.loadData() }
                    )
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
}

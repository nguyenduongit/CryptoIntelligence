import SwiftUI

public struct SmartMoneyView: View {
    public let symbol: String
    @State private var viewModel: SmartMoneyViewModel
    @State private var selectedSectionId: String = "wallets"
    
    private let sections: [SubtabSectionItem] = [
        SubtabSectionItem(id: "wallets", title: "Ví Cá Voi & Smart Money", iconName: "person.3.sequence.fill"),
        SubtabSectionItem(id: "trapsRadar", title: "Radar Bẫy Thao Túng", iconName: "radar.fill"),
        SubtabSectionItem(id: "dexSwaps", title: "Lệnh Swap Khủng On-Chain", iconName: "arrow.triangle.swap"),
        SubtabSectionItem(id: "freshWallets", title: "Ví Mới Gom Hàng", iconName: "sparkles")
    ]
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: SmartMoneyViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang theo dấu dòng tiền Smart Money & Cá Voi cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Sub-navigation Section Selector
                    SubtabSectionSelector(items: sections, selectedId: $selectedSectionId)
                    
                    // Dynamic Module Rendering
                    switch selectedSectionId {
                    case "wallets":
                        // 1. Overall Signal Banner
                        SmartMoneySignalBannerView(signal: profile.sentimentSignal)
                        
                        // 2. Wallets Leaderboard
                        SmartMoneyWalletsLeaderboardView(wallets: profile.topWallets)
                        
                    case "trapsRadar":
                        // 1. Whale Traps Radar (Pump/Dump & Wash Trading)
                        WhaleTrapsRadarCardView(
                            symbol: symbol,
                            pumpDumpRiskLevel: profile.sentimentSignal.score > 75 ? "Thấp" : "Trung bình",
                            washTradingScore: max(5, min(35, 100 - profile.sentimentSignal.score)),
                            top10ConcentrationPercent: 24.5
                        )
                        
                        // 2. Signal Context
                        SmartMoneySignalBannerView(signal: profile.sentimentSignal)
                        
                    case "dexSwaps":
                        // Large Swap Orders on DEX / CEX
                        SmartMoneyDEXSwapsTableView(
                            swaps: viewModel.filteredDEXSwaps,
                            selectedFilter: $viewModel.selectedSwapFilter
                        )
                        
                    case "freshWallets":
                        // Fresh Wallets Alerts
                        FreshWalletsAlertCardView(alerts: profile.freshWallets)
                        
                    default:
                        EmptyView()
                    }
                } else if let err = viewModel.errorMessage {
                    DataUnavailableView(
                        title: "Dòng Tiền Cá Voi",
                        symbol: symbol,
                        iconName: "person.3.sequence.fill",
                        message: err,
                        onRetry: { viewModel.loadData() }
                    )
                } else {
                    DataUnavailableView(
                        title: "Dòng Tiền Cá Voi",
                        symbol: symbol,
                        iconName: "person.3.sequence.fill",
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

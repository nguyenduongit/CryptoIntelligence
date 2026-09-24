import SwiftUI

public struct SmartMoneyView: View {
    public let symbol: String
    @State private var viewModel: SmartMoneyViewModel
    
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
                        Text("Đang phân tích dòng tiền Smart Money cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Header Status Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Smart Money, Dòng Tiền Cá Voi & Quỹ Đầu Tư (\(symbol))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Theo dõi ví cá voi, quỹ VC và luồng hoán đổi DEX quy mô lớn.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .simulatedCatalog, text: "Mô Phỏng Dòng Tiền Whale")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // 1. Smart Money Sentiment & Signal Banner
                    SmartMoneySignalBannerView(signal: profile.sentimentSignal)
                    
                    // 2. VC Backers & Institutional Holdings Grid
                    VCBackersGridView(backers: profile.vcBackers)
                    
                    // 3. Top Profitable Smart Money Wallets Leaderboard
                    if !profile.topWallets.isEmpty {
                        SmartMoneyWalletsLeaderboardView(wallets: profile.topWallets)
                    }
                    
                    // 4. Fresh Wallets Accumulation Alert
                    if !profile.freshWallets.isEmpty {
                        FreshWalletsAlertCardView(alerts: profile.freshWallets)
                    }
                    
                    // 5. DEX Liquidity & Capital Efficiency
                    DEXLiquidityCardView(metrics: profile.dexLiquidity)
                    
                    // 6. Smart Money DEX Swaps Feed
                    SmartMoneyDEXSwapsTableView(
                        swaps: viewModel.filteredDEXSwaps,
                        selectedFilter: $viewModel.selectedSwapFilter
                    )
                } else if let err = viewModel.errorMessage {
                    DataUnavailableView(
                        title: "Smart Money & Dòng Tiền DEX",
                        symbol: symbol,
                        iconName: "dollarsign.arrow.circlepath",
                        message: err,
                        onRetry: { viewModel.loadData() }
                    )
                } else {
                    DataUnavailableView(
                        title: "Smart Money & Dòng Tiền DEX",
                        symbol: symbol,
                        iconName: "dollarsign.arrow.circlepath",
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

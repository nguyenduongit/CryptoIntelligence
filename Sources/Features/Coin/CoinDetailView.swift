import SwiftUI

public struct CoinDetailView: View {
    public let symbol: String
    public let watchlistItem: WatchlistItem?
    var watchlistVM: WatchlistViewModel?
    @Bindable var router: NavigationRouter
    @State private var chartViewModel: ChartViewModel
    @State private var multiChartLayout: MultiChartLayout = .single
    @State private var showRelativeStrength: Bool = false
    
    public init(
        symbol: String,
        watchlistItem: WatchlistItem? = nil,
        watchlistVM: WatchlistViewModel? = nil,
        router: NavigationRouter
    ) {
        self.symbol = symbol
        self.watchlistItem = watchlistItem
        self.watchlistVM = watchlistVM
        self.router = router
        self._chartViewModel = State(initialValue: ChartViewModel(symbol: symbol))
    }
    
    private var activeWatchlistItem: WatchlistItem? {
        if let vm = watchlistVM {
            return vm.items.first(where: { $0.symbol.uppercased() == symbol.uppercased() })
        }
        return watchlistItem
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Subtab Bar
            HStack(spacing: 4) {
                ForEach(CoinSubtab.allCases) { subtab in
                    Button(action: { router.selectedSubtab = subtab }) {
                        Text(subtab.rawValue)
                            .font(.system(size: 12, weight: router.selectedSubtab == subtab ? .semibold : .medium))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                router.selectedSubtab == subtab
                                ? AppTheme.darkCard
                                : Color.clear
                            )
                            .foregroundColor(
                                router.selectedSubtab == subtab
                                ? .white
                                : .white.opacity(0.6)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        router.selectedSubtab == subtab ? AppTheme.accentBlue.opacity(0.4) : Color.clear,
                                        lineWidth: 1
                                    )
                            )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Active Coin Tier & Status Pills (or Quick Add Button if not in Watchlist)
                if let item = activeWatchlistItem {
                    HStack(spacing: 6) {
                        // Tier Badge
                        HStack(spacing: 3) {
                            Text("Tier:")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.4))
                            Text(item.tier.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(tierColor(for: item.tier).opacity(0.2))
                        .foregroundColor(tierColor(for: item.tier))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        // Status Badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(statusColor(for: item.status))
                                .frame(width: 6, height: 6)
                            Text(item.status.rawValue)
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(statusColor(for: item.status).opacity(0.18))
                        .foregroundColor(statusColor(for: item.status))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(.trailing, 4)
                } else if let watchlistVM {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            watchlistVM.toggleWatchlist(symbol: symbol)
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "star")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                            Text("+ Thêm Watchlist")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.75))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.darkCard)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .help("Thêm \(symbol) vào Watchlist")
                    .padding(.trailing, 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(AppTheme.darkHeaderBg)
            .overlay(
                Rectangle()
                    .fill(AppTheme.darkBorder)
                    .frame(height: 1),
                alignment: .bottom
            )
            
            // Subtab Content View
            Group {
                switch router.selectedSubtab {
                case .overview:
                    CoinOverviewView(symbol: symbol, item: activeWatchlistItem)
                case .chart:
                    MultiChartWorkspaceView(
                        primarySymbol: symbol,
                        layout: $multiChartLayout,
                        showRelativeStrength: $showRelativeStrength
                    )
                case .derivatives:
                    DerivativesView(symbol: symbol)
                case .tokenomics:
                    TokenomicsView(symbol: symbol)
                case .onchain:
                    OnChainView(symbol: symbol)
                case .smartMoney:
                    SmartMoneyView(symbol: symbol)
                case .project:
                    ProjectProfileView(symbol: symbol)
                case .securityLegal:
                    SecurityLegalView(symbol: symbol)
                case .notes:
                    NotesView(symbol: symbol)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: symbol) { _, newSym in
            chartViewModel.setSymbol(newSym)
        }
    }
    
    private func tierColor(for tier: CoinTier) -> Color {
        switch tier {
        case .core: return AppTheme.purple
        case .narrative: return AppTheme.cyan
        case .moonshot: return AppTheme.orange
        case .unassigned: return .white.opacity(0.5)
        }
    }
    
    private func statusColor(for status: CoinStatus) -> Color {
        switch status {
        case .watching: return .white.opacity(0.6)
        case .buyZone: return AppTheme.upGreen
        case .holding: return AppTheme.accentBlue
        case .ignored: return AppTheme.downRed
        }
    }
}

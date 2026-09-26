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
                
                // Quick Add Button if not in Watchlist
                if activeWatchlistItem == nil, let watchlistVM {
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
            .frame(height: AppTheme.subHeaderHeight)
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
                case .valuation:
                    TokenomicsView(symbol: symbol)
                case .liquidity:
                    LiquidityView(symbol: symbol)
                case .derivatives:
                    DerivativesView(symbol: symbol)
                case .whales:
                    SmartMoneyView(symbol: symbol)
                case .profile:
                    ProfileView(symbol: symbol)
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
}

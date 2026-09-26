import SwiftUI

public struct ShellView: View {
    @State private var router: NavigationRouter = NavigationRouter()
    @State private var watchlistVM: WatchlistViewModel = WatchlistViewModel()
    @State private var marketVM: MarketViewModel = MarketViewModel()
    @State private var selectedSymbol: String = "BTCUSDT"
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Top Header Bar
            HeaderBarView(router: router)
            
            // 2. Center Split View (Sidebar + Main Content)
            HStack(spacing: 0) {
                SidebarContainerView(
                    router: router,
                    watchlistVM: watchlistVM,
                    marketVM: marketVM,
                    selectedSymbol: $selectedSymbol
                )
                
                // Main Content View
                Group {
                    switch router.selectedTab {
                    case .coin:
                        let activeItem = watchlistVM.items.first(where: { $0.symbol == selectedSymbol })
                        CoinDetailView(
                            symbol: selectedSymbol,
                            watchlistItem: activeItem,
                            watchlistVM: watchlistVM,
                            router: router
                        )
                        
                    case .heatmap:
                        MarketHeatmapMainHubView(
                            viewModel: marketVM,
                            onSelectSymbol: { sym in
                                selectedSymbol = sym
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    router.selectedTab = .coin
                                }
                            }
                        )
                        
                    case .valuation:
                        MarketValuationHubView(viewModel: marketVM)
                        
                    case .globalMacro:
                        MarketGlobalMacroHubView(viewModel: marketVM)
                        
                    case .movers:
                        MarketMoversHubView(
                            viewModel: marketVM,
                            onSelectSymbol: { sym in
                                selectedSymbol = sym
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    router.selectedTab = .coin
                                }
                            }
                        )
                        
                    case .screener:
                        MarketScreenerMainView(
                            router: router,
                            selectedSymbol: $selectedSymbol,
                            selectedPreset: marketVM.selectedScreenerPreset
                        )
                        
                    case .settings:
                        SettingsView(router: router)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.darkBackground)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // 3. Bottom Status Bar
            StatusBarView(router: router)
        }
        .background(AppTheme.darkBackground)
        .preferredColorScheme(.dark)
        .onAppear {
            setupWebSocket()
        }
    }
    
    private func setupWebSocket() {
        Task {
            await BinanceWebSocketManager.shared.setHandlers(
                onKline: { candle, symbol, timeframe in
                    Task { @MainActor in
                        NotificationCenter.default.post(
                            name: .didReceiveKline,
                            object: nil,
                            userInfo: [
                                "candle": candle,
                                "symbol": symbol,
                                "timeframe": timeframe
                            ]
                        )
                        router.lastUpdatedTime = Date()
                    }
                },
                onTicker: { symbol, price, changePercent, volume in
                    Task { @MainActor in
                        watchlistVM.updateTicker(symbol: symbol, price: price, changePercent: changePercent, volume: volume)
                        NotificationCenter.default.post(
                            name: .didReceiveTicker,
                            object: nil,
                            userInfo: [
                                "symbol": symbol,
                                "price": price,
                                "changePercent": changePercent,
                                "volume": volume
                            ]
                        )
                        router.lastUpdatedTime = Date()
                    }
                },
                onStatus: { isConnected in
                    Task { @MainActor in
                        router.isWebSocketConnected = isConnected
                        if isConnected {
                            router.lastNetworkError = nil
                        }
                    }
                },
                onError: { message in
                    Task { @MainActor in
                        router.lastNetworkError = message
                    }
                }
            )
            
            await BinanceWebSocketManager.shared.start()
            
            let defaultBotSymbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "BNBUSDT", "XRPUSDT", "DOGEUSDT", "AVAXUSDT", "LINKUSDT", "SUIUSDT", "NEARUSDT"]
            await BinanceWebSocketManager.shared.updateTickerSubscriptions(source: "bot", symbols: defaultBotSymbols)
            await BinanceWebSocketManager.shared.updateTickerSubscriptions(source: "watchlist", symbols: watchlistVM.items.map { $0.symbol })
        }
        
        // Start weight tracker timer (polls rateLimiter weight every 5s)
        Task {
            while !Task.isCancelled {
                let (used, maxLimit) = await BinanceRateLimiter.shared.getCurrentUsedWeight()
                await MainActor.run {
                    self.router.usedWeight1m = used
                    self.router.maxWeight1m = maxLimit
                }
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }
}

private struct MainTabPlaceholderView: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.accentBlue, AppTheme.purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 8)
            
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(AppTheme.accentBlue)
                    .frame(width: 8, height: 8)
                Text("Trạng thái: Phase 2 Roadmap")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.accentBlue)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(AppTheme.darkCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.accentBlue.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkBackground)
    }
}

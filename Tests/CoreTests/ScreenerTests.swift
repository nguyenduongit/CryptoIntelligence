import Testing
import Foundation
@testable import CryptoResearch

@Suite("ScreenerTests")
struct ScreenerTests {
    
    @Test("Test SignalCategory and SignalDirection properties")
    func testSignalEnums() {
        #expect(SignalCategory.allCases.count == 6)
        #expect(SignalDirection.allCases.count == 5)
        
        let breakout = SignalCategory.trendBreakout
        #expect(breakout.iconName == "chart.line.uptrend.xyaxis")
        
        let squeeze = SignalCategory.volatilitySqueeze
        #expect(squeeze.iconName == "arrow.left.and.right.circle.fill")
        
        let strongBull = SignalDirection.strongBullish
        #expect(strongBull.rawValue.contains("Strong Bullish"))
    }
    
    @Test("Test MarketSignalItem model instantiation and fields")
    func testMarketSignalItemModel() {
        let signal = MarketSignalItem(
            symbol: "SOLUSDT",
            baseAsset: "SOL",
            category: .trendBreakout,
            direction: .strongBullish,
            strengthScore: 92,
            timeframe: "4H",
            triggerPriceUSD: 145.0,
            currentPriceUSD: 148.5,
            priceChange24h: 5.82,
            volume24hUSD: 1_250_000_000,
            title: "EMA Golden Cross",
            reason: "EMA20 crossed EMA50"
        )
        
        #expect(signal.symbol == "SOLUSDT")
        #expect(signal.baseAsset == "SOL")
        #expect(signal.strengthScore == 92)
        #expect(signal.direction == .strongBullish)
        #expect(signal.category == .trendBreakout)
    }
    
    @Test("Test ScreenerDataProvider live signals and radar summary")
    func testScreenerDataProvider() async {
        let provider = ScreenerDataProvider.shared
        let signals = await provider.fetchLiveMarketSignals()
        
        #expect(!signals.isEmpty)
        #expect(signals.count >= 8)
        
        let summary = await provider.computeRadarSummary(from: signals)
        
        #expect(summary.totalSignalsScanned == signals.count)
        #expect(summary.bullishSignalsCount >= 0)
        #expect(summary.marketSentimentRatio >= 0.0 && summary.marketSentimentRatio <= 1.0)
        #expect(!summary.topSqueezeCoins.isEmpty)
        #expect(!summary.topWhaleAccumulationCoins.isEmpty)
    }
    
    @Test("Test MarketScreenerViewModel filtering logic")
    @MainActor
    func testScreenerViewModelFiltering() async {
        let vm = MarketScreenerViewModel()
        await vm.loadData()
        
        let totalCount = vm.signals.count
        #expect(totalCount > 0)
        
        // Filter by category: trendBreakout
        vm.config.selectedCategory = .trendBreakout
        let breakoutOnly = vm.filteredSignals
        #expect(breakoutOnly.allSatisfy { $0.category == .trendBreakout })
        
        // Reset category and filter by direction: bullish
        vm.config.selectedCategory = nil
        vm.config.selectedDirection = .bullish
        let bullishOnly = vm.filteredSignals
        #expect(bullishOnly.allSatisfy { $0.direction == .bullish || $0.direction == .strongBullish })
        
        // Search by symbol
        vm.config.selectedDirection = nil
        vm.config.searchText = "BTC"
        let btcSignals = vm.filteredSignals
        #expect(btcSignals.allSatisfy { $0.symbol.contains("BTC") || $0.baseAsset.contains("BTC") || $0.title.contains("BTC") })
        
        // Min strength score filter
        vm.config.searchText = ""
        vm.config.minStrengthScore = 90
        let highStrength = vm.filteredSignals
        #expect(highStrength.allSatisfy { $0.strengthScore >= 90 })
    }
}

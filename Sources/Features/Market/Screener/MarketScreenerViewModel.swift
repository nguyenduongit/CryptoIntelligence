import SwiftUI
import Observation

@Observable
@MainActor
public final class MarketScreenerViewModel {
    public var signals: [MarketSignalItem] = []
    public var summary: MarketRadarSummary
    public var config: ScreenerFilterConfig = ScreenerFilterConfig()
    public var isLoading: Bool = false
    
    private let provider: ScreenerDataProvider
    
    public init(provider: ScreenerDataProvider = .shared) {
        self.provider = provider
        self.summary = MarketRadarSummary(
            totalSignalsScanned: 0,
            bullishSignalsCount: 0,
            bearishSignalsCount: 0,
            neutralSignalsCount: 0,
            topSqueezeCoins: [],
            topWhaleAccumulationCoins: [],
            marketSentimentRatio: 0.5
        )
    }
    
    public func loadData() async {
        isLoading = true
        let sigs = await provider.fetchLiveMarketSignals()
        let sum = await provider.computeRadarSummary(from: sigs)
        self.signals = sigs
        self.summary = sum
        self.isLoading = false
    }
    
    public var filteredSignals: [MarketSignalItem] {
        signals.filter { item in
            // Filter by Category
            if let cat = config.selectedCategory, item.category != cat {
                return false
            }
            
            // Filter by Direction
            if let dir = config.selectedDirection {
                if dir == .bullish && !(item.direction == .bullish || item.direction == .strongBullish) {
                    return false
                }
                if dir == .bearish && !(item.direction == .bearish || item.direction == .strongBearish) {
                    return false
                }
            }
            
            // Filter by Min Strength Score
            if item.strengthScore < config.minStrengthScore {
                return false
            }
            
            // Filter by Search Text
            if !config.searchText.isEmpty {
                let query = config.searchText.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                let matchSymbol = item.symbol.uppercased().contains(query)
                let matchBase = item.baseAsset.uppercased().contains(query)
                let matchTitle = item.title.uppercased().contains(query)
                if !matchSymbol && !matchBase && !matchTitle {
                    return false
                }
            }
            
            return true
        }
    }
}

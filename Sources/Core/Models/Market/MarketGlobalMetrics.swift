import Foundation

public struct MarketGlobalMetrics: Sendable, Codable, Equatable {
    public var total24hVolumeUSDT: Double
    public var btcDominancePercent: Double
    public var ethDominancePercent: Double
    public var topGainersCount: Int
    public var topLosersCount: Int
    public var fearAndGreedIndex: Int
    public var fearAndGreedClassification: String
    public var lastUpdated: Date
    
    public init(
        total24hVolumeUSDT: Double,
        btcDominancePercent: Double,
        ethDominancePercent: Double,
        topGainersCount: Int,
        topLosersCount: Int,
        fearAndGreedIndex: Int = 60,
        fearAndGreedClassification: String = "Greed",
        lastUpdated: Date = Date()
    ) {
        self.total24hVolumeUSDT = total24hVolumeUSDT
        self.btcDominancePercent = btcDominancePercent
        self.ethDominancePercent = ethDominancePercent
        self.topGainersCount = topGainersCount
        self.topLosersCount = topLosersCount
        self.fearAndGreedIndex = fearAndGreedIndex
        self.fearAndGreedClassification = fearAndGreedClassification
        self.lastUpdated = lastUpdated
    }
}

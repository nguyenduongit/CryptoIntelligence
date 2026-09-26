import SwiftUI

public struct BubbleNode: Identifiable, Sendable {
    public let id: String // e.g. "BTCUSDT"
    public let symbol: String
    public let baseAsset: String
    public var price: Double
    public var priceChangePercent: Double
    public var quoteVolume: Double
    public var estimatedMarketCap: Double
    public var sector: CryptoSector
    
    // Physics Simulation State
    public var position: CGPoint
    public var velocity: CGPoint = .zero
    public var radius: CGFloat
    public var targetRadius: CGFloat
    public var phase: Double
    public var isPinned: Bool = false
    
    public var isBullish: Bool {
        priceChangePercent >= 0
    }
    
    public init(
        ticker: MarketTicker24h,
        position: CGPoint,
        radius: CGFloat,
        phase: Double = Double.random(in: 0...Double.pi * 2)
    ) {
        self.id = ticker.symbol
        self.symbol = ticker.symbol
        self.baseAsset = ticker.baseAsset
        self.price = ticker.price
        self.priceChangePercent = ticker.priceChangePercent
        self.quoteVolume = ticker.quoteVolume
        self.estimatedMarketCap = ticker.estimatedMarketCap
        self.sector = ticker.sector
        self.position = position
        self.radius = radius
        self.targetRadius = radius
        self.phase = phase
    }
    
    public func formattedSubMetric(for metric: BubbleSizingMetric) -> String {
        switch metric {
        case .marketCap:
            return Formatters.formatMarketCap(estimatedMarketCap)
        case .volume24h:
            return "$\(Formatters.formatVolume(quoteVolume))"
        case .priceChange:
            return Formatters.formatPrice(price)
        }
    }
}

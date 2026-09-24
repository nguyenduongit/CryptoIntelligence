import Foundation
import SwiftUI

// MARK: - Liquidation Side & Clusters
public enum LiquidationSide: String, Sendable, Codable {
    case longLiquidation = "Thanh Lý Long (Bán Ép / Long Squeeze)"
    case shortLiquidation = "Thanh Lý Short (Mua Ép / Short Squeeze)"
    
    public var color: Color {
        switch self {
        case .longLiquidation: return Color(red: 0.95, green: 0.35, blue: 0.25) // Orange/Red
        case .shortLiquidation: return Color(red: 0.15, green: 0.85, blue: 0.55) // Green/Cyan
        }
    }
}

public struct LiquidationCluster: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(priceLevel)_\(side.rawValue)" }
    public let priceLevel: Double
    public let volumeUSD: Double
    public let volumeToken: Double
    public let side: LiquidationSide
    public let leverageTier: String // "100x", "50x", "25x", "10x", "5x"
    public let intensity: Double // 0.0 to 1.0
    public let distancePercent: Double // e.g. -3.5% or +4.2%
    
    public init(
        priceLevel: Double,
        volumeUSD: Double,
        volumeToken: Double,
        side: LiquidationSide,
        leverageTier: String,
        intensity: Double,
        distancePercent: Double
    ) {
        self.priceLevel = priceLevel
        self.volumeUSD = volumeUSD
        self.volumeToken = volumeToken
        self.side = side
        self.leverageTier = leverageTier
        self.intensity = min(1.0, max(0.0, intensity))
        self.distancePercent = distancePercent
    }
}

public struct LiquidationHeatmapData: Sendable, Codable, Equatable {
    public let currentPriceUSD: Double
    public let totalLongLiquidationUSD: Double // e.g. $1.85B
    public let totalShortLiquidationUSD: Double // e.g. $2.14B
    public let maxPainPriceUSD: Double // Price level where maximum liquidations occur
    public let shortSqueezeTriggerPriceUSD: Double // Major cluster above
    public let longSqueezeTriggerPriceUSD: Double // Major cluster below
    public let clusters: [LiquidationCluster]
    
    public var liquidationImbalanceRatio: Double {
        guard totalLongLiquidationUSD > 0 else { return 1.0 }
        return totalShortLiquidationUSD / totalLongLiquidationUSD
    }
    
    public var primarySqueezeRisk: String {
        if liquidationImbalanceRatio > 1.3 {
            return "Nguy cơ Short Squeeze cao (Lượng thanh lý Short áp đảo phía trên)"
        } else if liquidationImbalanceRatio < 0.77 {
            return "Nguy cơ Long Squeeze cao (Lượng thanh lý Long áp đảo phía dưới)"
        } else {
            return "Thanh lý hai chiều cân bằng (Biến động biên độ hẹp)"
        }
    }
    
    public init(
        currentPriceUSD: Double,
        totalLongLiquidationUSD: Double,
        totalShortLiquidationUSD: Double,
        maxPainPriceUSD: Double,
        shortSqueezeTriggerPriceUSD: Double,
        longSqueezeTriggerPriceUSD: Double,
        clusters: [LiquidationCluster]
    ) {
        self.currentPriceUSD = currentPriceUSD
        self.totalLongLiquidationUSD = totalLongLiquidationUSD
        self.totalShortLiquidationUSD = totalShortLiquidationUSD
        self.maxPainPriceUSD = maxPainPriceUSD
        self.shortSqueezeTriggerPriceUSD = shortSqueezeTriggerPriceUSD
        self.longSqueezeTriggerPriceUSD = longSqueezeTriggerPriceUSD
        self.clusters = clusters
    }
}

// MARK: - Funding Rate & Arbitrage
public enum FundingSentiment: String, Sendable, Codable {
    case overheatedLong = "Quá Nhiệt Phe Long (Phí Cao)"
    case healthyLong = "Tích Cực Phe Long (Hợp Lý)"
    case neutral = "Cân Bằng (Trung Lập)"
    case negativeShort = "Phe Short Áp Đảo (Âm)"
    
    public var color: Color {
        switch self {
        case .overheatedLong: return AppTheme.downRed
        case .healthyLong: return AppTheme.upGreen
        case .neutral: return AppTheme.cyan
        case .negativeShort: return AppTheme.warningYellow
        }
    }
}

public struct FundingRateItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { exchangeName }
    public let exchangeName: String // "Binance", "Bybit", "OKX", "dYdX"
    public let currentRate8hPercent: Double // e.g. +0.0125%
    public let annualizedRatePercent: Double // e.g. +13.68%
    public let nextFundingCountdownMinutes: Int // e.g. 240
    public let sentiment: FundingSentiment
    
    public init(
        exchangeName: String,
        currentRate8hPercent: Double,
        annualizedRatePercent: Double,
        nextFundingCountdownMinutes: Int,
        sentiment: FundingSentiment
    ) {
        self.exchangeName = exchangeName
        self.currentRate8hPercent = currentRate8hPercent
        self.annualizedRatePercent = annualizedRatePercent
        self.nextFundingCountdownMinutes = nextFundingCountdownMinutes
        self.sentiment = sentiment
    }
}

public struct FundingRateHistoryPoint: Identifiable, Sendable, Codable, Equatable {
    public var id: String { dateLabel }
    public let dateLabel: String // e.g. "18/09 00h", "18/09 08h"
    public let rate8hPercent: Double // e.g. +0.0150
    public let priceUSD: Double
    
    public init(dateLabel: String, rate8hPercent: Double, priceUSD: Double) {
        self.dateLabel = dateLabel
        self.rate8hPercent = rate8hPercent
        self.priceUSD = priceUSD
    }
}

// MARK: - Open Interest & Long/Short Metrics
public struct OpenInterestMetrics: Sendable, Codable, Equatable {
    public let totalOpenInterestUSD: Double // e.g. $32.4B
    public let totalOpenInterestToken: Double // e.g. 485,000 BTC
    public let oiChange24hPercent: Double // e.g. +4.8%
    public let oiMarketCapRatio: Double // e.g. 2.4%
    public let globalLongAccountPercent: Double // e.g. 52.8%
    public let globalShortAccountPercent: Double // e.g. 47.2%
    public let topTraderLongPositionPercent: Double // e.g. 58.5%
    public let topTraderShortPositionPercent: Double // e.g. 41.5%
    
    public var isOIExpanding: Bool {
        oiChange24hPercent > 0
    }
    
    public init(
        totalOpenInterestUSD: Double,
        totalOpenInterestToken: Double,
        oiChange24hPercent: Double,
        oiMarketCapRatio: Double,
        globalLongAccountPercent: Double,
        globalShortAccountPercent: Double,
        topTraderLongPositionPercent: Double,
        topTraderShortPositionPercent: Double
    ) {
        self.totalOpenInterestUSD = totalOpenInterestUSD
        self.totalOpenInterestToken = totalOpenInterestToken
        self.oiChange24hPercent = oiChange24hPercent
        self.oiMarketCapRatio = oiMarketCapRatio
        self.globalLongAccountPercent = globalLongAccountPercent
        self.globalShortAccountPercent = globalShortAccountPercent
        self.topTraderLongPositionPercent = topTraderLongPositionPercent
        self.topTraderShortPositionPercent = topTraderShortPositionPercent
    }
}

// MARK: - Orderbook Wall Scanner
public enum OrderbookWallSide: String, Sendable, Codable {
    case bidWall = "Tường Mua (Bid Wall - Hỗ Trợ)"
    case askWall = "Tường Bán (Ask Wall - Kháng Cự)"
    
    public var color: Color {
        switch self {
        case .bidWall: return AppTheme.upGreen
        case .askWall: return AppTheme.downRed
        }
    }
}

public struct OrderbookWallItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(priceUSD)_\(side.rawValue)" }
    public let priceUSD: Double
    public let quantityToken: Double
    public let totalValueUSD: Double
    public let side: OrderbookWallSide
    public let distancePercent: Double // e.g. -1.8% or +2.4%
    public let depthPercent: Double // 0..100 (relative to largest wall)
    
    public init(
        priceUSD: Double,
        quantityToken: Double,
        totalValueUSD: Double,
        side: OrderbookWallSide,
        distancePercent: Double,
        depthPercent: Double
    ) {
        self.priceUSD = priceUSD
        self.quantityToken = quantityToken
        self.totalValueUSD = totalValueUSD
        self.side = side
        self.distancePercent = distancePercent
        self.depthPercent = min(100.0, max(0.0, depthPercent))
    }
}

// MARK: - Full Derivatives Profile
public struct DerivativesProfile: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public let heatmapData: LiquidationHeatmapData
    public let exchangeFundingRates: [FundingRateItem]
    public let fundingHistory: [FundingRateHistoryPoint]
    public let openInterest: OpenInterestMetrics
    public let orderbookWalls: [OrderbookWallItem]
    public let lastUpdated: Date
    
    public init(
        symbol: String,
        baseAsset: String,
        heatmapData: LiquidationHeatmapData,
        exchangeFundingRates: [FundingRateItem],
        fundingHistory: [FundingRateHistoryPoint],
        openInterest: OpenInterestMetrics,
        orderbookWalls: [OrderbookWallItem],
        lastUpdated: Date = Date()
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.heatmapData = heatmapData
        self.exchangeFundingRates = exchangeFundingRates
        self.fundingHistory = fundingHistory
        self.openInterest = openInterest
        self.orderbookWalls = orderbookWalls
        self.lastUpdated = lastUpdated
    }
}

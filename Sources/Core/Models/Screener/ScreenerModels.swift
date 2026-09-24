import Foundation
import SwiftUI

// MARK: - Signal Categories & Direction
public enum SignalCategory: String, Sendable, Codable, CaseIterable, Identifiable {
    case trendBreakout = "Đột Phá Xu Hướng (Breakout)"
    case volatilitySqueeze = "Bùng Nổ Biến Động (BB Squeeze)"
    case momentumRSI = "Xung Lượng & Phân Kỳ (RSI/MACD)"
    case volumeSpike = "Khối Lượng Bùng Nổ (Volume Spike)"
    case onChainWhale = "Cá Voi & Smart Money Gom (Whale Inflow)"
    case derivativesSqueeze = "Ép Thanh Lý & Funding (Short Squeeze)"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .trendBreakout: return "chart.line.uptrend.xyaxis"
        case .volatilitySqueeze: return "arrow.left.and.right.circle.fill"
        case .momentumRSI: return "waveform.path.ecg"
        case .volumeSpike: return "chart.bar.xaxis"
        case .onChainWhale: return "water.waves"
        case .derivativesSqueeze: return "bolt.horizontal.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .trendBreakout: return AppTheme.accentBlue
        case .volatilitySqueeze: return AppTheme.purple
        case .momentumRSI: return AppTheme.cyan
        case .volumeSpike: return AppTheme.warningYellow
        case .onChainWhale: return AppTheme.upGreen
        case .derivativesSqueeze: return AppTheme.orange
        }
    }
}

public enum SignalDirection: String, Sendable, Codable, CaseIterable, Identifiable {
    case strongBullish = "Tăng Mạnh (Strong Bullish)"
    case bullish = "Tích Cực (Bullish)"
    case neutral = "Trung Lập (Neutral)"
    case bearish = "Tiêu Cực (Bearish)"
    case strongBearish = "Giảm Mạnh (Strong Bearish)"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .strongBullish, .bullish: return AppTheme.upGreen
        case .neutral: return Color.white.opacity(0.6)
        case .bearish, .strongBearish: return AppTheme.downRed
        }
    }
}

// MARK: - Market Signal Item
public struct MarketSignalItem: Identifiable, Sendable, Codable, Equatable {
    public let id: String
    public let symbol: String
    public let baseAsset: String
    public let category: SignalCategory
    public let direction: SignalDirection
    public let strengthScore: Int // 0..100
    public let timeframe: String // e.g. "1H", "4H", "1D"
    public let triggerPriceUSD: Double
    public let currentPriceUSD: Double
    public let priceChange24h: Double
    public let volume24hUSD: Double
    public let title: String
    public let reason: String
    public let detectedAt: Date
    
    public init(
        id: String = UUID().uuidString,
        symbol: String,
        baseAsset: String,
        category: SignalCategory,
        direction: SignalDirection,
        strengthScore: Int,
        timeframe: String = "4H",
        triggerPriceUSD: Double,
        currentPriceUSD: Double,
        priceChange24h: Double,
        volume24hUSD: Double,
        title: String,
        reason: String,
        detectedAt: Date = Date()
    ) {
        self.id = id
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.category = category
        self.direction = direction
        self.strengthScore = strengthScore
        self.timeframe = timeframe
        self.triggerPriceUSD = triggerPriceUSD
        self.currentPriceUSD = currentPriceUSD
        self.priceChange24h = priceChange24h
        self.volume24hUSD = volume24hUSD
        self.title = title
        self.reason = reason
        self.detectedAt = detectedAt
    }
}

// MARK: - Screener Filter Config
public struct ScreenerFilterConfig: Sendable, Codable, Equatable {
    public var selectedCategory: SignalCategory? = nil
    public var selectedDirection: SignalDirection? = nil
    public var minVolume24hUSD: Double = 0.0
    public var minStrengthScore: Int = 50
    public var searchText: String = ""
    
    public init(
        selectedCategory: SignalCategory? = nil,
        selectedDirection: SignalDirection? = nil,
        minVolume24hUSD: Double = 0.0,
        minStrengthScore: Int = 50,
        searchText: String = ""
    ) {
        self.selectedCategory = selectedCategory
        self.selectedDirection = selectedDirection
        self.minVolume24hUSD = minVolume24hUSD
        self.minStrengthScore = minStrengthScore
        self.searchText = searchText
    }
}

// MARK: - Market Radar Summary
public struct MarketRadarSummary: Sendable, Codable, Equatable {
    public let totalSignalsScanned: Int
    public let bullishSignalsCount: Int
    public let bearishSignalsCount: Int
    public let neutralSignalsCount: Int
    public let topSqueezeCoins: [String]
    public let topWhaleAccumulationCoins: [String]
    public let marketSentimentRatio: Double // e.g. 0.72 (72% Bullish)
    
    public init(
        totalSignalsScanned: Int,
        bullishSignalsCount: Int,
        bearishSignalsCount: Int,
        neutralSignalsCount: Int,
        topSqueezeCoins: [String],
        topWhaleAccumulationCoins: [String],
        marketSentimentRatio: Double
    ) {
        self.totalSignalsScanned = totalSignalsScanned
        self.bullishSignalsCount = bullishSignalsCount
        self.bearishSignalsCount = bearishSignalsCount
        self.neutralSignalsCount = neutralSignalsCount
        self.topSqueezeCoins = topSqueezeCoins
        self.topWhaleAccumulationCoins = topWhaleAccumulationCoins
        self.marketSentimentRatio = marketSentimentRatio
    }
}

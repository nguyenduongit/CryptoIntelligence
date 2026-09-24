import Foundation
import SwiftUI

// MARK: - Central Bank Policy Model
public enum CentralBankStance: String, Codable, Sendable {
    case dovish = "Nới lỏng (Dovish)"
    case neutral = "Trung lập (Neutral)"
    case hawkish = "Thắt chặt (Hawkish)"
    
    public var badgeColor: Color {
        switch self {
        case .dovish: return AppTheme.upGreen
        case .neutral: return AppTheme.warningYellow
        case .hawkish: return AppTheme.downRed
        }
    }
}

public struct CentralBankPolicyItem: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let countryCode: String // US, EU, JP, CN, UK
    public let currentRate: Double // e.g. 4.75%
    public let previousRate: Double
    public let rateChangeBps: Int // e.g. -50 bps
    public let stance: CentralBankStance
    public let nextMeetingDate: String
    public let fedWatchCutProbability: Double? // e.g. 82.5%
    public let keyNotes: String
    
    public init(
        id: String,
        name: String,
        countryCode: String,
        currentRate: Double,
        previousRate: Double,
        rateChangeBps: Int,
        stance: CentralBankStance,
        nextMeetingDate: String,
        fedWatchCutProbability: Double? = nil,
        keyNotes: String
    ) {
        self.id = id
        self.name = name
        self.countryCode = countryCode
        self.currentRate = currentRate
        self.previousRate = previousRate
        self.rateChangeBps = rateChangeBps
        self.stance = stance
        self.nextMeetingDate = nextMeetingDate
        self.fedWatchCutProbability = fedWatchCutProbability
        self.keyNotes = keyNotes
    }
}

// MARK: - Inflation & Labor Metrics Model
public struct InflationReportItem: Identifiable, Sendable {
    public let id: String
    public let metricName: String // CPI YoY, Core CPI, PCE YoY, Core PCE, PPI
    public let latestValue: Double // e.g. 2.5%
    public let previousValue: Double
    public let forecastValue: Double
    public let targetValue: Double // 2.0%
    public let releaseDate: String
    public let trend: String // "Giảm", "Tăng", "Đi ngang"
    
    public var isBetterThanForecast: Bool {
        latestValue <= forecastValue
    }
    
    public init(
        id: String,
        metricName: String,
        latestValue: Double,
        previousValue: Double,
        forecastValue: Double,
        targetValue: Double = 2.0,
        releaseDate: String,
        trend: String
    ) {
        self.id = id
        self.metricName = metricName
        self.latestValue = latestValue
        self.previousValue = previousValue
        self.forecastValue = forecastValue
        self.targetValue = targetValue
        self.releaseDate = releaseDate
        self.trend = trend
    }
}

// MARK: - Global Liquidity & M2 Data Point
public struct GlobalLiquidityM2Point: Identifiable, Sendable {
    public let id = UUID()
    public let timestamp: Int64
    public let dateString: String // "Q1 2024" or "MM/YY"
    public let globalM2Trillions: Double // e.g. 108.5 ($T)
    public let btcPriceUSD: Double // e.g. 65000
    public let fedBalanceSheetTrillions: Double // e.g. 6.8 ($T)
    
    public init(timestamp: Int64, dateString: String, globalM2Trillions: Double, btcPriceUSD: Double, fedBalanceSheetTrillions: Double) {
        self.timestamp = timestamp
        self.dateString = dateString
        self.globalM2Trillions = globalM2Trillions
        self.btcPriceUSD = btcPriceUSD
        self.fedBalanceSheetTrillions = fedBalanceSheetTrillions
    }
}

// MARK: - Cross-Asset Market Ticker
public enum CrossAssetCategory: String, CaseIterable, Identifiable, Sendable {
    case currencies = "Tiền tệ & Chỉ số USD"
    case commodities = "Hàng hóa (Vàng, Dầu)"
    case bonds = "Trái phiếu & Lợi suất"
    case equities = "Chứng khoán Mỹ"
    
    public var id: String { rawValue }
}

public struct CrossAssetTickerItem: Identifiable, Sendable {
    public let id: String
    public let symbol: String
    public let name: String
    public let category: CrossAssetCategory
    public let currentPrice: Double
    public let priceUnit: String // "USD", "pts", "%"
    public let change24h: Double
    public let change30d: Double
    public let correlationWithBTC_30d: Double // -1.0 to +1.0
    public let correlationWithBTC_90d: Double
    public let iconName: String
    public let note: String
    
    public init(
        id: String,
        symbol: String,
        name: String,
        category: CrossAssetCategory,
        currentPrice: Double,
        priceUnit: String,
        change24h: Double,
        change30d: Double,
        correlationWithBTC_30d: Double,
        correlationWithBTC_90d: Double,
        iconName: String,
        note: String
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.category = category
        self.currentPrice = currentPrice
        self.priceUnit = priceUnit
        self.change24h = change24h
        self.change30d = change30d
        self.correlationWithBTC_30d = correlationWithBTC_30d
        self.correlationWithBTC_90d = correlationWithBTC_90d
        self.iconName = iconName
        self.note = note
    }
    
    public var correlationColor: Color {
        if correlationWithBTC_30d > 0.4 {
            return AppTheme.upGreen
        } else if correlationWithBTC_30d < -0.4 {
            return AppTheme.downRed
        } else {
            return AppTheme.warningYellow
        }
    }
}

// MARK: - Macro Economic Calendar Event
public enum EventImpactLevel: String, Sendable {
    case high = "Cao (High 🔴)"
    case medium = "Trung bình (Med 🟡)"
    case low = "Thấp (Low 🟢)"
    
    public var badgeColor: Color {
        switch self {
        case .high: return AppTheme.downRed
        case .medium: return AppTheme.warningYellow
        case .low: return AppTheme.upGreen
        }
    }
}

public enum CryptoMarketImpact: String, Sendable {
    case bullish = "Tăng giá (Bullish 🚀)"
    case bearish = "Giảm giá (Bearish ⚠️)"
    case neutral = "Trung lập (Neutral ⚖️)"
    case volatilityAlert = "Biến động mạnh (High Volatility ⚡)"
    
    public var badgeColor: Color {
        switch self {
        case .bullish: return AppTheme.upGreen
        case .bearish: return AppTheme.downRed
        case .neutral: return Color.white.opacity(0.6)
        case .volatilityAlert: return AppTheme.purple
        }
    }
}

public struct EconomicEventItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let country: String
    public let dateString: String
    public let timeString: String
    public let impactLevel: EventImpactLevel
    public let actual: String?
    public let forecast: String?
    public let previous: String?
    public let cryptoImpact: CryptoMarketImpact
    public let analysis: String
    
    public init(
        id: String,
        title: String,
        country: String,
        dateString: String,
        timeString: String,
        impactLevel: EventImpactLevel,
        actual: String? = nil,
        forecast: String? = nil,
        previous: String? = nil,
        cryptoImpact: CryptoMarketImpact,
        analysis: String
    ) {
        self.id = id
        self.title = title
        self.country = country
        self.dateString = dateString
        self.timeString = timeString
        self.impactLevel = impactLevel
        self.actual = actual
        self.forecast = forecast
        self.previous = previous
        self.cryptoImpact = cryptoImpact
        self.analysis = analysis
    }
}

// MARK: - Global Macro Overview Aggregate
public struct GlobalMacroOverviewData: Sendable {
    public let centralBanks: [CentralBankPolicyItem]
    public let inflationMetrics: [InflationReportItem]
    public let unemploymentRate: Double // e.g. 4.2%
    public let nonFarmPayrollsK: Double // e.g. +142K
    public let m2History: [GlobalLiquidityM2Point]
    public let crossAssets: [CrossAssetTickerItem]
    public let upcomingEvents: [EconomicEventItem]
    public let macroRiskScore: Int // 0 (Extreme Risk-Off) to 100 (Extreme Risk-On)
    public let macroSentimentSummary: String
    public let lastUpdated: Date
    
    public init(
        centralBanks: [CentralBankPolicyItem],
        inflationMetrics: [InflationReportItem],
        unemploymentRate: Double,
        nonFarmPayrollsK: Double,
        m2History: [GlobalLiquidityM2Point],
        crossAssets: [CrossAssetTickerItem],
        upcomingEvents: [EconomicEventItem],
        macroRiskScore: Int,
        macroSentimentSummary: String,
        lastUpdated: Date = Date()
    ) {
        self.centralBanks = centralBanks
        self.inflationMetrics = inflationMetrics
        self.unemploymentRate = unemploymentRate
        self.nonFarmPayrollsK = nonFarmPayrollsK
        self.m2History = m2History
        self.crossAssets = crossAssets
        self.upcomingEvents = upcomingEvents
        self.macroRiskScore = macroRiskScore
        self.macroSentimentSummary = macroSentimentSummary
        self.lastUpdated = lastUpdated
    }
}

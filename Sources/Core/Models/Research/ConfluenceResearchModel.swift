import Foundation
import SwiftUI

// MARK: - Recommendation Stance
public enum ConfluenceRecommendation: String, Sendable, Codable, CaseIterable {
    case strongBuy = "MUA MẠNH (Strong Buy)"
    case accumulate = "TÍCH LŨY VÙNG GIÁ (Accumulate)"
    case watch = "QUAN SÁT (Neutral / Watch)"
    case takeProfit = "HẠ TỶ TRỌNG / CHỐT LỜI (Take Profit)"
    case highRisk = "RỦI RO CAO / TRÁNH MUA (High Risk)"
    
    public var badgeColor: Color {
        switch self {
        case .strongBuy: return AppTheme.upGreen
        case .accumulate: return AppTheme.cyan
        case .watch: return AppTheme.warningYellow
        case .takeProfit: return Color(red: 0.95, green: 0.5, blue: 0.2)
        case .highRisk: return AppTheme.downRed
        }
    }
    
    public var iconName: String {
        switch self {
        case .strongBuy: return "bolt.shield.fill"
        case .accumulate: return "cart.fill.badge.plus"
        case .watch: return "eye.fill"
        case .takeProfit: return "arrow.down.right.circle.fill"
        case .highRisk: return "exclamationmark.octagon.fill"
        }
    }
}

// MARK: - Pillar Types & Scores
public enum PillarType: String, Sendable, Codable, CaseIterable, Identifiable {
    case technical = "Kỹ Thuật & Động Lượng (Technical 20%)"
    case onchainETF = "On-Chain & Dòng Vốn ETF (25%)"
    case tokenomics = "Tokenomics & Áp Lực Cung (20%)"
    case macro = "Vĩ Mô & Thanh Khoản M2 (20%)"
    case smartMoney = "Smart Money & Cá Voi (15%)"
    
    public var id: String { rawValue }
    
    public var shortName: String {
        switch self {
        case .technical: return "Kỹ thuật (20%)"
        case .onchainETF: return "On-chain & ETF (25%)"
        case .tokenomics: return "Tokenomics (20%)"
        case .macro: return "Vĩ mô & M2 (20%)"
        case .smartMoney: return "Cá voi (15%)"
        }
    }
    
    public var weight: Double {
        switch self {
        case .technical: return 0.20
        case .onchainETF: return 0.25
        case .tokenomics: return 0.20
        case .macro: return 0.20
        case .smartMoney: return 0.15
        }
    }
    
    public var iconName: String {
        switch self {
        case .technical: return "waveform.path.ecg"
        case .onchainETF: return "link.circle.fill"
        case .tokenomics: return "circle.hexagongrid.fill"
        case .macro: return "globe.americas.fill"
        case .smartMoney: return "water.waves"
        }
    }
}

public enum PillarSignal: String, Sendable, Codable {
    case strongBullish = "Rất Tích Cực"
    case bullish = "Tích Cực"
    case neutral = "Trung Lập"
    case bearish = "Tiêu Cực"
    case strongBearish = "Rất Tiêu Cực"
    
    public var color: Color {
        switch self {
        case .strongBullish: return AppTheme.upGreen
        case .bullish: return AppTheme.cyan
        case .neutral: return AppTheme.warningYellow
        case .bearish: return Color(red: 0.95, green: 0.45, blue: 0.2)
        case .strongBearish: return AppTheme.downRed
        }
    }
}

public struct PillarScoreItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { pillar.rawValue }
    public let pillar: PillarType
    public let score: Int // 0..100
    public let signal: PillarSignal
    public let summary: String
    
    public var weightedContribution: Double {
        Double(score) * pillar.weight
    }
    
    public init(pillar: PillarType, score: Int, signal: PillarSignal, summary: String) {
        self.pillar = pillar
        self.score = min(100, max(0, score))
        self.signal = signal
        self.summary = summary
    }
}

// MARK: - Scenario Projections (Bull / Base / Bear)
public enum ScenarioType: String, Sendable, Codable {
    case bullCase = "Kịch Bản Lạc Quan (Bull Case)"
    case baseCase = "Kịch Bản Cơ Sở (Base Case)"
    case bearCase = "Kịch Bản Rủi Ro (Bear Case)"
    
    public var color: Color {
        switch self {
        case .bullCase: return AppTheme.upGreen
        case .baseCase: return AppTheme.cyan
        case .bearCase: return AppTheme.downRed
        }
    }
    
    public var iconName: String {
        switch self {
        case .bullCase: return "arrow.up.forward.circle.fill"
        case .baseCase: return "arrow.right.circle.fill"
        case .bearCase: return "arrow.down.forward.circle.fill"
        }
    }
}

public struct ScenarioProjection: Identifiable, Sendable, Codable, Equatable {
    public var id: String { scenarioType.rawValue }
    public let scenarioType: ScenarioType
    public let targetPriceUSD: Double
    public let expectedReturnPercent: Double // e.g. +45.2% or -18.5%
    public let probabilityPercent: Int // e.g. 60%
    public let keyDrivers: [String]
    
    public init(
        scenarioType: ScenarioType,
        targetPriceUSD: Double,
        expectedReturnPercent: Double,
        probabilityPercent: Int,
        keyDrivers: [String]
    ) {
        self.scenarioType = scenarioType
        self.targetPriceUSD = targetPriceUSD
        self.expectedReturnPercent = expectedReturnPercent
        self.probabilityPercent = probabilityPercent
        self.keyDrivers = keyDrivers
    }
}

// MARK: - Trade & Allocation Execution Plan
public struct TradeExecutionPlan: Sendable, Codable, Equatable {
    public let optimalDCAMinUSD: Double
    public let optimalDCAMaxUSD: Double
    public let recommendedAllocationPercent: Double // e.g. 15.0% of portfolio
    public let stopLossPriceUSD: Double
    public let takeProfit1USD: Double
    public let takeProfit2USD: Double
    public let riskRewardRatio: Double // e.g. 3.4
    public let timeHorizonMonths: Int // e.g. 6-12 months
    
    public var isAttractiveRiskReward: Bool {
        riskRewardRatio >= 2.0
    }
    
    public init(
        optimalDCAMinUSD: Double,
        optimalDCAMaxUSD: Double,
        recommendedAllocationPercent: Double,
        stopLossPriceUSD: Double,
        takeProfit1USD: Double,
        takeProfit2USD: Double,
        riskRewardRatio: Double,
        timeHorizonMonths: Int
    ) {
        self.optimalDCAMinUSD = optimalDCAMinUSD
        self.optimalDCAMaxUSD = optimalDCAMaxUSD
        self.recommendedAllocationPercent = recommendedAllocationPercent
        self.stopLossPriceUSD = stopLossPriceUSD
        self.takeProfit1USD = takeProfit1USD
        self.takeProfit2USD = takeProfit2USD
        self.riskRewardRatio = riskRewardRatio
        self.timeHorizonMonths = timeHorizonMonths
    }
}

// MARK: - Full Confluence Research Report
public struct ConfluenceResearchReport: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public let currentPriceUSD: Double
    public let overallScore: Int // 0..100
    public let recommendation: ConfluenceRecommendation
    public let thesisSummary: String
    public let pillars: [PillarScoreItem]
    public let scenarios: [ScenarioProjection]
    public let tradePlan: TradeExecutionPlan
    public let keyCatalysts: [String]
    public let keyRisks: [String]
    public let generatedAt: Date
    
    public init(
        symbol: String,
        baseAsset: String,
        currentPriceUSD: Double,
        overallScore: Int,
        recommendation: ConfluenceRecommendation,
        thesisSummary: String,
        pillars: [PillarScoreItem],
        scenarios: [ScenarioProjection],
        tradePlan: TradeExecutionPlan,
        keyCatalysts: [String],
        keyRisks: [String],
        generatedAt: Date = Date()
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.currentPriceUSD = currentPriceUSD
        self.overallScore = overallScore
        self.recommendation = recommendation
        self.thesisSummary = thesisSummary
        self.pillars = pillars
        self.scenarios = scenarios
        self.tradePlan = tradePlan
        self.keyCatalysts = keyCatalysts
        self.keyRisks = keyRisks
        self.generatedAt = generatedAt
    }
}

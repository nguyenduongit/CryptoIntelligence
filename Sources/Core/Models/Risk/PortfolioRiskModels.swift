import Foundation
import SwiftUI

// MARK: - Historical Crisis Scenario
public struct HistoricalCrisisScenario: Sendable, Codable, Equatable, Identifiable {
    public var id: String
    public let name: String
    public let dateRange: String
    public let marketDropPercent: Double
    public let description: String
    public let historicalRecoveryDays: Int
    
    public init(
        id: String,
        name: String,
        dateRange: String,
        marketDropPercent: Double,
        description: String,
        historicalRecoveryDays: Int
    ) {
        self.id = id
        self.name = name
        self.dateRange = dateRange
        self.marketDropPercent = marketDropPercent
        self.description = description
        self.historicalRecoveryDays = historicalRecoveryDays
    }
}

// MARK: - Crisis Stress Result
public struct CrisisStressResult: Sendable, Codable, Equatable, Identifiable {
    public var id: String { scenario.id }
    public let scenario: HistoricalCrisisScenario
    public let positionSizeUSD: Double
    public let projectedLossUSD: Double
    public let projectedDrawdownPercent: Double
    public let safeMaxLeverage: Double
    public let isCriticalRisk: Bool
    
    public init(
        scenario: HistoricalCrisisScenario,
        positionSizeUSD: Double,
        projectedLossUSD: Double,
        projectedDrawdownPercent: Double,
        safeMaxLeverage: Double,
        isCriticalRisk: Bool
    ) {
        self.scenario = scenario
        self.positionSizeUSD = positionSizeUSD
        self.projectedLossUSD = projectedLossUSD
        self.projectedDrawdownPercent = projectedDrawdownPercent
        self.safeMaxLeverage = safeMaxLeverage
        self.isCriticalRisk = isCriticalRisk
    }
}

// MARK: - Value At Risk Metrics
public struct ValueAtRiskMetrics: Sendable, Codable, Equatable {
    public let positionSizeUSD: Double
    public let var95DailyUSD: Double
    public let var95DailyPercent: Double
    public let var99DailyUSD: Double
    public let var99DailyPercent: Double
    public let expectedShortfallCVaRUSD: Double
    public let expectedShortfallPercent: Double
    public let annualizedVolatility: Double
    public let confidenceRating: String
    
    public init(
        positionSizeUSD: Double,
        var95DailyUSD: Double,
        var95DailyPercent: Double,
        var99DailyUSD: Double,
        var99DailyPercent: Double,
        expectedShortfallCVaRUSD: Double,
        expectedShortfallPercent: Double,
        annualizedVolatility: Double,
        confidenceRating: String
    ) {
        self.positionSizeUSD = positionSizeUSD
        self.var95DailyUSD = var95DailyUSD
        self.var95DailyPercent = var95DailyPercent
        self.var99DailyUSD = var99DailyUSD
        self.var99DailyPercent = var99DailyPercent
        self.expectedShortfallCVaRUSD = expectedShortfallCVaRUSD
        self.expectedShortfallPercent = expectedShortfallPercent
        self.annualizedVolatility = annualizedVolatility
        self.confidenceRating = confidenceRating
    }
}

// MARK: - Risk Parity & Kelly Sizing
public struct RiskParitySizing: Sendable, Codable, Equatable {
    public let baseAsset: String
    public let currentPriceUSD: Double
    public let recommendedPortfolioWeightPercent: Double
    public let maxAllocationUSD: Double
    public let halfKellyFractionPercent: Double
    public let sizingRational: String
    
    public init(
        baseAsset: String,
        currentPriceUSD: Double,
        recommendedPortfolioWeightPercent: Double,
        maxAllocationUSD: Double,
        halfKellyFractionPercent: Double,
        sizingRational: String
    ) {
        self.baseAsset = baseAsset
        self.currentPriceUSD = currentPriceUSD
        self.recommendedPortfolioWeightPercent = recommendedPortfolioWeightPercent
        self.maxAllocationUSD = maxAllocationUSD
        self.halfKellyFractionPercent = halfKellyFractionPercent
        self.sizingRational = sizingRational
    }
}

// MARK: - Complete Portfolio Risk Profile
public struct PortfolioRiskProfile: Sendable, Codable, Equatable {
    public let symbol: String
    public let timestamp: Date
    public let varMetrics: ValueAtRiskMetrics
    public let stressScenarios: [CrisisStressResult]
    public let sizing: RiskParitySizing
    
    public init(
        symbol: String,
        timestamp: Date,
        varMetrics: ValueAtRiskMetrics,
        stressScenarios: [CrisisStressResult],
        sizing: RiskParitySizing
    ) {
        self.symbol = symbol
        self.timestamp = timestamp
        self.varMetrics = varMetrics
        self.stressScenarios = stressScenarios
        self.sizing = sizing
    }
}

import Testing
import Foundation
@testable import CryptoResearch

@Suite("ConfluenceResearchTests")
struct ConfluenceResearchTests {
    
    @Test("Test 5 Pillar weights sum to 100%")
    func testPillarWeightsSumToOne() {
        let totalWeight = PillarType.allCases.reduce(0.0) { $0 + $1.weight }
        #expect(abs(totalWeight - 1.0) < 0.0001)
    }
    
    @Test("Test PillarScoreItem weighted contribution")
    func testWeightedContributionCalculation() {
        let techPillar = PillarScoreItem(
            pillar: .technical,
            score: 80,
            signal: .strongBullish,
            summary: "Strong breakout"
        )
        // 80 * 0.20 = 16.0
        #expect(abs(techPillar.weightedContribution - 16.0) < 0.001)
        
        let onChainPillar = PillarScoreItem(
            pillar: .onchainETF,
            score: 90,
            signal: .strongBullish,
            summary: "High ETF Inflows"
        )
        // 90 * 0.25 = 22.5
        #expect(abs(onChainPillar.weightedContribution - 22.5) < 0.001)
    }
    
    @Test("Test ScenarioProjection properties and return calculations")
    func testScenarioProjectionCalculations() {
        let bullScenario = ScenarioProjection(
            scenarioType: .bullCase,
            targetPriceUSD: 100_000,
            expectedReturnPercent: 50.0,
            probabilityPercent: 55,
            keyDrivers: ["ETF Inflows", "Halving Supply Squeeze"]
        )
        
        #expect(bullScenario.targetPriceUSD == 100_000)
        #expect(bullScenario.expectedReturnPercent == 50.0)
        #expect(bullScenario.probabilityPercent == 55)
        #expect(bullScenario.keyDrivers.count == 2)
    }
    
    @Test("Test TradeExecutionPlan risk reward logic")
    func testTradeExecutionPlanProperties() {
        let plan = TradeExecutionPlan(
            optimalDCAMinUSD: 60_000,
            optimalDCAMaxUSD: 65_000,
            recommendedAllocationPercent: 25.0,
            stopLossPriceUSD: 54_000,
            takeProfit1USD: 90_000,
            takeProfit2USD: 120_000,
            riskRewardRatio: 3.2,
            timeHorizonMonths: 12
        )
        
        #expect(plan.isAttractiveRiskReward == true)
        #expect(plan.recommendedAllocationPercent == 25.0)
        #expect(plan.stopLossPriceUSD == 54_000)
    }
    
    @Test("Test ConfluenceResearchEngine generates full report for BTC")
    func testConfluenceResearchEngineBTC() async throws {
        let engine = ConfluenceResearchEngine.shared
        let report = try await engine.generateResearchReport(for: "BTCUSDT")
        
        #expect(report.symbol == "BTCUSDT")
        #expect(report.baseAsset == "BTC")
        #expect(report.overallScore > 0 && report.overallScore <= 100)
        #expect(report.pillars.count == 5)
        #expect(report.scenarios.count == 3)
        #expect(!report.keyCatalysts.isEmpty)
        #expect(!report.keyRisks.isEmpty)
        #expect(report.tradePlan.riskRewardRatio > 0)
    }
    
    @Test("Test Scenario projections calibrate mathematically to confluence score")
    func testScenarioExpectationCalibratedToScore() async throws {
        let engine = ConfluenceResearchEngine.shared
        
        // When report is generated, verify scenario probabilities sum to 100%
        let report = try await engine.generateResearchReport(for: "BTCUSDT")
        let totalProb = report.scenarios.reduce(0) { $0 + $1.probabilityPercent }
        #expect(totalProb == 100)
        
        // Macro pillar summary should not be hardcoded static text
        if let macroPillar = report.pillars.first(where: { $0.pillar == .macro }) {
            #expect(!macroPillar.summary.isEmpty)
            // Summary should reflect the score state
            if macroPillar.score >= 75 {
                #expect(macroPillar.summary.contains("nới lỏng"))
            }
        }
    }
}

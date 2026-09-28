import Testing
import Foundation
@testable import CryptoResearch

@Suite("PortfolioRiskStressTests")
struct PortfolioRiskStressTests {
    
    @Test("Test ValueAtRiskMetrics creation and scaling")
    func testValueAtRiskMetrics() {
        let metrics = ValueAtRiskMetrics(
            positionSizeUSD: 1_000_000.0,
            var95DailyUSD: 32_000.0,
            var95DailyPercent: 3.2,
            var99DailyUSD: 48_000.0,
            var99DailyPercent: 4.8,
            expectedShortfallCVaRUSD: 60_000.0,
            expectedShortfallPercent: 6.0,
            annualizedVolatility: 55.0,
            confidenceRating: "Cao"
        )
        
        #expect(metrics.positionSizeUSD == 1_000_000.0)
        #expect(metrics.var95DailyPercent == 3.2)
        #expect(metrics.var99DailyPercent > metrics.var95DailyPercent)
        #expect(metrics.expectedShortfallPercent > metrics.var99DailyPercent)
    }
    
    @Test("Test HistoricalCrisisScenario and CrisisStressResult")
    func testCrisisStressResult() {
        let scenario = HistoricalCrisisScenario(
            id: "covid",
            name: "COVID-19 Flash Crash",
            dateRange: "12-13/03/2020",
            marketDropPercent: 50.0,
            description: "Toàn cầu bán tháo",
            historicalRecoveryDays: 52
        )
        
        let result = CrisisStressResult(
            scenario: scenario,
            positionSizeUSD: 2_000_000.0,
            projectedLossUSD: 1_000_000.0,
            projectedDrawdownPercent: 50.0,
            safeMaxLeverage: 1.7,
            isCriticalRisk: false
        )
        
        #expect(result.id == "covid")
        #expect(result.projectedLossUSD == 1_000_000.0)
        #expect(result.projectedDrawdownPercent == 50.0)
        #expect(result.safeMaxLeverage == 1.7)
    }
    
    @Test("Test PortfolioRiskEngine live analysis and dynamic capital recalculation")
    func testPortfolioRiskEngineLiveAnalysis() async {
        let engine = PortfolioRiskEngine.shared
        let profile = await engine.analyzePortfolioRisk(for: "BTCUSDT", assumedCapitalUSD: 1_000_000.0)
        
        #expect(profile.symbol == "BTCUSDT")
        #expect(profile.varMetrics.positionSizeUSD == 1_000_000.0)
        #expect(profile.varMetrics.var95DailyUSD > 0)
        #expect(profile.stressScenarios.count == 4)
        #expect(profile.sizing.recommendedPortfolioWeightPercent > 0)
        
        // Recalculate with 5M USD
        let scaledProfile = engine.recalculateWithCapital(baseProfile: profile, newCapitalUSD: 5_000_000.0)
        #expect(scaledProfile.varMetrics.positionSizeUSD == 5_000_000.0)
        #expect(abs(scaledProfile.varMetrics.var95DailyUSD - profile.varMetrics.var95DailyUSD * 5.0) < 0.01)
        #expect(abs(scaledProfile.stressScenarios.first!.projectedLossUSD - profile.stressScenarios.first!.projectedLossUSD * 5.0) < 0.01)
    }
}

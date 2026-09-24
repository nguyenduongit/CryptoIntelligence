import Testing
import Foundation
@testable import CryptoResearch

@Suite("GlobalMacroTests")
struct GlobalMacroTests {
    
    @Test("Test CentralBankPolicy model properties and stance")
    func testCentralBankPolicyProperties() {
        let fed = CentralBankPolicyItem(
            id: "fed",
            name: "Federal Reserve",
            countryCode: "US",
            currentRate: 4.875,
            previousRate: 5.375,
            rateChangeBps: -50,
            stance: .dovish,
            nextMeetingDate: "18/12/2026",
            fedWatchCutProbability: 84.5,
            keyNotes: "Econ Easing"
        )
        
        #expect(fed.countryCode == "US")
        #expect(fed.currentRate == 4.875)
        #expect(fed.rateChangeBps == -50)
        #expect(fed.stance == .dovish)
        #expect(fed.fedWatchCutProbability == 84.5)
    }
    
    @Test("Test InflationReportItem comparison and target gap")
    func testInflationReportItemCalculations() {
        let cpi = InflationReportItem(
            id: "cpi",
            metricName: "US Headline CPI",
            latestValue: 2.5,
            previousValue: 2.9,
            forecastValue: 2.6,
            targetValue: 2.0,
            releaseDate: "11/10/2026",
            trend: "Hạ nhiệt"
        )
        
        #expect(cpi.latestValue == 2.5)
        #expect(cpi.isBetterThanForecast == true) // 2.5 <= 2.6
        #expect(cpi.latestValue - cpi.targetValue == 0.5) // Gap to 2% target
    }
    
    @Test("Test CrossAssetTickerItem correlation calculations")
    func testCrossAssetCorrelations() {
        let dxy = CrossAssetTickerItem(
            id: "dxy",
            symbol: "DXY",
            name: "Dollar Index",
            category: .currencies,
            currentPrice: 100.85,
            priceUnit: "pts",
            change24h: -0.42,
            change30d: -2.35,
            correlationWithBTC_30d: -0.72,
            correlationWithBTC_90d: -0.68,
            iconName: "dollarsign.circle",
            note: "Inversely correlated"
        )
        
        #expect(dxy.correlationWithBTC_30d < -0.4) // Strong negative correlation
        
        let gold = CrossAssetTickerItem(
            id: "gold",
            symbol: "XAU/USD",
            name: "Spot Gold",
            category: .commodities,
            currentPrice: 2658.0,
            priceUnit: "USD/oz",
            change24h: 1.2,
            change30d: 5.4,
            correlationWithBTC_30d: 0.68,
            correlationWithBTC_90d: 0.62,
            iconName: "sparkles",
            note: "Positive correlation"
        )
        
        #expect(gold.correlationWithBTC_30d > 0.4) // Strong positive correlation
    }
    
    @Test("Test GlobalMacroDataProvider retrieval and risk score")
    func testGlobalMacroDataProvider() {
        let data = GlobalMacroDataProvider.shared.fetchGlobalMacroData()
        
        #expect(!data.centralBanks.isEmpty)
        #expect(data.centralBanks.contains { $0.countryCode == "US" })
        #expect(data.centralBanks.contains { $0.countryCode == "EU" })
        #expect(data.centralBanks.contains { $0.countryCode == "JP" })
        
        #expect(!data.inflationMetrics.isEmpty)
        #expect(data.unemploymentRate == 4.2)
        #expect(data.nonFarmPayrollsK == 142.0)
        
        #expect(!data.m2History.isEmpty)
        let latestM2 = data.m2History.last
        #expect(latestM2?.globalM2Trillions ?? 0.0 > 100.0)
        
        #expect(!data.crossAssets.isEmpty)
        #expect(!data.upcomingEvents.isEmpty)
        #expect(data.macroRiskScore >= 0 && data.macroRiskScore <= 100)
    }
}

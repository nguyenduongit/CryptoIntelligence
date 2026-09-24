import Testing
import Foundation
@testable import CryptoResearch

@Suite("OnChainCycleTests")
struct OnChainCycleTests {
    
    @Test("Test MVRV Cycle calculations and indicators")
    func testMVRVCycleCalculations() {
        let metrics = MVRVCycleMetrics(
            mvrvZScore: 2.14,
            realizedPriceUSD: 34_850.0,
            currentPriceUSD: 69_700.0,
            nupl: 0.54,
            puellMultiple: 1.18,
            piCycle111DMA: 65_000.0,
            piCycle2x350DMA: 97_500.0,
            cyclePhase: "Giữa chu kỳ tăng trưởng",
            cycleRiskScore: 0.44
        )
        
        // MVRV Ratio = 69700 / 34850 = 2.0
        #expect(abs(metrics.mvrvRatio - 2.0) < 0.001)
        
        // Pi Cycle Gap = (97500 - 65000) / 65000 * 100 = 50.0%
        #expect(abs(metrics.piCycleGapPercent - 50.0) < 0.001)
        #expect(metrics.isPiCycleCrossed == false)
        
        // NUPL 0.54 falls into "Niềm tin / Hưng phấn vừa (Belief)"
        #expect(metrics.nuplSentiment.label.contains("Niềm tin"))
    }
    
    @Test("Test LTH vs STH Supply Distribution calculations")
    func testLTHSupplyDistributionCalculations() {
        let supply = LTHSupplyMetrics(
            longTermHolderSupply: 14_800_000,
            shortTermHolderSupply: 3_200_000,
            exchangeReserveSupply: 2_000_000,
            totalSupply: 20_000_000,
            lth30dNetChangeToken: 42_500,
            sthRealizedPriceUSD: 61_200.0
        )
        
        #expect(abs(supply.lthPercentage - 74.0) < 0.01)
        #expect(abs(supply.sthPercentage - 16.0) < 0.01)
        #expect(abs(supply.exchangePercentage - 10.0) < 0.01)
        #expect(supply.isLTHAccumulating == true)
    }
    
    @Test("Test Spot ETF Flow Summary aggregations")
    func testSpotETFFlowSummary() {
        let items: [SpotETFFlowItem] = [
            SpotETFFlowItem(
                ticker: "IBIT",
                fundName: "iShares Bitcoin Trust",
                sponsor: "BlackRock",
                aumUSD: 24_800_000_000,
                btcHoldings: 368_000,
                netFlow24hUSD: 125_000_000,
                netFlow24hBTC: 1_880,
                cumulativeNetInflowUSD: 21_200_000_000,
                feePercent: 0.25,
                streakDays: 8
            )
        ]
        
        let summary = SpotETFFlowSummary(
            totalAUMUSD: 65_400_000_000,
            totalBTCHeld: 985_000,
            totalNetFlow24hUSD: 185_400_000,
            totalNetFlow24hBTC: 2_780,
            totalCumulativeInflowsUSD: 22_800_000_000,
            topInflowETF: "BlackRock (IBIT)",
            history14Days: [DailyFlowDataPoint(dateString: "20/09", netFlowUSD: 185.4)],
            etfList: items
        )
        
        #expect(summary.etfList.count == 1)
        #expect(summary.etfList[0].ticker == "IBIT")
        #expect(summary.totalAUMUSD == 65_400_000_000)
        #expect(summary.history14Days.count == 1)
    }
    
    @Test("Test Entity Whale Holding model properties")
    func testEntityWhaleHoldings() {
        let entity = EntityWhaleHolding(
            entityName: "MicroStrategy",
            category: .corporate,
            holdingsToken: 252_220,
            holdingsUSD: 16_750_000_000,
            avgPurchasePriceUSD: 39_266,
            unrealizedPnLUSD: 6_850_000_000,
            change30dToken: 18_300,
            addressSnippet: "1P5ZEDWT...",
            riskSignal: "Tích lũy trái phiếu"
        )
        
        #expect(entity.category == .corporate)
        #expect(entity.holdingsToken == 252_220)
        #expect(entity.change30dToken == 18_300)
    }
    
    @Test("Test OnChainDataProvider profile for BTC includes cycle metrics")
    func testOnChainDataProviderBTC() async throws {
        let provider = OnChainDataProvider.shared
        let profile = try await provider.fetchOnChainProfile(for: "BTCUSDT")
        
        #expect(profile.symbol == "BTCUSDT")
        #expect(profile.baseAsset == "BTC")
        #expect(profile.cycleMetrics != nil)
        #expect(profile.lthSupply != nil)
        #expect(profile.spotETFFlows != nil)
        #expect(profile.entityHoldings != nil)
        
        if let cycle = profile.cycleMetrics,
           let lth = profile.lthSupply,
           let etf = profile.spotETFFlows,
           let entities = profile.entityHoldings {
            #expect(cycle.mvrvZScore > 0.0)
            #expect(lth.longTermHolderSupply > 0.0)
            #expect(etf.totalAUMUSD > 0.0)
            #expect(!entities.isEmpty)
        }
    }
}

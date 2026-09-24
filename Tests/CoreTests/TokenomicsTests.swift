import Testing
import Foundation
@testable import CryptoResearch

@Suite("TokenomicsTests")
struct TokenomicsTests {
    
    @Test("Test TokenomicsDataProvider for major assets")
    func testTokenomicsDataProviderMajorAssets() async throws {
        let provider = TokenomicsDataProvider()
        
        // Test BTC
        let btcProfile = try await provider.fetchTokenomics(for: "BTCUSDT")
        #expect(btcProfile.baseAsset == "BTC")
        #expect(btcProfile.supplyMetrics.maxSupply == 21_000_000.0)
        #expect(btcProfile.supplyMetrics.mcFdvRatio > 0.9)
        #expect(btcProfile.allocations.first?.percentage == 100.0)
        #expect(btcProfile.upcomingUnlocks.isEmpty)
        
        // Test SUI
        let suiProfile = try await provider.fetchTokenomics(for: "SUIUSDT")
        #expect(suiProfile.baseAsset == "SUI")
        #expect(suiProfile.supplyMetrics.maxSupply == 10_000_000_000.0)
        #expect(suiProfile.supplyMetrics.mcFdvRatio < 0.5)
        #expect(!suiProfile.upcomingUnlocks.isEmpty)
        #expect(suiProfile.allocations.count >= 4)
        
        // Test ARB
        let arbProfile = try await provider.fetchTokenomics(for: "ARBUSDT")
        #expect(arbProfile.baseAsset == "ARB")
        #expect(arbProfile.supplyMetrics.maxSupply == 10_000_000_000.0)
        #expect(!arbProfile.upcomingUnlocks.isEmpty)
    }
    
    @Test("Test TokenSupplyMetrics ratio and risk categorization")
    func testSupplyMetricsCalculations() {
        let metrics = TokenSupplyMetrics(
            circulatingSupply: 250_000_000,
            totalSupply: 1_000_000_000,
            maxSupply: 1_000_000_000,
            marketCapUSD: 500_000_000,
            fdvUSD: 2_000_000_000,
            mcFdvRatio: 0.25,
            annualInflationRate: 8.5,
            isBurnActive: true,
            burnedTokens: 5_000_000
        )
        
        #expect(metrics.mcFdvRatio == 0.25)
        #expect(metrics.isBurnActive == true)
        #expect(metrics.burnedTokens == 5_000_000)
    }
    
    @Test("Test TokenUnlockEvent properties")
    func testTokenUnlockEventProperties() {
        let event = TokenUnlockEvent(
            unlockDate: Date().addingTimeInterval(86400 * 10),
            category: "Core Contributors (Cliff)",
            tokenAmount: 50_000_000,
            valueUSD: 100_000_000,
            percentOfCirculating: 5.2,
            unlockType: .cliff,
            riskLevel: .high
        )
        
        #expect(event.riskLevel == .high)
        #expect(event.unlockType == .cliff)
        #expect(event.percentOfCirculating == 5.2)
    }
    
    @Test("Test VestingSchedule and TokenUtilityInfo properties")
    func testVestingScheduleAndUtilityInfo() async throws {
        let provider = TokenomicsDataProvider()
        let sol = try await provider.fetchTokenomics(for: "SOLUSDT")
        
        #expect(!sol.vestingSchedule.isEmpty)
        #expect(sol.vestingSchedule.first?.yearLabel == "2024")
        #expect(sol.utilityInfo.hasFeeBurnMechanism == true)
        #expect(sol.utilityInfo.stakingAPR != nil)
        
        let btc = try await provider.fetchTokenomics(for: "BTCUSDT")
        #expect(btc.utilityInfo.hasFeeBurnMechanism == false)
        #expect(btc.vestingSchedule.last?.circulatingPercent == 100.0)
    }
    
    @Test("Test TokenomicsDataProvider throws dataUnavailable for unknown assets")
    func testTokenomicsDataProviderUnknownAsset() async {
        let provider = TokenomicsDataProvider()
        await #expect(throws: TokenomicsError.self) {
            try await provider.fetchTokenomics(for: "UNKNOWNCOINUSDT")
        }
    }
}

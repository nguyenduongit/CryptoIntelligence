import Testing
import Foundation
@testable import CryptoResearch

@Suite("SmartMoneyTests")
struct SmartMoneyTests {
    
    @Test("Test SmartMoneyDataProvider profile retrieval")
    func testSmartMoneyDataProviderProfiles() async throws {
        let provider = SmartMoneyDataProvider()
        
        // BTC Test
        let btc = try await provider.fetchSmartMoneyProfile(for: "BTCUSDT")
        #expect(btc.baseAsset == "BTC")
        #expect(btc.sentimentSignal.score > 80)
        #expect(!btc.vcBackers.isEmpty)
        #expect(btc.vcBackers.first?.fundName.contains("BlackRock") == true)
        
        // SOL Test
        let sol = try await provider.fetchSmartMoneyProfile(for: "SOLUSDT")
        #expect(sol.baseAsset == "SOL")
        #expect(sol.vcBackers.first?.roiMultiplier ?? 0 > 100)
        #expect(!sol.recentDEXSwaps.isEmpty)
        
        // SUI Test
        let sui = try await provider.fetchSmartMoneyProfile(for: "SUIUSDT")
        #expect(sui.baseAsset == "SUI")
        #expect(sui.dexLiquidity.totalLiquidityUSD > 100_000_000)
    }
    
    @Test("Test VCBackerHolding properties")
    func testVCBackerHoldingProperties() {
        let holding = VCBackerHolding(
            fundName: "a16z Crypto",
            fundTier: "Tier 1",
            isLeadInvestor: true,
            investmentRound: "Series A ($0.10)",
            estimatedHoldingUSD: 280_000_000,
            roiMultiplier: 15.4,
            status: .holding
        )
        
        #expect(holding.isLeadInvestor == true)
        #expect(holding.status == .holding)
        #expect(holding.roiMultiplier == 15.4)
    }
    
    @Test("Test SmartMoneyViewModel swap filtering")
    func testSmartMoneyViewModelSwapFiltering() {
        let vm = SmartMoneyViewModel(symbol: "SOLUSDT")
        let now = Date()
        
        let swap1 = SmartMoneyDEXSwap(id: "sw1", timestamp: now, traderLabel: "Trader A", type: .buy, dexName: "Raydium", amountToken: 1000, amountUSD: 150_000, executionPriceUSD: 150)
        let swap2 = SmartMoneyDEXSwap(id: "sw2", timestamp: now, traderLabel: "Trader B", type: .sell, dexName: "Orca", amountToken: 500, amountUSD: 75_000, executionPriceUSD: 150)
        
        vm.profile = SmartMoneyProfile(
            symbol: "SOLUSDT",
            baseAsset: "SOL",
            sentimentSignal: SmartMoneySentimentSignal(score: 85, signalLabel: "Bullish", netDEXVolume24hUSD: 75_000, smartMoneyHoldersCount: 500, smartHoldersChange7d: 20, analysisSummary: "Test"),
            vcBackers: [],
            dexLiquidity: DEXLiquidityMetrics(totalLiquidityUSD: 1_000_000, liquidity24hChangePercent: 2, volume24hDEXUSD: 500_000, topPoolPair: "SOL/USDC", volumeToLiquidityRatio: 0.5),
            recentDEXSwaps: [swap1, swap2]
        )
        
        vm.selectedSwapFilter = .all
        #expect(vm.filteredDEXSwaps.count == 2)
        
        vm.selectedSwapFilter = .buys
        #expect(vm.filteredDEXSwaps.count == 1)
        #expect(vm.filteredDEXSwaps.first?.id == "sw1")
        
        vm.selectedSwapFilter = .sells
        #expect(vm.filteredDEXSwaps.count == 1)
        #expect(vm.filteredDEXSwaps.first?.id == "sw2")
    }
    
    @Test("Test SmartMoney Top Wallets Leaderboard and Fresh Alerts")
    func testSmartMoneyLeaderboardAndFreshWallets() async throws {
        let provider = SmartMoneyDataProvider()
        let sol = try await provider.fetchSmartMoneyProfile(for: "SOLUSDT")
        
        #expect(!sol.topWallets.isEmpty)
        #expect(sol.topWallets.first?.winRatePercent ?? 0 > 70)
        #expect(sol.topWallets.first?.pnl30dUSD ?? 0 > 1_000_000)
        
        #expect(!sol.freshWallets.isEmpty)
        #expect(sol.freshWallets.first?.ageHours ?? 0 > 0)
        #expect(sol.freshWallets.first?.accumulatedAmountUSD ?? 0 > 500_000)
    }
    
    @Test("Test SmartMoneyDataProvider throws dataUnavailable for unknown assets")
    func testSmartMoneyDataProviderUnknownAsset() async {
        let provider = SmartMoneyDataProvider()
        await #expect(throws: SmartMoneyError.self) {
            try await provider.fetchSmartMoneyProfile(for: "UNKNOWNCOINUSDT")
        }
    }
}

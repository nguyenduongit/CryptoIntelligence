import Testing
import Foundation
@testable import CryptoResearch

@Suite("OnChainTests")
struct OnChainTests {
    
    @Test("Test OnChainDataProvider profile retrieval")
    func testOnChainDataProviderProfiles() async throws {
        let provider = OnChainDataProvider()
        
        // BTC Test
        let btc = try await provider.fetchOnChainProfile(for: "BTCUSDT")
        #expect(btc.baseAsset == "BTC")
        #expect(btc.exchangeFlow.exchangeReserveTotal > 0)
        #expect(btc.networkActivity.dailyActiveAddresses > 500_000)
        // Whale list comes from live Binance trades and may legitimately be empty.
        #expect(btc.onChainHealthScore >= 0 && btc.onChainHealthScore <= 100)
        
        // ETH Test
        let eth = try await provider.fetchOnChainProfile(for: "ETHUSDT")
        #expect(eth.baseAsset == "ETH")
        #expect(eth.networkActivity.totalValueLockedUSD != nil)
        #expect(eth.networkActivity.totalValueLockedUSD! > 10_000_000_000)
        
        // SOL Test
        let sol = try await provider.fetchOnChainProfile(for: "SOLUSDT")
        #expect(sol.baseAsset == "SOL")
        #expect(sol.networkActivity.dailyActiveAddresses > 1_000_000)
    }
    
    @Test("Test ExchangeFlowMetrics calculations")
    func testExchangeFlowMetrics() {
        let flow1 = ExchangeFlowMetrics(
            netFlow24hUSD: -50_000_000,
            inflow24hUSD: 100_000_000,
            outflow24hUSD: 150_000_000,
            exchangeReserveTotal: 1_000_000,
            exchangeReserveChange7dPercent: -1.5
        )
        #expect(flow1.isAccumulation == true)
        
        let flow2 = ExchangeFlowMetrics(
            netFlow24hUSD: 30_000_000,
            inflow24hUSD: 130_000_000,
            outflow24hUSD: 100_000_000,
            exchangeReserveTotal: 1_000_000,
            exchangeReserveChange7dPercent: 2.1
        )
        #expect(flow2.isAccumulation == false)
    }
    
    @Test("Test OnChainViewModel transaction filtering")
    func testOnChainViewModelFiltering() {
        let vm = OnChainViewModel(symbol: "BTCUSDT")
        let now = Date()
        
        let tx1 = WhaleTransaction(id: "tx1", timestamp: now, amountToken: 100, amountUSD: 6_000_000, fromLabel: "Wallet", toLabel: "Binance", type: .exchangeInflow)
        let tx2 = WhaleTransaction(id: "tx2", timestamp: now, amountToken: 200, amountUSD: 12_000_000, fromLabel: "Coinbase", toLabel: "Cold Storage", type: .exchangeOutflow)
        let tx3 = WhaleTransaction(id: "tx3", timestamp: now, amountToken: 500, amountUSD: 30_000_000, fromLabel: "Whale 1", toLabel: "Whale 2", type: .whaleToWhale)
        
        vm.profile = OnChainProfile(
            symbol: "BTCUSDT",
            baseAsset: "BTC",
            networkName: "Bitcoin",
            exchangeFlow: ExchangeFlowMetrics(netFlow24hUSD: -6_000_000, inflow24hUSD: 6_000_000, outflow24hUSD: 12_000_000, exchangeReserveTotal: 1000, exchangeReserveChange7dPercent: -1),
            networkActivity: NetworkActivityMetrics(dailyActiveAddresses: 100, daaChange7dPercent: 1, dailyTransactionsCount: 1000),
            holderConcentration: HolderConcentrationMetrics(top10HoldersPercent: 10, top50HoldersPercent: 20, top100HoldersPercent: 30, retailHoldersPercent: 70, totalHoldersCount: 1000, holdersGrowth30d: 1),
            recentWhaleTransactions: [tx1, tx2, tx3],
            onChainHealthScore: 85,
            onChainHealthLabel: "Bullish",
            onChainSummary: "Test summary"
        )
        
        vm.selectedTxFilter = .all
        #expect(vm.filteredWhaleTransactions.count == 3)
        
        vm.selectedTxFilter = .inflows
        #expect(vm.filteredWhaleTransactions.count == 1)
        #expect(vm.filteredWhaleTransactions.first?.id == "tx1")
        
        vm.selectedTxFilter = .outflows
        #expect(vm.filteredWhaleTransactions.count == 1)
        #expect(vm.filteredWhaleTransactions.first?.id == "tx2")
        
        vm.selectedTxFilter = .whales
        #expect(vm.filteredWhaleTransactions.count == 1)
        #expect(vm.filteredWhaleTransactions.first?.id == "tx3")
    }
    
    @Test("Test OnChainDataProvider throws dataUnavailable for unknown assets")
    func testOnChainDataProviderUnknownAsset() async {
        let provider = OnChainDataProvider()
        await #expect(throws: OnChainError.self) {
            try await provider.fetchOnChainProfile(for: "UNKNOWNCOINUSDT")
        }
    }
}

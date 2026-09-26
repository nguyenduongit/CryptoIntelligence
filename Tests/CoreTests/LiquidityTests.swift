import Testing
import Foundation
@testable import CryptoResearch

@Suite("LiquidityTests")
struct LiquidityTests {
    
    @Test("Test DEXPoolData properties and initialization")
    func testDEXPoolDataProperties() {
        let pool = DEXPoolData(
            dexId: "uniswap_v3",
            dexName: "Uniswap v3",
            chainId: "Ethereum",
            pairAddress: "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640",
            baseSymbol: "WETH",
            quoteSymbol: "USDC",
            priceUSD: 2800.0,
            liquidityUSD: 220_000_000.0,
            volume24hUSD: 110_000_000.0,
            priceChange24h: 2.5,
            txns24hBuys: 4300,
            txns24hSells: 3900,
            url: "https://dexscreener.com/ethereum/0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640"
        )
        
        #expect(pool.id == "0x88e6a0c2ddd26feeb64f039a2c41296fcb3f5640")
        #expect(pool.dexName == "Uniswap v3")
        #expect(pool.liquidityUSD == 220_000_000.0)
        #expect(pool.txns24hBuys == 4300)
    }
    
    @Test("Test LiquidityOverviewProfile and slippage calculation")
    func testLiquidityOverviewProfile() async {
        let provider = DexScreenerProvider.shared
        let profile = await provider.fetchLiquidityOverview(for: "BTCUSDT", currentPrice: 95000.0, cexVolume24hUSD: 2_000_000_000.0)
        
        #expect(profile.symbol == "BTC")
        #expect(profile.cexVolume24hUSD >= 1_000_000.0)
        #expect(profile.estimatedSlippage10k >= 0.0)
        #expect(profile.estimatedSlippage100k >= profile.estimatedSlippage10k)
        #expect(!profile.topPools.isEmpty)
    }
    
    @Test("Test SubtabSectionItem identification")
    func testSubtabSectionItem() {
        let item = SubtabSectionItem(id: "supply", title: "Nguồn Cung & Vốn Hóa", iconName: "dollarsign.circle.fill", badge: "Live")
        #expect(item.id == "supply")
        #expect(item.title == "Nguồn Cung & Vốn Hóa")
        #expect(item.badge == "Live")
    }
}

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
        // Pool list depends on the live DexScreener API; when empty the profile must say "no data", not invent numbers.
        #expect(profile.hasDexData == !profile.topPools.isEmpty)
        if !profile.hasDexData {
            #expect(profile.dexVolume24hUSD == 0)
            #expect(profile.totalLiquidityDEXUSD == 0)
        }
    }
    
    @Test("parsePools keeps only the asset's own liquid pairs, sorted by liquidity")
    func testParsePoolsFiltersWrongSymbolsAndLowLiquidity() throws {
        let raw = """
        {"pairs":[
          {"dexId":"uniswap","chainId":"ethereum","pairAddress":"0xaaa","baseToken":{"symbol":"WBTC"},"quoteToken":{"symbol":"USDC"},"priceUsd":"90000","liquidity":{"usd":5000000},"volume":{"h24":1000000},"priceChange":{"h24":1.5},"txns":{"h24":{"buys":10,"sells":12}}},
          {"dexId":"scam","chainId":"ethereum","pairAddress":"0xbbb","baseToken":{"symbol":"BTC"},"quoteToken":{"symbol":"WETH"},"priceUsd":"0.5","liquidity":{"usd":1000},"volume":{"h24":10},"priceChange":{"h24":0},"txns":{"h24":{"buys":1,"sells":0}}},
          {"dexId":"other","chainId":"ethereum","pairAddress":"0xccc","baseToken":{"symbol":"PEPE"},"quoteToken":{"symbol":"WETH"},"priceUsd":"0.00001","liquidity":{"usd":9000000},"volume":{"h24":500000},"priceChange":{"h24":3},"txns":{"h24":{"buys":100,"sells":90}}},
          {"dexId":"curve","chainId":"ethereum","pairAddress":"0xddd","baseToken":{"symbol":"BTC"},"quoteToken":{"symbol":"USDT"},"priceUsd":"90010","liquidity":{"usd":8000000},"volume":{"h24":2000000},"priceChange":{"h24":1.4},"txns":{"h24":{"buys":20,"sells":25}}}
        ]}
        """
        let json = try #require(try JSONSerialization.jsonObject(with: Data(raw.utf8)) as? [String: Any])
        let pools = DexScreenerProvider.parsePools(from: json, symbol: "BTC")
        
        #expect(pools.count == 2)
        #expect(pools.first?.pairAddress == "0xddd")
        #expect(pools.last?.pairAddress == "0xaaa")
        #expect(!pools.contains { $0.baseSymbol == "PEPE" })
    }
    
    @Test("parsePools returns empty for empty or malformed payloads")
    func testParsePoolsEmpty() {
        #expect(DexScreenerProvider.parsePools(from: [:], symbol: "BTC").isEmpty)
        #expect(DexScreenerProvider.parsePools(from: ["pairs": [] as [[String: Any]]], symbol: "BTC").isEmpty)
    }
    
    @Test("Test SubtabSectionItem identification")
    func testSubtabSectionItem() {
        let item = SubtabSectionItem(id: "supply", title: "Nguồn Cung & Vốn Hóa", iconName: "dollarsign.circle.fill", badge: "Live")
        #expect(item.id == "supply")
        #expect(item.title == "Nguồn Cung & Vốn Hóa")
        #expect(item.badge == "Live")
    }
}

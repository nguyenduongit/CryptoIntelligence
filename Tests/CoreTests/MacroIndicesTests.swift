import Testing
import Foundation
@testable import CryptoResearch

@Suite("MacroIndicesTests")
struct MacroIndicesTests {
    
    @Test("Test MacroIndexType properties, display names, and percentages")
    func testMacroIndexTypeProperties() {
        #expect(MacroIndexType.total.rawValue == "TOTAL")
        #expect(MacroIndexType.total2.rawValue == "TOTAL2")
        #expect(MacroIndexType.total3.rawValue == "TOTAL3")
        #expect(MacroIndexType.btcD.rawValue == "BTC.D")
        #expect(MacroIndexType.ethD.rawValue == "ETH.D")
        #expect(MacroIndexType.stableD.rawValue == "STABLE.D")
        #expect(MacroIndexType.usdtD.rawValue == "USDT.D")
        #expect(MacroIndexType.othersD.rawValue == "OTHERS.D")
        
        #expect(MacroIndexType.total.isPercentage == false)
        #expect(MacroIndexType.total2.isPercentage == false)
        #expect(MacroIndexType.total3.isPercentage == false)
        #expect(MacroIndexType.btcD.isPercentage == true)
        #expect(MacroIndexType.ethD.isPercentage == true)
        #expect(MacroIndexType.stableD.isPercentage == true)
        #expect(MacroIndexType.usdtD.isPercentage == true)
        #expect(MacroIndexType.othersD.isPercentage == true)
        
        #expect(!MacroIndexType.total.displayName.isEmpty)
        #expect(!MacroIndexType.stableD.displayName.isEmpty)
        #expect(!MacroIndexType.total.subtitle.isEmpty)
        #expect(!MacroIndexType.total.iconName.isEmpty)
    }
    
    @Test("Test StablecoinBreakdownItem model")
    func testStablecoinBreakdownItem() {
        let item = StablecoinBreakdownItem(
            symbol: "USDC",
            name: "USD Coin",
            circulatingUSD: 76_600_000_000,
            dominancePercentage: 2.66,
            shareOfStablesPercentage: 24.4,
            change7dPercent: 2.92
        )
        
        #expect(item.id == "USDC")
        #expect(item.symbol == "USDC")
        #expect(item.name == "USD Coin")
        #expect(item.circulatingUSD == 76_600_000_000)
        #expect(item.dominancePercentage == 2.66)
        #expect(item.shareOfStablesPercentage == 24.4)
        #expect(item.change7dPercent == 2.92)
    }
    
    @Test("Test MacroIndexSnapshot data model")
    func testMacroIndexSnapshot() {
        let snapshot = MacroIndexSnapshot(
            indexType: .total,
            currentValue: 3_250_000_000_000.0,
            change24h: 2.15,
            change7d: 5.40,
            formattedValue: "$3.25T",
            sparkline: [3.1, 3.15, 3.2, 3.25]
        )
        
        #expect(snapshot.id == "TOTAL")
        #expect(snapshot.currentValue == 3_250_000_000_000.0)
        #expect(snapshot.change24h == 2.15)
        #expect(snapshot.change7d == 5.40)
        #expect(snapshot.formattedValue == "$3.25T")
        #expect(snapshot.sparkline.count == 4)
    }
    
    @Test("Test MarketSeasonState and MarketSeasonReport")
    func testMarketSeasonStateAndReport() {
        let states = MarketSeasonState.allCases
        #expect(states.count == 4)
        
        for state in states {
            #expect(!state.rawValue.isEmpty)
            #expect(!state.iconName.isEmpty)
        }
        
        let report = MarketSeasonReport(
            currentState: .bitcoinSeason,
            altcoinSeasonIndex: 32,
            totalMarketCapUSD: 3_200_000_000_000,
            altcoinMarketCapUSD: 1_350_000_000_000,
            btcDPercentage: 57.5,
            ethDPercentage: 11.32,
            usdtDPercentage: 6.37,
            stablecoinDominancePercentage: 10.88,
            totalStablecoinLiquidityUSD: 313_900_000_000,
            topStablecoins: [
                StablecoinBreakdownItem(symbol: "USDT", name: "Tether", circulatingUSD: 183.7e9, dominancePercentage: 6.37, shareOfStablesPercentage: 58.5, change7dPercent: 0.24),
                StablecoinBreakdownItem(symbol: "USDC", name: "USD Coin", circulatingUSD: 76.6e9, dominancePercentage: 2.66, shareOfStablesPercentage: 24.4, change7dPercent: 2.92)
            ],
            actionableSummary: "Dòng tiền tập trung vào Bitcoin."
        )
        
        #expect(report.currentState == .bitcoinSeason)
        #expect(report.altcoinSeasonIndex == 32)
        #expect(report.btcDPercentage == 57.5)
        #expect(report.ethDPercentage == 11.32)
        #expect(report.usdtDPercentage == 6.37)
        #expect(report.stablecoinDominancePercentage == 10.88)
        #expect(report.totalStablecoinLiquidityUSD == 313_900_000_000)
        #expect(report.topStablecoins.count == 2)
        #expect(!report.actionableSummary.isEmpty)
    }
    
    @Test("Test MacroIndicesDataProvider snapshots fetch and calculation")
    func testMacroIndicesDataProvider() async {
        let provider = MacroIndicesDataProvider.shared
        let snapshots = await provider.fetchMacroSnapshots()
        
        #expect(!snapshots.isEmpty)
        #expect(snapshots.count >= 7)
        
        let total = snapshots.first { $0.indexType == .total }
        let total2 = snapshots.first { $0.indexType == .total2 }
        let total3 = snapshots.first { $0.indexType == .total3 }
        let btcD = snapshots.first { $0.indexType == .btcD }
        let ethD = snapshots.first { $0.indexType == .ethD }
        let stableD = snapshots.first { $0.indexType == .stableD }
        let usdtD = snapshots.first { $0.indexType == .usdtD }
        
        #expect(total != nil)
        #expect(total2 != nil)
        #expect(total3 != nil)
        #expect(btcD != nil)
        #expect(ethD != nil)
        #expect(stableD != nil)
        #expect(usdtD != nil)
        
        if let total = total, let total2 = total2, let total3 = total3 {
            // TOTAL > TOTAL2 > TOTAL3
            #expect(total.currentValue >= total2.currentValue)
            #expect(total2.currentValue >= total3.currentValue)
            #expect(total.currentValue > 0)
        }
        
        if let btcD = btcD {
            #expect(btcD.currentValue > 20.0 && btcD.currentValue < 90.0)
        }
        
        if let stableD = stableD, let usdtD = usdtD {
            #expect(stableD.currentValue >= usdtD.currentValue)
        }
    }
    
    @Test("Test MacroIndicesDataProvider season report and stablecoins fetch")
    func testMacroIndicesSeasonReport() async {
        let provider = MacroIndicesDataProvider.shared
        let report = await provider.fetchSeasonReport()
        
        #expect(report.altcoinSeasonIndex >= 0 && report.altcoinSeasonIndex <= 100)
        #expect(report.totalMarketCapUSD > 0)
        #expect(report.altcoinMarketCapUSD > 0)
        #expect(report.btcDPercentage > 0)
        #expect(report.stablecoinDominancePercentage > 0)
        #expect(report.totalStablecoinLiquidityUSD > 0)
        #expect(!report.topStablecoins.isEmpty)
        #expect(!report.actionableSummary.isEmpty)
    }
    
    @Test("Test MacroIndicesDataProvider K-Line candle generation")
    func testMacroIndicesCandleGeneration() async {
        let provider = MacroIndicesDataProvider.shared
        
        for index in [MacroIndexType.total, .btcD, .stableD, .usdtD] {
            let candles1D = await provider.fetchIndexCandles(index: index, timeframe: "1D")
            #expect(!candles1D.isEmpty)
            #expect(candles1D.count >= 20)
            
            for candle in candles1D {
                #expect(candle.high >= candle.low)
                #expect(candle.open > 0)
                #expect(candle.close > 0)
            }
        }
    }
    
    @Test("Test Market Navigation Enums and View Modes")
    func testMarketNavigationViewModes() {
        let modes = MarketViewMode.allCases
        #expect(modes.count == 7)
        #expect(modes.contains(.all))
        #expect(modes.contains(.topGainers))
        #expect(modes.contains(.topLosers))
        #expect(modes.contains(.topVolume))
        #expect(modes.contains(.topCap))
        #expect(modes.contains(.highVolatility))
        #expect(modes.contains(.newListings))
        
        #expect(MarketValuationSection.allCases.count == 2)
        #expect(GlobalMacroSection.allCases.count == 7)
        #expect(GlobalMacroSection.allCases.contains(.valuation))
        #expect(ScreenerPresetSelection.allCases.count == 6)
        
        let vm = MarketViewModel()
        #expect(vm.selectedMarketViewMode == .all)
        #expect(vm.selectedValuationSection == .overview)
        #expect(vm.selectedMacroIndex == .total)
        #expect(vm.selectedGlobalMacroSection == .all)
    }
}

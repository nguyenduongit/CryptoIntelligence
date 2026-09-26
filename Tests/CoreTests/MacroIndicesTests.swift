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
        #expect(MacroIndexType.usdtD.rawValue == "USDT.D")
        #expect(MacroIndexType.othersD.rawValue == "OTHERS.D")
        
        #expect(MacroIndexType.total.isPercentage == false)
        #expect(MacroIndexType.total2.isPercentage == false)
        #expect(MacroIndexType.total3.isPercentage == false)
        #expect(MacroIndexType.btcD.isPercentage == true)
        #expect(MacroIndexType.ethD.isPercentage == true)
        #expect(MacroIndexType.usdtD.isPercentage == true)
        #expect(MacroIndexType.othersD.isPercentage == true)
        
        #expect(!MacroIndexType.total.displayName.isEmpty)
        #expect(!MacroIndexType.total.subtitle.isEmpty)
        #expect(!MacroIndexType.total.iconName.isEmpty)
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
            usdtDPercentage: 4.8,
            stablecoinLiquidityUSD: 160_000_000_000,
            actionableSummary: "Dòng tiền tập trung vào Bitcoin."
        )
        
        #expect(report.currentState == .bitcoinSeason)
        #expect(report.altcoinSeasonIndex == 32)
        #expect(report.btcDPercentage == 57.5)
        #expect(report.usdtDPercentage == 4.8)
        #expect(!report.actionableSummary.isEmpty)
    }
    
    @Test("Test MacroIndicesDataProvider snapshots fetch and calculation")
    func testMacroIndicesDataProvider() async {
        let provider = MacroIndicesDataProvider.shared
        let snapshots = await provider.fetchMacroSnapshots()
        
        #expect(!snapshots.isEmpty)
        #expect(snapshots.count >= 6)
        
        let total = snapshots.first { $0.indexType == .total }
        let total2 = snapshots.first { $0.indexType == .total2 }
        let total3 = snapshots.first { $0.indexType == .total3 }
        let btcD = snapshots.first { $0.indexType == .btcD }
        let usdtD = snapshots.first { $0.indexType == .usdtD }
        
        #expect(total != nil)
        #expect(total2 != nil)
        #expect(total3 != nil)
        #expect(btcD != nil)
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
    }
    
    @Test("Test MacroIndicesDataProvider season report logic")
    func testMacroIndicesSeasonReport() async {
        let provider = MacroIndicesDataProvider.shared
        let report = await provider.fetchSeasonReport()
        
        #expect(report.altcoinSeasonIndex >= 0 && report.altcoinSeasonIndex <= 100)
        #expect(report.totalMarketCapUSD > 0)
        #expect(report.altcoinMarketCapUSD > 0)
        #expect(report.btcDPercentage > 0)
        #expect(!report.actionableSummary.isEmpty)
    }
    
    @Test("Test MacroIndicesDataProvider K-Line candle generation")
    func testMacroIndicesCandleGeneration() async {
        let provider = MacroIndicesDataProvider.shared
        
        for index in [MacroIndexType.total, .btcD, .usdtD] {
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
}

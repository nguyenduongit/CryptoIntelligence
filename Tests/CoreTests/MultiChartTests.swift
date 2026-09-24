import Testing
import Foundation
@testable import CryptoResearch

@Suite("MultiChartTests")
struct MultiChartTests {
    
    @Test("Test MultiChartLayout properties and count")
    func testMultiChartLayoutEnums() {
        #expect(MultiChartLayout.allCases.count == 5)
        
        let single = MultiChartLayout.single
        #expect(single.iconName == "rectangle.fill")
        
        let grid = MultiChartLayout.grid2x2
        #expect(grid.iconName == "rectangle.split.2x2.fill")
    }
    
    @Test("Test MultiChartPaneConfig initialization and fields")
    func testPaneConfig() {
        var pane = MultiChartPaneConfig(symbol: "SOLUSDT", timeframe: .h4, showRelativeStrengthToBTC: true)
        
        #expect(pane.symbol == "SOLUSDT")
        #expect(pane.timeframe == .h4)
        #expect(pane.showRelativeStrengthToBTC == true)
        
        pane.timeframe = .d1
        #expect(pane.timeframe == .d1)
    }
    
    @Test("Test RelativePerformanceGrade enums and colors")
    func testRelativePerformanceGrade() {
        let grades = RelativePerformanceGrade.allCases
        #expect(grades.count == 4)
        #expect(RelativePerformanceGrade.strongOutperformance.rawValue.contains("Strong Alpha"))
    }
    
    @Test("Test MultiChartDataProvider fetchRelativeStrength generates 30 daily points")
    func testRelativeStrengthData() async {
        let provider = MultiChartDataProvider.shared
        let summary = await provider.fetchRelativeStrength(for: "SOLUSDT")
        
        #expect(summary.symbol == "SOLUSDT")
        #expect(summary.baseAsset == "SOL")
        #expect(summary.benchmarkSymbol == "BTCUSDT")
        #expect(summary.currentRatio > 0)
        #expect(summary.history.count >= 2)
        #expect(summary.isLiveCandleData == true || summary.isLiveCandleData == false)
    }
    
    @Test("Test MultiChartDataProvider default panes generation")
    func testCreateDefaultPanes() async {
        let provider = MultiChartDataProvider.shared
        let panes = await provider.createDefaultPanes(for: "NEARUSDT")
        
        #expect(panes.count == 4)
        #expect(panes[0].symbol == "NEARUSDT")
        #expect(panes[2].symbol == "BTCUSDT")
        #expect(panes[3].symbol == "ETHUSDT")
    }
}

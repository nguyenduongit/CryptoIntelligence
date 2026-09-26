import Testing
import Foundation
import CoreGraphics
@testable import CryptoResearch

struct ChartInteractionTests {
    
    @Test func testChartPanAndZoom() {
        let db = DatabaseManager(inMemory: true)
        let vm = ChartViewModel(symbol: "BTCUSDT", dbManager: db)
        
        // Provide mock candles
        var mockCandles: [Candle] = []
        for i in 0..<100 {
            let c = Candle(
                openTime: Int64(1000 + i * 60),
                open: 100.0 + Double(i),
                high: 105.0 + Double(i),
                low: 95.0 + Double(i),
                close: 102.0 + Double(i),
                volume: 50.0
            )
            mockCandles.append(c)
        }
        vm.candles = mockCandles
        vm.visibleRange = 50.0...80.0
        vm.updatePriceRange()
        
        let initialSpan = vm.visibleRange.upperBound - vm.visibleRange.lowerBound
        #expect(abs(initialSpan - 30.0) < 0.001)
        
        // Test Pan rightward (dragging right pulls past candles into view, so visibleRange indices decrease)
        vm.pan(deltaX: 100.0, width: 500.0)
        let deltaCandles = (100.0 / 500.0) * 30.0 // 6.0
        #expect(abs(vm.visibleRange.lowerBound - (50.0 - deltaCandles)) < 0.001)
        #expect(abs(vm.visibleRange.upperBound - (80.0 - deltaCandles)) < 0.001)
        
        // Test Zoom in (factor < 1.0 reduces span)
        let preZoomSpan = vm.visibleRange.upperBound - vm.visibleRange.lowerBound
        vm.zoom(factor: 0.9, anchorX: 250.0, width: 500.0)
        let postZoomSpan = vm.visibleRange.upperBound - vm.visibleRange.lowerBound
        #expect(postZoomSpan < preZoomSpan)
    }
    
    @Test func testChartOlderCandlesPaginationState() {
        let db = DatabaseManager(inMemory: true)
        let vm = ChartViewModel(symbol: "ETHUSDT", dbManager: db)
        
        #expect(vm.isLoadingOlderCandles == false)
        #expect(vm.hasReachedOldestCandle == false)
        
        // Set symbol or timeframe resets pagination state
        vm.hasReachedOldestCandle = true
        vm.setTimeframe(.d1)
        #expect(vm.hasReachedOldestCandle == false)
    }
}

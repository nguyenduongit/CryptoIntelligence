import Testing
import Foundation
import CoreGraphics
@testable import CryptoResearch

struct DrawingInteractionTests {
    
    @Test func testDrawingUndoRedo() {
        let db = DatabaseManager(inMemory: true)
        let vm = ChartViewModel(symbol: "BTCUSDT", dbManager: db)
        vm.drawings = []
        
        let elem1 = DrawingElement(
            symbol: "BTCUSDT",
            type: .horizontalLine,
            startPoint: CandlePoint(openTime: 1000, price: 90000.0),
            endPoint: CandlePoint(openTime: 1000, price: 90000.0),
            isCompleted: true
        )
        
        vm.addDrawing(elem1)
        #expect(vm.drawings.count == 1)
        #expect(vm.canUndo == true)
        #expect(vm.canRedo == false)
        
        let elem2 = DrawingElement(
            symbol: "BTCUSDT",
            type: .trendline,
            startPoint: CandlePoint(openTime: 1000, price: 80000.0),
            endPoint: CandlePoint(openTime: 2000, price: 85000.0),
            isCompleted: true
        )
        
        vm.addDrawing(elem2)
        #expect(vm.drawings.count == 2)
        
        // Undo
        vm.undo()
        #expect(vm.drawings.count == 1)
        #expect(vm.drawings[0].id == elem1.id)
        #expect(vm.canRedo == true)
        
        // Redo
        vm.redo()
        #expect(vm.drawings.count == 2)
        #expect(vm.drawings[1].id == elem2.id)
    }
    
    @Test func testDrawingDeletion() {
        let db = DatabaseManager(inMemory: true)
        let vm = ChartViewModel(symbol: "ETHUSDT", dbManager: db)
        vm.drawings = []
        
        let elem = DrawingElement(
            symbol: "ETHUSDT",
            type: .horizontalLine,
            startPoint: CandlePoint(openTime: 1000, price: 3000.0),
            endPoint: CandlePoint(openTime: 1000, price: 3000.0),
            isCompleted: true
        )
        
        vm.addDrawing(elem)
        vm.selectedDrawingId = elem.id
        
        vm.deleteSelectedDrawing()
        #expect(vm.drawings.isEmpty)
        #expect(vm.selectedDrawingId == nil)
        #expect(vm.canUndo == true)
        
        // Undo deletion
        vm.undo()
        #expect(vm.drawings.count == 1)
        #expect(vm.drawings[0].id == elem.id)
    }
    
    @Test func testDrawingHandleDrag() {
        let db = DatabaseManager(inMemory: true)
        let vm = ChartViewModel(symbol: "SOLUSDT", dbManager: db)
        vm.candles = [
            Candle(openTime: 1000, open: 100, high: 110, low: 90, close: 105, volume: 10),
            Candle(openTime: 2000, open: 105, high: 120, low: 100, close: 115, volume: 20),
            Candle(openTime: 3000, open: 115, high: 130, low: 110, close: 125, volume: 30)
        ]
        vm.visibleRange = 0.0...2.0
        vm.priceRange = 90.0...130.0
        
        let elem = DrawingElement(
            symbol: "SOLUSDT",
            type: .trendline,
            startPoint: CandlePoint(openTime: 1000, price: 100.0),
            endPoint: CandlePoint(openTime: 2000, price: 115.0),
            isCompleted: true
        )
        vm.drawings = [elem]
        
        // Simulate start drag of handle 1 (endpoint)
        vm.draggingDrawingId = elem.id
        vm.draggingHandleIndex = 1
        vm.dragInitialElement = elem
        vm.dragStartCandlePoint = elem.endPoint
        
        let transform = CoordinateTransform(visibleRange: vm.visibleRange, priceRange: vm.priceRange)
        let targetX = transform.x(forIndex: 2.0, width: 300)
        let targetY = transform.y(forPrice: 125.0, height: 200)
        
        vm.handleDrawingDrag(currentPoint: CGPoint(x: targetX, y: targetY), chartWidth: 300, chartHeight: 200)
        
        #expect(vm.drawings[0].startPoint.openTime == 1000)
        #expect(vm.drawings[0].endPoint?.openTime == 3000)
        #expect(abs(vm.drawings[0].endPoint!.price - 125.0) < 1.0)
    }
}

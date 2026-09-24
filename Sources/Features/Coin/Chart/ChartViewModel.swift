import SwiftUI
import Observation
import GRDB

@Observable
public final class ChartViewModel: @unchecked Sendable {
    public var symbol: String
    public var timeframe: Timeframe = .h1
    
    public var candles: [Candle] = []
    public var visibleRange: ClosedRange<Double> = 0.0...100.0
    public var priceRange: ClosedRange<Double> = 0.0...1.0
    public var manualPriceRange: ClosedRange<Double>? = nil
    
    public var crosshairPoint: CGPoint? = nil
    public var hoveredCandleIndex: Int? = nil
    
    // Technical Indicators
    public var indicatorConfig: IndicatorConfig = IndicatorConfig()
    public var computedIndicators: ComputedIndicators = ComputedIndicators()
    
    // Drawing Tools
    public var selectedDrawingTool: DrawingToolType = .cursor
    public var drawings: [DrawingElement] = []
    public var activeDrawing: DrawingElement? = nil
    public var selectedDrawingId: UUID? = nil
    
    // Undo / Redo Stacks
    private var undoStack: [[DrawingElement]] = []
    private var redoStack: [[DrawingElement]] = []
    
    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    
    // Dragging an existing drawing state
    public var draggingDrawingId: UUID? = nil
    public var draggingHandleIndex: Int? = nil
    public var dragStartCandlePoint: CandlePoint? = nil
    public var dragInitialElement: DrawingElement? = nil
    
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let dbManager: DatabaseManager
    private let candleProvider: BinanceCandleProvider
    private var loadTask: Task<Void, Never>?
    private var klineObserver: NSObjectProtocol?
    
    public init(
        symbol: String,
        timeframe: Timeframe = .h1,
        dbManager: DatabaseManager = .shared,
        candleProvider: BinanceCandleProvider = .shared
    ) {
        self.symbol = symbol
        self.timeframe = timeframe
        self.dbManager = dbManager
        self.candleProvider = candleProvider
        self.loadDrawings()
        self.setupKlineObserver()
    }
    
    deinit {
        if let observer = klineObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupKlineObserver() {
        self.klineObserver = NotificationCenter.default.addObserver(
            forName: .didReceiveKline,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self,
                  let candle = notification.userInfo?["candle"] as? Candle,
                  let sym = notification.userInfo?["symbol"] as? String,
                  let tf = notification.userInfo?["timeframe"] as? Timeframe else { return }
            self.handleLiveKline(candle: candle, symbol: sym, timeframe: tf)
        }
    }
    
    public func setSymbol(_ newSymbol: String) {
        guard newSymbol != self.symbol else { return }
        self.symbol = newSymbol
        self.candles = []
        self.computedIndicators = ComputedIndicators()
        self.manualPriceRange = nil
        self.activeDrawing = nil
        self.selectedDrawingId = nil
        self.undoStack.removeAll()
        self.redoStack.removeAll()
        self.loadDrawings()
        loadData()
    }
    
    public func setTimeframe(_ newTimeframe: Timeframe) {
        guard newTimeframe != self.timeframe else { return }
        self.timeframe = newTimeframe
        self.candles = []
        self.computedIndicators = ComputedIndicators()
        self.manualPriceRange = nil
        loadData()
    }
    
    public func loadData() {
        loadTask?.cancel()
        let currentSymbol = self.symbol
        let currentTimeframe = self.timeframe
        
        loadTask = Task { @MainActor in
            self.isLoading = true
            self.errorMessage = nil
            
            // 1. Read cached candles from SQLite first for instant display
            let cached = loadFromDatabase()
            guard self.symbol == currentSymbol && self.timeframe == currentTimeframe else { return }
            
            self.candles = cached
            self.recomputeIndicators()
            self.resetViewportToLatest()
            
            // 2. Fetch historical candles from Binance REST
            do {
                let fetched = try await candleProvider.fetchHistoricalCandles(
                    symbol: currentSymbol,
                    timeframe: currentTimeframe,
                    limit: 2000,
                    endTime: nil
                )
                
                guard !Task.isCancelled, self.symbol == currentSymbol, self.timeframe == currentTimeframe else { return }
                
                if !fetched.isEmpty {
                    self.mergeAndSaveCandles(fetched)
                    self.recomputeIndicators()
                    self.resetViewportToLatest()
                }
                
                self.isLoading = false
            } catch {
                guard !Task.isCancelled, self.symbol == currentSymbol, self.timeframe == currentTimeframe else { return }
                self.isLoading = false
                self.errorMessage = "Lỗi tải nến: \(error.localizedDescription)"
            }
            
            // 3. Subscribe WebSocket for real-time tick updates
            await BinanceWebSocketManager.shared.subscribeKline(symbol: currentSymbol, timeframe: currentTimeframe)
        }
    }
    
    private func loadFromDatabase() -> [Candle] {
        do {
            let records = try dbManager.dbQueue.read { db in
                try CandleRecord
                    .filter(Column("symbol") == self.symbol && Column("interval") == self.timeframe.intervalString)
                    .order(Column("openTime").asc)
                    .fetchAll(db)
            }
            return records.map { $0.toModel() }
        } catch {
            print("Failed to read candles from database: \(error)")
            return []
        }
    }
    
    private func mergeAndSaveCandles(_ newCandles: [Candle]) {
        // Only merge with current symbol's candles
        var map = [Int64: Candle]()
        for c in self.candles {
            map[c.openTime] = c
        }
        for c in newCandles {
            map[c.openTime] = c
        }
        
        let merged = map.values.sorted { $0.openTime < $1.openTime }
        self.candles = merged
        
        let currentSymbol = self.symbol
        let currentInterval = self.timeframe.intervalString
        let records = newCandles.map { CandleRecord(symbol: currentSymbol, interval: currentInterval, candle: $0) }
        Task.detached(priority: .background) { [dbManager = self.dbManager] in
            do {
                try dbManager.dbQueue.write { db in
                    for rec in records {
                        try rec.save(db)
                    }
                }
            } catch {
                print("Failed to save candles to DB: \(error)")
            }
        }
    }
    
    public func handleLiveKline(candle: Candle, symbol: String, timeframe: Timeframe) {
        guard symbol.uppercased() == self.symbol.uppercased(), timeframe == self.timeframe else { return }
        
        Task { @MainActor in
            if let lastIndex = self.candles.indices.last, self.candles[lastIndex].openTime == candle.openTime {
                self.candles[lastIndex] = candle
            } else {
                self.candles.append(candle)
                if self.visibleRange.upperBound >= Double(self.candles.count - 2) {
                    let span = self.visibleRange.upperBound - self.visibleRange.lowerBound
                    let newUpper = Double(self.candles.count)
                    self.visibleRange = (newUpper - span)...newUpper
                }
            }
            
            self.recomputeIndicators()
            self.updatePriceRange()
            
            if candle.isClosed {
                let rec = CandleRecord(symbol: self.symbol, interval: self.timeframe.intervalString, candle: candle)
                Task.detached(priority: .background) { [dbManager = self.dbManager] in
                    try? dbManager.dbQueue.write { db in
                        try? rec.save(db)
                    }
                }
            }
        }
    }
    
    public func recomputeIndicators() {
        self.computedIndicators = IndicatorEngine.compute(candles: self.candles, config: self.indicatorConfig)
    }
    
    public func resetViewportToLatest() {
        let count = Double(candles.count)
        if count <= 0 {
            visibleRange = 0.0...100.0
            priceRange = 0.0...1.0
            return
        }
        
        let visibleCount = min(count, 120.0)
        visibleRange = max(0.0, count - visibleCount)...(count + 5.0)
        updatePriceRange()
    }
    
    public func updatePriceRange() {
        guard !candles.isEmpty else { return }
        
        if let manual = manualPriceRange {
            self.priceRange = manual
            return
        }
        
        let startIdx = max(0, Int(floor(visibleRange.lowerBound)))
        let endIdx = min(candles.count - 1, Int(ceil(visibleRange.upperBound)))
        
        guard startIdx <= endIdx, startIdx < candles.count else { return }
        
        var minP = Double.greatestFiniteMagnitude
        var maxP = -Double.greatestFiniteMagnitude
        
        for i in startIdx...endIdx {
            let c = candles[i]
            minP = min(minP, c.low)
            maxP = max(maxP, c.high)
        }
        
        if minP == Double.greatestFiniteMagnitude || maxP == -Double.greatestFiniteMagnitude || minP == maxP {
            let lastPrice = candles.last?.close ?? 100.0
            minP = lastPrice * 0.95
            maxP = lastPrice * 1.05
        }
        
        let span = maxP - minP
        let topPadding = span * 0.05
        let bottomPadding = indicatorConfig.showVolume ? span * 0.18 : span * 0.05
        
        self.priceRange = (minP - bottomPadding)...(maxP + topPadding)
    }
    
    // MARK: - Drawing Tools & Persistence
    public func loadDrawings() {
        do {
            let records = try dbManager.dbQueue.read { db in
                try DrawingRecord.filter(Column("symbol") == self.symbol).fetchAll(db)
            }
            self.drawings = records.compactMap { $0.toModel() }
        } catch {
            print("Failed to load drawings: \(error)")
            self.drawings = []
        }
    }
    
    public func pushUndoState() {
        undoStack.append(drawings)
        if undoStack.count > 50 {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }
    
    public func undo() {
        guard let previous = undoStack.popLast() else { return }
        redoStack.append(drawings)
        self.drawings = previous
        self.selectedDrawingId = nil
        saveAllDrawings()
    }
    
    public func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(drawings)
        self.drawings = next
        self.selectedDrawingId = nil
        saveAllDrawings()
    }
    
    public func addDrawing(_ element: DrawingElement) {
        pushUndoState()
        drawings.append(element)
        saveDrawing(element)
    }
    
    public func saveDrawing(_ element: DrawingElement) {
        do {
            try dbManager.dbQueue.write { db in
                let rec = DrawingRecord(element: element)
                try rec.save(db)
            }
        } catch {
            print("Failed to save drawing: \(error)")
        }
    }
    
    public func saveAllDrawings() {
        do {
            try dbManager.dbQueue.write { db in
                _ = try DrawingRecord.filter(Column("symbol") == self.symbol).deleteAll(db)
                for d in self.drawings {
                    let rec = DrawingRecord(element: d)
                    try rec.save(db)
                }
            }
        } catch {
            print("Failed to save all drawings: \(error)")
        }
    }
    
    public func clearAllDrawings() {
        guard !drawings.isEmpty else { return }
        pushUndoState()
        self.drawings.removeAll()
        self.activeDrawing = nil
        self.selectedDrawingId = nil
        do {
            try dbManager.dbQueue.write { db in
                _ = try DrawingRecord.filter(Column("symbol") == self.symbol).deleteAll(db)
            }
        } catch {
            print("Failed to clear drawings: \(error)")
        }
    }
    
    public func deleteSelectedDrawing() {
        guard let id = selectedDrawingId else { return }
        pushUndoState()
        self.drawings.removeAll { $0.id == id }
        self.selectedDrawingId = nil
        do {
            try dbManager.dbQueue.write { db in
                _ = try DrawingRecord.filter(Column("id") == id.uuidString).deleteAll(db)
            }
        } catch {
            print("Failed to delete drawing: \(error)")
        }
    }
    
    // MARK: - Dragging & Editing Existing Drawings
    public func handleDrawingDrag(currentPoint: CGPoint, chartWidth: CGFloat, chartHeight: CGFloat) {
        guard let dragId = draggingDrawingId,
              let initial = dragInitialElement,
              let dragStart = dragStartCandlePoint,
              let currentCandlePoint = candlePoint(forLocation: currentPoint, chartWidth: chartWidth, chartHeight: chartHeight),
              let index = drawings.firstIndex(where: { $0.id == dragId }) else { return }
        
        var modified = initial
        
        if let handle = draggingHandleIndex {
            if handle == 0 {
                modified.startPoint = currentCandlePoint
            } else if handle == 1 {
                modified.endPoint = currentCandlePoint
            }
        } else {
            // Dragging entire shape: calculate delta time and delta price
            let deltaPrice = currentCandlePoint.price - dragStart.price
            let deltaTime = currentCandlePoint.openTime - dragStart.openTime
            
            modified.startPoint = CandlePoint(
                openTime: initial.startPoint.openTime + deltaTime,
                price: initial.startPoint.price + deltaPrice
            )
            if let initEnd = initial.endPoint {
                modified.endPoint = CandlePoint(
                    openTime: initEnd.openTime + deltaTime,
                    price: initEnd.price + deltaPrice
                )
            }
        }
        
        drawings[index] = modified
    }
    
    // MARK: - Geometric Hit-Testing
    public func hitTestDrawing(point: CGPoint, chartWidth: CGFloat, chartHeight: CGFloat) -> (elementId: UUID, handleIndex: Int?)? {
        guard chartWidth > 0, chartHeight > 0, !drawings.isEmpty else { return nil }
        
        let threshold: CGFloat = 12.0
        
        for element in drawings.reversed() {
            guard let p1 = location(forCandlePoint: element.startPoint, chartWidth: chartWidth, chartHeight: chartHeight) else { continue }
            let p2 = element.endPoint.flatMap { location(forCandlePoint: $0, chartWidth: chartWidth, chartHeight: chartHeight) } ?? p1
            
            // Check Start Handle
            if hypot(point.x - p1.x, point.y - p1.y) <= threshold {
                return (element.id, 0)
            }
            
            // Check End Handle
            if element.type != .horizontalLine && hypot(point.x - p2.x, point.y - p2.y) <= threshold {
                return (element.id, 1)
            }
            
            // Check Body Hit
            switch element.type {
            case .cursor:
                break
            case .horizontalLine:
                if abs(point.y - p1.y) <= threshold && point.x <= chartWidth {
                    return (element.id, nil)
                }
            case .trendline, .priceRuler:
                let dist = distanceToSegment(p: point, a: p1, b: p2)
                if dist <= threshold {
                    return (element.id, nil)
                }
            case .fibonacci:
                let p1Price = element.startPoint.price
                let p2Price = element.endPoint?.price ?? p1Price
                let span = p2Price - p1Price
                let levels = [0.0, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0]
                
                let transform = CoordinateTransform(visibleRange: visibleRange, priceRange: priceRange, isLogScale: indicatorConfig.isLogScale)
                for lvl in levels {
                    let lvlPrice = p1Price + span * lvl
                    let lvlY = transform.y(forPrice: lvlPrice, height: chartHeight)
                    if abs(point.y - lvlY) <= threshold {
                        return (element.id, nil)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func distanceToSegment(p: CGPoint, a: CGPoint, b: CGPoint) -> CGFloat {
        let dx = b.x - a.x
        let dy = b.y - a.y
        let lengthSq = dx * dx + dy * dy
        if lengthSq == 0 { return hypot(p.x - a.x, p.y - a.y) }
        
        var t = ((p.x - a.x) * dx + (p.y - a.y) * dy) / lengthSq
        t = max(0, min(1, t))
        let projX = a.x + t * dx
        let projY = a.y + t * dy
        return hypot(p.x - projX, p.y - projY)
    }
    
    public func candlePoint(forLocation point: CGPoint, chartWidth: CGFloat, chartHeight: CGFloat) -> CandlePoint? {
        guard chartWidth > 0, chartHeight > 0, !candles.isEmpty else { return nil }
        let transform = CoordinateTransform(visibleRange: visibleRange, priceRange: priceRange, isLogScale: indicatorConfig.isLogScale)
        
        let index = transform.index(forX: point.x, width: chartWidth)
        let price = transform.price(forY: point.y, height: chartHeight)
        
        let candleCount = candles.count
        if candleCount == 1 {
            return CandlePoint(openTime: candles[0].openTime, price: price)
        }
        
        let firstTime = candles.first!.openTime
        let lastTime = candles.last!.openTime
        let avgInterval = Double(lastTime - firstTime) / Double(candleCount - 1)
        
        let candleTime: Int64
        if index < 0 {
            candleTime = firstTime + Int64(index * avgInterval)
        } else if index >= Double(candleCount) {
            candleTime = lastTime + Int64((index - Double(candleCount - 1)) * avgInterval)
        } else {
            let clampedIndex = max(0, min(candleCount - 1, Int(round(index))))
            candleTime = candles[clampedIndex].openTime
        }
        
        return CandlePoint(openTime: candleTime, price: price)
    }
    
    public func location(forCandlePoint point: CandlePoint, chartWidth: CGFloat, chartHeight: CGFloat) -> CGPoint? {
        guard chartWidth > 0, chartHeight > 0, !candles.isEmpty else { return nil }
        let transform = CoordinateTransform(visibleRange: visibleRange, priceRange: priceRange, isLogScale: indicatorConfig.isLogScale)
        
        let candleCount = candles.count
        if candleCount == 1 {
            let x = transform.x(forIndex: 0, width: chartWidth)
            let y = transform.y(forPrice: point.price, height: chartHeight)
            return CGPoint(x: x, y: y)
        }
        
        let firstTime = candles.first!.openTime
        let lastTime = candles.last!.openTime
        let avgInterval = Double(lastTime - firstTime) / Double(candleCount - 1)
        
        let index: Double
        if point.openTime < firstTime {
            let diff = Double(point.openTime - firstTime)
            index = avgInterval > 0 ? (diff / avgInterval) : 0
        } else if point.openTime > lastTime {
            let diff = Double(point.openTime - lastTime)
            index = avgInterval > 0 ? (Double(candleCount - 1) + (diff / avgInterval)) : Double(candleCount - 1)
        } else {
            if let idx = candles.firstIndex(where: { $0.openTime >= point.openTime }) {
                index = Double(idx)
            } else {
                index = Double(candleCount - 1)
            }
        }
        
        let x = transform.x(forIndex: index, width: chartWidth)
        let y = transform.y(forPrice: point.price, height: chartHeight)
        return CGPoint(x: x, y: y)
    }
    
    // MARK: - Zoom & Pan Interactions
    public func zoom(factor: Double, anchorX: CGFloat, width: CGFloat) {
        guard width > 0, !candles.isEmpty else { return }
        
        let transform = CoordinateTransform(visibleRange: visibleRange, priceRange: priceRange, isLogScale: indicatorConfig.isLogScale)
        let anchorIndex = transform.index(forX: anchorX, width: width)
        let currentSpan = visibleRange.upperBound - visibleRange.lowerBound
        
        let minSpan: Double = 10.0
        let maxSpan: Double = max(100.0, Double(candles.count) * 1.5)
        let newSpan = min(max(currentSpan * factor, minSpan), maxSpan)
        
        let anchorFraction = Double(anchorX / width)
        var newLower = anchorIndex - anchorFraction * newSpan
        var newUpper = newLower + newSpan
        
        if newLower < -5.0 {
            newLower = -5.0
            newUpper = newLower + newSpan
        }
        
        self.visibleRange = newLower...newUpper
        updatePriceRange()
    }
    
    public func pan(deltaX: CGFloat, width: CGFloat) {
        guard width > 0, !candles.isEmpty else { return }
        
        let span = visibleRange.upperBound - visibleRange.lowerBound
        let deltaCandles = Double(deltaX / width) * span
        
        var newLower = visibleRange.lowerBound - deltaCandles
        var newUpper = visibleRange.upperBound - deltaCandles
        
        let minBound: Double = -10.0
        let maxBound = Double(candles.count) + 30.0
        
        if newLower < minBound {
            newLower = minBound
            newUpper = newLower + span
        } else if newUpper > maxBound {
            newUpper = maxBound
            newLower = newUpper - span
        }
        
        self.visibleRange = newLower...newUpper
        updatePriceRange()
    }
    
    public func stretchPriceY(deltaY: CGFloat, height: CGFloat) {
        guard height > 0 else { return }
        let currentSpan = priceRange.upperBound - priceRange.lowerBound
        let factor = 1.0 + Double(deltaY / height)
        let newSpan = max(currentSpan * factor, 1e-8)
        let mid = (priceRange.lowerBound + priceRange.upperBound) / 2.0
        
        let newRange = (mid - newSpan / 2.0)...(mid + newSpan / 2.0)
        self.manualPriceRange = newRange
        self.priceRange = newRange
    }
    
    public func resetPriceAutoFit() {
        self.manualPriceRange = nil
        updatePriceRange()
    }
}

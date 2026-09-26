import SwiftUI
import AppKit

public struct ChartInteractionView: NSViewRepresentable {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public func makeNSView(context: Context) -> NSChartContainerView {
        let view = NSChartContainerView()
        view.viewModel = viewModel
        view.priceAxisWidth = priceAxisWidth
        return view
    }
    
    public func updateNSView(_ nsView: NSChartContainerView, context: Context) {
        nsView.viewModel = viewModel
        nsView.priceAxisWidth = priceAxisWidth
    }
}

public final class NSChartContainerView: NSView {
    public var viewModel: ChartViewModel?
    public var priceAxisWidth: CGFloat = 65
    
    private var trackingArea: NSTrackingArea?
    private var lastDragPoint: NSPoint?
    private var isDraggingPriceAxis: Bool = false
    private var isDrawing: Bool = false
    
    public override var acceptsFirstResponder: Bool { true }
    
    public override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let trackingArea = self.trackingArea {
            removeTrackingArea(trackingArea)
        }
        
        let options: NSTrackingArea.Options = [
            .mouseMoved,
            .mouseEnteredAndExited,
            .activeInKeyWindow,
            .inVisibleRect
        ]
        let area = NSTrackingArea(rect: bounds, options: options, owner: self, userInfo: nil)
        addTrackingArea(area)
        self.trackingArea = area
    }
    
    // MARK: - Mouse Events
    public override func mouseMoved(with event: NSEvent) {
        guard let vm = viewModel else { return }
        let location = convert(event.locationInWindow, from: nil)
        let chartWidth = bounds.width - priceAxisWidth
        
        guard chartWidth > 0 else { return }
        
        if location.x >= 0 && location.x <= chartWidth && location.y >= 0 && location.y <= bounds.height {
            let transform = CoordinateTransform(
                visibleRange: vm.visibleRange,
                priceRange: vm.priceRange,
                isLogScale: vm.indicatorConfig.isLogScale
            )
            
            let swiftUIY = bounds.height - location.y
            let candleIndex = Int(round(transform.index(forX: location.x, width: chartWidth)))
            
            vm.crosshairPoint = CGPoint(x: location.x, y: swiftUIY)
            if candleIndex >= 0 && candleIndex < vm.candles.count {
                vm.hoveredCandleIndex = candleIndex
            } else {
                vm.hoveredCandleIndex = nil
            }
            
            // Cursor icon update for drawing hover
            if vm.selectedDrawingTool == .cursor {
                if let hit = vm.hitTestDrawing(point: CGPoint(x: location.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height) {
                    if hit.handleIndex != nil {
                        NSCursor.crosshair.set()
                    } else {
                        NSCursor.openHand.set()
                    }
                } else {
                    NSCursor.arrow.set()
                }
            }
        } else {
            vm.crosshairPoint = nil
            vm.hoveredCandleIndex = nil
            NSCursor.arrow.set()
        }
    }
    
    public override func mouseExited(with event: NSEvent) {
        viewModel?.crosshairPoint = nil
        viewModel?.hoveredCandleIndex = nil
        NSCursor.arrow.set()
    }
    
    public override func mouseDown(with event: NSEvent) {
        window?.makeFirstResponder(self)
        guard let vm = viewModel else { return }
        
        let location = convert(event.locationInWindow, from: nil)
        lastDragPoint = location
        let chartWidth = bounds.width - priceAxisWidth
        let swiftUIY = bounds.height - location.y
        
        if location.x > chartWidth {
            isDraggingPriceAxis = true
            isDrawing = false
            return
        }
        isDraggingPriceAxis = false
        
        // Handle Drawing Tool Click (Creating new drawing)
        if vm.selectedDrawingTool != .cursor {
            isDrawing = true
            if let point = vm.candlePoint(forLocation: CGPoint(x: location.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height) {
                if vm.selectedDrawingTool == .horizontalLine {
                    let element = DrawingElement(
                        symbol: vm.symbol,
                        type: .horizontalLine,
                        startPoint: point,
                        endPoint: point,
                        isCompleted: true
                    )
                    vm.addDrawing(element)
                    vm.selectedDrawingId = element.id
                    vm.selectedDrawingTool = .cursor
                    isDrawing = false
                } else {
                    vm.activeDrawing = DrawingElement(
                        symbol: vm.symbol,
                        type: vm.selectedDrawingTool,
                        startPoint: point,
                        endPoint: point,
                        isCompleted: false
                    )
                }
            }
            return
        }
        
        // Handle Selection and Dragging in Cursor Mode
        if let hit = vm.hitTestDrawing(point: CGPoint(x: location.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height) {
            vm.selectedDrawingId = hit.elementId
            vm.draggingDrawingId = hit.elementId
            vm.draggingHandleIndex = hit.handleIndex
            if let elem = vm.drawings.first(where: { $0.id == hit.elementId }) {
                vm.dragInitialElement = elem
                vm.pushUndoState()
            }
            if let pt = vm.candlePoint(forLocation: CGPoint(x: location.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height) {
                vm.dragStartCandlePoint = pt
            }
            NSCursor.closedHand.set()
            return
        } else {
            // Clicked empty area: deselect drawing
            vm.selectedDrawingId = nil
            vm.draggingDrawingId = nil
            vm.draggingHandleIndex = nil
            vm.dragStartCandlePoint = nil
            vm.dragInitialElement = nil
        }
        
        isDrawing = false
        if event.clickCount == 2 {
            viewModel?.resetPriceAutoFit()
        }
    }
    
    public override func mouseDragged(with event: NSEvent) {
        guard let vm = viewModel, let lastPoint = lastDragPoint else { return }
        let currentPoint = convert(event.locationInWindow, from: nil)
        let deltaX = currentPoint.x - lastPoint.x
        let deltaY = currentPoint.y - lastPoint.y
        let chartWidth = bounds.width - priceAxisWidth
        let swiftUIY = bounds.height - currentPoint.y
        
        if isDrawing, let active = vm.activeDrawing {
            if let pt = vm.candlePoint(forLocation: CGPoint(x: currentPoint.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height) {
                var updated = active
                updated.endPoint = pt
                vm.activeDrawing = updated
            }
        } else if vm.draggingDrawingId != nil {
            vm.handleDrawingDrag(currentPoint: CGPoint(x: currentPoint.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height)
            NSCursor.closedHand.set()
        } else if isDraggingPriceAxis {
            vm.stretchPriceY(deltaY: -deltaY, height: bounds.height)
        } else {
            vm.pan(deltaX: deltaX, width: chartWidth)
        }
        
        lastDragPoint = currentPoint
        vm.crosshairPoint = CGPoint(x: currentPoint.x, y: swiftUIY)
    }
    
    public override func mouseUp(with event: NSEvent) {
        guard let vm = viewModel else { return }
        let currentPoint = convert(event.locationInWindow, from: nil)
        let chartWidth = bounds.width - priceAxisWidth
        let swiftUIY = bounds.height - currentPoint.y
        
        if isDrawing, var active = vm.activeDrawing {
            if let pt = vm.candlePoint(forLocation: CGPoint(x: currentPoint.x, y: swiftUIY), chartWidth: chartWidth, chartHeight: bounds.height) {
                active.endPoint = pt
            }
            active.isCompleted = true
            vm.addDrawing(active)
            vm.selectedDrawingId = active.id
            vm.activeDrawing = nil
            vm.selectedDrawingTool = .cursor
        } else if let dragId = vm.draggingDrawingId {
            if let elem = vm.drawings.first(where: { $0.id == dragId }) {
                vm.saveDrawing(elem)
            }
            vm.draggingDrawingId = nil
            vm.draggingHandleIndex = nil
            vm.dragStartCandlePoint = nil
            vm.dragInitialElement = nil
            NSCursor.arrow.set()
        }
        
        lastDragPoint = nil
        isDraggingPriceAxis = false
        isDrawing = false
    }
    
    // MARK: - Native Trackpad Pinch to Zoom
    public override func magnify(with event: NSEvent) {
        guard let vm = viewModel else { return }
        let location = convert(event.locationInWindow, from: nil)
        let chartWidth = bounds.width - priceAxisWidth
        guard chartWidth > 0 else { return }
        
        let anchorX = max(0, min(location.x, chartWidth))
        // event.magnification > 0 means pinch outward (zoom in), < 0 means pinch inward (zoom out)
        let factor = 1.0 - Double(event.magnification) * 1.2
        let clamped = max(0.85, min(1.15, factor))
        vm.zoom(factor: clamped, anchorX: anchorX, width: chartWidth)
    }
    
    // MARK: - Scroll & Zoom
    public override func scrollWheel(with event: NSEvent) {
        guard let vm = viewModel else { return }
        let location = convert(event.locationInWindow, from: nil)
        let chartWidth = bounds.width - priceAxisWidth
        guard chartWidth > 0 else { return }
        
        let anchorX = max(0, min(location.x, chartWidth))
        
        if event.hasPreciseScrollingDeltas {
            // Trackpad continuous scrolling
            let deltaX = event.scrollingDeltaX
            let deltaY = event.scrollingDeltaY
            
            // Shift key or dominant horizontal swipe -> Pan horizontally
            if event.modifierFlags.contains(.shift) || abs(deltaX) > abs(deltaY) * 1.2 {
                let panDelta = event.modifierFlags.contains(.shift) ? (deltaY != 0 ? deltaY : deltaX) : deltaX
                if abs(panDelta) > 0.2 {
                    vm.pan(deltaX: panDelta * 1.2, width: chartWidth)
                }
            }
            // Dominant vertical swipe -> Zoom
            else if abs(deltaY) > 0.8 {
                let zoomFactor = deltaY > 0 ? 0.97 : 1.03
                vm.zoom(factor: zoomFactor, anchorX: anchorX, width: chartWidth)
            }
        } else {
            // Traditional stepped mouse wheel (e.g. external USB/Bluetooth mouse)
            if event.modifierFlags.contains(.shift) {
                let panDelta = event.deltaY != 0 ? event.deltaY : event.deltaX
                vm.pan(deltaX: panDelta * 20.0, width: chartWidth)
            } else {
                let zoomFactor = event.deltaY > 0 ? 0.90 : 1.10
                vm.zoom(factor: zoomFactor, anchorX: anchorX, width: chartWidth)
            }
        }
    }
    
    // MARK: - Keyboard Shortcuts
    public override func keyDown(with event: NSEvent) {
        guard let vm = viewModel else { return }
        
        let flags = event.modifierFlags
        let chars = event.charactersIgnoringModifiers ?? ""
        
        // Command shortcuts
        if flags.contains(.command) {
            if chars == "z" || chars == "Z" {
                if flags.contains(.shift) {
                    vm.redo()
                } else {
                    vm.undo()
                }
                return
            } else if chars == "y" || chars == "Y" {
                vm.redo()
                return
            }
        }
        
        // Delete / Backspace key (keyCode 51 = Backspace, keyCode 117 = Forward Delete)
        if event.keyCode == 51 || event.keyCode == 117 || chars == "\u{7f}" || chars == "\u{f728}" {
            if vm.selectedDrawingId != nil {
                vm.deleteSelectedDrawing()
                return
            }
        }
        
        switch chars {
        case "1": vm.setTimeframe(.m1)
        case "2": vm.setTimeframe(.m5)
        case "3": vm.setTimeframe(.m15)
        case "4": vm.setTimeframe(.h1)
        case "5": vm.setTimeframe(.h4)
        case "6": vm.setTimeframe(.d1)
        case "7": vm.setTimeframe(.w1)
        case "8": vm.setTimeframe(.mo1)
        case "l", "L":
            vm.indicatorConfig.isLogScale.toggle()
            vm.updatePriceRange()
        case "\u{1b}": // Escape key to cancel drawing mode or deselect
            vm.selectedDrawingTool = .cursor
            vm.activeDrawing = nil
            vm.selectedDrawingId = nil
        default:
            super.keyDown(with: event)
        }
    }
}

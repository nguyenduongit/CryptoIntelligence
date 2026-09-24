import SwiftUI

public struct OverlayIndicatorsLayer: View {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public var body: some View {
        Canvas { context, size in
            let chartWidth = size.width - priceAxisWidth
            guard chartWidth > 0, size.height > 0, !viewModel.candles.isEmpty else { return }
            
            let transform = CoordinateTransform(
                visibleRange: viewModel.visibleRange,
                priceRange: viewModel.priceRange,
                isLogScale: viewModel.indicatorConfig.isLogScale
            )
            
            let startIndex = max(0, Int(floor(viewModel.visibleRange.lowerBound)) - 1)
            let endIndex = min(viewModel.candles.count - 1, Int(ceil(viewModel.visibleRange.upperBound)) + 1)
            
            guard startIndex <= endIndex else { return }
            
            // 1. Bollinger Bands
            if viewModel.indicatorConfig.showBollinger, let boll = viewModel.computedIndicators.bollinger {
                drawBollingerBands(
                    context: &context,
                    boll: boll,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
            
            // 2. SMAs
            if viewModel.indicatorConfig.showSMA20 {
                drawLine(
                    context: &context,
                    values: viewModel.computedIndicators.sma20,
                    color: AppTheme.ma20,
                    lineWidth: 1.5,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
            if viewModel.indicatorConfig.showSMA50 {
                drawLine(
                    context: &context,
                    values: viewModel.computedIndicators.sma50,
                    color: AppTheme.ma50,
                    lineWidth: 1.5,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
            if viewModel.indicatorConfig.showSMA200 {
                drawLine(
                    context: &context,
                    values: viewModel.computedIndicators.sma200,
                    color: AppTheme.ma200,
                    lineWidth: 2.0,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
            
            // 3. EMAs
            if viewModel.indicatorConfig.showEMA12 {
                drawLine(
                    context: &context,
                    values: viewModel.computedIndicators.ema12,
                    color: AppTheme.ema12,
                    lineWidth: 1.5,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
            if viewModel.indicatorConfig.showEMA26 {
                drawLine(
                    context: &context,
                    values: viewModel.computedIndicators.ema26,
                    color: AppTheme.ema26,
                    lineWidth: 1.5,
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
            
            // 4. EMA Ribbon (20, 50, 100, 200)
            if viewModel.indicatorConfig.showEMARibbon {
                drawLine(context: &context, values: viewModel.computedIndicators.emaRibbon20, color: AppTheme.cyan, lineWidth: 1.2, startIndex: startIndex, endIndex: endIndex, transform: transform, chartWidth: chartWidth, height: size.height)
                drawLine(context: &context, values: viewModel.computedIndicators.emaRibbon50, color: AppTheme.accentBlue, lineWidth: 1.5, startIndex: startIndex, endIndex: endIndex, transform: transform, chartWidth: chartWidth, height: size.height)
                drawLine(context: &context, values: viewModel.computedIndicators.emaRibbon100, color: AppTheme.purple, lineWidth: 1.8, startIndex: startIndex, endIndex: endIndex, transform: transform, chartWidth: chartWidth, height: size.height)
                drawLine(context: &context, values: viewModel.computedIndicators.emaRibbon200, color: AppTheme.downRed.opacity(0.9), lineWidth: 2.0, startIndex: startIndex, endIndex: endIndex, transform: transform, chartWidth: chartWidth, height: size.height)
            }
            
            // 5. VWAP
            if viewModel.indicatorConfig.showVWAP {
                drawDashedLine(
                    context: &context,
                    values: viewModel.computedIndicators.vwap,
                    color: AppTheme.orange,
                    lineWidth: 2.0,
                    dash: [4, 3],
                    startIndex: startIndex,
                    endIndex: endIndex,
                    transform: transform,
                    chartWidth: chartWidth,
                    height: size.height
                )
            }
        }
    }
    
    private func drawLine(
        context: inout GraphicsContext,
        values: [Double?],
        color: Color,
        lineWidth: CGFloat,
        startIndex: Int,
        endIndex: Int,
        transform: CoordinateTransform,
        chartWidth: CGFloat,
        height: CGFloat
    ) {
        guard values.count > endIndex else { return }
        var path = Path()
        var hasStarted = false
        
        for i in startIndex...endIndex {
            guard let val = values[i] else {
                hasStarted = false
                continue
            }
            let x = transform.x(forIndex: Double(i), width: chartWidth)
            let y = transform.y(forPrice: val, height: height)
            
            if !hasStarted {
                path.move(to: CGPoint(x: x, y: y))
                hasStarted = true
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        context.stroke(path, with: .color(color), lineWidth: lineWidth)
    }
    
    private func drawDashedLine(
        context: inout GraphicsContext,
        values: [Double?],
        color: Color,
        lineWidth: CGFloat,
        dash: [CGFloat],
        startIndex: Int,
        endIndex: Int,
        transform: CoordinateTransform,
        chartWidth: CGFloat,
        height: CGFloat
    ) {
        guard values.count > endIndex else { return }
        var path = Path()
        var hasStarted = false
        
        for i in startIndex...endIndex {
            guard let val = values[i] else {
                hasStarted = false
                continue
            }
            let x = transform.x(forIndex: Double(i), width: chartWidth)
            let y = transform.y(forPrice: val, height: height)
            
            if !hasStarted {
                path.move(to: CGPoint(x: x, y: y))
                hasStarted = true
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        context.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, dash: dash))
    }
    
    private func drawBollingerBands(
        context: inout GraphicsContext,
        boll: BollingerResult,
        startIndex: Int,
        endIndex: Int,
        transform: CoordinateTransform,
        chartWidth: CGFloat,
        height: CGFloat
    ) {
        var upperPoints = [CGPoint]()
        var lowerPoints = [CGPoint]()
        
        for i in startIndex...endIndex {
            if i < boll.upper.count, let up = boll.upper[i],
               i < boll.lower.count, let low = boll.lower[i] {
                let x = transform.x(forIndex: Double(i), width: chartWidth)
                let yUp = transform.y(forPrice: up, height: height)
                let yLow = transform.y(forPrice: low, height: height)
                
                upperPoints.append(CGPoint(x: x, y: yUp))
                lowerPoints.append(CGPoint(x: x, y: yLow))
            }
        }
        
        // Fill area between upper and lower
        if !upperPoints.isEmpty && upperPoints.count == lowerPoints.count {
            var fillPath = Path()
            fillPath.move(to: upperPoints[0])
            for pt in upperPoints.dropFirst() {
                fillPath.addLine(to: pt)
            }
            for pt in lowerPoints.reversed() {
                fillPath.addLine(to: pt)
            }
            fillPath.closeSubpath()
            context.fill(fillPath, with: .color(AppTheme.bollingerBand.opacity(0.08)))
            
            // Stroke upper band
            var upperPath = Path()
            upperPath.move(to: upperPoints[0])
            for pt in upperPoints.dropFirst() { upperPath.addLine(to: pt) }
            context.stroke(upperPath, with: .color(AppTheme.bollingerBand.opacity(0.7)), lineWidth: 1)
            
            // Stroke lower band
            var lowerPath = Path()
            lowerPath.move(to: lowerPoints[0])
            for pt in lowerPoints.dropFirst() { lowerPath.addLine(to: pt) }
            context.stroke(lowerPath, with: .color(AppTheme.bollingerBand.opacity(0.7)), lineWidth: 1)
        }
        
        // Stroke middle band
        drawLine(
            context: &context,
            values: boll.middle,
            color: AppTheme.bollingerBand,
            lineWidth: 1.2,
            startIndex: startIndex,
            endIndex: endIndex,
            transform: transform,
            chartWidth: chartWidth,
            height: height
        )
    }
}

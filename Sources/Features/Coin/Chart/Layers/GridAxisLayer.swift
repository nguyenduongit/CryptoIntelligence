import SwiftUI

public struct GridAxisLayer: View {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public var body: some View {
        Canvas { context, size in
            let chartWidth = size.width - priceAxisWidth
            guard chartWidth > 0, size.height > 0 else { return }
            
            let transform = CoordinateTransform(
                visibleRange: viewModel.visibleRange,
                priceRange: viewModel.priceRange,
                isLogScale: viewModel.indicatorConfig.isLogScale
            )
            
            // 1. Horizontal Price Grid Lines & Axis Labels
            let priceSteps = CoordinateTransform.calculateNicePriceSteps(
                minPrice: viewModel.priceRange.lowerBound,
                maxPrice: viewModel.priceRange.upperBound,
                targetStepCount: 6
            )
            
            for price in priceSteps {
                let y = transform.y(forPrice: price, height: size.height)
                guard y >= 0 && y <= size.height else { continue }
                
                // Grid line
                var gridPath = Path()
                gridPath.move(to: CGPoint(x: 0, y: y))
                gridPath.addLine(to: CGPoint(x: chartWidth, y: y))
                context.stroke(
                    gridPath,
                    with: .color(AppTheme.darkBorder.opacity(0.4)),
                    style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                )
                
                // Price label on right axis
                let labelText = Text(Formatters.formatPrice(price))
                    .font(AppTheme.chartFont)
                    .foregroundColor(Color.white.opacity(0.6))
                
                context.draw(
                    labelText,
                    at: CGPoint(x: chartWidth + 6, y: y),
                    anchor: .leading
                )
            }
            
            // 2. Vertical Time Grid Lines & Labels
            let startIndex = max(0, Int(floor(viewModel.visibleRange.lowerBound)))
            let endIndex = min(viewModel.candles.count - 1, Int(ceil(viewModel.visibleRange.upperBound)))
            
            if startIndex <= endIndex && !viewModel.candles.isEmpty {
                let candleSpan = Double(endIndex - startIndex)
                let step = max(1, Int(candleSpan / 6.0))
                
                var i = startIndex
                while i <= endIndex {
                    let candle = viewModel.candles[i]
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    
                    if x >= 0 && x <= chartWidth {
                        // Vertical grid line
                        var vPath = Path()
                        vPath.move(to: CGPoint(x: x, y: 0))
                        vPath.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(
                            vPath,
                            with: .color(AppTheme.darkBorder.opacity(0.25)),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                        
                        // Time label at bottom
                        let timeStr = Formatters.formatCandleTime(ms: candle.openTime, timeframe: viewModel.timeframe)
                        
                        let timeLabel = Text(timeStr)
                            .font(Font.system(size: 9, design: .monospaced))
                            .foregroundColor(Color.white.opacity(0.5))
                        
                        context.draw(
                            timeLabel,
                            at: CGPoint(x: x, y: size.height - 10),
                            anchor: .center
                        )
                    }
                    i += step
                }
            }
            
            // Axis separator line
            var axisLine = Path()
            axisLine.move(to: CGPoint(x: chartWidth, y: 0))
            axisLine.addLine(to: CGPoint(x: chartWidth, y: size.height))
            context.stroke(axisLine, with: .color(AppTheme.darkBorder), lineWidth: 1)
        }
    }
}

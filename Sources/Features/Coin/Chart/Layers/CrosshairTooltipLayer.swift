import SwiftUI

public struct CrosshairTooltipLayer: View {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public var body: some View {
        ZStack(alignment: .topLeading) {
            // 1. Crosshair Canvas
            if let point = viewModel.crosshairPoint {
                Canvas { context, size in
                    let chartWidth = size.width - priceAxisWidth
                    guard chartWidth > 0, size.height > 0 else { return }
                    
                    let transform = CoordinateTransform(
                        visibleRange: viewModel.visibleRange,
                        priceRange: viewModel.priceRange,
                        isLogScale: viewModel.indicatorConfig.isLogScale
                    )
                    
                    let x = point.x
                    let y = point.y
                    
                    // Vertical Crosshair Line
                    if x >= 0 && x <= chartWidth {
                        var vLine = Path()
                        vLine.move(to: CGPoint(x: x, y: 0))
                        vLine.addLine(to: CGPoint(x: x, y: size.height))
                        context.stroke(
                            vLine,
                            with: .color(Color.white.opacity(0.4)),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                        )
                        
                        // Bottom Time Badge
                        let candleIndex = Int(round(transform.index(forX: x, width: chartWidth)))
                        let timeText: String
                        if candleIndex >= 0 && candleIndex < viewModel.candles.count {
                            timeText = Formatters.formatCandleTime(ms: viewModel.candles[candleIndex].openTime, timeframe: viewModel.timeframe)
                        } else if let pt = viewModel.candlePoint(forLocation: point, chartWidth: chartWidth, chartHeight: size.height) {
                            timeText = Formatters.formatCandleTime(ms: pt.openTime, timeframe: viewModel.timeframe)
                        } else {
                            timeText = ""
                        }
                        
                        if !timeText.isEmpty {
                            let badgeWidth: CGFloat = (viewModel.timeframe == .d1 || viewModel.timeframe == .w1 || viewModel.timeframe == .mo1) ? 90 : 120
                            let badgeHeight: CGFloat = 18
                            let badgeX = max(2, min(chartWidth - badgeWidth - 2, x - badgeWidth / 2))
                            let badgeY = size.height - badgeHeight - 2
                            let timeRect = CGRect(x: badgeX, y: badgeY, width: badgeWidth, height: badgeHeight)
                            
                            context.fill(Path(roundedRect: timeRect, cornerRadius: 3), with: .color(AppTheme.darkHeaderBg.opacity(0.95)))
                            context.stroke(Path(roundedRect: timeRect, cornerRadius: 3), with: .color(AppTheme.accentBlue), lineWidth: 1)
                            
                            let timeLabel = Text(timeText)
                                .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            context.draw(timeLabel, at: CGPoint(x: badgeX + badgeWidth / 2, y: badgeY + badgeHeight / 2), anchor: .center)
                        }
                    }
                    
                    // Horizontal Crosshair Line
                    if y >= 0 && y <= size.height {
                        var hLine = Path()
                        hLine.move(to: CGPoint(x: 0, y: y))
                        hLine.addLine(to: CGPoint(x: chartWidth, y: y))
                        context.stroke(
                            hLine,
                            with: .color(Color.white.opacity(0.4)),
                            style: StrokeStyle(lineWidth: 1, dash: [3, 3])
                        )
                        
                        // Right Price Badge
                        let cursorPrice = transform.price(forY: y, height: size.height)
                        let badgeRect = CGRect(x: chartWidth + 2, y: y - 9, width: priceAxisWidth - 4, height: 18)
                        context.fill(Path(roundedRect: badgeRect, cornerRadius: 3), with: .color(AppTheme.accentBlue))
                        
                        let priceText = Text(Formatters.formatPrice(cursorPrice))
                            .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        context.draw(priceText, at: CGPoint(x: chartWidth + 6, y: y), anchor: .leading)
                    }
                }
                .allowsHitTesting(false)
            }
            
            // 2. Top-Left OHLCV Header Badge
            let activeCandle = (viewModel.hoveredCandleIndex != nil && viewModel.hoveredCandleIndex! < viewModel.candles.count)
                ? viewModel.candles[viewModel.hoveredCandleIndex!]
                : viewModel.candles.last
            
            if let c = activeCandle {
                HStack(spacing: 10) {
                    // Date & Time Stamp
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(AppTheme.cyan)
                        Text(Formatters.formatCandleTime(ms: c.openTime, timeframe: viewModel.timeframe))
                            .font(Font.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.cyan)
                    }
                    .padding(.trailing, 2)
                    
                    Text(viewModel.symbol)
                        .font(Font.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 3) {
                        Text("O")
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatPrice(c.open))
                            .foregroundColor(c.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    
                    HStack(spacing: 3) {
                        Text("H")
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatPrice(c.high))
                            .foregroundColor(c.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    
                    HStack(spacing: 3) {
                        Text("L")
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatPrice(c.low))
                            .foregroundColor(c.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    
                    HStack(spacing: 3) {
                        Text("C")
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatPrice(c.close))
                            .foregroundColor(c.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    
                    HStack(spacing: 3) {
                        Text("Vol")
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatVolume(c.volume))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Text(Formatters.formatPercentage(c.changePercent))
                        .font(Font.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(c.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                }
                .font(Font.system(size: 11, weight: .medium, design: .monospaced))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.darkHeaderBg.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                .padding(10)
                .allowsHitTesting(false)
            }
        }
    }
}

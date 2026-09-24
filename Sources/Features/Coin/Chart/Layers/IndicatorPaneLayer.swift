import SwiftUI

public struct RSIPaneView: View {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Pane Header
            HStack {
                Text("RSI(\(viewModel.indicatorConfig.rsiPeriod))")
                    .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.rsiColor)
                
                if let idx = viewModel.hoveredCandleIndex ?? viewModel.candles.indices.last,
                   idx < viewModel.computedIndicators.rsi.count,
                   let rsiVal = viewModel.computedIndicators.rsi[idx] {
                    Text(String(format: "%.2f", rsiVal))
                        .font(Font.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppTheme.rsiColor)
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(AppTheme.darkHeaderBg)
            
            Canvas { context, size in
                let chartWidth = size.width - priceAxisWidth
                guard chartWidth > 0, size.height > 0, !viewModel.candles.isEmpty else { return }
                
                let transform = CoordinateTransform(
                    visibleRange: viewModel.visibleRange,
                    priceRange: 0.0...100.0,
                    isLogScale: false
                )
                
                // 1. Threshold lines (70, 30, 50)
                for level in [30.0, 50.0, 70.0] {
                    let y = transform.y(forPrice: level, height: size.height)
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: chartWidth, y: y))
                    context.stroke(
                        line,
                        with: .color(level == 50 ? AppTheme.darkBorder.opacity(0.3) : AppTheme.darkBorder.opacity(0.6)),
                        style: StrokeStyle(lineWidth: 1, dash: level == 50 ? [2, 4] : [4, 4])
                    )
                    
                    // Axis label
                    let label = Text(String(format: "%.0f", level))
                        .font(Font.system(size: 9, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.5))
                    context.draw(label, at: CGPoint(x: chartWidth + 6, y: y), anchor: .leading)
                }
                
                // 2. RSI Line
                let startIndex = max(0, Int(floor(viewModel.visibleRange.lowerBound)) - 1)
                let endIndex = min(viewModel.candles.count - 1, Int(ceil(viewModel.visibleRange.upperBound)) + 1)
                
                guard startIndex <= endIndex, viewModel.computedIndicators.rsi.count > endIndex else { return }
                
                var rsiPath = Path()
                var hasStarted = false
                
                for i in startIndex...endIndex {
                    guard let rsiVal = viewModel.computedIndicators.rsi[i] else {
                        hasStarted = false
                        continue
                    }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let y = transform.y(forPrice: rsiVal, height: size.height)
                    
                    if !hasStarted {
                        rsiPath.move(to: CGPoint(x: x, y: y))
                        hasStarted = true
                    } else {
                        rsiPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                
                context.stroke(rsiPath, with: .color(AppTheme.rsiColor), lineWidth: 1.5)
                
                // Axis separator
                var axisLine = Path()
                axisLine.move(to: CGPoint(x: chartWidth, y: 0))
                axisLine.addLine(to: CGPoint(x: chartWidth, y: size.height))
                context.stroke(axisLine, with: .color(AppTheme.darkBorder), lineWidth: 1)
            }
        }
        .frame(height: 90)
        .background(AppTheme.darkSurface)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

public struct MACDPaneView: View {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Pane Header
            HStack(spacing: 12) {
                Text("MACD(\(viewModel.indicatorConfig.macdFastPeriod),\(viewModel.indicatorConfig.macdSlowPeriod),\(viewModel.indicatorConfig.macdSignalPeriod))")
                    .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                
                if let idx = viewModel.hoveredCandleIndex ?? viewModel.candles.indices.last,
                   let macd = viewModel.computedIndicators.macd {
                    if idx < macd.macdLine.count, let val = macd.macdLine[idx] {
                        Text("MACD: \(String(format: "%.2f", val))")
                            .font(Font.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.macdLine)
                    }
                    if idx < macd.signalLine.count, let sig = macd.signalLine[idx] {
                        Text("Signal: \(String(format: "%.2f", sig))")
                            .font(Font.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.macdSignal)
                    }
                    if idx < macd.histogram.count, let hist = macd.histogram[idx] {
                        Text("Hist: \(String(format: "%.2f", hist))")
                            .font(Font.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(hist >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(AppTheme.darkHeaderBg)
            
            Canvas { context, size in
                let chartWidth = size.width - priceAxisWidth
                guard chartWidth > 0, size.height > 0, !viewModel.candles.isEmpty,
                      let macd = viewModel.computedIndicators.macd else { return }
                
                let startIndex = max(0, Int(floor(viewModel.visibleRange.lowerBound)) - 1)
                let endIndex = min(viewModel.candles.count - 1, Int(ceil(viewModel.visibleRange.upperBound)) + 1)
                
                guard startIndex <= endIndex else { return }
                
                // Determine min/max across visible macd values
                var maxAbs: Double = 0.0001
                for i in startIndex...endIndex {
                    if i < macd.macdLine.count, let v = macd.macdLine[i] { maxAbs = max(maxAbs, abs(v)) }
                    if i < macd.signalLine.count, let s = macd.signalLine[i] { maxAbs = max(maxAbs, abs(s)) }
                    if i < macd.histogram.count, let h = macd.histogram[i] { maxAbs = max(maxAbs, abs(h)) }
                }
                
                let transform = CoordinateTransform(
                    visibleRange: viewModel.visibleRange,
                    priceRange: (-maxAbs * 1.1)...(maxAbs * 1.1),
                    isLogScale: false
                )
                
                // Zero Line
                let zeroY = transform.y(forPrice: 0.0, height: size.height)
                var zeroLine = Path()
                zeroLine.move(to: CGPoint(x: 0, y: zeroY))
                zeroLine.addLine(to: CGPoint(x: chartWidth, y: zeroY))
                context.stroke(zeroLine, with: .color(AppTheme.darkBorder.opacity(0.5)), lineWidth: 1)
                
                let visibleCount = viewModel.visibleRange.upperBound - viewModel.visibleRange.lowerBound
                let slotWidth = chartWidth / CGFloat(max(1.0, visibleCount))
                let barWidth = max(1.0, slotWidth * 0.6)
                
                // 1. Histogram Bars
                for i in startIndex...endIndex {
                    guard i < macd.histogram.count, let h = macd.histogram[i] else { continue }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let y = transform.y(forPrice: h, height: size.height)
                    
                    let barTop = min(zeroY, y)
                    let barHeight = max(1.0, abs(y - zeroY))
                    let rect = CGRect(x: x - barWidth / 2, y: barTop, width: barWidth, height: barHeight)
                    
                    let color = h >= 0 ? AppTheme.upGreen.opacity(0.8) : AppTheme.downRed.opacity(0.8)
                    context.fill(Path(rect), with: .color(color))
                }
                
                // 2. MACD Line
                var macdPath = Path()
                var hasMacd = false
                for i in startIndex...endIndex {
                    guard i < macd.macdLine.count, let v = macd.macdLine[i] else {
                        hasMacd = false
                        continue
                    }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let y = transform.y(forPrice: v, height: size.height)
                    if !hasMacd {
                        macdPath.move(to: CGPoint(x: x, y: y))
                        hasMacd = true
                    } else {
                        macdPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(macdPath, with: .color(AppTheme.macdLine), lineWidth: 1.5)
                
                // 3. Signal Line
                var sigPath = Path()
                var hasSig = false
                for i in startIndex...endIndex {
                    guard i < macd.signalLine.count, let s = macd.signalLine[i] else {
                        hasSig = false
                        continue
                    }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let y = transform.y(forPrice: s, height: size.height)
                    if !hasSig {
                        sigPath.move(to: CGPoint(x: x, y: y))
                        hasSig = true
                    } else {
                        sigPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(sigPath, with: .color(AppTheme.macdSignal), lineWidth: 1.5)
                
                // Axis separator
                var axisLine = Path()
                axisLine.move(to: CGPoint(x: chartWidth, y: 0))
                axisLine.addLine(to: CGPoint(x: chartWidth, y: size.height))
                context.stroke(axisLine, with: .color(AppTheme.darkBorder), lineWidth: 1)
            }
        }
        .frame(height: 95)
        .background(AppTheme.darkSurface)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

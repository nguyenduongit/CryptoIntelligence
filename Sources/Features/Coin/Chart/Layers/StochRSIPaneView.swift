import SwiftUI

public struct StochRSIPaneView: View {
    public let viewModel: ChartViewModel
    public let priceAxisWidth: CGFloat
    
    public init(viewModel: ChartViewModel, priceAxisWidth: CGFloat = 65) {
        self.viewModel = viewModel
        self.priceAxisWidth = priceAxisWidth
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Text("Stoch RSI(\(viewModel.indicatorConfig.stochRsiPeriod),\(viewModel.indicatorConfig.stochRsiKPeriod),\(viewModel.indicatorConfig.stochRsiDPeriod))")
                    .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                
                if let idx = viewModel.hoveredCandleIndex ?? viewModel.candles.indices.last,
                   let stoch = viewModel.computedIndicators.stochRSI {
                    if idx < stoch.kLine.count, let k = stoch.kLine[idx] {
                        Text("%K: \(String(format: "%.2f", k))")
                            .font(Font.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.cyan)
                    }
                    if idx < stoch.dLine.count, let d = stoch.dLine[idx] {
                        Text("%D: \(String(format: "%.2f", d))")
                            .font(Font.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.orange)
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
                      let stoch = viewModel.computedIndicators.stochRSI else { return }
                
                let transform = CoordinateTransform(
                    visibleRange: viewModel.visibleRange,
                    priceRange: 0.0...100.0,
                    isLogScale: false
                )
                
                // 1. Levels (20, 50, 80)
                for level in [20.0, 50.0, 80.0] {
                    let y = transform.y(forPrice: level, height: size.height)
                    var line = Path()
                    line.move(to: CGPoint(x: 0, y: y))
                    line.addLine(to: CGPoint(x: chartWidth, y: y))
                    context.stroke(
                        line,
                        with: .color(AppTheme.darkBorder.opacity(0.5)),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )
                    
                    let label = Text(String(format: "%.0f", level))
                        .font(Font.system(size: 9, design: .monospaced))
                        .foregroundColor(Color.white.opacity(0.5))
                    context.draw(label, at: CGPoint(x: chartWidth + 6, y: y), anchor: .leading)
                }
                
                let startIndex = max(0, Int(floor(viewModel.visibleRange.lowerBound)) - 1)
                let endIndex = min(viewModel.candles.count - 1, Int(ceil(viewModel.visibleRange.upperBound)) + 1)
                
                guard startIndex <= endIndex else { return }
                
                // 2. %K Line
                var kPath = Path()
                var hasK = false
                for i in startIndex...endIndex {
                    guard i < stoch.kLine.count, let kVal = stoch.kLine[i] else {
                        hasK = false
                        continue
                    }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let y = transform.y(forPrice: kVal, height: size.height)
                    if !hasK {
                        kPath.move(to: CGPoint(x: x, y: y))
                        hasK = true
                    } else {
                        kPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(kPath, with: .color(AppTheme.cyan), lineWidth: 1.5)
                
                // 3. %D Line
                var dPath = Path()
                var hasD = false
                for i in startIndex...endIndex {
                    guard i < stoch.dLine.count, let dVal = stoch.dLine[i] else {
                        hasD = false
                        continue
                    }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let y = transform.y(forPrice: dVal, height: size.height)
                    if !hasD {
                        dPath.move(to: CGPoint(x: x, y: y))
                        hasD = true
                    } else {
                        dPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(dPath, with: .color(AppTheme.orange), lineWidth: 1.5)
                
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

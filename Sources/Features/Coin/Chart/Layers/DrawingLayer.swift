import SwiftUI

public struct DrawingLayer: View {
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
            
            let allElements = viewModel.drawings + (viewModel.activeDrawing.map { [$0] } ?? [])
            
            for element in allElements {
                drawElement(element, context: &context, size: size, chartWidth: chartWidth)
            }
        }
        .allowsHitTesting(false)
    }
    
    private func drawElement(
        _ element: DrawingElement,
        context: inout GraphicsContext,
        size: CGSize,
        chartWidth: CGFloat
    ) {
        guard let p1 = viewModel.location(forCandlePoint: element.startPoint, chartWidth: chartWidth, chartHeight: size.height) else { return }
        let p2 = element.endPoint.flatMap { viewModel.location(forCandlePoint: $0, chartWidth: chartWidth, chartHeight: size.height) } ?? p1
        let isSelected = (element.id == viewModel.selectedDrawingId)
        
        switch element.type {
        case .cursor:
            break
            
        case .trendline:
            var path = Path()
            path.move(to: p1)
            path.addLine(to: p2)
            
            if isSelected {
                context.stroke(path, with: .color(AppTheme.accentBlue.opacity(0.3)), lineWidth: 6)
            }
            context.stroke(path, with: .color(AppTheme.accentBlue), lineWidth: isSelected ? 2.5 : 2)
            
            // Handles
            drawHandle(at: p1, isSelected: isSelected, color: AppTheme.accentBlue, context: &context)
            drawHandle(at: p2, isSelected: isSelected, color: AppTheme.accentBlue, context: &context)
            
        case .horizontalLine:
            var path = Path()
            path.move(to: CGPoint(x: 0, y: p1.y))
            path.addLine(to: CGPoint(x: chartWidth, y: p1.y))
            
            if isSelected {
                context.stroke(path, with: .color(AppTheme.warningYellow.opacity(0.3)), lineWidth: 5)
            }
            context.stroke(path, with: .color(AppTheme.warningYellow), style: StrokeStyle(lineWidth: isSelected ? 2 : 1.5, dash: [4, 4]))
            
            // Price Tag
            let tagRect = CGRect(x: chartWidth + 2, y: p1.y - 8, width: priceAxisWidth - 4, height: 16)
            context.fill(Path(roundedRect: tagRect, cornerRadius: 3), with: .color(AppTheme.warningYellow))
            let tagText = Text(Formatters.formatPrice(element.startPoint.price))
                .font(Font.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.black)
            context.draw(tagText, at: CGPoint(x: chartWidth + 6, y: p1.y), anchor: .leading)
            
            if isSelected {
                drawHandle(at: CGPoint(x: chartWidth / 2, y: p1.y), isSelected: true, color: AppTheme.warningYellow, context: &context)
            }
            
        case .priceRuler:
            let leftX = min(p1.x, p2.x)
            let rightX = max(p1.x, p2.x)
            let topY = min(p1.y, p2.y)
            let bottomY = max(p1.y, p2.y)
            
            let p1Price = element.startPoint.price
            let p2Price = element.endPoint?.price ?? p1Price
            let isGain = p2Price >= p1Price
            let boxColor = isGain ? AppTheme.upGreen : AppTheme.downRed
            
            // Box
            let boxRect = CGRect(x: leftX, y: topY, width: max(2, rightX - leftX), height: max(2, bottomY - topY))
            context.fill(Path(boxRect), with: .color(boxColor.opacity(isSelected ? 0.20 : 0.12)))
            context.stroke(Path(boxRect), with: .color(boxColor.opacity(isSelected ? 0.9 : 0.7)), lineWidth: isSelected ? 1.5 : 1)
            
            // Connecting Ray
            var line = Path()
            line.move(to: p1)
            line.addLine(to: p2)
            context.stroke(line, with: .color(boxColor), style: StrokeStyle(lineWidth: 1.5, dash: [3, 3]))
            
            // Measurement Text Badge
            let deltaPrice = p2Price - p1Price
            let percentChange = p1Price > 0 ? (deltaPrice / p1Price) * 100.0 : 0.0
            
            let timeDiffMs = abs((element.endPoint?.openTime ?? element.startPoint.openTime) - element.startPoint.openTime)
            let hours = Double(timeDiffMs) / (3600 * 1000.0)
            let durationStr: String
            if hours >= 24 {
                durationStr = String(format: "%.1fd", hours / 24.0)
            } else {
                durationStr = String(format: "%.0fh", hours)
            }
            
            let badgeText = String(format: "%@%.2f%% (%@, %@)", isGain ? "+" : "", percentChange, Formatters.formatPrice(abs(deltaPrice)), durationStr)
            
            let badgeCenter = CGPoint(x: (leftX + rightX) / 2, y: (topY + bottomY) / 2)
            let label = Text(badgeText)
                .font(Font.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            context.draw(label, at: badgeCenter, anchor: .center)
            
            // Handles
            drawHandle(at: p1, isSelected: isSelected, color: boxColor, context: &context)
            drawHandle(at: p2, isSelected: isSelected, color: boxColor, context: &context)
            
        case .fibonacci:
            let p1Price = element.startPoint.price
            let p2Price = element.endPoint?.price ?? p1Price
            let span = p2Price - p1Price
            
            let fibLevels: [(level: Double, name: String, color: Color)] = [
                (0.0, "0.0 (0%)", .white.opacity(0.6)),
                (0.236, "0.236 (23.6%)", AppTheme.cyan),
                (0.382, "0.382 (38.2%)", AppTheme.upGreen),
                (0.5, "0.5 (50.0%)", AppTheme.warningYellow),
                (0.618, "0.618 (Golden)", AppTheme.orange),
                (0.786, "0.786 (78.6%)", AppTheme.downRed),
                (1.0, "1.0 (100%)", .white.opacity(0.6))
            ]
            
            let transform = CoordinateTransform(
                visibleRange: viewModel.visibleRange,
                priceRange: viewModel.priceRange,
                isLogScale: viewModel.indicatorConfig.isLogScale
            )
            
            let leftX = min(p1.x, p2.x)
            let rightX = max(chartWidth, max(p1.x, p2.x))
            
            for fib in fibLevels {
                let levelPrice = p1Price + span * fib.level
                let y = transform.y(forPrice: levelPrice, height: size.height)
                
                var fibLine = Path()
                fibLine.move(to: CGPoint(x: leftX, y: y))
                fibLine.addLine(to: CGPoint(x: rightX, y: y))
                
                let isMajor = (fib.level == 0.0 || fib.level == 0.5 || fib.level == 0.618 || fib.level == 1.0)
                context.stroke(fibLine, with: .color(fib.color.opacity(isSelected ? 0.95 : 0.8)), lineWidth: isMajor ? 1.5 : 1)
                
                let fibLabel = Text("\(fib.name): \(Formatters.formatPrice(levelPrice))")
                    .font(Font.system(size: 9, weight: .medium, design: .monospaced))
                    .foregroundColor(fib.color)
                
                context.draw(fibLabel, at: CGPoint(x: leftX + 4, y: y - 7), anchor: .leading)
            }
            
            // Handles at 0% and 100% anchors
            drawHandle(at: p1, isSelected: isSelected, color: AppTheme.warningYellow, context: &context)
            drawHandle(at: p2, isSelected: isSelected, color: AppTheme.warningYellow, context: &context)
        }
    }
    
    private func drawHandle(at point: CGPoint, isSelected: Bool, color: Color, context: inout GraphicsContext) {
        let radius: CGFloat = isSelected ? 4.5 : 3.0
        let handleRect = CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2)
        
        if isSelected {
            // White interior, colored ring, shadow halo
            context.fill(Path(ellipseIn: handleRect), with: .color(.white))
            context.stroke(Path(ellipseIn: handleRect), with: .color(color), lineWidth: 2)
        } else {
            context.fill(Path(ellipseIn: handleRect), with: .color(color))
        }
    }
}

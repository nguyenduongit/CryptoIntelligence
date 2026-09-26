import SwiftUI

/// Mini sparkline chart rendered from ticker's open/high/low/close data.
/// Uses SwiftUI Canvas for zero-overhead GPU rendering. No API call required.
public struct SparklineView: View {
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let isUp: Bool

    public init(open: Double, high: Double, low: Double, close: Double, isUp: Bool) {
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.isUp = isUp
    }

    // Convenience init from ticker
    public init(ticker: MarketTicker24h) {
        // Binance 24hr ticker gives us: lastPrice (close), highPrice, lowPrice, priceChange
        // We reconstruct open = close - priceChange
        self.close = ticker.price
        self.open = ticker.price - ticker.priceChange
        self.high = ticker.highPrice
        self.low = ticker.lowPrice
        self.isUp = ticker.isBullish
    }

    private var lineColor: Color { isUp ? AppTheme.upGreen : AppTheme.downRed }
    private var fillColor: Color { isUp ? AppTheme.upGreen.opacity(0.15) : AppTheme.downRed.opacity(0.15) }

    public var body: some View {
        Canvas { context, size in
            let range = high - low
            guard range > 0, size.width > 0, size.height > 0 else {
                // Flat line if no range
                let y = size.height / 2
                var path = Path()
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: size.width, y: y))
                context.stroke(path, with: .color(lineColor.opacity(0.5)), lineWidth: 1)
                return
            }

            // Normalize a price value to a Y coordinate (top = high, bottom = low)
            func yPos(_ price: Double) -> CGFloat {
                let normalized = (price - low) / range
                return size.height - CGFloat(normalized) * size.height
            }

            // Build a representative path: open → low/high midpoint → close
            // with a subtle curve suggesting intraday movement
            let xOpen  = CGFloat(0)
            let xMid   = size.width * 0.5
            let xClose = size.width

            let yOpen  = yPos(open)
            let yMid   = isUp ? yPos(low + range * 0.3) : yPos(high - range * 0.3) // pullback / rally
            let yClose = yPos(close)

            // Fill area under the line
            var fillPath = Path()
            fillPath.move(to: CGPoint(x: xOpen, y: size.height))
            fillPath.addLine(to: CGPoint(x: xOpen, y: yOpen))
            fillPath.addQuadCurve(
                to: CGPoint(x: xMid, y: yMid),
                control: CGPoint(x: xOpen + size.width * 0.25, y: yOpen)
            )
            fillPath.addQuadCurve(
                to: CGPoint(x: xClose, y: yClose),
                control: CGPoint(x: xMid + size.width * 0.25, y: yMid)
            )
            fillPath.addLine(to: CGPoint(x: xClose, y: size.height))
            fillPath.closeSubpath()
            context.fill(fillPath, with: .color(fillColor))

            // Draw the stroke line
            var linePath = Path()
            linePath.move(to: CGPoint(x: xOpen, y: yOpen))
            linePath.addQuadCurve(
                to: CGPoint(x: xMid, y: yMid),
                control: CGPoint(x: xOpen + size.width * 0.25, y: yOpen)
            )
            linePath.addQuadCurve(
                to: CGPoint(x: xClose, y: yClose),
                control: CGPoint(x: xMid + size.width * 0.25, y: yMid)
            )
            context.stroke(linePath, with: .color(lineColor), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))

            // Close dot
            let dotRadius: CGFloat = 2.0
            let dotRect = CGRect(
                x: xClose - dotRadius,
                y: yClose - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            )
            context.fill(Path(ellipseIn: dotRect), with: .color(lineColor))
        }
        .frame(width: 64, height: 28)
    }
}

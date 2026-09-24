import SwiftUI

public struct CandlestickLayer: View {
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
            
            let visibleCount = viewModel.visibleRange.upperBound - viewModel.visibleRange.lowerBound
            let candleSlotWidth = chartWidth / CGFloat(max(1.0, visibleCount))
            let candleBodyWidth = max(1.0, candleSlotWidth * 0.75)
            let isClustered = candleSlotWidth < 1.5 // Multi-scale LOD mode
            
            // Find max volume in visible range for volume bar scaling
            var maxVol: Double = 1.0
            if viewModel.indicatorConfig.showVolume {
                for i in startIndex...endIndex {
                    let v = viewModel.candles[i].volume
                    if v > maxVol { maxVol = v }
                }
            }
            // Strict 14% max height at bottom so it never touches candles
            let maxVolumeHeight = size.height * 0.14
            let volumeBottomY = size.height - 20.0
            
            if isClustered {
                // LOD Aggregation: group candles by pixel column
                var pixelColumns = [Int: (open: Double, high: Double, low: Double, close: Double, volume: Double)]()
                
                for i in startIndex...endIndex {
                    let c = viewModel.candles[i]
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let pixelX = Int(round(x))
                    guard pixelX >= 0 && pixelX <= Int(chartWidth) else { continue }
                    
                    if var existing = pixelColumns[pixelX] {
                        existing.high = max(existing.high, c.high)
                        existing.low = min(existing.low, c.low)
                        existing.close = c.close
                        existing.volume += c.volume
                        pixelColumns[pixelX] = existing
                    } else {
                        pixelColumns[pixelX] = (open: c.open, high: c.high, low: c.low, close: c.close, volume: c.volume)
                    }
                }
                
                for (pixelX, agg) in pixelColumns {
                    let x = CGFloat(pixelX)
                    let yHigh = transform.y(forPrice: agg.high, height: size.height)
                    let yLow = transform.y(forPrice: agg.low, height: size.height)
                    let yOpen = transform.y(forPrice: agg.open, height: size.height)
                    let yClose = transform.y(forPrice: agg.close, height: size.height)
                    
                    let isBull = agg.close >= agg.open
                    let color = isBull ? AppTheme.upGreen : AppTheme.downRed
                    
                    // Volume bar
                    if viewModel.indicatorConfig.showVolume && maxVol > 0 {
                        let volHeight = CGFloat(agg.volume / maxVol) * maxVolumeHeight
                        let volRect = CGRect(x: x - 0.5, y: volumeBottomY - volHeight, width: 1.0, height: volHeight)
                        context.fill(Path(volRect), with: .color(color.opacity(0.35)))
                    }
                    
                    // Wick line
                    var wickPath = Path()
                    wickPath.move(to: CGPoint(x: x, y: yHigh))
                    wickPath.addLine(to: CGPoint(x: x, y: yLow))
                    context.stroke(wickPath, with: .color(color), lineWidth: 1)
                    
                    // Body
                    let bodyTop = min(yOpen, yClose)
                    let bodyHeight = max(1.0, abs(yClose - yOpen))
                    let bodyRect = CGRect(x: x - 0.5, y: bodyTop, width: 1.0, height: bodyHeight)
                    context.fill(Path(bodyRect), with: .color(color))
                }
            } else {
                // Standard Candlestick & Volume Rendering
                for i in startIndex...endIndex {
                    let candle = viewModel.candles[i]
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    guard x >= -candleBodyWidth && x <= chartWidth + candleBodyWidth else { continue }
                    
                    let isBull = candle.close >= candle.open
                    let candleColor = isBull ? AppTheme.upGreen : AppTheme.downRed
                    
                    // 1. Volume Bar at bottom (strictly in bottom 14%)
                    if viewModel.indicatorConfig.showVolume && maxVol > 0 {
                        let volHeight = CGFloat(candle.volume / maxVol) * maxVolumeHeight
                        let volRect = CGRect(
                            x: x - candleBodyWidth / 2,
                            y: volumeBottomY - volHeight,
                            width: candleBodyWidth,
                            height: volHeight
                        )
                        context.fill(Path(volRect), with: .color(candleColor.opacity(0.35)))
                    }
                    
                    // 2. High/Low Wick
                    let yHigh = transform.y(forPrice: candle.high, height: size.height)
                    let yLow = transform.y(forPrice: candle.low, height: size.height)
                    
                    var wickPath = Path()
                    wickPath.move(to: CGPoint(x: x, y: yHigh))
                    wickPath.addLine(to: CGPoint(x: x, y: yLow))
                    context.stroke(wickPath, with: .color(candleColor), lineWidth: 1)
                    
                    // 3. Candle Body
                    let yOpen = transform.y(forPrice: candle.open, height: size.height)
                    let yClose = transform.y(forPrice: candle.close, height: size.height)
                    
                    let bodyTop = min(yOpen, yClose)
                    let bodyHeight = max(1.0, abs(yClose - yOpen))
                    
                    let bodyRect = CGRect(
                        x: x - candleBodyWidth / 2,
                        y: bodyTop,
                        width: candleBodyWidth,
                        height: bodyHeight
                    )
                    
                    context.fill(Path(bodyRect), with: .color(candleColor))
                }
            }
            
            // 4. Volume MA(20) line overlay
            if viewModel.indicatorConfig.showVolume && viewModel.indicatorConfig.showVolumeMA && maxVol > 0 {
                var vmaPath = Path()
                var hasStarted = false
                let vmaValues = viewModel.computedIndicators.volumeMA
                
                for i in startIndex...endIndex {
                    guard i < vmaValues.count, let vma = vmaValues[i] else {
                        hasStarted = false
                        continue
                    }
                    let x = transform.x(forIndex: Double(i), width: chartWidth)
                    let vmaHeight = CGFloat(vma / maxVol) * maxVolumeHeight
                    let y = volumeBottomY - vmaHeight
                    
                    if !hasStarted {
                        vmaPath.move(to: CGPoint(x: x, y: y))
                        hasStarted = true
                    } else {
                        vmaPath.addLine(to: CGPoint(x: x, y: y))
                    }
                }
                context.stroke(vmaPath, with: .color(AppTheme.cyan.opacity(0.8)), lineWidth: 1.2)
            }
        }
    }
}

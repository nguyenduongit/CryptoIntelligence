import SwiftUI

/// 2D Canvas View rendering Coinglass-style Liquidation Heatmap
/// Includes: Left color legend, 2D heat matrix, K-line overlay, Price/Time axes, and Interactive crosshair tooltip.
public struct LiquidationHeatmap2DCanvasView: View {
    public let data: LiquidationHeatmap2DData
    public let palette: LiquidationHeatmapPalette
    public let liquidityThreshold: Double
    public let showCandleOverlay: Bool
    public let showHeatmapBands: Bool
    
    @State private var hoverPoint: CGPoint? = nil
    
    public init(
        data: LiquidationHeatmap2DData,
        palette: LiquidationHeatmapPalette = .coinglass,
        liquidityThreshold: Double = 0.20,
        showCandleOverlay: Bool = true,
        showHeatmapBands: Bool = true
    ) {
        self.data = data
        self.palette = palette
        self.liquidityThreshold = liquidityThreshold
        self.showCandleOverlay = showCandleOverlay
        self.showHeatmapBands = showHeatmapBands
    }
    
    private let priceAxisWidth: CGFloat = 68
    private let timeAxisHeight: CGFloat = 22
    private let colorBarWidth: CGFloat = 36
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                // 1. Left Vertical Color Scale Bar
                colorScaleBar
                    .frame(width: colorBarWidth)
                
                // 2. Main 2D Canvas Area
                GeometryReader { geo in
                    let canvasW = geo.size.width
                    let canvasH = geo.size.height
                    
                    ZStack(alignment: .topLeading) {
                        // Hardware-accelerated SwiftUI Canvas
                        Canvas { context, size in
                            drawHeatmapCanvas(context: context, size: size)
                        }
                        
                        // Interactive Crosshair & Tooltip Overlay
                        if let hp = hoverPoint, hp.x >= 0, hp.x <= canvasW, hp.y >= 0, hp.y <= canvasH {
                            crosshairView(point: hp, size: CGSize(width: canvasW, height: canvasH))
                        }
                        
                        // Watermark bottom-right
                        Text("coinglass / CryptoIntelligence")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.18))
                            .padding(8)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
                            .allowsHitTesting(false)
                    }
                    .background(Color(red: 0.05, green: 0.03, blue: 0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    .onContinuousHover { phase in
                        switch phase {
                        case .active(let location):
                            hoverPoint = location
                        case .ended:
                            hoverPoint = nil
                        }
                    }
                }
                
                // 3. Right Price Y-Axis Labels
                priceAxisLabels
                    .frame(width: priceAxisWidth)
            }
            .frame(height: 380)
            
            // 4. Bottom Time X-Axis
            timeAxisLabels
                .padding(.leading, colorBarWidth + 6)
                .padding(.trailing, priceAxisWidth)
                .frame(height: timeAxisHeight)
        }
        .padding(10)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Left Color Scale Bar
    
    private var colorScaleBar: some View {
        VStack(spacing: 2) {
            Text(Formatters.formatVolume(data.peakVolumeUSD))
                .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 3)
                    .fill(
                        LinearGradient(
                            colors: palette.previewColors.reversed(),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            .frame(width: 14)
            
            Text("0")
                .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                .foregroundColor(.white.opacity(0.65))
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Right Price Axis Labels
    
    private var priceAxisLabels: some View {
        GeometryReader { geo in
            let steps = 5
            let priceSpan = max(1e-8, data.maxPrice - data.minPrice)
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0...steps, id: \.self) { i in
                    let ratio = Double(steps - i) / Double(steps)
                    let p = data.minPrice + priceSpan * ratio
                    
                    Text(Formatters.formatPrice(p))
                        .font(.system(size: 9.5, weight: .medium, design: .monospaced))
                        .foregroundColor(abs(p - data.currentPrice) < (priceSpan * 0.05) ? AppTheme.cyan : .white.opacity(0.65))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if i < steps {
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    // MARK: - Bottom Time Axis Labels
    
    private var timeAxisLabels: some View {
        HStack {
            if !data.slices.isEmpty {
                let sliceStep = max(1, data.slices.count / 6)
                ForEach(0..<data.slices.count, id: \.self) { idx in
                    if idx % sliceStep == 0 || idx == data.slices.count - 1 {
                        Text(data.slices[idx].timeLabel)
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                        
                        if idx < data.slices.count - 1 {
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Canvas Rendering Engine
    
    private func drawHeatmapCanvas(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height
        let priceSpan = max(1e-8, data.maxPrice - data.minPrice)
        let sliceCount = max(1, data.slices.count)
        let colW = w / CGFloat(sliceCount)
        
        // 1. Grid lines (horizontal price lines)
        let gridSteps = 5
        for i in 1..<gridSteps {
            let y = h * (CGFloat(i) / CGFloat(gridSteps))
            var path = Path()
            path.move(to: CGPoint(x: 0, y: y))
            path.addLine(to: CGPoint(x: w, y: y))
            context.stroke(path, with: .color(Color.white.opacity(0.04)), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
        }
        
        // 2. Render Heatmap Bands (Coinglass continuous glowing ribbons)
        if showHeatmapBands {
            for (colIdx, slice) in data.slices.enumerated() {
                let x = CGFloat(colIdx) * colW
                
                for band in slice.bands {
                    // Filter out bands below user-specified liquidity threshold
                    guard band.intensity >= liquidityThreshold else { continue }
                    
                    let priceRatio = (band.price - data.minPrice) / priceSpan
                    guard priceRatio >= 0.0 && priceRatio <= 1.0 else { continue }
                    
                    let y = (1.0 - CGFloat(priceRatio)) * h
                    let bandH = max(6.0, h / 36.0)
                    
                    let bandColor = palette.color(for: band.intensity, threshold: liquidityThreshold)
                    let rect = CGRect(x: x, y: y - bandH / 2.0, width: colW + 0.5, height: bandH)
                    
                    // Soft vertical gradient glow
                    let stops: [Gradient.Stop] = [
                        .init(color: bandColor.opacity(0.08), location: 0.0),
                        .init(color: bandColor.opacity(0.65), location: 0.25),
                        .init(color: bandColor, location: 0.5),
                        .init(color: bandColor.opacity(0.65), location: 0.75),
                        .init(color: bandColor.opacity(0.08), location: 1.0)
                    ]
                    context.fill(
                        Path(rect),
                        with: .linearGradient(
                            Gradient(stops: stops),
                            startPoint: CGPoint(x: x, y: rect.minY),
                            endPoint: CGPoint(x: x, y: rect.maxY)
                        )
                    )
                    
                    // Luminous center laser line for high-intensity unswept levels
                    if band.intensity >= 0.70 && !band.isSwept {
                        var corePath = Path()
                        corePath.move(to: CGPoint(x: x, y: y))
                        corePath.addLine(to: CGPoint(x: x + colW + 0.5, y: y))
                        context.stroke(corePath, with: .color(bandColor.opacity(0.85)), lineWidth: 1.2)
                    }
                }
            }
        }
        
        // 3. Current Price Line (Cyan glowing dashed)
        let curRatio = (data.currentPrice - data.minPrice) / priceSpan
        if curRatio >= 0 && curRatio <= 1 {
            let curY = (1.0 - CGFloat(curRatio)) * h
            var curPath = Path()
            curPath.move(to: CGPoint(x: 0, y: curY))
            curPath.addLine(to: CGPoint(x: w, y: curY))
            
            // Soft cyan glow behind
            context.stroke(curPath, with: .color(AppTheme.cyan.opacity(0.25)), style: StrokeStyle(lineWidth: 3.5))
            // Crisp cyan dashed line
            context.stroke(curPath, with: .color(AppTheme.cyan), style: StrokeStyle(lineWidth: 1.2, dash: [6, 4]))
        }
        
        // 4. Supercharts Candlestick Overlay
        if showCandleOverlay {
            for (colIdx, slice) in data.slices.enumerated() {
                let candle = slice.candle
                let xCenter = (CGFloat(colIdx) + 0.5) * colW
                
                let highY = (1.0 - CGFloat((candle.high - data.minPrice) / priceSpan)) * h
                let lowY = (1.0 - CGFloat((candle.low - data.minPrice) / priceSpan)) * h
                let openY = (1.0 - CGFloat((candle.open - data.minPrice) / priceSpan)) * h
                let closeY = (1.0 - CGFloat((candle.close - data.minPrice) / priceSpan)) * h
                
                let candleColor = candle.isBullish ? AppTheme.upGreen : AppTheme.downRed
                
                // Wick
                var wickPath = Path()
                wickPath.move(to: CGPoint(x: xCenter, y: highY))
                wickPath.addLine(to: CGPoint(x: xCenter, y: lowY))
                context.stroke(wickPath, with: .color(candleColor.opacity(0.85)), lineWidth: 1.0)
                
                // Body - compact & sleek so it sits gracefully over the heatmap
                let bodyTop = min(openY, closeY)
                let bodyH = max(2.0, abs(closeY - openY))
                let bodyW = min(12.0, max(3.0, colW * 0.42))
                let bodyRect = CGRect(x: xCenter - bodyW / 2.0, y: bodyTop, width: bodyW, height: bodyH)
                
                context.fill(Path(bodyRect), with: .color(candleColor.opacity(0.80)))
                context.stroke(Path(bodyRect), with: .color(candleColor), lineWidth: 1.0)
            }
        }
    }
    
    // MARK: - Interactive Crosshair View
    
    private func crosshairView(point: CGPoint, size: CGSize) -> some View {
        let priceSpan = max(1e-8, data.maxPrice - data.minPrice)
        let priceRatio = Double(1.0 - (point.y / size.height))
        let hoverPrice = data.minPrice + priceSpan * max(0.0, min(1.0, priceRatio))
        
        let sliceIdx = min(data.slices.count - 1, max(0, Int((point.x / size.width) * CGFloat(data.slices.count))))
        let slice = data.slices.isEmpty ? nil : data.slices[sliceIdx]
        
        let dist = ((hoverPrice - data.currentPrice) / max(1e-8, data.currentPrice)) * 100.0
        let distSign = dist >= 0 ? "+" : ""
        
        return ZStack {
            // Horizontal Crosshair Line
            Path { path in
                path.move(to: CGPoint(x: 0, y: point.y))
                path.addLine(to: CGPoint(x: size.width, y: point.y))
            }
            .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Vertical Crosshair Line
            Path { path in
                path.move(to: CGPoint(x: point.x, y: 0))
                path.addLine(to: CGPoint(x: point.x, y: size.height))
            }
            .stroke(Color.white.opacity(0.4), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            
            // Tooltip Pill
            let tooltipX = min(size.width - 90, max(90, point.x))
            let tooltipY = point.y < 90 ? point.y + 60 : point.y - 45
            
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 4) {
                    Text(Formatters.formatPrice(hoverPrice))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text("\(distSign)\(String(format: "%.1f%%", dist))")
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(dist >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                }
                
                if let sl = slice {
                    Text("Thời điểm: \(sl.timeLabel)")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                    
                    // Nearest band estimation (within 2% proximity)
                    if let nearest = sl.bands.min(by: { abs($0.price - hoverPrice) < abs($1.price - hoverPrice) }),
                       abs(nearest.price - hoverPrice) / max(1e-8, hoverPrice) < 0.02 {
                        HStack(spacing: 4) {
                            Text("Đòn bẩy \(nearest.leverageTier):")
                                .font(.system(size: 9))
                                .foregroundColor(nearest.side.color)
                            Text(Formatters.formatVolume(nearest.volumeUSD) + " USD")
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            if nearest.isSwept {
                                Text("(Đã quét)")
                                    .font(.system(size: 8.5))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 6)
            .background(Color.black.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.accentBlue.opacity(0.6), lineWidth: 1)
            )
            .position(x: tooltipX, y: tooltipY)
            .shadow(color: .black.opacity(0.4), radius: 6, x: 0, y: 3)
        }
        .allowsHitTesting(false)
    }
}

import SwiftUI

public struct CryptoBubblesView: View {
    public let tickers: [MarketTicker24h]
    public let sizingMetric: BubbleSizingMetric
    public let onSelectSymbol: (String) -> Void
    
    @State private var engine: BubblePhysicsEngine = BubblePhysicsEngine()
    @State private var hoveredSymbol: String? = nil
    @State private var draggingSymbol: String? = nil
    
    // Zoom & Pan state
    @State private var zoomScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var dragStartOffset: CGSize = .zero
    
    public init(
        tickers: [MarketTicker24h],
        sizingMetric: BubbleSizingMetric = .marketCap,
        onSelectSymbol: @escaping (String) -> Void
    ) {
        self.tickers = tickers
        self.sizingMetric = sizingMetric
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            TimelineView(.animation) { timeline in
                ZStack {
                    // Deep Dark Space Background with subtle vignette
                    RadialGradient(
                        colors: [
                            Color(red: 0.08, green: 0.10, blue: 0.14),
                            Color(red: 0.03, green: 0.04, blue: 0.06)
                        ],
                        center: .center,
                        startRadius: 80,
                        endRadius: max(size.width, size.height) * 0.75
                    )
                    .contentShape(Rectangle())
                    .gesture(
                        // Pan gesture on canvas background
                        DragGesture()
                            .onChanged { value in
                                panOffset = CGSize(
                                    width: dragStartOffset.width + value.translation.width,
                                    height: dragStartOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                dragStartOffset = panOffset
                            }
                    )
                    
                    // Bubble Simulation Canvas with Zoom & Pan transform
                    ZStack {
                        ForEach(engine.bubbles) { node in
                            let isHovered = (hoveredSymbol == node.symbol)
                            let isDragging = (draggingSymbol == node.symbol)
                            
                            BubbleItemView(
                                node: node,
                                metric: sizingMetric,
                                isHovered: isHovered,
                                isDragging: isDragging,
                                onSelect: {
                                    onSelectSymbol(node.symbol)
                                }
                            )
                            .position(node.position)
                            .gesture(
                                DragGesture(minimumDistance: 2)
                                    .onChanged { value in
                                        draggingSymbol = node.symbol
                                        // Adjust position taking zoom and pan into account
                                        let adjustedPoint = CGPoint(
                                            x: (value.location.x - panOffset.width) / zoomScale,
                                            y: (value.location.y - panOffset.height) / zoomScale
                                        )
                                        engine.updateDrag(symbol: node.symbol, to: adjustedPoint)
                                    }
                                    .onEnded { value in
                                        draggingSymbol = nil
                                        engine.endDrag(symbol: node.symbol, releaseVelocity: CGPoint(
                                            x: value.velocity.width / zoomScale,
                                            y: value.velocity.height / zoomScale
                                        ))
                                    }
                            )
                            .onHover { hovering in
                                if hovering {
                                    hoveredSymbol = node.symbol
                                } else if hoveredSymbol == node.symbol {
                                    hoveredSymbol = nil
                                }
                            }
                        }
                    }
                    .scaleEffect(zoomScale)
                    .offset(panOffset)
                    .animation(.spring(response: 0.25, dampingFraction: 0.8), value: zoomScale)
                    
                    // Floating Controls Overlay in Bottom Right
                    VStack(alignment: .trailing, spacing: 8) {
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Spacer()
                            
                            // Zoom & Re-pack Toolbar
                            HStack(spacing: 6) {
                                // Zoom Out
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        zoomScale = max(0.6, zoomScale - 0.15)
                                    }
                                }) {
                                    Image(systemName: "minus.magnifyingglass")
                                        .font(.system(size: 11, weight: .bold))
                                        .frame(width: 26, height: 26)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                                .help("Thu nhỏ")
                                
                                // Zoom Label / Reset
                                Button(action: {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        zoomScale = 1.0
                                        panOffset = .zero
                                        dragStartOffset = .zero
                                    }
                                }) {
                                    Text("\(Int(zoomScale * 100))%")
                                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                                        .foregroundColor(Color.cyan)
                                        .padding(.horizontal, 6)
                                        .frame(height: 26)
                                }
                                .buttonStyle(.plain)
                                .help("Đặt lại kích thước chuẩn (100%)")
                                
                                // Zoom In
                                Button(action: {
                                    withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                                        zoomScale = min(2.2, zoomScale + 0.15)
                                    }
                                }) {
                                    Image(systemName: "plus.magnifyingglass")
                                        .font(.system(size: 11, weight: .bold))
                                        .frame(width: 26, height: 26)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .buttonStyle(.plain)
                                .help("Phóng to")
                                
                                Divider()
                                    .frame(height: 14)
                                    .background(Color.white.opacity(0.2))
                                
                                // Re-pack / Shake
                                Button(action: {
                                    engine.repack()
                                }) {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                            .font(.system(size: 10, weight: .semibold))
                                        Text("Xếp lại")
                                            .font(.system(size: 10.5, weight: .medium))
                                    }
                                    .foregroundColor(.white.opacity(0.85))
                                    .padding(.horizontal, 8)
                                    .frame(height: 26)
                                }
                                .buttonStyle(.plain)
                                .help("Tái sắp xếp và làm mới vị trí các bong bóng")
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 4)
                            .background(AppTheme.darkCard.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                            .shadow(color: Color.black.opacity(0.4), radius: 6, x: 0, y: 3)
                        }
                        .padding(.trailing, 14)
                        .padding(.bottom, 12)
                    }
                }
                .onChange(of: timeline.date) { _, _ in
                    engine.step(dt: 0.016)
                }
            }
            .onAppear {
                engine.update(with: tickers, metric: sizingMetric, in: size)
            }
            .onChange(of: size) { _, newSize in
                engine.update(with: tickers, metric: sizingMetric, in: newSize)
            }
            .onChange(of: tickers) { _, newTickers in
                engine.update(with: newTickers, metric: sizingMetric, in: size)
            }
            .onChange(of: sizingMetric) { _, newMetric in
                engine.update(with: tickers, metric: newMetric, in: size)
            }
        }
        .clipped()
    }
}

// MARK: - Bubble Item View (Matches CryptoBubbles.net visual style)
private struct BubbleItemView: View {
    let node: BubbleNode
    let metric: BubbleSizingMetric
    let isHovered: Bool
    let isDragging: Bool
    let onSelect: () -> Void
    
    var body: some View {
        let diameter = node.radius * 2
        let rimColor = node.isBullish
            ? Color(red: 0.0, green: 0.96, blue: 0.46) // Neon Emerald Green
            : Color(red: 1.0, green: 0.20, blue: 0.32) // Neon Crimson Red
        
        Button(action: onSelect) {
            ZStack {
                // 1. Outer Glow Shadow
                Circle()
                    .fill(rimColor.opacity(isHovered ? 0.45 : 0.22))
                    .frame(width: diameter + 8, height: diameter + 8)
                    .blur(radius: isHovered ? 9 : 4)
                
                // 2. Bubble Body with Dark Glass Radial Gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: node.isBullish ? [
                                Color(red: 0.09, green: 0.34, blue: 0.17),
                                Color(red: 0.03, green: 0.14, blue: 0.07),
                                Color(red: 0.01, green: 0.07, blue: 0.03)
                            ] : [
                                Color(red: 0.38, green: 0.08, blue: 0.12),
                                Color(red: 0.18, green: 0.03, blue: 0.05),
                                Color(red: 0.08, green: 0.01, blue: 0.02)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: node.radius
                        )
                    )
                    .frame(width: diameter, height: diameter)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        rimColor,
                                        rimColor.opacity(0.85),
                                        rimColor.opacity(0.4)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isHovered ? 3.0 : (node.radius > 45 ? 2.2 : 1.6)
                            )
                    )
                
                // 3. Information Content inside Bubble
                VStack(spacing: contentSpacing) {
                    // Mini Icon / Logo Token Initial (only on medium/large bubbles)
                    if node.radius >= 38 {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.14))
                                .frame(width: iconSize, height: iconSize)
                            
                            Text(String(node.baseAsset.prefix(1)))
                                .font(.system(size: iconSize * 0.55, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Token Symbol (always fits, never cuts off)
                    Text(node.baseAsset)
                        .font(.system(size: symbolFontSize, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    
                    // % Price Change (clean format, never truncates with ..)
                    Text(formattedChange)
                        .font(.system(size: percentFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    
                    // Secondary Metric (Vốn hóa, Volume hoặc Giá - only on large bubbles)
                    if node.radius >= 52 {
                        Text(node.formattedSubMetric(for: metric))
                            .font(.system(size: subMetricFontSize, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                }
                .padding(3)
                .frame(width: diameter * 0.88, height: diameter * 0.88)
            }
            .scaleEffect(isDragging ? 1.12 : (isHovered ? 1.08 : 1.0))
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isHovered)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isDragging)
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .help("\(node.symbol) | Giá: \(Formatters.formatPrice(node.price)) | 24h: \(Formatters.formatPercentage(node.priceChangePercent)) | Vốn hóa: \(Formatters.formatMarketCap(node.estimatedMarketCap)) | Vol 24h: $\(Formatters.formatVolume(node.quoteVolume))\n(Kéo thả để nảy vật lý, nhấn để mở biểu đồ)")
    }
    
    // MARK: - Scaled Font Sizes based on Radius
    private var symbolFontSize: CGFloat {
        max(10.0, min(24.0, node.radius * 0.38))
    }
    
    private var percentFontSize: CGFloat {
        max(9.0, min(18.0, node.radius * 0.30))
    }
    
    private var subMetricFontSize: CGFloat {
        max(8.0, min(11.5, node.radius * 0.20))
    }
    
    private var iconSize: CGFloat {
        max(14.0, min(24.0, node.radius * 0.32))
    }
    
    private var contentSpacing: CGFloat {
        if node.radius > 55 { return 3.5 }
        if node.radius > 40 { return 2.0 }
        return 1.0
    }
    
    private var formattedChange: String {
        let prefix = node.priceChangePercent > 0 ? "+" : ""
        return String(format: "%@%.1f%%", prefix, node.priceChangePercent)
    }
}

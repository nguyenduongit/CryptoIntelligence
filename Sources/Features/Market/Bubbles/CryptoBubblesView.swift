import SwiftUI

public struct CryptoBubblesView: View {
    public let tickers: [MarketTicker24h]
    public let sizingMetric: BubbleSizingMetric
    public let onSelectSymbol: (String) -> Void
    
    @State private var engine: BubblePhysicsEngine = BubblePhysicsEngine()
    @State private var hoveredSymbol: String? = nil
    @State private var draggingSymbol: String? = nil
    
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
                Canvas { context, canvasSize in
                    // Background deep dark grid / cosmic glow
                }
                .background(
                    RadialGradient(
                        colors: [
                            Color(red: 0.07, green: 0.09, blue: 0.13),
                            Color(red: 0.03, green: 0.04, blue: 0.06)
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: max(size.width, size.height) * 0.7
                    )
                )
                .overlay(
                    ZStack {
                        // Render interactive bubbles
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
                                        engine.updateDrag(symbol: node.symbol, to: value.location)
                                    }
                                    .onEnded { value in
                                        draggingSymbol = nil
                                        engine.endDrag(symbol: node.symbol, releaseVelocity: CGPoint(
                                            x: value.velocity.width,
                                            y: value.velocity.height
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
                )
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
            ? Color(red: 0.0, green: 0.95, blue: 0.45) // Neon Emerald Green
            : Color(red: 1.0, green: 0.20, blue: 0.30) // Neon Crimson Red
        
        Button(action: onSelect) {
            ZStack {
                // 1. Outer Glow Shadow
                Circle()
                    .fill(rimColor.opacity(isHovered ? 0.45 : 0.22))
                    .frame(width: diameter + 8, height: diameter + 8)
                    .blur(radius: isHovered ? 8 : 4)
                
                // 2. Bubble Body with Dark Glass Radial Gradient
                Circle()
                    .fill(
                        RadialGradient(
                            colors: node.isBullish ? [
                                Color(red: 0.08, green: 0.32, blue: 0.16),
                                Color(red: 0.02, green: 0.12, blue: 0.06),
                                Color(red: 0.01, green: 0.06, blue: 0.03)
                            ] : [
                                Color(red: 0.36, green: 0.08, blue: 0.12),
                                Color(red: 0.16, green: 0.03, blue: 0.05),
                                Color(red: 0.07, green: 0.01, blue: 0.02)
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
                                        rimColor.opacity(0.8),
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
                    // Mini Icon / Logo Token Initials
                    if node.radius >= 32 {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.12))
                                .frame(width: iconSize, height: iconSize)
                            
                            Text(String(node.baseAsset.prefix(1)))
                                .font(.system(size: iconSize * 0.55, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Token Symbol
                    Text(node.baseAsset)
                        .font(.system(size: symbolFontSize, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    
                    // % Price Change
                    Text(Formatters.formatPercentage(node.priceChangePercent))
                        .font(.system(size: percentFontSize, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Secondary Metric (Vốn hóa, Volume hoặc Giá)
                    if node.radius >= 44 {
                        Text(node.formattedSubMetric(for: metric))
                            .font(.system(size: subMetricFontSize, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.75))
                            .lineLimit(1)
                    }
                }
                .padding(4)
                .frame(width: diameter * 0.85, height: diameter * 0.85)
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
        max(9.5, min(22, node.radius * 0.36))
    }
    
    private var percentFontSize: CGFloat {
        max(8.5, min(17, node.radius * 0.30))
    }
    
    private var subMetricFontSize: CGFloat {
        max(7.5, min(11, node.radius * 0.20))
    }
    
    private var iconSize: CGFloat {
        max(12, min(22, node.radius * 0.32))
    }
    
    private var contentSpacing: CGFloat {
        if node.radius > 50 { return 3.5 }
        if node.radius > 35 { return 2.0 }
        return 1.0
    }
}

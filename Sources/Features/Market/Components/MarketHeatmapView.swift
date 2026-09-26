import SwiftUI

public struct MarketHeatmapView: View {
    public let tickers: [MarketTicker24h]
    public let isSizingByVolume: Bool
    public let onSelectSymbol: (String) -> Void
    
    @State private var hoveredSymbol: String? = nil
    
    public init(
        tickers: [MarketTicker24h],
        isSizingByVolume: Bool = false,
        onSelectSymbol: @escaping (String) -> Void
    ) {
        self.tickers = tickers
        self.isSizingByVolume = isSizingByVolume
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 145, maximum: 260), spacing: 8)
                ],
                spacing: 8
            ) {
                ForEach(Array(tickers.enumerated()), id: \.element.id) { index, ticker in
                    let tier = tierForIndex(index)
                    HeatmapTileView(
                        ticker: ticker,
                        rank: index + 1,
                        tier: tier,
                        isSizingByVolume: isSizingByVolume,
                        isHovered: hoveredSymbol == ticker.symbol,
                        onSelect: { onSelectSymbol(ticker.symbol) }
                    )
                    .onHover { hovering in
                        if hovering {
                            hoveredSymbol = ticker.symbol
                        } else if hoveredSymbol == ticker.symbol {
                            hoveredSymbol = nil
                        }
                    }
                }
            }
            .padding(12)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSizingByVolume)
        }
        .background(AppTheme.darkBackground)
    }
    
    private func tierForIndex(_ index: Int) -> HeatmapTier {
        if index < 2 {
            return .mega
        } else if index < 8 {
            return .large
        } else if index < 24 {
            return .medium
        } else {
            return .compact
        }
    }
}

public enum HeatmapTier {
    case mega
    case large
    case medium
    case compact
    
    var minHeight: CGFloat {
        switch self {
        case .mega: return 130
        case .large: return 105
        case .medium: return 82
        case .compact: return 68
        }
    }
}

private struct HeatmapTileView: View {
    let ticker: MarketTicker24h
    let rank: Int
    let tier: HeatmapTier
    let isSizingByVolume: Bool
    let isHovered: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: tierSpacing) {
                // Top Row: Symbol, Rank & Sector
                HStack(alignment: .center, spacing: 4) {
                    Text(ticker.baseAsset)
                        .font(.system(size: symbolFontSize, weight: .bold))
                        .foregroundColor(.white)
                    
                    if tier == .mega || tier == .large {
                        Text("#\(rank)")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1.5)
                            .background(Color.white.opacity(0.18))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    
                    Spacer()
                    
                    if tier != .compact {
                        Text(ticker.sector.rawValue)
                            .font(.system(size: 8.5, weight: .medium))
                            .padding(.horizontal, 4.5)
                            .padding(.vertical, 1.5)
                            .background(Color.black.opacity(0.4))
                            .foregroundColor(.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                
                // Center Row: Price & % Change
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(Formatters.formatPrice(ticker.price))
                        .font(.system(size: priceFontSize, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: ticker.priceChangePercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: percentFontSize - 2, weight: .bold))
                        Text(Formatters.formatPercentage(ticker.priceChangePercent))
                            .font(.system(size: percentFontSize, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(.white)
                }
                
                // Bottom Row: Dynamic Primary Metric (Market Cap vs Volume 24h)
                HStack(alignment: .center, spacing: 4) {
                    if isSizingByVolume {
                        // Sizing Mode: Volume 24h
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 8.5))
                                .foregroundColor(Color.orange.opacity(0.9))
                            Text("Vol: " + Formatters.formatVolume(ticker.quoteVolume))
                                .font(.system(size: metricFontSize, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(.white.opacity(0.85))
                    } else {
                        // Sizing Mode: Market Cap
                        HStack(spacing: 3) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 8.5))
                                .foregroundColor(AppTheme.cyan.opacity(0.9))
                            Text("Cap: " + Formatters.formatMarketCap(ticker.estimatedMarketCap))
                                .font(.system(size: metricFontSize, weight: .medium, design: .monospaced))
                        }
                        .foregroundColor(.white.opacity(0.85))
                    }
                    
                    Spacer()
                    
                    if isHovered {
                        HStack(spacing: 2) {
                            Text("Chart")
                                .font(.system(size: 8.5, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 8.5))
                        }
                        .foregroundColor(.white)
                        .transition(.opacity)
                    } else if tier == .mega {
                        Text(isSizingByVolume ? "\(Formatters.formatNumber(ticker.tradesCount)) trades" : "Vol: \(Formatters.formatVolume(ticker.quoteVolume))")
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(tierPadding)
            .frame(maxWidth: .infinity, minHeight: tier.minHeight, alignment: .topLeading)
            .background(heatmapBackground(for: ticker.priceChangePercent))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isHovered ? Color.white.opacity(0.7) : (tier == .mega ? Color.white.opacity(0.25) : Color.clear),
                        lineWidth: isHovered ? 1.5 : 1
                    )
            )
            .shadow(color: isHovered ? Color.black.opacity(0.45) : Color.clear, radius: 5, x: 0, y: 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .help("\(ticker.symbol) | Giá: \(Formatters.formatPrice(ticker.price)) | 24h: \(Formatters.formatPercentage(ticker.priceChangePercent)) | Vốn hóa: \(Formatters.formatMarketCap(ticker.estimatedMarketCap)) | Vol 24h: $\(Formatters.formatVolume(ticker.quoteVolume))")
    }
    
    // MARK: - Responsive Metrics
    private var tierSpacing: CGFloat {
        switch tier {
        case .mega: return 8
        case .large: return 6
        case .medium: return 4
        case .compact: return 3
        }
    }
    
    private var tierPadding: CGFloat {
        switch tier {
        case .mega: return 11
        case .large: return 9
        case .medium: return 8
        case .compact: return 7
        }
    }
    
    private var symbolFontSize: CGFloat {
        switch tier {
        case .mega: return 17
        case .large: return 14.5
        case .medium: return 13
        case .compact: return 12
        }
    }
    
    private var priceFontSize: CGFloat {
        switch tier {
        case .mega: return 14
        case .large: return 12.5
        case .medium: return 11.5
        case .compact: return 10.5
        }
    }
    
    private var percentFontSize: CGFloat {
        switch tier {
        case .mega: return 13.5
        case .large: return 12
        case .medium: return 11
        case .compact: return 10
        }
    }
    
    private var metricFontSize: CGFloat {
        switch tier {
        case .mega: return 10.5
        case .large: return 9.5
        case .medium: return 9
        case .compact: return 8.5
        }
    }
    
    // MARK: - Gradient Background
    private func heatmapBackground(for change: Double) -> some View {
        let (topColor, bottomColor) = gradientColors(for: change)
        return LinearGradient(
            colors: [topColor, bottomColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private func gradientColors(for change: Double) -> (Color, Color) {
        if change >= 10.0 {
            // Bright Emerald Green
            return (Color(red: 0.05, green: 0.58, blue: 0.26), Color(red: 0.02, green: 0.42, blue: 0.18))
        } else if change >= 4.0 {
            // Strong Green
            return (Color(red: 0.08, green: 0.46, blue: 0.22), Color(red: 0.04, green: 0.33, blue: 0.15))
        } else if change >= 0.0 {
            // Mild Dark Green
            return (Color(red: 0.10, green: 0.32, blue: 0.18), Color(red: 0.07, green: 0.23, blue: 0.12))
        } else if change >= -4.0 {
            // Mild Dark Red
            return (Color(red: 0.36, green: 0.12, blue: 0.12), Color(red: 0.25, green: 0.08, blue: 0.08))
        } else if change >= -10.0 {
            // Strong Red
            return (Color(red: 0.56, green: 0.12, blue: 0.15), Color(red: 0.42, green: 0.08, blue: 0.10))
        } else {
            // Crimson Scarlet Red
            return (Color(red: 0.72, green: 0.10, blue: 0.15), Color(red: 0.52, green: 0.06, blue: 0.10))
        }
    }
}

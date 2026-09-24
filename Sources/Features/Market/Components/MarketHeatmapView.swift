import SwiftUI

public struct MarketHeatmapView: View {
    public let tickers: [MarketTicker24h]
    public let onSelectSymbol: (String) -> Void
    
    @State private var hoveredSymbol: String? = nil
    
    public init(tickers: [MarketTicker24h], onSelectSymbol: @escaping (String) -> Void) {
        self.tickers = tickers
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: 140, maximum: 240), spacing: 8)
                ],
                spacing: 8
            ) {
                ForEach(tickers) { ticker in
                    HeatmapTileView(
                        ticker: ticker,
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
        }
        .background(AppTheme.darkBackground)
    }
}

private struct HeatmapTileView: View {
    let ticker: MarketTicker24h
    let isHovered: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 6) {
                // Top row: Symbol & Sector
                HStack {
                    Text(ticker.baseAsset)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text(ticker.sector.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.black.opacity(0.35))
                        .foregroundColor(.white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                
                // Center row: Price & % Change
                HStack(alignment: .lastTextBaseline) {
                    Text(Formatters.formatPrice(ticker.price))
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(Formatters.formatPercentage(ticker.priceChangePercent))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Bottom row: 24h Volume & Quick Action hint
                HStack {
                    HStack(spacing: 3) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 9))
                        Text(Formatters.formatVolume(ticker.quoteVolume))
                            .font(.system(size: 10, design: .monospaced))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    if isHovered {
                        HStack(spacing: 2) {
                            Text("Xem Chart")
                                .font(.system(size: 9, weight: .bold))
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 9))
                        }
                        .foregroundColor(.white)
                        .transition(.opacity)
                    }
                }
            }
            .padding(10)
            .frame(minHeight: 85)
            .background(heatmapBackground(for: ticker.priceChangePercent))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isHovered ? Color.white.opacity(0.6) : Color.clear, lineWidth: isHovered ? 1.5 : 1)
            )
            .shadow(color: isHovered ? Color.black.opacity(0.4) : Color.clear, radius: 4, x: 0, y: 2)
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .help("\(ticker.symbol) - Nhấn để mở Chart nến và phân tích kỹ thuật")
    }
    
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
            return (Color(red: 0.05, green: 0.55, blue: 0.25), Color(red: 0.02, green: 0.40, blue: 0.18))
        } else if change >= 4.0 {
            // Strong Green
            return (Color(red: 0.08, green: 0.45, blue: 0.22), Color(red: 0.04, green: 0.32, blue: 0.15))
        } else if change >= 0.0 {
            // Mild Dark Green
            return (Color(red: 0.10, green: 0.30, blue: 0.18), Color(red: 0.07, green: 0.22, blue: 0.12))
        } else if change >= -4.0 {
            // Mild Dark Red
            return (Color(red: 0.35, green: 0.12, blue: 0.12), Color(red: 0.24, green: 0.08, blue: 0.08))
        } else if change >= -10.0 {
            // Strong Red
            return (Color(red: 0.55, green: 0.12, blue: 0.15), Color(red: 0.40, green: 0.08, blue: 0.10))
        } else {
            // Crimson Red
            return (Color(red: 0.70, green: 0.10, blue: 0.15), Color(red: 0.50, green: 0.06, blue: 0.10))
        }
    }
}

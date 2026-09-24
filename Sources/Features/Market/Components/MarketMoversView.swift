import SwiftUI

public struct MarketMoversView: View {
    public let topGainers: [MarketTicker24h]
    public let topLosers: [MarketTicker24h]
    public let topVolumes: [MarketTicker24h]
    public let onSelectSymbol: (String) -> Void
    
    public init(
        topGainers: [MarketTicker24h],
        topLosers: [MarketTicker24h],
        topVolumes: [MarketTicker24h],
        onSelectSymbol: @escaping (String) -> Void
    ) {
        self.topGainers = topGainers
        self.topLosers = topLosers
        self.topVolumes = topVolumes
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 14) {
                // Column 1: Top Gainers
                MoversColumnView(
                    title: "Top Tăng Giá 24h",
                    icon: "arrow.up.right.circle.fill",
                    headerColor: AppTheme.upGreen,
                    tickers: topGainers,
                    onSelectSymbol: onSelectSymbol
                )
                
                // Column 2: Top Losers
                MoversColumnView(
                    title: "Top Giảm Giá 24h",
                    icon: "arrow.down.right.circle.fill",
                    headerColor: AppTheme.downRed,
                    tickers: topLosers,
                    onSelectSymbol: onSelectSymbol
                )
                
                // Column 3: Top Volume
                MoversColumnView(
                    title: "Khối Lượng Cao Nhất",
                    icon: "flame.fill",
                    headerColor: AppTheme.orange,
                    tickers: topVolumes,
                    onSelectSymbol: onSelectSymbol
                )
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
    }
}

private struct MoversColumnView: View {
    let title: String
    let icon: String
    let headerColor: Color
    let tickers: [MarketTicker24h]
    let onSelectSymbol: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(headerColor)
                    .font(.system(size: 13, weight: .bold))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("\(tickers.count)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white.opacity(0.7))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.darkHeaderBg)
            
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1)
            
            // List Items
            VStack(spacing: 0) {
                ForEach(Array(tickers.enumerated()), id: \.element.id) { index, ticker in
                    MoversRowItemView(
                        rank: index + 1,
                        ticker: ticker,
                        onSelect: { onSelectSymbol(ticker.symbol) }
                    )
                    
                    if index < tickers.count - 1 {
                        Rectangle()
                            .fill(AppTheme.darkBorder.opacity(0.4))
                            .frame(height: 1)
                    }
                }
            }
        }
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
        .frame(maxWidth: .infinity)
    }
}

private struct MoversRowItemView: View {
    let rank: Int
    let ticker: MarketTicker24h
    let onSelect: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 10) {
                // Rank Badge
                Text("\(rank)")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .frame(width: 22, height: 22)
                    .background(rankBadgeColor(rank))
                    .foregroundColor(rankTextColor(rank))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Symbol & Sector
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 4) {
                        Text(ticker.baseAsset)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("/USDT")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    Text(ticker.sector.rawValue)
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                Spacer()
                
                // Price & % Change
                VStack(alignment: .trailing, spacing: 2) {
                    Text(Formatters.formatPrice(ticker.price))
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text(Formatters.formatPercentage(ticker.priceChangePercent))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(ticker.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isHovered ? AppTheme.darkHeaderBg.opacity(0.8) : Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
        .help("Xem chi tiết \(ticker.symbol)")
    }
    
    private func rankBadgeColor(_ r: Int) -> Color {
        switch r {
        case 1: return AppTheme.orange.opacity(0.3)
        case 2: return Color.white.opacity(0.2)
        case 3: return AppTheme.purple.opacity(0.3)
        default: return Color.white.opacity(0.06)
        }
    }
    
    private func rankTextColor(_ r: Int) -> Color {
        switch r {
        case 1: return AppTheme.orange
        case 2: return .white
        case 3: return AppTheme.purple
        default: return .white.opacity(0.5)
        }
    }
}

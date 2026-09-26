import SwiftUI

/// A single row in the Market table displaying one coin's data.
public struct MarketTableRowView: View {
    public let rank: Int
    public let ticker: MarketTicker24h
    public let onSelect: () -> Void

    @State private var isHovered: Bool = false

    public init(rank: Int, ticker: MarketTicker24h, onSelect: @escaping () -> Void) {
        self.rank = rank
        self.ticker = ticker
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                // ── Rank ──────────────────────────── 44pt
                rankBadge
                    .frame(width: 44, alignment: .center)

                // ── Symbol + Sector ───────────────── 160pt
                symbolCell
                    .frame(width: 160, alignment: .leading)

                // ── Price ─────────────────────────── 104pt
                Text(Formatters.formatPrice(ticker.price))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .frame(width: 104, alignment: .trailing)
                    .padding(.trailing, 8)

                // ── 24h % ─────────────────────────── 84pt
                changeBadge
                    .frame(width: 84, alignment: .trailing)
                    .padding(.trailing, 8)

                // ── Vol 24h (USDT) ────────────────── 96pt
                Text("$\(Formatters.formatVolume(ticker.quoteVolume))")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.75))
                    .lineLimit(1)
                    .frame(width: 96, alignment: .trailing)
                    .padding(.trailing, 8)

                // ── Market Cap ────────────────────── 84pt
                Text(Formatters.formatMarketCap(ticker.estimatedMarketCap))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
                    .frame(width: 84, alignment: .trailing)
                    .padding(.trailing, 8)

                // ── Sparkline ─────────────────────── 80pt
                SparklineView(ticker: ticker)
                    .frame(width: 80, alignment: .center)
                    .padding(.horizontal, 8)
            }
            .frame(height: 38)
            .background(rowBg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .help("Xem chi tiết \(ticker.baseAsset)")
    }

    // MARK: - Sub-views

    private var rankBadge: some View {
        ZStack {
            switch rank {
            case 1:
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(red: 1, green: 0.84, blue: 0).opacity(0.18))
                    .frame(width: 26, height: 20)
            case 2:
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.12))
                    .frame(width: 26, height: 20)
            case 3:
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppTheme.orange.opacity(0.18))
                    .frame(width: 26, height: 20)
            default:
                EmptyView()
            }

            Text("\(rank)")
                .font(.system(size: 11, weight: rank <= 3 ? .bold : .regular, design: .monospaced))
                .foregroundColor(rankTextColor)
        }
    }

    private var symbolCell: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Text(ticker.baseAsset)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                Text("/USDT")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.35))
            }
            Text(ticker.sector.rawValue)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(sectorColor)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(sectorColor.opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.leading, 4)
    }

    private var changeBadge: some View {
        let color: Color = ticker.isBullish ? AppTheme.upGreen : AppTheme.downRed
        return Text(Formatters.formatPercentage(ticker.priceChangePercent))
            .font(.system(size: 12, weight: .bold, design: .monospaced))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 4))
    }

    private var rowBg: Color {
        if isHovered { return AppTheme.darkSurface }
        return Color.clear
    }

    private var rankTextColor: Color {
        switch rank {
        case 1: return Color(red: 1, green: 0.84, blue: 0)
        case 2: return .white.opacity(0.85)
        case 3: return AppTheme.orange
        default: return .white.opacity(0.4)
        }
    }

    private var sectorColor: Color {
        switch ticker.sector {
        case .layer1:  return AppTheme.accentBlue
        case .layer2:  return AppTheme.cyan
        case .defi:    return AppTheme.upGreen
        case .ai:      return AppTheme.purple
        case .meme:    return AppTheme.orange
        case .rwa:     return AppTheme.warningYellow
        case .depin:   return Color(red: 0.2, green: 0.7, blue: 0.9)
        case .gaming:  return Color(red: 0.9, green: 0.3, blue: 0.7)
        case .cex:     return AppTheme.accentBlue.opacity(0.8)
        case .all, .others: return .white.opacity(0.4)
        }
    }
}

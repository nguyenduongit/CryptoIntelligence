import SwiftUI

/// A single row in the Market table displaying one coin's data.
/// Uses responsive column widths from MarketTableColumns to fill 100% of the table width.
public struct MarketTableRowView: View {
    public let rank: Int
    public let ticker: MarketTicker24h
    public let columns: MarketTableColumns
    public let onSelect: () -> Void

    @State private var isHovered: Bool = false

    public init(
        rank: Int,
        ticker: MarketTicker24h,
        columns: MarketTableColumns,
        onSelect: @escaping () -> Void
    ) {
        self.rank = rank
        self.ticker = ticker
        self.columns = columns
        self.onSelect = onSelect
    }

    public var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 0) {
                // ── Rank ────────────────────────────
                rankBadge
                    .frame(width: columns.rank, alignment: .center)

                // ── Symbol + Sector ─────────────────
                symbolCell
                    .padding(.leading, 8)
                    .frame(width: columns.symbol, alignment: .leading)

                // ── Price ───────────────────────────
                Text(Formatters.formatPrice(ticker.price))
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.trailing, 8)
                    .frame(width: columns.price, alignment: .trailing)

                // ── 24h % ───────────────────────────
                changeBadge
                    .padding(.trailing, 8)
                    .frame(width: columns.change24h, alignment: .trailing)

                // ── 24h High / Low ──────────────────
                highLowCell
                    .padding(.trailing, 8)
                    .frame(width: columns.highLow, alignment: .trailing)

                // ── Vol 24h (USDT) ──────────────────
                volumeCell
                    .padding(.trailing, 8)
                    .frame(width: columns.volume, alignment: .trailing)

                // ── Market Cap ──────────────────────
                Text(Formatters.formatMarketCap(ticker.estimatedMarketCap))
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
                    .padding(.trailing, 8)
                    .frame(width: columns.cap, alignment: .trailing)

                // ── Sparkline ───────────────────────
                SparklineView(ticker: ticker)
                    .frame(width: max(36, columns.sparkline - 12), height: 26)
                    .frame(width: columns.sparkline, alignment: .center)

                // ── Action / Detail ─────────────────
                actionIcon
                    .frame(width: columns.action, alignment: .center)
            }
            .frame(width: columns.totalWidth, height: 40, alignment: .leading)
            .background(rowBg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in isHovered = hovering }
        .help("Nhấn để xem biểu đồ & phân tích chi tiết \(ticker.baseAsset)/USDT")
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

    private var highLowCell: some View {
        VStack(alignment: .trailing, spacing: 1.5) {
            HStack(spacing: 2) {
                Text("C")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(AppTheme.upGreen.opacity(0.8))
                Text(Formatters.formatPrice(ticker.highPrice))
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.75))
            }
            HStack(spacing: 2) {
                Text("T")
                    .font(.system(size: 8.5, weight: .bold))
                    .foregroundColor(AppTheme.downRed.opacity(0.8))
                Text(Formatters.formatPrice(ticker.lowPrice))
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .lineLimit(1)
    }

    private var volumeCell: some View {
        VStack(alignment: .trailing, spacing: 1.5) {
            Text("$\(Formatters.formatVolume(ticker.quoteVolume))")
                .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
            Text("\(Formatters.formatVolume(ticker.volume)) \(ticker.baseAsset)")
                .font(.system(size: 9.5, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
        }
        .lineLimit(1)
    }

    private var actionIcon: some View {
        Image(systemName: "chevron.right.circle.fill")
            .font(.system(size: 13))
            .foregroundColor(isHovered ? AppTheme.accentBlue : .white.opacity(0.12))
            .scaleEffect(isHovered ? 1.15 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
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

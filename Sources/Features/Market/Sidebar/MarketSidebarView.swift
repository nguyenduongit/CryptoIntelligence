import SwiftUI

/// Left sidebar for the Market tab.
/// Displays: View Mode selector | Sector filter | Market Stats
public struct MarketSidebarView: View {
    @Bindable var viewModel: MarketViewModel

    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ── Level 2 Sub-Header ──────────────────────────────────────
            subHeader

            // ── Scrollable content ──────────────────────────────────────
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Section 1: View Modes
                    viewModeSection

                    divider

                    // Section 2: Sector Filter
                    sectorSection

                    divider

                    // Section 3: Market Stats
                    statsSection

                    Spacer(minLength: 16)
                }
            }
        }
        .background(AppTheme.darkSidebarBg)
    }

    // MARK: - Sub-Header

    private var subHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(AppTheme.accentBlue)
            Text("THỊ TRƯỜNG")
                .font(.system(size: 12.5, weight: .bold))
                .foregroundColor(.white)
            Spacer()
            // Coin count badge
            if !viewModel.tickers.isEmpty {
                Text("\(viewModel.tickers.count)")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.accentBlue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.accentBlue.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .frame(height: AppTheme.subHeaderHeight)
        .background(AppTheme.darkHeaderBg)
        .overlay(Rectangle().fill(AppTheme.darkBorder).frame(height: 1), alignment: .bottom)
    }

    // MARK: - Section: View Modes

    private var viewModeSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionTitle("Chế Độ Xem")

            ForEach(MarketViewMode.allCases) { mode in
                viewModeRow(mode)
            }
        }
        .padding(.bottom, 6)
    }

    private func viewModeRow(_ mode: MarketViewMode) -> some View {
        let isSelected = viewModel.selectedMarketViewMode == mode

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedMarketViewMode = mode
            }
        } label: {
            HStack(spacing: 9) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.5))
                    .frame(width: 16)

                Text(mode.rawValue)
                    .font(.system(size: 12.5, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))

                Spacer()

                // Count badge for selected mode
                if isSelected {
                    let count = viewModel.marketTableRows.count
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? AppTheme.accentBlue.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }

    // MARK: - Section: Sector Filter

    private var sectorSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            sectionTitle("Phân Khúc")

            // "All" row
            sectorRow(.all, count: viewModel.tickers.count)

            // Other sectors sorted by count
            ForEach(viewModel.sectorStats, id: \.sector) { item in
                sectorRow(item.sector, count: item.count)
            }
        }
        .padding(.bottom, 6)
    }

    private func sectorRow(_ sector: CryptoSector, count: Int) -> some View {
        let isSelected = viewModel.selectedSector == sector

        return Button {
            withAnimation(.easeInOut(duration: 0.12)) {
                viewModel.selectedSector = sector
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: sector.iconName)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.4))
                    .frame(width: 14)

                Text(sector.rawValue)
                    .font(.system(size: 11.5, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                    .lineLimit(1)

                Spacer()

                Text("\(count)")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(isSelected ? AppTheme.accentBlue.opacity(0.08) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
    }

    // MARK: - Section: Market Stats

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionTitle("Thống Kê Thị Trường")

            VStack(spacing: 6) {
                // Gainers vs Losers
                HStack {
                    statRow(
                        icon: "arrow.up.circle.fill",
                        color: AppTheme.upGreen,
                        label: "Tăng",
                        value: "\(viewModel.totalGainerCount)"
                    )
                    Spacer()
                    statRow(
                        icon: "arrow.down.circle.fill",
                        color: AppTheme.downRed,
                        label: "Giảm",
                        value: "\(viewModel.totalLoserCount)"
                    )
                }

                // Gainers/Losers ratio bar
                if viewModel.tickers.count > 0 {
                    let ratio = Double(viewModel.totalGainerCount) / Double(viewModel.tickers.count)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.downRed.opacity(0.3))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.upGreen.opacity(0.7))
                                .frame(width: geo.size.width * CGFloat(ratio))
                        }
                    }
                    .frame(height: 4)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                }

                Rectangle().fill(AppTheme.darkBorder.opacity(0.4)).frame(height: 1)

                // Total Volume
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.warningYellow)
                    Text("Tổng Vol 24h")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.55))
                    Spacer()
                    Text("$\(Formatters.formatVolume(viewModel.totalQuoteVolume))")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppTheme.warningYellow)
                }

                // Total coins
                HStack {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Tổng Coins")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.55))
                    Spacer()
                    Text("\(viewModel.tickers.count)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(AppTheme.darkSurface.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
    }

    private func statRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 10))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.55))
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .foregroundColor(color)
        }
    }

    // MARK: - Helpers

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundColor(.white.opacity(0.35))
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.darkBorder)
            .frame(height: 1)
            .padding(.horizontal, 8)
    }
}

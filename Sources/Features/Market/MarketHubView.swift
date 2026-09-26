import SwiftUI

/// Root view for the Market tab.
/// Contains: unified sub-header bar (search + stats + refresh) + full market table.
public struct MarketHubView: View {
    @Bindable var viewModel: MarketViewModel
    let onSelectSymbol: (String) -> Void

    public init(viewModel: MarketViewModel, onSelectSymbol: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.onSelectSymbol = onSelectSymbol
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ── Level 2 Sub-Header (unified 44pt height) ─────────────────
            marketSubHeader

            // ── Sector Capital Allocation & Flow Widget ──────────────────
            if viewModel.isSectorFlowExpanded && !viewModel.sectorPerformances.isEmpty {
                SectorCapitalAllocationView(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    .padding(.bottom, 6)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // ── Full Market Table ─────────────────────────────────────────
            MarketTableView(viewModel: viewModel, onSelectSymbol: onSelectSymbol)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            if viewModel.tickers.isEmpty {
                viewModel.loadData()
            }
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }

    // MARK: - Sub-Header Bar

    private var marketSubHeader: some View {
        HStack(spacing: 10) {
            // Search field
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                TextField("Tìm coin...", text: $viewModel.searchQuery)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .frame(width: 130)
                if !viewModel.searchQuery.isEmpty {
                    Button {
                        viewModel.searchQuery = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.35))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )

            // Result count
            let count = viewModel.marketTableRows.count
            Text(viewModel.searchQuery.isEmpty && viewModel.selectedSector == .all
                 ? "\(viewModel.tickers.count) coins"
                 : "\(count) / \(viewModel.tickers.count) coins")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.45))

            Spacer()

            // View mode label
            HStack(spacing: 5) {
                Image(systemName: viewModel.selectedMarketViewMode.iconName)
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.accentBlue)
                Text(viewModel.selectedMarketViewMode.rawValue)
                    .font(.system(size: 11.5, weight: .semibold))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(AppTheme.accentBlue.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(AppTheme.accentBlue.opacity(0.25), lineWidth: 1)
            )

            // Sector flow toggle button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.isSectorFlowExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 10.5))
                    Text("Dòng Tiền")
                        .font(.system(size: 11, weight: .semibold))
                    Image(systemName: viewModel.isSectorFlowExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 8.5, weight: .bold))
                }
                .foregroundColor(viewModel.isSectorFlowExpanded ? AppTheme.cyan : .white.opacity(0.7))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(viewModel.isSectorFlowExpanded ? AppTheme.cyan.opacity(0.12) : AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(viewModel.isSectorFlowExpanded ? AppTheme.cyan.opacity(0.4) : AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help("Bật/tắt widget phân bổ vốn & dòng tiền phân khúc")

            // Auto-refresh countdown
            autoRefreshBadge

            // Data source badge
            DataSourceBadge(type: .liveBinance, text: "Ticker 24h Binance")

            // Manual refresh button
            Button {
                viewModel.loadData()
                viewModel.startAutoRefresh() // reset countdown
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(viewModel.isLoading ? AppTheme.accentBlue.opacity(0.5) : AppTheme.accentBlue)
                    .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                    .animation(
                        viewModel.isLoading
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                        value: viewModel.isLoading
                    )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading)
            .help("Làm mới dữ liệu thủ công")
        }
        .padding(.horizontal, 14)
        .frame(height: AppTheme.subHeaderHeight)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Auto-refresh countdown badge

    private var autoRefreshBadge: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(AppTheme.upGreen)
                .frame(width: 5, height: 5)
                .opacity(viewModel.isLoading ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: viewModel.autoRefreshCountdown)
            Text("↻ \(viewModel.autoRefreshCountdown)s")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
}

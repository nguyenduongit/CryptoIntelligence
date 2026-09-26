import SwiftUI

/// Full market listing table with lazy rendering.
/// Shows all coins for the selected view mode with sticky header and lazy rows.
public struct MarketTableView: View {
    @Bindable var viewModel: MarketViewModel
    let onSelectSymbol: (String) -> Void

    // Pagination: render in chunks of 100 for smooth scrolling
    @State private var visibleCount: Int = 100

    public init(viewModel: MarketViewModel, onSelectSymbol: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.onSelectSymbol = onSelectSymbol
    }

    private var rows: [MarketTicker24h] { viewModel.marketTableRows }

    public var body: some View {
        VStack(spacing: 0) {
            // ── Sticky Column Header ──────────────────────────────────────
            MarketTableHeaderView(
                sortColumn: $viewModel.tableSortColumn,
                sortDirection: $viewModel.tableSortDirection,
                onSort: { viewModel.toggleSort(column: $0) }
            )

            // ── Scrollable Data Rows ──────────────────────────────────────
            if viewModel.isLoading && rows.isEmpty {
                loadingPlaceholder
            } else if rows.isEmpty {
                emptyPlaceholder
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0, pinnedViews: []) {
                        ForEach(Array(rows.prefix(visibleCount).enumerated()), id: \.element.id) { index, ticker in
                            MarketTableRowView(
                                rank: index + 1,
                                ticker: ticker,
                                onSelect: { onSelectSymbol(ticker.symbol) }
                            )

                            // Row separator
                            Rectangle()
                                .fill(AppTheme.darkBorder.opacity(0.4))
                                .frame(height: 1)
                        }

                        // Load more trigger
                        if visibleCount < rows.count {
                            Color.clear
                                .frame(height: 1)
                                .onAppear {
                                    withAnimation {
                                        visibleCount = min(visibleCount + 100, rows.count)
                                    }
                                }

                            // Show how many more to load
                            HStack {
                                ProgressView()
                                    .scaleEffect(0.7)
                                Text("Đang tải thêm \(rows.count - visibleCount) coins...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        } else if rows.count > 0 {
                            // Footer
                            Text("Hiển thị \(rows.count) coins — Binance USDT pairs")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                        }
                    }
                }
                .onChange(of: viewModel.selectedMarketViewMode) { _, _ in visibleCount = 100 }
                .onChange(of: viewModel.selectedSector) { _, _ in visibleCount = 100 }
                .onChange(of: viewModel.searchQuery) { _, _ in visibleCount = 100 }
            }
        }
        .background(AppTheme.darkBackground)
    }

    // MARK: - Placeholder states

    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            Spacer()
            ProgressView()
                .scaleEffect(1.2)
            Text("Đang tải dữ liệu từ Binance...")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.white.opacity(0.2))
            Text("Không tìm thấy kết quả")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            if !viewModel.searchQuery.isEmpty {
                Text("Thử tìm kiếm tên khác hoặc xóa bộ lọc")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.35))
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

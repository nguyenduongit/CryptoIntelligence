import SwiftUI

/// Sticky column header bar for the market table.
/// Clicking a column header sorts by that column; clicking again toggles direction.
/// Uses responsive column widths from MarketTableColumns.
public struct MarketTableHeaderView: View {
    public let columns: MarketTableColumns
    @Binding var sortColumn: MarketTableSortColumn
    @Binding var sortDirection: MarketSortDirection
    let onSort: (MarketTableSortColumn) -> Void

    public init(
        columns: MarketTableColumns,
        sortColumn: Binding<MarketTableSortColumn>,
        sortDirection: Binding<MarketSortDirection>,
        onSort: @escaping (MarketTableSortColumn) -> Void
    ) {
        self.columns = columns
        self._sortColumn = sortColumn
        self._sortDirection = sortDirection
        self.onSort = onSort
    }

    public var body: some View {
        HStack(spacing: 0) {
            // # (Rank)
            headerCell(label: "#", column: .rank, width: columns.rank, alignment: .center)

            // Symbol
            headerCell(label: "Tên / Cặp", column: .symbol, width: columns.symbol, alignment: .leading, leadingPad: 8)

            // Price
            headerCell(label: "Giá (USDT)", column: .price, width: columns.price, alignment: .trailing, trailingPad: 8)

            // 24h %
            headerCell(label: "24h %", column: .change24h, width: columns.change24h, alignment: .trailing, trailingPad: 8)

            // 24h High/Low
            headerCell(label: "24h Cao / Thấp", column: .highLow, width: columns.highLow, alignment: .trailing, trailingPad: 8)

            // Volume 24h
            headerCell(label: "Vol 24h (USDT)", column: .volume, width: columns.volume, alignment: .trailing, trailingPad: 8)

            // Market Cap
            headerCell(label: "Vốn Hóa", column: .cap, width: columns.cap, alignment: .trailing, trailingPad: 8)

            // Sparkline — not sortable
            Text("Biến Động 24h")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
                .frame(width: columns.sparkline, alignment: .center)

            // Detail / Action
            Text("Chi Tiết")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
                .frame(width: columns.action, alignment: .center)
        }
        .frame(width: columns.totalWidth, height: 32, alignment: .leading)
        .background(AppTheme.darkHeaderBg)
        .overlay(Rectangle().fill(AppTheme.darkBorder).frame(height: 1), alignment: .bottom)
    }

    // MARK: - Helper

    @ViewBuilder
    private func headerCell(
        label: String,
        column: MarketTableSortColumn,
        width: CGFloat,
        alignment: Alignment,
        leadingPad: CGFloat = 0,
        trailingPad: CGFloat = 0
    ) -> some View {
        let isActive = sortColumn == column
        Button {
            onSort(column)
        } label: {
            HStack(spacing: 3) {
                if alignment == .trailing { Spacer() }

                Text(label)
                    .font(.system(size: 10, weight: isActive ? .bold : .medium))
                    .foregroundColor(isActive ? AppTheme.accentBlue : .white.opacity(0.45))

                if isActive {
                    Image(systemName: sortDirection == .descending ? "chevron.down" : "chevron.up")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                }

                if alignment == .leading { Spacer() }
            }
            .padding(.leading, leadingPad)
            .padding(.trailing, trailingPad)
            .frame(width: width, alignment: alignment)
            .background(Color.white.opacity(0.001))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

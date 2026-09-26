import SwiftUI

/// Sticky column header bar for the market table.
/// Clicking a column header sorts by that column; clicking again toggles direction.
public struct MarketTableHeaderView: View {
    @Binding var sortColumn: MarketTableSortColumn
    @Binding var sortDirection: MarketSortDirection
    let onSort: (MarketTableSortColumn) -> Void

    public init(
        sortColumn: Binding<MarketTableSortColumn>,
        sortDirection: Binding<MarketSortDirection>,
        onSort: @escaping (MarketTableSortColumn) -> Void
    ) {
        self._sortColumn = sortColumn
        self._sortDirection = sortDirection
        self.onSort = onSort
    }

    public var body: some View {
        HStack(spacing: 0) {
            // #
            headerCell(label: "#", column: .rank, width: 44, alignment: .center)

            // Symbol
            headerCell(label: "Symbol", column: .symbol, width: 160, alignment: .leading, leadingPad: 4)

            // Price
            headerCell(label: "Giá (USDT)", column: .price, width: 104, alignment: .trailing, trailingPad: 8)

            // 24h %
            headerCell(label: "24h %", column: .change24h, width: 84, alignment: .trailing, trailingPad: 8)

            // Volume
            headerCell(label: "Vol 24h", column: .volume, width: 96, alignment: .trailing, trailingPad: 8)

            // Cap
            headerCell(label: "Vốn Hóa", column: .cap, width: 84, alignment: .trailing, trailingPad: 8)

            // Sparkline — not sortable
            Text("Biến Động")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.45))
                .frame(width: 80, alignment: .center)
        }
        .frame(height: 30)
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
            .frame(width: width - leadingPad - trailingPad, alignment: alignment)
            .padding(.leading, leadingPad)
            .padding(.trailing, trailingPad)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: width, alignment: alignment)
    }
}

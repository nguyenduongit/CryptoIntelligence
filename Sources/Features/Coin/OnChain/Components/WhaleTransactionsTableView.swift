import SwiftUI

public struct WhaleTransactionsTableView: View {
    public let transactions: [WhaleTransaction]
    @Binding var selectedFilter: WhaleTxFilter
    
    public init(transactions: [WhaleTransaction], selectedFilter: Binding<WhaleTxFilter>) {
        self.transactions = transactions
        self._selectedFilter = selectedFilter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header & Filter Pills
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "fish.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Giao Dịch Cá Voi Gần Đây (Whale Alerts)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Filter Tabs
                HStack(spacing: 4) {
                    ForEach(WhaleTxFilter.allCases) { f in
                        Button(action: { selectedFilter = f }) {
                            Text(f.rawValue)
                                .font(.system(size: 10, weight: selectedFilter == f ? .semibold : .medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedFilter == f ? AppTheme.accentBlue : AppTheme.darkHeaderBg)
                                .foregroundColor(selectedFilter == f ? .white : .white.opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Transaction Rows
            if transactions.isEmpty {
                HStack {
                    Spacer()
                    Text("Không có giao dịch cá voi nào trong bộ lọc hiện tại.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 6) {
                    ForEach(transactions) { tx in
                        WhaleTransactionRowView(tx: tx)
                    }
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

private struct WhaleTransactionRowView: View {
    let tx: WhaleTransaction
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Type Icon
            Image(systemName: tx.type.iconName)
                .font(.system(size: 16))
                .foregroundColor(tx.type.color)
                .frame(width: 28, height: 28)
                .background(tx.type.color.opacity(0.15))
                .clipShape(Circle())
            
            // From -> To Routing
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(tx.fromLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text(tx.toLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                HStack(spacing: 6) {
                    Text(relativeTimeString(tx.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("•")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Tx: \(tx.id)")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Amount in Tokens & USD
            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.formatVolume(tx.amountToken) + " tokens")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("≈ " + Formatters.formatVolume(tx.amountUSD) + " USD")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(tx.type.color)
            }
            
            // Type Badge
            Text(tx.type.rawValue)
                .font(.system(size: 9, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(tx.type.color.opacity(0.15))
                .foregroundColor(tx.type.color)
                .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(isHovered ? AppTheme.darkHeaderBg.opacity(0.7) : AppTheme.darkHeaderBg.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func relativeTimeString(_ d: Date) -> String {
        let diffSecs = Int(Date().timeIntervalSince(d))
        if diffSecs < 60 {
            return "Vừa xong"
        } else if diffSecs < 3600 {
            return "\(diffSecs / 60) phút trước"
        } else if diffSecs < 86400 {
            return "\(diffSecs / 3600) giờ trước"
        } else {
            return "\(diffSecs / 86400) ngày trước"
        }
    }
}

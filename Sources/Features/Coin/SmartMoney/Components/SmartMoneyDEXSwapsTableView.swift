import SwiftUI

public struct SmartMoneyDEXSwapsTableView: View {
    public let swaps: [SmartMoneyDEXSwap]
    @Binding var selectedFilter: DEXSwapFilter
    
    public init(swaps: [SmartMoneyDEXSwap], selectedFilter: Binding<DEXSwapFilter>) {
        self.swaps = swaps
        self._selectedFilter = selectedFilter
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header & Filter Tabs
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Giao Dịch Swap Smart Money Gần Đây (DEX Trades)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Filter Buttons
                HStack(spacing: 4) {
                    ForEach(DEXSwapFilter.allCases) { f in
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
            
            // Swap Rows
            if swaps.isEmpty {
                HStack {
                    Spacer()
                    Text("Không có giao dịch swap nào phù hợp với bộ lọc.")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .padding(.vertical, 24)
            } else {
                VStack(spacing: 6) {
                    ForEach(swaps) { swap in
                        DEXSwapRowView(swap: swap)
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

private struct DEXSwapRowView: View {
    let swap: SmartMoneyDEXSwap
    @State private var isHovered: Bool = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Action Type Badge Icon
            Image(systemName: swap.type == .buy ? "arrow.down.circle.fill" : "arrow.up.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(swap.type.color)
                .frame(width: 28, height: 28)
                .background(swap.type.color.opacity(0.15))
                .clipShape(Circle())
            
            // Trader Label & DEX
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(swap.traderLabel)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white.opacity(0.95))
                    
                    Text(swap.dexName)
                        .font(.system(size: 9))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppTheme.accentBlue.opacity(0.15))
                        .foregroundColor(AppTheme.accentBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                
                HStack(spacing: 6) {
                    Text(relativeTimeString(swap.timestamp))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("•")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.3))
                    
                    Text("Giá khớp: " + Formatters.formatPrice(swap.executionPriceUSD) + " USD")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            // Amount in Tokens & USD
            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.formatVolume(swap.amountToken) + " tokens")
                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("≈ " + Formatters.formatVolume(swap.amountUSD) + " USD")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(swap.type.color)
            }
            
            // Type Pill
            Text(swap.type.rawValue)
                .font(.system(size: 9, weight: .bold))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(swap.type.color.opacity(0.15))
                .foregroundColor(swap.type.color)
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

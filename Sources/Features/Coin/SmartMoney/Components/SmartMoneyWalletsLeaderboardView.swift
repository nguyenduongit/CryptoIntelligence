import SwiftUI

public struct SmartMoneyWalletsLeaderboardView: View {
    public let wallets: [SmartMoneyWalletLeader]
    
    public init(wallets: [SmartMoneyWalletLeader]) {
        self.wallets = wallets
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.warningYellow)
                    Text("Top Ví Thông Minh Sinh Lời Cao Nhất (Smart Money Leaderboard)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Tracking 30 Ngày qua")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Table
            VStack(spacing: 0) {
                // Table Header
                HStack(spacing: 8) {
                    Text("VÍ / NHÃN TRACKING")
                        .frame(minWidth: 160, alignment: .leading)
                    Spacer()
                    Text("TỶ LỆ THẮNG")
                        .frame(width: 85, alignment: .trailing)
                    Text("PNL 30D (USD)")
                        .frame(width: 105, alignment: .trailing)
                    Text("TỔNG TÀI SẢN")
                        .frame(width: 100, alignment: .trailing)
                    Text("HOẠT ĐỘNG")
                        .frame(width: 90, alignment: .trailing)
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppTheme.darkBackground.opacity(0.6))
                
                Divider().background(AppTheme.darkBorder)
                
                // Rows
                ForEach(Array(wallets.enumerated()), id: \.element.id) { index, w in
                    HStack(spacing: 8) {
                        // Rank + Label + Address
                        HStack(spacing: 6) {
                            Text("#\(index + 1)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(index == 0 ? AppTheme.warningYellow : .white.opacity(0.5))
                                .frame(width: 20, alignment: .leading)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(w.label)
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                Text(formatAddress(w.address))
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(AppTheme.cyan.opacity(0.8))
                            }
                        }
                        .frame(minWidth: 160, alignment: .leading)
                        
                        Spacer()
                        
                        // Win Rate
                        HStack(spacing: 3) {
                            Circle().fill(AppTheme.upGreen).frame(width: 4, height: 4)
                            Text(String(format: "%.1f%%", w.winRatePercent))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.upGreen)
                        }
                        .frame(width: 85, alignment: .trailing)
                        
                        // 30d PnL
                        Text(formatCurrencyWithPlus(w.pnl30dUSD))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(w.pnl30dUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            .frame(width: 105, alignment: .trailing)
                        
                        // Total Balance
                        Text(formatCurrency(w.totalBalanceUSD))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 100, alignment: .trailing)
                        
                        // Last Active
                        Text(w.lastActiveAgo)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                            .frame(width: 90, alignment: .trailing)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(index % 2 == 0 ? Color.clear : AppTheme.darkBackground.opacity(0.25))
                    
                    if index < wallets.count - 1 {
                        Divider().background(AppTheme.darkBorder.opacity(0.5))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func formatAddress(_ addr: String) -> String {
        if addr.count > 16 {
            return "\(addr.prefix(6))...\(addr.suffix(4))"
        }
        return addr
    }
    
    private func formatCurrency(_ val: Double) -> String {
        if val >= 1_000_000 {
            return String(format: "$%.2fM", val / 1_000_000)
        } else if val >= 1_000 {
            return String(format: "$%.0fK", val / 1_000)
        } else {
            return String(format: "$%.2f", val)
        }
    }
    
    private func formatCurrencyWithPlus(_ val: Double) -> String {
        if val >= 1_000_000 {
            return String(format: "+$%.2fM", val / 1_000_000)
        } else {
            return String(format: "+$%.0fK", val / 1_000)
        }
    }
}

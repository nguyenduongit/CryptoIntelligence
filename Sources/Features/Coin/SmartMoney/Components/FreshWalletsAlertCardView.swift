import SwiftUI

public struct FreshWalletsAlertCardView: View {
    public let alerts: [FreshWalletAlert]
    
    public init(alerts: [FreshWalletAlert]) {
        self.alerts = alerts
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.cyan)
                    Text("Cảnh Báo Ví Mới Tích Lũy Đột Biến (Fresh Wallets Inflow)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Phát hiện ví <48h nạp từ CEX")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.cyan.opacity(0.8))
            }
            
            // Alert Cards
            VStack(spacing: 8) {
                ForEach(alerts) { alert in
                    HStack(spacing: 12) {
                        // Icon + Age
                        VStack(spacing: 2) {
                            Image(systemName: "wallet.pass.fill")
                                .font(.system(size: 14))
                                .foregroundColor(AppTheme.cyan)
                            Text("\(alert.ageHours)h tuổi")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(width: 48)
                        
                        // Address & Source Exchange
                        VStack(alignment: .leading, spacing: 2) {
                            Text(formatAddress(alert.address))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            HStack(spacing: 4) {
                                Text("Nguồn rút:")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.4))
                                Text(alert.sourceExchange)
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppTheme.accentBlue)
                            }
                        }
                        
                        Spacer()
                        
                        // Amount & Entry
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(formatCurrency(alert.accumulatedAmountUSD))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.upGreen)
                            Text("Giá gom: $\(String(format: "%.2f", alert.averageEntryPrice))")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(10)
                    .background(AppTheme.darkBackground.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.cyan.opacity(0.2), lineWidth: 1)
                    )
                }
            }
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
            return "\(addr.prefix(8))...\(addr.suffix(6))"
        }
        return addr
    }
    
    private func formatCurrency(_ val: Double) -> String {
        if val >= 1_000_000 {
            return String(format: "$%.2fM", val / 1_000_000)
        } else {
            return String(format: "$%.0fK", val / 1_000)
        }
    }
}

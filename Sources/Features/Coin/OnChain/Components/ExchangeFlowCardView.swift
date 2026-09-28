import SwiftUI

public struct ExchangeFlowCardView: View {
    public let metrics: ExchangeFlowMetrics
    
    public init(metrics: ExchangeFlowMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Dòng Nạp / Rút Sàn (Exchange Flow 24h)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Net Flow Pill
                HStack(spacing: 4) {
                    Image(systemName: metrics.isAccumulation ? "arrow.down.left" : "arrow.up.right")
                        .font(.system(size: 10, weight: .bold))
                    Text(netFlowText)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(metrics.isAccumulation ? AppTheme.upGreen.opacity(0.18) : AppTheme.downRed.opacity(0.18))
                .foregroundColor(metrics.isAccumulation ? AppTheme.upGreen : AppTheme.downRed)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Inflow vs Outflow Visual Bar
            VStack(spacing: 4) {
                GeometryReader { geo in
                    let total = max(1.0, metrics.inflow24hUSD + metrics.outflow24hUSD)
                    let inflowWidth = (metrics.inflow24hUSD / total) * geo.size.width
                    
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(AppTheme.downRed)
                            .frame(width: max(4, inflowWidth))
                        Rectangle()
                            .fill(AppTheme.upGreen)
                            .frame(width: max(4, geo.size.width - inflowWidth - 2))
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 7)
                
                HStack {
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.downRed)
                            .frame(width: 6, height: 6)
                        Text("Nạp: +" + Formatters.formatVolume(metrics.inflow24hUSD) + " USD")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(AppTheme.downRed)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.upGreen)
                            .frame(width: 6, height: 6)
                        Text("Rút: -" + Formatters.formatVolume(metrics.outflow24hUSD) + " USD")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen)
                    }
                }
            }
            
            // Bottom Row: Total Exchange Reserves & 7d change
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Cung Dự Trữ Trên Sàn")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(metrics.exchangeReserveTotal) + " tokens")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Biến động 7 ngày")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 2) {
                        Text(String(format: "%@%.2f%%", metrics.exchangeReserveChange7dPercent > 0 ? "+" : "", metrics.exchangeReserveChange7dPercent))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(metrics.exchangeReserveChange7dPercent <= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        Text(metrics.exchangeReserveChange7dPercent <= 0 ? "(Giảm cung sàn)" : "(Tăng cung sàn)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.top, 2)
            
            Text("* Dòng nạp/rút ước tính từ tỷ lệ khớp lệnh chủ động (Taker Buy/Sell) và khối lượng giao dịch 24h.")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 2)
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private var netFlowText: String {
        let absVal = abs(metrics.netFlow24hUSD)
        if metrics.netFlow24hUSD < 0 {
            return "Rút ròng: -" + Formatters.formatVolume(absVal) + " USD (Gom hàng)"
        } else if metrics.netFlow24hUSD > 0 {
            return "Nạp ròng: +" + Formatters.formatVolume(absVal) + " USD (Áp lực bán)"
        } else {
            return "Cân bằng"
        }
    }
}

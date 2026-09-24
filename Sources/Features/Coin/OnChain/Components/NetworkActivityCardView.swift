import SwiftUI

public struct NetworkActivityCardView: View {
    public let metrics: NetworkActivityMetrics
    
    public init(metrics: NetworkActivityMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(AppTheme.cyan)
                    .font(.system(size: 13))
                Text("Hoạt Động Mạng Lưới (Network Activity)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Grid of Metrics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                // 1. Daily Active Addresses
                VStack(alignment: .leading, spacing: 3) {
                    Text("Địa Chỉ Ví Hoạt Động (DAA)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 6) {
                        Text(Formatters.formatVolume(Double(metrics.dailyActiveAddresses)))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(String(format: "%@%.1f%% (7d)", metrics.daaChange7dPercent > 0 ? "+" : "", metrics.daaChange7dPercent))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(metrics.daaChange7dPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 2. Daily Transactions
                VStack(alignment: .leading, spacing: 3) {
                    Text("Số Lượng Giao Dịch 24h")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(Formatters.formatVolume(Double(metrics.dailyTransactionsCount)))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 3. Average Gas Fee
                if let gas = metrics.averageGasFeeUSD {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Phí Gas Trung Bình")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(gas < 0.01 ? String(format: "$%.4f", gas) : String(format: "$%.2f", gas))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.warningYellow)
                    }
                    .padding(8)
                    .background(AppTheme.darkHeaderBg.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // 4. NVT Ratio
                if let nvt = metrics.nvtRatio {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Chỉ Số NVT Ratio")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", nvt))
                                .font(.system(size: 14, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text(nvt < 35 ? "(Hợp lý)" : "(Định giá cao)")
                                .font(.system(size: 9))
                                .foregroundColor(nvt < 35 ? AppTheme.upGreen : AppTheme.orange)
                        }
                    }
                    .padding(8)
                    .background(AppTheme.darkHeaderBg.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

import SwiftUI

public struct OpenInterestSentimentCardView: View {
    public let metrics: OpenInterestMetrics
    
    public init(metrics: OpenInterestMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Hợp Đồng Mở & Tỷ Lệ Long/Short (Open Interest & Sentiment)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(metrics.isOIExpanding ? AppTheme.upGreen : AppTheme.warningYellow)
                        .frame(width: 6, height: 6)
                    Text(metrics.isOIExpanding ? "OI Đang Mở Rộng" : "OI Đang Co Hẹp")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(metrics.isOIExpanding ? AppTheme.upGreen : AppTheme.warningYellow)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background((metrics.isOIExpanding ? AppTheme.upGreen : AppTheme.warningYellow).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Stats Row
            HStack(spacing: 10) {
                // Total OI USD
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Hợp Đồng Mở (OI)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(metrics.totalOpenInterestUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("~" + Formatters.formatVolume(metrics.totalOpenInterestToken) + " Coin")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 24H OI Change
                VStack(alignment: .leading, spacing: 2) {
                    Text("Biến Động OI 24H")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Image(systemName: metrics.oiChange24hPercent >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(metrics.oiChange24hPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            .font(.system(size: 11, weight: .bold))
                        Text((metrics.oiChange24hPercent >= 0 ? "+" : "") + String(format: "%.2f%%", metrics.oiChange24hPercent))
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(metrics.oiChange24hPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    Text("Dòng tiền đòn bẩy phái sinh")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // OI / Market Cap Ratio
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tỷ Lệ OI / Vốn Hóa")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2f%%", metrics.oiMarketCapRatio))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("Đòn bẩy thị trường an toàn")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Dual Long/Short Sentiment Ratio Bars
            VStack(alignment: .leading, spacing: 8) {
                // 1. Global Accounts Long/Short
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("Tỷ Lệ Tài Khoản Toàn Thị Trường:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("Long: " + String(format: "%.1f%%", metrics.globalLongAccountPercent))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                        Text("vs")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                        Text("Short: " + String(format: "%.1f%%", metrics.globalShortAccountPercent))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.downRed)
                    }
                    
                    GeometryReader { geo in
                        let longW = geo.size.width * CGFloat(metrics.globalLongAccountPercent / 100.0)
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(AppTheme.upGreen)
                                .frame(width: longW)
                            Rectangle()
                                .fill(AppTheme.downRed)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 6)
                }
                
                // 2. Top Trader Position Long/Short
                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text("Vị Thế Top Trader (Cá Voi Phái Sinh):")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("Long: " + String(format: "%.1f%%", metrics.topTraderLongPositionPercent))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                        Text("vs")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                        Text("Short: " + String(format: "%.1f%%", metrics.topTraderShortPositionPercent))
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.downRed)
                    }
                    
                    GeometryReader { geo in
                        let topLongW = geo.size.width * CGFloat(metrics.topTraderLongPositionPercent / 100.0)
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(AppTheme.upGreen)
                                .frame(width: topLongW)
                            Rectangle()
                                .fill(AppTheme.downRed)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 6)
                }
            }
            .padding(10)
            .background(AppTheme.darkHeaderBg.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
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

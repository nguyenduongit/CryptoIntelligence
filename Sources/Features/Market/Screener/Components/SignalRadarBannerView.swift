import SwiftUI

public struct SignalRadarBannerView: View {
    public let summary: MarketRadarSummary
    
    public init(summary: MarketRadarSummary) {
        self.summary = summary
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "radar")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                    
                    Text("Radar Tín Hiệu Thị Trường Toàn Diện (Market Signal Radar)")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Quét Đa Khung 1H-4H-1D")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.cyan)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(AppTheme.cyan.opacity(0.15))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.upGreen)
                        .frame(width: 8, height: 8)
                    Text("Tự động quét: Real-time Live")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            // 3-Card Summary Metric Row
            HStack(spacing: 12) {
                // Metric 1: Bullish vs Bearish Sentiment Ratio
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("XUNG LỰC THỊ TRƯỜNG (MARKET SENTIMENT)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("\(Int(summary.marketSentimentRatio * 100))% Bullish")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    
                    // Progress bar
                    GeometryReader { geo in
                        HStack(spacing: 2) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.upGreen)
                                .frame(width: max(4, geo.size.width * summary.marketSentimentRatio))
                            RoundedRectangle(cornerRadius: 2)
                                .fill(AppTheme.downRed)
                                .frame(width: max(4, geo.size.width * (1.0 - summary.marketSentimentRatio)))
                        }
                    }
                    .frame(height: 6)
                    
                    HStack {
                        Text("\(summary.bullishSignalsCount) Tăng (Bullish)")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.upGreen)
                        Spacer()
                        Text("\(summary.bearishSignalsCount) Giảm | \(summary.neutralSignalsCount) Trung lập")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .padding(12)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.upGreen.opacity(0.3), lineWidth: 1))
                
                // Metric 2: Top Volatility Squeeze
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.left.and.right.circle.fill")
                            .foregroundColor(AppTheme.purple)
                        Text("NÉN BIẾN ĐỘNG (BB SQUEEZE)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("Sắp bùng nổ")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.purple)
                    }
                    
                    HStack(spacing: 6) {
                        ForEach(summary.topSqueezeCoins, id: \.self) { coin in
                            Text(coin)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.purple.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(AppTheme.purple.opacity(0.5), lineWidth: 1))
                        }
                    }
                    
                    Text("Biên độ dải Bollinger co thắt hẹp chuẩn bị nổ vol")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.purple.opacity(0.3), lineWidth: 1))
                
                // Metric 3: Top Whale Accumulation
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "water.waves")
                            .foregroundColor(AppTheme.cyan)
                        Text("CÁ VOI GOM HÀNG (WHALE INFLOW)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("Smart Money")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(AppTheme.cyan)
                    }
                    
                    HStack(spacing: 6) {
                        ForEach(summary.topWhaleAccumulationCoins, id: \.self) { coin in
                            Text(coin)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AppTheme.cyan.opacity(0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .overlay(RoundedRectangle(cornerRadius: 4).stroke(AppTheme.cyan.opacity(0.5), lineWidth: 1))
                        }
                    }
                    
                    Text("Dòng tiền tổ chức rút ròng mạnh khỏi sàn CEX")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.cyan.opacity(0.3), lineWidth: 1))
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
}

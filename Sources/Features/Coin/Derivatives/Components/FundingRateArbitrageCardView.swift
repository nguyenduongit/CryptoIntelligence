import SwiftUI

public struct FundingRateArbitrageCardView: View {
    public let rates: [FundingRateItem]
    public let history: [FundingRateHistoryPoint]
    
    public init(rates: [FundingRateItem], history: [FundingRateHistoryPoint]) {
        self.rates = rates
        self.history = history
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "percent")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13, weight: .bold))
                    Text("Tỷ Lệ Tài Trợ & Chênh Lệch Sàn (Funding Rate & Arbitrage)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Kỳ thanh toán 8H")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Exchange Rates Table
            VStack(spacing: 6) {
                // Table Headers
                HStack {
                    Text("Sàn Giao Dịch")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 140, alignment: .leading)
                    
                    Text("Funding 8H")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("Quy Năm (APR)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("Trạng Thái / Tâm Lý")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                
                Divider()
                    .background(AppTheme.darkBorder)
                
                ForEach(rates) { r in
                    HStack {
                        // Exchange Name
                        HStack(spacing: 6) {
                            Circle()
                                .fill(r.sentiment.color)
                                .frame(width: 6, height: 6)
                            Text(r.exchangeName)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .frame(width: 140, alignment: .leading)
                        
                        // 8H Rate
                        Text((r.currentRate8hPercent >= 0 ? "+" : "") + String(format: "%.4f%%", r.currentRate8hPercent))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(r.currentRate8hPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            .frame(width: 100, alignment: .trailing)
                        
                        // Annualized Rate
                        Text((r.annualizedRatePercent >= 0 ? "+" : "") + String(format: "%.2f%%", r.annualizedRatePercent))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                            .frame(width: 100, alignment: .trailing)
                        
                        // Sentiment Badge
                        Text(r.sentiment.rawValue)
                            .font(.system(size: 9, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(r.sentiment.color.opacity(0.15))
                            .foregroundColor(r.sentiment.color)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppTheme.darkHeaderBg.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            // Historical Funding Rate 8H Bar Chart
            if !history.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Lịch Sử Biến Động Funding Rate (8 Phiên Gần Nhất)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(history) { pt in
                            VStack(spacing: 3) {
                                // Rate text
                                Text((pt.rate8hPercent >= 0 ? "+" : "") + String(format: "%.3f%%", pt.rate8hPercent))
                                    .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                    .foregroundColor(pt.rate8hPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                
                                // Bar container
                                ZStack(alignment: .bottom) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.06))
                                        .frame(width: 24, height: 36)
                                    
                                    let barH = max(4.0, min(36.0, CGFloat(abs(pt.rate8hPercent) / 0.03) * 36.0))
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(pt.rate8hPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                        .frame(width: 24, height: barH)
                                }
                                
                                // Time label
                                Text(pt.dateLabel)
                                    .font(.system(size: 7.5, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                                    .lineLimit(1)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(8)
                    .background(AppTheme.darkHeaderBg.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
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

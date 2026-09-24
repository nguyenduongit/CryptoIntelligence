import SwiftUI

public struct SpotETFFlowsCardView: View {
    public let summary: SpotETFFlowSummary
    
    public init(summary: SpotETFFlowSummary) {
        self.summary = summary
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Dòng Tiền Quỹ Spot ETF Hoa Kỳ (Institutional Flows)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Dẫn đầu Inflow:")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(summary.topInflowETF)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(AppTheme.accentBlue.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Stats Row
            HStack(spacing: 10) {
                // Total AUM
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Giá Trị Quản Lý (AUM)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(summary.totalAUMUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Nắm giữ: \(Formatters.formatVolume(summary.totalBTCHeld)) BTC")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 24H Net Inflow
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dòng Vốn Ròng 24H (Net Flow)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Image(systemName: summary.totalNetFlow24hUSD >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(summary.totalNetFlow24hUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            .font(.system(size: 11, weight: .bold))
                        Text((summary.totalNetFlow24hUSD >= 0 ? "+" : "") + Formatters.formatVolume(summary.totalNetFlow24hUSD) + " USD")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(summary.totalNetFlow24hUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    Text("Tương đương \(summary.totalNetFlow24hBTC >= 0 ? "+" : "")\(Formatters.formatVolume(summary.totalNetFlow24hBTC)) BTC")
                        .font(.system(size: 9))
                        .foregroundColor(summary.totalNetFlow24hUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Cumulative Inflow
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dòng Tiền Ròng Lũy Kế")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text((summary.totalCumulativeInflowsUSD >= 0 ? "+" : "") + Formatters.formatVolume(summary.totalCumulativeInflowsUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("Kể từ ngày ra mắt quỹ")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // 14-Day Inflow / Outflow Bar Chart
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Biểu Đồ Dòng Vốn ETF 14 Phiên Gần Nhất (Triệu USD)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.upGreen).frame(width: 5, height: 5)
                            Text("Mua ròng (Inflow)").font(.system(size: 9)).foregroundColor(.white.opacity(0.6))
                        }
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.downRed).frame(width: 5, height: 5)
                            Text("Bán ròng (Outflow)").font(.system(size: 9)).foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                let maxFlow = max(100.0, summary.history14Days.map { abs($0.netFlowUSD) }.max() ?? 100.0)
                
                HStack(alignment: .bottom, spacing: 6) {
                    ForEach(summary.history14Days) { point in
                        VStack(spacing: 4) {
                            // Flow Value
                            Text((point.netFlowUSD >= 0 ? "+" : "") + String(format: "%.0fM", point.netFlowUSD))
                                .font(.system(size: 8, weight: .semibold, design: .monospaced))
                                .foregroundColor(point.netFlowUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                .lineLimit(1)
                            
                            // Bar Container with baseline
                            ZStack(alignment: point.netFlowUSD >= 0 ? .bottom : .top) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.06))
                                    .frame(width: 22, height: 48)
                                
                                let barHeight = min(48.0, max(4.0, CGFloat(abs(point.netFlowUSD) / maxFlow) * 48.0))
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(point.netFlowUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                    .frame(width: 22, height: barHeight)
                            }
                            
                            // Date
                            Text(point.dateString)
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
                .background(AppTheme.darkHeaderBg.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // ETF Breakdown Table
            VStack(alignment: .leading, spacing: 4) {
                Text("Bảng Chi Tiết Từng Quỹ Spot ETF")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                // Table Headers
                HStack {
                    Text("Quỹ / Ticker")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 140, alignment: .leading)
                    
                    Text("Nhà Quản Lý")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("AUM (USD)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 90, alignment: .trailing)
                    
                    Text("Dòng Tiền 24H")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("Chuỗi Inflow")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 80, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                Divider()
                    .background(AppTheme.darkBorder)
                
                ForEach(summary.etfList) { etf in
                    HStack {
                        // Ticker & Name
                        VStack(alignment: .leading, spacing: 1) {
                            Text(etf.ticker)
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text(etf.fundName)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.5))
                                .lineLimit(1)
                        }
                        .frame(width: 140, alignment: .leading)
                        
                        // Sponsor & Fee
                        VStack(alignment: .leading, spacing: 1) {
                            Text(etf.sponsor)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                            Text("Phí: \(String(format: "%.2f%%", etf.feePercent))")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // AUM
                        Text(Formatters.formatVolume(etf.aumUSD) + " USD")
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 90, alignment: .trailing)
                        
                        // Net Flow 24h
                        VStack(alignment: .trailing, spacing: 1) {
                            Text((etf.netFlow24hUSD >= 0 ? "+" : "") + Formatters.formatVolume(etf.netFlow24hUSD) + " USD")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(etf.netFlow24hUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            Text((etf.netFlow24hBTC >= 0 ? "+" : "") + Formatters.formatVolume(etf.netFlow24hBTC) + " BTC")
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor((etf.netFlow24hUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed).opacity(0.8))
                        }
                        .frame(width: 100, alignment: .trailing)
                        
                        // Streak
                        HStack(spacing: 2) {
                            Image(systemName: etf.streakDays > 0 ? "flame.fill" : "arrow.down")
                                .font(.system(size: 8))
                            Text("\(abs(etf.streakDays)) ngày")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundColor(etf.streakDays > 0 ? AppTheme.upGreen : AppTheme.downRed)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background((etf.streakDays > 0 ? AppTheme.upGreen : AppTheme.downRed).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .frame(width: 80, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(AppTheme.darkHeaderBg.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
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

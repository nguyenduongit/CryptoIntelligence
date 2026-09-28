import SwiftUI

public struct MultiExchangeDepthCardView: View {
    public let orderbook: AggregatedOrderbook
    
    public init(orderbook: AggregatedOrderbook) {
        self.orderbook = orderbook
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "square.stack.3d.down.right.fill")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 13))
                Text("SỔ LỆNH L2 HỢP NHẤT ĐA SÀN (BINANCE + OKX + BYBIT)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.upGreen)
                        .frame(width: 6, height: 6)
                    Text("Live Aggregated Feed")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.upGreen)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppTheme.upGreen.opacity(0.12))
                .clipShape(Capsule())
            }
            
            // Mid Price & Aggregate Spread Summary Banner
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("GIÁ BÌNH QUÂN (MID-PRICE)")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    Text("$\(orderbook.midPrice, specifier: "%.2f")")
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Divider()
                    .frame(height: 28)
                    .background(AppTheme.darkBorder)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("CHÊNH LỆCH MUA/BÁN (SPREAD)")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Text("$\(orderbook.aggregatedSpreadUSD, specifier: "%.2f")")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(spreadColor)
                        Text("(\(orderbook.aggregatedSpreadBps, specifier: "%.2f") bps)")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(spreadColor.opacity(0.85))
                    }
                }
                
                Divider()
                    .frame(height: 28)
                    .background(AppTheme.darkBorder)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("THANH KHOẢN TRONG BIÊN ĐỘ ±1%")
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                    Text("$\(formatUSD(orderbook.depth1PercentUSD))")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue)
                }
                
                Spacer()
            }
            .padding(12)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 3-Exchange Volume & Spread Distribution
            VStack(alignment: .leading, spacing: 8) {
                Text("PHÂN BỔ THANH KHOẢN GIỮA CÁC SÀN")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                // Stacked Bar representing Exchange shares
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        ForEach(orderbook.exchangeSummaries) { summary in
                            let width = max(4.0, (geo.size.width - CGFloat(orderbook.exchangeSummaries.count - 1) * 2) * CGFloat(summary.sharePercent / 100.0))
                            Rectangle()
                                .fill(summary.exchange.color)
                                .frame(width: width, height: 8)
                        }
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 8)
                
                // Exchange Badges & Metrics
                HStack(spacing: 10) {
                    ForEach(orderbook.exchangeSummaries) { s in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(s.exchange.color)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 4) {
                                    Text(s.exchange.rawValue)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                    Text("\(s.sharePercent, specifier: "%.1f")%")
                                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Text("Spread: $\(s.spreadUSD, specifier: "%.2f") (\(s.spreadBps, specifier: "%.1f") bps)")
                                    .font(.system(size: 9.5, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            Spacer()
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.02))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            // Depth Comparison Table at ±0.5%, ±1.0%, ±2.0%
            VStack(alignment: .leading, spacing: 8) {
                Text("ĐỘ SÂU SỔ LỆNH LŨY KẾ THEO KHOẢNG GIÁ")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 12) {
                    depthRangeCard(title: "Biên độ ±0.5%", depthUSD: orderbook.depth1PercentUSD * 0.55, subtext: "Khớp tức thì an toàn")
                    depthRangeCard(title: "Biên độ ±1.0%", depthUSD: orderbook.depth1PercentUSD, subtext: "Khối lượng thể chế chuẩn")
                    depthRangeCard(title: "Biên độ ±2.0%", depthUSD: orderbook.depth2PercentUSD, subtext: "Ngưỡng xả cá voi tối đa")
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private var spreadColor: Color {
        if orderbook.aggregatedSpreadBps <= 2.0 {
            return AppTheme.upGreen
        } else if orderbook.aggregatedSpreadBps <= 5.0 {
            return AppTheme.accentBlue
        } else {
            return AppTheme.orange
        }
    }
    
    private func depthRangeCard(title: String, depthUSD: Double, subtext: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
            Text("$\(formatUSD(depthUSD))")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(subtext)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func formatUSD(_ val: Double) -> String {
        if val >= 1_000_000_000 {
            return String(format: "%.2fB", val / 1_000_000_000.0)
        } else if val >= 1_000_000 {
            return String(format: "%.2fM", val / 1_000_000.0)
        } else if val >= 1_000 {
            return String(format: "%.1fK", val / 1_000.0)
        } else {
            return String(format: "%.0f", val)
        }
    }
}

import SwiftUI

public struct LTHSupplyDistributionCardView: View {
    public let metrics: LTHSupplyMetrics
    
    public init(metrics: LTHSupplyMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.pie.fill")
                        .foregroundColor(AppTheme.upGreen)
                        .font(.system(size: 13))
                    Text("Cơ Cấu Nguồn Cung Dài Hạn (LTH) & Ngắn Hạn (STH)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(metrics.isLTHAccumulating ? AppTheme.upGreen : AppTheme.downRed)
                        .frame(width: 6, height: 6)
                    Text(metrics.isLTHAccumulating ? "LTH Đang Mua Gom" : "LTH Đang Bán Phân Phối")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(metrics.isLTHAccumulating ? AppTheme.upGreen : AppTheme.downRed)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background((metrics.isLTHAccumulating ? AppTheme.upGreen : AppTheme.downRed).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Stacked Supply Distribution Bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    let totalW = geo.size.width
                    let lthW = totalW * (metrics.lthPercentage / 100.0)
                    let sthW = totalW * (metrics.sthPercentage / 100.0)
                    let exchW = max(0, totalW - lthW - sthW)
                    
                    HStack(spacing: 2) {
                        // LTH
                        Rectangle()
                            .fill(AppTheme.accentBlue)
                            .frame(width: lthW)
                            .overlay(
                                Text(String(format: "%.1f%%", metrics.lthPercentage))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.white)
                            )
                        
                        // STH
                        Rectangle()
                            .fill(AppTheme.warningYellow)
                            .frame(width: sthW)
                            .overlay(
                                Text(String(format: "%.1f%%", metrics.sthPercentage))
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.black)
                            )
                        
                        // Exchange Reserve
                        Rectangle()
                            .fill(AppTheme.downRed)
                            .frame(width: exchW)
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 18)
                
                // Legend
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.accentBlue)
                            .frame(width: 8, height: 8)
                        Text("LTH (>155 ngày): \(String(format: "%.1f%%", metrics.lthPercentage))")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.warningYellow)
                            .frame(width: 8, height: 8)
                        Text("STH (<155 ngày): \(String(format: "%.1f%%", metrics.sthPercentage))")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(AppTheme.downRed)
                            .frame(width: 8, height: 8)
                        Text("Dự trữ sàn CEX: \(String(format: "%.1f%%", metrics.exchangePercentage))")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }
            .padding(10)
            .background(AppTheme.darkHeaderBg.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Metrics Summary Grid
            HStack(spacing: 10) {
                // LTH 30D Accumulation
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tích Lũy LTH (30 Ngày)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Image(systemName: metrics.isLTHAccumulating ? "arrow.up.right" : "arrow.down.right")
                            .foregroundColor(metrics.isLTHAccumulating ? AppTheme.upGreen : AppTheme.downRed)
                            .font(.system(size: 11, weight: .bold))
                        Text((metrics.lth30dNetChangeToken > 0 ? "+" : "") + Formatters.formatVolume(metrics.lth30dNetChangeToken) + " Coin")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(metrics.isLTHAccumulating ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    Text("Dòng tiền thông minh không lung lay")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // STH Realized Price (Cost Basis)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Giá Vốn STH (Hỗ Trợ Chu Kỳ)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatPrice(metrics.sthRealizedPriceUSD))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("Ngưỡng hỗ trợ sống còn của phe Bò")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.cyan.opacity(0.8))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Total Illiquid Supply
                VStack(alignment: .leading, spacing: 3) {
                    Text("Nguồn Cung Kém Thanh Khoản")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(metrics.longTermHolderSupply) + " Coin")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("~" + String(format: "%.1f%%", metrics.lthPercentage) + " Tổng cung lưu hành")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            Text("* Cơ cấu nguồn cung LTH/STH là chỉ số ước tính theo mô hình phân bổ thanh khoản, không phải dữ liệu trích xuất trực tiếp từ UTXO node.")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
                .padding(.top, 2)
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

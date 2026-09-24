import SwiftUI

public struct MVRVCycleGaugeCardView: View {
    public let metrics: MVRVCycleMetrics
    
    public init(metrics: MVRVCycleMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "gauge.with.needle.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Định Giá Chu Kỳ & MVRV Z-Score")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(metrics.cyclePhase)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.accentBlue.opacity(0.15))
                    .foregroundColor(AppTheme.accentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // MVRV Z-Score Gauge Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("MVRV Z-Score:")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                    Text(String(format: "%.2f", metrics.mvrvZScore))
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(zScoreColor(metrics.mvrvZScore))
                    
                    Spacer()
                    
                    Text(zScoreEvaluation(metrics.mvrvZScore))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(zScoreColor(metrics.mvrvZScore))
                }
                
                // Color Gradient Band with needle
                GeometryReader { geo in
                    let width = geo.size.width
                    // Map Z-Score (-0.5 to 7.0) to (0.0 to 1.0)
                    let clampedZ = max(-0.5, min(7.0, metrics.mvrvZScore))
                    let normalized = CGFloat((clampedZ - (-0.5)) / (7.0 - (-0.5)))
                    let needleX = max(4.0, min(width - 4.0, normalized * width))
                    
                    ZStack(alignment: .leading) {
                        // Colored gradient band
                        LinearGradient(
                            stops: [
                                .init(color: AppTheme.upGreen, location: 0.0), // Undervalued (< 0.1)
                                .init(color: AppTheme.cyan, location: 0.25),   // Fair Value (0.1 - 2.0)
                                .init(color: AppTheme.warningYellow, location: 0.65), // Heating up (2.0 - 5.0)
                                .init(color: AppTheme.downRed, location: 1.0)  // Top Mania (> 6.0)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 8)
                        .clipShape(Capsule())
                        
                        // Needle Indicator
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(color: .black.opacity(0.6), radius: 2)
                            .overlay(
                                Circle()
                                    .stroke(zScoreColor(metrics.mvrvZScore), lineWidth: 3)
                            )
                            .offset(x: needleX - 7)
                    }
                }
                .frame(height: 16)
                
                // Scale Labels
                HStack {
                    Text("Đáy cực độ (< 0.1)")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.upGreen)
                    Spacer()
                    Text("Hợp lý (1.0 - 2.5)")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.cyan)
                    Spacer()
                    Text("Đỉnh hưng phấn (> 6.0)")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.downRed)
                }
            }
            .padding(10)
            .background(AppTheme.darkHeaderBg.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Key Cycle Valuation Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                // 1. Realized Price vs Current
                VStack(alignment: .leading, spacing: 3) {
                    Text("Giá Thực Tế (Realized Price)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatPrice(metrics.realizedPriceUSD))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    let profitRatio = ((metrics.currentPriceUSD - metrics.realizedPriceUSD) / metrics.realizedPriceUSD) * 100.0
                    Text("Thị giá gấp \(String(format: "%.2fx", metrics.mvrvRatio)) (Lãi +\(String(format: "%.1f", profitRatio))%)")
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.upGreen)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 2. NUPL Sentiment
                VStack(alignment: .leading, spacing: 3) {
                    Text("NUPL (Lãi/Lỗ ròng chưa thực hiện)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2f", metrics.nupl))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(metrics.nuplSentiment.color)
                    Text(metrics.nuplSentiment.label)
                        .font(.system(size: 9))
                        .foregroundColor(metrics.nuplSentiment.color)
                        .lineLimit(1)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 3. Pi Cycle Top Indicator
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text("Chỉ Báo Đỉnh Pi Cycle")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        if metrics.isPiCycleCrossed {
                            Text("CẢNH BÁO ĐỈNH")
                                .font(.system(size: 8, weight: .bold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(AppTheme.downRed)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                    }
                    HStack(spacing: 6) {
                        Text("111 DMA: \(Formatters.formatPrice(metrics.piCycle111DMA))")
                            .font(.system(size: 11, weight: .medium, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Text("Cách đường 2x 350 DMA: +\(String(format: "%.1f", metrics.piCycleGapPercent))%")
                        .font(.system(size: 9))
                        .foregroundColor(metrics.isPiCycleCrossed ? AppTheme.downRed : AppTheme.cyan)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 4. Puell Multiple (Miner Revenue)
                VStack(alignment: .leading, spacing: 3) {
                    Text("Bội Số Puell (Áp Lực Thợ Đào)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2f", metrics.puellMultiple))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(puellColor(metrics.puellMultiple))
                    Text(puellEvaluation(metrics.puellMultiple))
                        .font(.system(size: 9))
                        .foregroundColor(puellColor(metrics.puellMultiple))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
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
    
    private func zScoreColor(_ z: Double) -> Color {
        if z < 0.1 { return AppTheme.upGreen }
        if z < 2.5 { return AppTheme.cyan }
        if z < 5.0 { return AppTheme.warningYellow }
        return AppTheme.downRed
    }
    
    private func zScoreEvaluation(_ z: Double) -> String {
        if z < 0.1 { return "Vùng Đáy Tuyệt Đối (Undervalued)" }
        if z < 1.5 { return "Tích Lũy Bền Vững" }
        if z < 3.5 { return "Mở Rộng Tăng Trưởng (Bull Run)" }
        if z < 6.0 { return "Quá Nhiệt / Cảnh Báo" }
        return "Đỉnh Hưng Phấn Cực Đại (Top Mania)"
    }
    
    private func puellColor(_ p: Double) -> Color {
        if p < 0.5 { return AppTheme.upGreen }
        if p < 1.5 { return AppTheme.cyan }
        if p < 2.5 { return AppTheme.warningYellow }
        return AppTheme.downRed
    }
    
    private func puellEvaluation(_ p: Double) -> String {
        if p < 0.5 { return "Thợ đào kiệt quệ (Vùng Mua Gom)" }
        if p < 1.5 { return "Thu nhập thợ đào ổn định" }
        return "Áp lực chốt lời từ thợ đào tăng cao"
    }
}

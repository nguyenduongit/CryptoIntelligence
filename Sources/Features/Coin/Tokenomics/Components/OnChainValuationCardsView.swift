import SwiftUI

public struct OnChainValuationCardsView: View {
    public let metrics: TokenSupplyMetrics
    public let currentPrice: Double
    
    public init(metrics: TokenSupplyMetrics, currentPrice: Double) {
        self.metrics = metrics
        self.currentPrice = currentPrice
    }
    
    private var realizedPrice: Double {
        if let rp = metrics.realizedPriceUSD, rp > 0 {
            return rp
        }
        return max(0.0001, currentPrice * 0.58)
    }
    
    private var realizedCap: Double {
        if let rc = metrics.realizedCapUSD, rc > 0 {
            return rc
        }
        return realizedPrice * metrics.circulatingSupply
    }
    
    private var mvrv: Double {
        if let m = metrics.mvrvRatio, m > 0 {
            return m
        }
        return currentPrice / max(0.0001, realizedPrice)
    }
    
    private var nupl: Double {
        let mc = metrics.marketCapUSD > 0 ? metrics.marketCapUSD : (currentPrice * metrics.circulatingSupply)
        guard mc > 0 else { return 0.0 }
        return (mc - realizedCap) / mc
    }
    
    private var mvrvColor: Color {
        if mvrv < 1.0 {
            return AppTheme.upGreen
        } else if mvrv <= 2.4 {
            return AppTheme.accentBlue
        } else {
            return AppTheme.orange
        }
    }
    
    private var mvrvStatusText: String {
        if let status = metrics.cycleValuationStatus {
            return status
        }
        if mvrv < 1.0 {
            return "Vùng gom hàng định giá thấp (Undervalued - MVRV < 1.0)"
        } else if mvrv <= 2.4 {
            return "Định giá cân bằng chu kỳ (Fair Value - 1.0 ≤ MVRV ≤ 2.4)"
        } else {
            return "Vùng quá nóng hưng phấn (Overvalued - MVRV > 2.4)"
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Top Grid: 4 Metric Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Card 1: Realized Price
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Giá Vốn On-Chain (Realized Price)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "banknote.fill")
                            .foregroundColor(AppTheme.cyan)
                            .font(.system(size: 13))
                    }
                    
                    Text(Formatters.formatPrice(realizedPrice))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    let diffPercent = ((currentPrice - realizedPrice) / realizedPrice) * 100.0
                    HStack(spacing: 4) {
                        Text("So với giá live:")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                        Text(String(format: "%+.1f%%", diffPercent))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(diffPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                
                // Card 2: MVRV Ratio
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Tỷ Số MVRV (Lãi/Lỗ Toàn Thị Trường)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "gauge.with.needle.fill")
                            .foregroundColor(mvrvColor)
                            .font(.system(size: 13))
                    }
                    
                    Text(String(format: "%.2fx", mvrv))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(mvrvColor)
                    
                    Text(mvrv < 1.0 ? "Thị trường đang lỗ (Vùng Đáy)" : (mvrv <= 2.4 ? "Thị trường lãi vừa phải" : "Thị trường siêu lãi (Cảnh báo đỉnh)"))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                
                // Card 3: Realized Cap
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Vốn Hóa Thực Tế (Realized Cap)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "lock.shield.fill")
                            .foregroundColor(AppTheme.accentBlue)
                            .font(.system(size: 13))
                    }
                    
                    Text(Formatters.formatVolume(realizedCap) + " USD")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text("Market Cap:")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                        Text(Formatters.formatVolume(metrics.marketCapUSD) + " USD")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                
                // Card 4: NUPL (Net Unrealized Profit/Loss)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Lãi/Lỗ Chưa Thực Hiện (NUPL)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(nupl >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            .font(.system(size: 13))
                    }
                    
                    Text(String(format: "%+.1f%%", nupl * 100.0))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(nupl >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    
                    Text(nupl > 0.5 ? "Hưng phấn (Euphoria)" : (nupl > 0.25 ? "Lạc quan (Optimism)" : (nupl >= 0 ? "Hy vọng (Hope)" : "Đầu hàng (Capitulation)")))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
            }
            
            // Detailed MVRV Zone Visualizer Card
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 12))
                    Text("ĐÁNH GIÁ CHU KỲ THEO MÔ HÌNH GLASSNODE ON-CHAIN")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                    Spacer()
                    Text(mvrvStatusText)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(mvrvColor)
                }
                
                // Horizontal MVRV Scale Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Background zones
                        HStack(spacing: 2) {
                            // Green Zone (0..1.0)
                            Rectangle()
                                .fill(AppTheme.upGreen.opacity(0.3))
                                .frame(width: geo.size.width * 0.25)
                                .overlay(Text("<1.0 Đáy").font(.system(size: 9)).foregroundColor(AppTheme.upGreen), alignment: .center)
                            
                            // Blue Zone (1.0..2.4)
                            Rectangle()
                                .fill(AppTheme.accentBlue.opacity(0.3))
                                .frame(width: geo.size.width * 0.45)
                                .overlay(Text("1.0 - 2.4 Tăng trưởng").font(.system(size: 9)).foregroundColor(AppTheme.accentBlue), alignment: .center)
                            
                            // Red Zone (>2.4)
                            Rectangle()
                                .fill(AppTheme.orange.opacity(0.3))
                                .frame(maxWidth: .infinity)
                                .overlay(Text(">2.4 Đỉnh quá nóng").font(.system(size: 9)).foregroundColor(AppTheme.orange), alignment: .center)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        // Current MVRV Indicator Needle
                        let clampedNormalized = min(1.0, max(0.0, mvrv / 3.5))
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 3, height: 18)
                            .shadow(color: .white, radius: 2)
                            .offset(x: max(0, min(geo.size.width - 3, geo.size.width * CGFloat(clampedNormalized))))
                    }
                }
                .frame(height: 18)
                
                // Explanatory note
                Text("• Realized Price là mức giá trung bình mà toàn bộ các ví on-chain đã gom coin. Khi giá thị trường chạm Realized Price (MVRV = 1.0), thị trường về điểm hòa vốn – thường là vùng hỗ trợ dài hạn vững chắc nhất của mọi chu kỳ crypto.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
                    .lineSpacing(2)
            }
            .padding(12)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
        }
    }
}

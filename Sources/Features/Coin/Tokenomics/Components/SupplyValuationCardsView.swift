import SwiftUI

public struct SupplyValuationCardsView: View {
    public let metrics: TokenSupplyMetrics
    public let tokenStandard: String
    public let useCases: [String]
    
    public init(metrics: TokenSupplyMetrics, tokenStandard: String, useCases: [String]) {
        self.metrics = metrics
        self.tokenStandard = tokenStandard
        self.useCases = useCases
    }
    
    public var body: some View {
        VStack(spacing: 12) {
            // Top Grid: 4 Main Valuation & Supply Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                // Card 1: Market Cap vs FDV
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Vốn Hóa Thị Trường (MC)")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(AppTheme.upGreen)
                            .font(.system(size: 13))
                    }
                    
                    Text(Formatters.formatVolume(metrics.marketCapUSD) + " USD")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text("FDV:")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                        Text(Formatters.formatVolume(metrics.fdvUSD) + " USD")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                
                // Card 2: MC / FDV Ratio
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Tỷ Lệ MC / FDV")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "chart.pie.fill")
                            .foregroundColor(AppTheme.accentBlue)
                            .font(.system(size: 13))
                    }
                    
                    Text(String(format: "%.1f%%", metrics.mcFdvRatio * 100.0))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(ratioColor(metrics.mcFdvRatio))
                    
                    Text(ratioDescription(metrics.mcFdvRatio))
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(1)
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                
                // Card 3: Cung Lưu Hành / Tổng Cung
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Cung Lưu Hành / Tổng")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: "circles.hexagonpath.fill")
                            .foregroundColor(AppTheme.cyan)
                            .font(.system(size: 13))
                    }
                    
                    Text(Formatters.formatVolume(metrics.circulatingSupply))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Text("Max / Total:")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                        Text(metrics.maxSupply != nil ? Formatters.formatVolume(metrics.maxSupply!) : "Không giới hạn")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
                
                // Card 4: Lạm Phát / Cơ Chế Đốt
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Lạm Phát & Đốt Token")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Image(systemName: metrics.isBurnActive ? "flame.fill" : "arrow.triangle.2.circlepath")
                            .foregroundColor(metrics.isBurnActive ? AppTheme.orange : AppTheme.purple)
                            .font(.system(size: 13))
                    }
                    
                    HStack(spacing: 6) {
                        if let inf = metrics.annualInflationRate {
                            Text(String(format: "%.1f%% / năm", inf))
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .foregroundColor(inf > 10 ? AppTheme.orange : AppTheme.purple)
                        } else {
                            Text("0.0% / năm")
                                .font(.system(size: 15, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        }
                    }
                    
                    if metrics.isBurnActive {
                        HStack(spacing: 4) {
                            Text("Đã đốt:")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.4))
                            Text(Formatters.formatVolume(metrics.burnedTokens ?? 0))
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppTheme.orange)
                        }
                    } else {
                        Text("Chưa có cơ chế đốt")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
            }
            
            // Bottom Bar: Supply Progress Bar & Utility Pills
            VStack(alignment: .leading, spacing: 8) {
                // Supply Progress
                let maxOrTotal = metrics.maxSupply ?? metrics.totalSupply
                let ratio = maxOrTotal > 0 ? min(1.0, metrics.circulatingSupply / maxOrTotal) : 1.0
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Tiến Độ Lưu Hành Cung")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(Formatters.formatVolume(metrics.circulatingSupply)) / \(Formatters.formatVolume(maxOrTotal)) (\(String(format: "%.1f%%", ratio * 100.0)))")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.cyan, AppTheme.accentBlue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(4, geo.size.width * CGFloat(ratio)), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                
                // Token Standard & Utility Tags
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.accentBlue)
                        Text("Tiêu chuẩn:")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(tokenStandard)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.darkHeaderBg)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    
                    Divider()
                        .frame(height: 14)
                        .background(AppTheme.darkBorder)
                    
                    Text("Công dụng:")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    ForEach(useCases, id: \.self) { u in
                        Text(u)
                            .font(.system(size: 10, weight: .medium))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(AppTheme.purple.opacity(0.15))
                            .foregroundColor(AppTheme.purple)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                }
                .padding(.top, 4)
            }
            .padding(12)
            .background(AppTheme.darkCard.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
        }
    }
    
    private func ratioColor(_ r: Double) -> Color {
        if r >= 0.8 { return AppTheme.upGreen }
        if r >= 0.5 { return AppTheme.cyan }
        if r >= 0.25 { return AppTheme.warningYellow }
        return AppTheme.orange
    }
    
    private func ratioDescription(_ r: Double) -> String {
        if r >= 0.8 { return "Cung lưu hành cao, ít rủi ro pha loãng" }
        if r >= 0.5 { return "Cung lưu hành trung bình khá" }
        if r >= 0.25 { return "Cần lưu ý lịch mở khóa token tương lai" }
        return "Cung lưu hành thấp (Low Float), áp lực pha loãng lớn"
    }
}

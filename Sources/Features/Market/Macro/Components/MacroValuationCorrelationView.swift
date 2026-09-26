import SwiftUI

public struct MacroValuationCorrelationView: View {
    public let snapshots: [MacroIndexSnapshot]
    public let seasonReport: MarketSeasonReport
    
    public init(snapshots: [MacroIndexSnapshot], seasonReport: MarketSeasonReport) {
        self.snapshots = snapshots
        self.seasonReport = seasonReport
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1. Top 6 Macro Index Cards Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(snapshots) { snap in
                    macroIndexCard(snap: snap)
                }
            }
            
            // 2. Capital Rotation & Season Matrix Radar Card
            seasonMatrixRadarCard
            
            // 3. Stablecoin Liquidity & Cash Sidelined Meter
            stablecoinLiquidityMeterCard
        }
    }
    
    // MARK: - Macro Index Card
    private func macroIndexCard(snap: MacroIndexSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                HStack(spacing: 5) {
                    Image(systemName: snap.indexType.iconName)
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 12))
                    Text(snap.indexType.displayName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.85))
                        .lineLimit(1)
                }
                Spacer()
                
                HStack(spacing: 3) {
                    Image(systemName: snap.change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                    Text(String(format: "%+.2f%%", snap.change24h))
                }
                .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                .foregroundColor(snap.change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 8) {
                Text(snap.formattedValue)
                    .font(.system(size: 19, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(snap.indexType.subtitle)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.45))
                    .lineLimit(1)
            }
            
            // Mini Sparkline preview
            if !snap.sparkline.isEmpty {
                miniSparkline(points: snap.sparkline, isUp: snap.change24h >= 0)
                    .frame(height: 18)
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    // MARK: - Mini Sparkline
    private func miniSparkline(points: [Double], isUp: Bool) -> some View {
        GeometryReader { geo in
            let minVal = points.min() ?? 0
            let maxVal = points.max() ?? 1
            let range = max(0.0001, maxVal - minVal)
            
            Path { path in
                for (idx, pt) in points.enumerated() {
                    let x = geo.size.width * CGFloat(idx) / CGFloat(points.count - 1)
                    let y = geo.size.height * CGFloat(1.0 - (pt - minVal) / range)
                    if idx == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                isUp ? AppTheme.upGreen : AppTheme.downRed,
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
        }
    }
    
    // MARK: - Season Matrix Radar Card
    private var seasonMatrixRadarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: seasonReport.currentState.iconName)
                        .foregroundColor(seasonReport.currentState.color)
                        .font(.system(size: 14))
                    Text("MA TRẬN NHẬN DIỆN MÙA & LUÂN CHUYỂN DÒNG TIỀN (CAPITAL ROTATION)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(seasonReport.currentState.color)
                        .frame(width: 8, height: 8)
                    Text(seasonReport.currentState.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(seasonReport.currentState.color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(seasonReport.currentState.color.opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Altcoin Season Index Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Chỉ Số Mùa Altcoin (Altcoin Season Index):")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(seasonReport.altcoinSeasonIndex) / 100")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(seasonReport.altcoinSeasonIndex >= 75 ? AppTheme.upGreen : (seasonReport.altcoinSeasonIndex <= 25 ? AppTheme.orange : AppTheme.accentBlue))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Gradient track
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(AppTheme.orange.opacity(0.4))
                                .frame(width: geo.size.width * 0.25)
                                .overlay(Text("Mùa BTC (<25)").font(.system(size: 9)).foregroundColor(AppTheme.orange), alignment: .center)
                            
                            Rectangle()
                                .fill(AppTheme.accentBlue.opacity(0.4))
                                .frame(width: geo.size.width * 0.50)
                                .overlay(Text("Cân bằng / Luân chuyển").font(.system(size: 9)).foregroundColor(AppTheme.accentBlue), alignment: .center)
                            
                            Rectangle()
                                .fill(AppTheme.upGreen.opacity(0.4))
                                .frame(maxWidth: .infinity)
                                .overlay(Text("Altseason (>75)").font(.system(size: 9)).foregroundColor(AppTheme.upGreen), alignment: .center)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        // Indicator Needle
                        let pos = CGFloat(seasonReport.altcoinSeasonIndex) / 100.0
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 3, height: 18)
                            .shadow(color: .white, radius: 2)
                            .offset(x: max(0, min(geo.size.width - 3, geo.size.width * pos)))
                    }
                }
                .frame(height: 18)
            }
            
            // Actionable summary box
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppTheme.warningYellow)
                    .font(.system(size: 12))
                    .padding(.top, 2)
                
                Text(seasonReport.actionableSummary)
                    .font(.system(size: 11.5))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(2)
            }
            .padding(10)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    // MARK: - Stablecoin Liquidity Meter Card
    private var stablecoinLiquidityMeterCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: "dollarsign.arrow.circlepath")
                        .foregroundColor(AppTheme.cyan)
                        .font(.system(size: 12))
                    Text("Thanh Khoản Tiền Mặt Đang Chờ Gom (Stablecoin Sidelined Liquidity)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                Text("Ước tính tổng lượng USDT, USDC, DAI đang ở trạng thái tiền mặt chờ giải ngân:")
                    .font(.system(size: 10.5))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(Formatters.formatVolume(seasonReport.stablecoinLiquidityUSD) + " USD")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.cyan)
                
                Text("Chiếm \(String(format: "%.1f%%", seasonReport.usdtDPercentage)) tổng vốn hóa")
                    .font(.system(size: 10.5))
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

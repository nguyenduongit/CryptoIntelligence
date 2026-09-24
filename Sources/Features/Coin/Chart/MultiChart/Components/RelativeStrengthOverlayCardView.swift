import SwiftUI

public struct RelativeStrengthOverlayCardView: View {
    public let summary: RelativeStrengthSummary
    
    public init(summary: RelativeStrengthSummary) {
        self.summary = summary
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(summary.performanceGrade.color)
                    Text("Sức Mạnh Tương Quan vs Bitcoin (\(summary.baseAsset)/BTC)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if summary.isLiveCandleData {
                    DataSourceBadge(type: .liveBinance, text: "30D Nến Binance")
                } else {
                    DataSourceBadge(type: .simulatedCatalog, text: "Nội Suy Tham Chiếu")
                }
                
                Text(summary.performanceGrade.rawValue)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(summary.performanceGrade.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(summary.performanceGrade.color.opacity(0.15))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(summary.performanceGrade.color.opacity(0.4), lineWidth: 1)
                    )
            }
            
            // Metrics Row
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TỶ GIÁ CẶP (RATIO)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.6f ₿", summary.currentRatio))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("HIỆU SUẤT 7 NGÀY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    let is7dUp = summary.change7dPercent >= 0
                    Text("\(is7dUp ? "+" : "")\(String(format: "%.2f", summary.change7dPercent))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(is7dUp ? AppTheme.upGreen : AppTheme.downRed)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("HIỆU SUẤT 30 NGÀY")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    let is30dUp = summary.change30dPercent >= 0
                    Text("\(is30dUp ? "+" : "")\(String(format: "%.2f", summary.change30dPercent))%")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(is30dUp ? AppTheme.cyan : AppTheme.downRed)
                }
                
                Spacer()
            }
            
            // Sparkline Curve (30-day normalized performance)
            if !summary.history.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ĐƯỜNG CONG ALPHA 30 NGÀY SO VỚI BTC")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    
                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        let points = summary.history.map { $0.changePercentSinceBase }
                        let minVal = (points.min() ?? 0.0) - 2.0
                        let maxVal = (points.max() ?? 10.0) + 2.0
                        let range = max(1.0, maxVal - minVal)
                        
                        Path { path in
                            for (idx, pt) in points.enumerated() {
                                let x = (CGFloat(idx) / CGFloat(max(1, points.count - 1))) * w
                                let y = h - ((CGFloat(pt - minVal) / CGFloat(range)) * h)
                                if idx == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.accentBlue, summary.performanceGrade.color],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                    }
                    .frame(height: 36)
                }
                .padding(8)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

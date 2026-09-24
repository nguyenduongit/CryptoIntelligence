import SwiftUI

public struct HolderConcentrationCardView: View {
    public let metrics: HolderConcentrationMetrics
    
    public init(metrics: HolderConcentrationMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "person.3.sequence.fill")
                        .foregroundColor(AppTheme.purple)
                        .font(.system(size: 13))
                    Text("Cơ Cấu Nắm Giữ & Phân Bổ Ví (Holders)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Total Holders Count & 30d Growth
                HStack(spacing: 6) {
                    Text("Tổng: \(Formatters.formatVolume(Double(metrics.totalHoldersCount))) ví")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    
                    Text(String(format: "(+%0.1f%% 30d)", metrics.holdersGrowth30d))
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                }
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Segmented Distribution Bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    let top10W = (CGFloat(metrics.top10HoldersPercent) / 100.0) * geo.size.width
                    let top50RemainingW = (CGFloat(metrics.top50HoldersPercent - metrics.top10HoldersPercent) / 100.0) * geo.size.width
                    let top100RemainingW = (CGFloat(metrics.top100HoldersPercent - metrics.top50HoldersPercent) / 100.0) * geo.size.width
                    let retailW = max(2, geo.size.width - top10W - top50RemainingW - top100RemainingW)
                    
                    HStack(spacing: 2) {
                        Rectangle()
                            .fill(AppTheme.orange)
                            .frame(width: max(2, top10W))
                        Rectangle()
                            .fill(AppTheme.purple)
                            .frame(width: max(2, top50RemainingW))
                        Rectangle()
                            .fill(AppTheme.accentBlue)
                            .frame(width: max(2, top100RemainingW))
                        Rectangle()
                            .fill(AppTheme.cyan)
                            .frame(width: max(2, retailW))
                    }
                    .clipShape(Capsule())
                }
                .frame(height: 8)
                
                // Legend
                HStack(spacing: 12) {
                    LegendPill(color: AppTheme.orange, title: "Top 10 ví", percent: metrics.top10HoldersPercent)
                    LegendPill(color: AppTheme.purple, title: "Top 50 ví", percent: metrics.top50HoldersPercent)
                    LegendPill(color: AppTheme.accentBlue, title: "Top 100 ví", percent: metrics.top100HoldersPercent)
                    LegendPill(color: AppTheme.cyan, title: "Nhỏ lẻ / Khác", percent: metrics.retailHoldersPercent)
                }
                .padding(.top, 2)
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

private struct LegendPill: View {
    let color: Color
    let title: String
    let percent: Double
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(title + ":")
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.5))
            Text(String(format: "%.1f%%", percent))
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
        }
    }
}

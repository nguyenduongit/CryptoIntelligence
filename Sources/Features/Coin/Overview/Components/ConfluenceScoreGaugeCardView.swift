import SwiftUI

public struct ConfluenceScoreGaugeCardView: View {
    public let report: ConfluenceResearchReport
    
    public init(report: ConfluenceResearchReport) {
        self.report = report
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Overall Score & Recommendation
            HStack(spacing: 16) {
                // Circular Gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 6)
                        .frame(width: 58, height: 58)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(report.overallScore) / 100.0)
                        .stroke(
                            report.recommendation.badgeColor,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 58, height: 58)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(report.overallScore)")
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .foregroundColor(.white)
                        Text("/ 100")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
                
                // Recommendation Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text("Điểm Hợp Lưu Định Lượng (Quantitative Confluence)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("5 Trụ Cột")
                            .font(.system(size: 9, weight: .bold))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(AppTheme.accentBlue.opacity(0.2))
                            .foregroundColor(AppTheme.accentBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: report.recommendation.iconName)
                            .foregroundColor(report.recommendation.badgeColor)
                            .font(.system(size: 13, weight: .bold))
                        
                        Text(report.recommendation.rawValue)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(report.recommendation.badgeColor)
                    }
                }
                
                Spacer()
                
                // Timestamp Badge
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Cập nhật theo thời gian thực")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    Text(Formatters.formatTime(date: report.generatedAt))
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // 5-Pillar Score Breakdown Bars
            VStack(alignment: .leading, spacing: 8) {
                Text("Chi Tiết Điểm Số 5 Trụ Cột Đánh Giá:")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                VStack(spacing: 7) {
                    ForEach(report.pillars) { p in
                        VStack(alignment: .leading, spacing: 3) {
                            HStack {
                                HStack(spacing: 5) {
                                    Image(systemName: p.pillar.iconName)
                                        .font(.system(size: 10))
                                        .foregroundColor(p.signal.color)
                                    Text(p.pillar.shortName)
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundColor(.white.opacity(0.85))
                                    
                                    if p.pillar == .technical {
                                        DataSourceBadge(type: .realTimeAlgorithm, text: "4H Live")
                                    } else {
                                        DataSourceBadge(type: .simulatedCatalog, text: "Catalog")
                                    }
                                }
                                
                                Spacer()
                                
                                Text(p.signal.rawValue)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(p.signal.color)
                                
                                Text("\(p.score)/100")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .frame(width: 48, alignment: .trailing)
                            }
                            
                            // Score bar
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.08))
                                        .frame(height: 5)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(p.signal.color)
                                        .frame(width: max(4, geo.size.width * CGFloat(p.score) / 100.0), height: 5)
                                }
                            }
                            .frame(height: 5)
                            
                            // Short note
                            Text(p.summary)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.5))
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.darkHeaderBg.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
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

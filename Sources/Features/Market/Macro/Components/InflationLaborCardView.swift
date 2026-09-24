import SwiftUI

public struct InflationLaborCardView: View {
    public let inflationMetrics: [InflationReportItem]
    public let unemploymentRate: Double
    public let nonFarmPayrollsK: Double
    
    public init(inflationMetrics: [InflationReportItem], unemploymentRate: Double, nonFarmPayrollsK: Double) {
        self.inflationMetrics = inflationMetrics
        self.unemploymentRate = unemploymentRate
        self.nonFarmPayrollsK = nonFarmPayrollsK
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.orange)
                    Text("Chỉ Số Lạm Phát & Việc Làm Mỹ")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Mục tiêu Lạm phát: 2.0%")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(AppTheme.warningYellow)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AppTheme.warningYellow.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Labor Market Summary Row
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.cyan)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("TỶ LỆ THẤT NGHIỆP")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.45))
                        Text(String(format: "%.1f%% (Ổn định)", unemploymentRate))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                HStack(spacing: 8) {
                    Image(systemName: "briefcase.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.upGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BẢNG LƯƠNG PHI NÔNG NGHIỆP (NFP)")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white.opacity(0.45))
                        Text(String(format: "+%.0fK Việc làm", nonFarmPayrollsK))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Inflation Indicators List
            VStack(spacing: 6) {
                ForEach(inflationMetrics) { item in
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.metricName)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Dự báo: \(String(format: "%.1f%%", item.forecastValue)) • Kỳ trước: \(String(format: "%.1f%%", item.previousValue))")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        
                        Spacer()
                        
                        // Latest Value & Gap to 2.0% Target
                        VStack(alignment: .trailing, spacing: 2) {
                            HStack(spacing: 4) {
                                Text(String(format: "%.1f%%", item.latestValue))
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(item.latestValue <= item.forecastValue ? AppTheme.upGreen : AppTheme.downRed)
                                
                                Text(item.trend)
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            let gap = item.latestValue - item.targetValue
                            Text(String(format: "%@%.1f%% vs Target", gap >= 0 ? "+" : "", gap))
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(gap <= 0.5 ? AppTheme.upGreen : AppTheme.warningYellow)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

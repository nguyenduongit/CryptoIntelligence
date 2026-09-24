import SwiftUI

public struct DerivativesOverviewBarView: View {
    public let metrics: DerivativesMetrics
    
    public init(metrics: DerivativesMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // 1. Funding Rate (8h)
            HStack(spacing: 6) {
                Image(systemName: "percent")
                    .font(.system(size: 11))
                    .foregroundColor(metrics.isPositiveFunding ? AppTheme.upGreen : AppTheme.downRed)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Funding Rate (8h)")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 3) {
                        Text(String(format: "%+.4f%%", metrics.fundingRatePercentage))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(metrics.isPositiveFunding ? AppTheme.upGreen : AppTheme.downRed)
                        Text("(Est. \(String(format: "%+.4f%%", metrics.predictedFundingRate * 100)))")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 2. Open Interest (OI)
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.accentBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Open Interest (OI)")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Text(formatCurrency(metrics.openInterestUSD))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Text(String(format: "%+.1f%%", metrics.openInterestChange24h))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(metrics.openInterestChange24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 3. Long / Short Ratio Bar
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text("Long / Short:")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(String(format: "%.1f%% L / %.1f%% S", metrics.longRatio * 100, metrics.shortRatio * 100))
                            .font(.system(size: 9, weight: .semibold))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    // Mini Ratio Bar
                    GeometryReader { geo in
                        HStack(spacing: 1) {
                            Rectangle()
                                .fill(AppTheme.upGreen)
                                .frame(width: geo.size.width * metrics.longRatio)
                            Rectangle()
                                .fill(AppTheme.downRed)
                                .frame(width: geo.size.width * metrics.shortRatio)
                        }
                    }
                    .frame(height: 4)
                    .clipShape(Capsule())
                }
                .frame(width: 140)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 4. 24h Liquidations
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 11))
                    .foregroundColor(AppTheme.orange)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Thanh lý 24h")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                    HStack(spacing: 4) {
                        Text(formatCurrency(metrics.totalLiquidations24hUSD))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Text("(🟢\(formatShortCurrency(metrics.liquidations24hLongUSD)) / 🔴\(formatShortCurrency(metrics.liquidations24hShortUSD)))")
                            .font(.system(size: 8))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Spacer()
        }
    }
    
    private func formatCurrency(_ value: Double) -> String {
        if value >= 1_000_000_000 {
            return String(format: "$%.2fB", value / 1_000_000_000)
        } else if value >= 1_000_000 {
            return String(format: "$%.2fM", value / 1_000_000)
        } else {
            return String(format: "$%.0f", value)
        }
    }
    
    private func formatShortCurrency(_ value: Double) -> String {
        if value >= 1_000_000 {
            return String(format: "$%.1fM", value / 1_000_000)
        } else {
            return String(format: "$%.0fK", value / 1_000)
        }
    }
}

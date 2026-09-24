import SwiftUI

public struct MarketMacroMetricsBarView: View {
    public let metrics: MarketGlobalMetrics?
    public let isLoading: Bool
    public let onRefresh: () -> Void
    
    public init(metrics: MarketGlobalMetrics?, isLoading: Bool, onRefresh: @escaping () -> Void) {
        self.metrics = metrics
        self.isLoading = isLoading
        self.onRefresh = onRefresh
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // 1. Total 24h Volume
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 13))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Khối lượng 24h")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(metrics?.total24hVolumeUSDT ?? 0) + " USDT")
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 2. BTC & ETH Dominance
            HStack(spacing: 12) {
                // BTC.D
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.orange)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("BTC.D")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(String(format: "%.1f%%", metrics?.btcDominancePercent ?? 56.4))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.orange)
                    }
                }
                
                Divider()
                    .frame(height: 20)
                    .background(AppTheme.darkBorder)
                
                // ETH.D
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.cyan)
                        .frame(width: 8, height: 8)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ETH.D")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(String(format: "%.1f%%", metrics?.ethDominancePercent ?? 14.8))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.cyan)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 3. Market Breadth (Gainers / Losers)
            if let m = metrics {
                HStack(spacing: 10) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                        Text("\(m.topGainersCount) tăng")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    
                    Text("/")
                        .foregroundColor(.white.opacity(0.3))
                        .font(.system(size: 11))
                    
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.downRed)
                        Text("\(m.topLosersCount) giảm")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(AppTheme.downRed)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(AppTheme.darkCard.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // 4. Fear & Greed Gauge Pill
            if let m = metrics {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.15), lineWidth: 3)
                            .frame(width: 22, height: 22)
                        Circle()
                            .trim(from: 0.0, to: CGFloat(m.fearAndGreedIndex) / 100.0)
                            .stroke(fearAndGreedColor(m.fearAndGreedIndex), lineWidth: 3)
                            .frame(width: 22, height: 22)
                            .rotationEffect(.degrees(-90))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tâm lý Thị trường")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        HStack(spacing: 4) {
                            Text("\(m.fearAndGreedIndex)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundColor(fearAndGreedColor(m.fearAndGreedIndex))
                            Text("(\(fearAndGreedVietnamese(m.fearAndGreedClassification)))")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(fearAndGreedColor(m.fearAndGreedIndex).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(fearAndGreedColor(m.fearAndGreedIndex).opacity(0.3), lineWidth: 1)
                )
            }
            
            Spacer()
            
            // Refresh Button
            Button(action: onRefresh) {
                HStack(spacing: 5) {
                    if isLoading {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    Text("Làm mới")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.darkCard)
                .foregroundColor(.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func fearAndGreedColor(_ val: Int) -> Color {
        if val >= 75 { return AppTheme.upGreen }
        if val >= 55 { return Color(red: 0.4, green: 0.85, blue: 0.3) }
        if val >= 45 { return AppTheme.warningYellow }
        if val >= 25 { return AppTheme.orange }
        return AppTheme.downRed
    }
    
    private func fearAndGreedVietnamese(_ classification: String) -> String {
        switch classification.lowercased() {
        case "extreme greed": return "Cực kỳ Hưng phấn"
        case "greed": return "Tham lam"
        case "neutral": return "Trung lập"
        case "fear": return "Sợ hãi"
        case "extreme fear": return "Cực kỳ Sợ hãi"
        default: return classification
        }
    }
}

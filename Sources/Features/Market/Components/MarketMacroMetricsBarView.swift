import SwiftUI

public struct MarketMacroMetricsBarView: View {
    public let globalMetrics: MarketGlobalMetrics?
    public let derivativesMetrics: DerivativesMetrics?
    
    public init(globalMetrics: MarketGlobalMetrics?, derivativesMetrics: DerivativesMetrics? = nil) {
        self.globalMetrics = globalMetrics
        self.derivativesMetrics = derivativesMetrics
    }
    
    // Backwards compatibility initializer
    public init(metrics: MarketGlobalMetrics?, isLoading: Bool = false, onRefresh: (() -> Void)? = nil) {
        self.globalMetrics = metrics
        self.derivativesMetrics = nil
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // MARK: - SPOT & MACRO METRICS
            HStack(spacing: 12) {
                // 1. Total 24h Volume
                HStack(spacing: 5) {
                    Image(systemName: "chart.bar.xaxis")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 11))
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Khối lượng 24h")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.45))
                        Text(Formatters.formatVolume(globalMetrics?.total24hVolumeUSDT ?? 0) + " USDT")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                
                Divider()
                    .frame(height: 16)
                    .background(AppTheme.darkBorder)
                
                // 2. BTC & ETH Dominance
                HStack(spacing: 10) {
                    // BTC.D
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.orange)
                            .frame(width: 6, height: 6)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("BTC.D")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            Text(String(format: "%.1f%%", globalMetrics?.btcDominancePercent ?? 58.6))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.orange)
                        }
                    }
                    
                    // ETH.D
                    HStack(spacing: 4) {
                        Circle()
                            .fill(AppTheme.cyan)
                            .frame(width: 6, height: 6)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("ETH.D")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            Text(String(format: "%.1f%%", globalMetrics?.ethDominancePercent ?? 11.3))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.cyan)
                        }
                    }
                }
                
                Divider()
                    .frame(height: 16)
                    .background(AppTheme.darkBorder)
                
                // 3. Market Breadth (Gainers / Losers)
                if let m = globalMetrics {
                    HStack(spacing: 6) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(AppTheme.upGreen)
                            Text("\(m.topGainersCount)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.upGreen)
                            Text("tăng")
                                .font(.system(size: 9))
                                .foregroundColor(AppTheme.upGreen.opacity(0.8))
                        }
                        
                        Text("/")
                            .foregroundColor(.white.opacity(0.25))
                            .font(.system(size: 10))
                        
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.down.right")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundColor(AppTheme.downRed)
                            Text("\(m.topLosersCount)")
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.downRed)
                            Text("giảm")
                                .font(.system(size: 9))
                                .foregroundColor(AppTheme.downRed.opacity(0.8))
                        }
                    }
                    
                    Divider()
                        .frame(height: 16)
                        .background(AppTheme.darkBorder)
                }
                
                // 4. Fear & Greed Index
                if let m = globalMetrics {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(fearAndGreedColor(m.fearAndGreedIndex))
                            .frame(width: 7, height: 7)
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Tâm lý")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            HStack(spacing: 3) {
                                Text("\(m.fearAndGreedIndex)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(fearAndGreedColor(m.fearAndGreedIndex))
                                Text("(\(fearAndGreedVietnamese(m.fearAndGreedClassification)))")
                                    .font(.system(size: 9, weight: .medium))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(fearAndGreedColor(m.fearAndGreedIndex).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            // MARK: - DERIVATIVES PULSE (IF AVAILABLE)
            if let deriv = derivativesMetrics {
                Divider()
                    .frame(height: 20)
                    .background(AppTheme.accentBlue.opacity(0.4))
                
                HStack(spacing: 12) {
                    // Funding Rate
                    HStack(spacing: 4) {
                        Image(systemName: "percent")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(deriv.isPositiveFunding ? AppTheme.upGreen : AppTheme.downRed)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Funding (8h)")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            Text(String(format: "%+.4f%%", deriv.fundingRatePercentage))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(deriv.isPositiveFunding ? AppTheme.upGreen : AppTheme.downRed)
                        }
                    }
                    
                    Divider()
                        .frame(height: 16)
                        .background(AppTheme.darkBorder)
                    
                    // Open Interest
                    HStack(spacing: 4) {
                        Image(systemName: "waveform.path.ecg")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.cyan)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Open Interest")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            HStack(spacing: 2) {
                                Text(formatCurrency(deriv.openInterestUSD))
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Text(String(format: "%+.1f%%", deriv.openInterestChange24h))
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                    .foregroundColor(deriv.openInterestChange24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            }
                        }
                    }
                    
                    Divider()
                        .frame(height: 16)
                        .background(AppTheme.darkBorder)
                    
                    // Long / Short Ratio with Mini Bar
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("L/S:")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            Text(String(format: "%.1f%% L / %.1f%% S", deriv.longRatio * 100, deriv.shortRatio * 100))
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                        }
                        
                        GeometryReader { geo in
                            HStack(spacing: 1) {
                                Rectangle()
                                    .fill(AppTheme.upGreen)
                                    .frame(width: geo.size.width * deriv.longRatio)
                                Rectangle()
                                    .fill(AppTheme.downRed)
                                    .frame(width: geo.size.width * deriv.shortRatio)
                            }
                        }
                        .frame(width: 90, height: 3.5)
                        .clipShape(Capsule())
                    }
                    
                    Divider()
                        .frame(height: 16)
                        .background(AppTheme.darkBorder)
                    
                    // 24h Liquidations
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.orange)
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Thanh lý 24h")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.45))
                            HStack(spacing: 3) {
                                Text(formatCurrency(deriv.totalLiquidations24hUSD))
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Text("(🟢\(formatShortCurrency(deriv.liquidations24hLongUSD)) / 🔴\(formatShortCurrency(deriv.liquidations24hShortUSD)))")
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.45))
                            }
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 6)
        .background(AppTheme.darkHeaderBg.opacity(0.95))
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Formatters & Colors
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

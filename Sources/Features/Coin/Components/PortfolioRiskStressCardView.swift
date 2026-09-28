import SwiftUI

public struct PortfolioRiskStressCardView: View {
    public let baseProfile: PortfolioRiskProfile
    
    @State private var assumedCapital: Double = 1_000_000.0 // Default 1M USD
    @State private var selectedSubtab: String = "var" // "var" or "stress" or "sizing"
    
    private let capitalPresets: [Double] = [
        100_000,
        500_000,
        1_000_000,
        2_500_000,
        5_000_000,
        10_000_000
    ]
    
    public init(baseProfile: PortfolioRiskProfile) {
        self.baseProfile = baseProfile
    }
    
    private var currentProfile: PortfolioRiskProfile {
        PortfolioRiskEngine.shared.recalculateWithCapital(baseProfile: baseProfile, newCapitalUSD: assumedCapital)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                    .foregroundColor(AppTheme.downRed)
                    .font(.system(size: 13))
                Text("QUẢN TRỊ RỦI RO THỂ CHẾ & MÔ PHỎNG KHỦNG HOẢNG (STRESS-TEST & VAR)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("Local Quant Risk Engine")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Capital Selector Controls
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Quy mô danh mục giả định:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("$\(Int(assumedCapital).formatted()) USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue)
                }
                
                HStack(spacing: 8) {
                    ForEach(capitalPresets, id: \.self) { cap in
                        Button(action: {
                            assumedCapital = cap
                        }) {
                            Text(formatCapital(cap))
                                .font(.system(size: 10.5, weight: assumedCapital == cap ? .bold : .medium, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(assumedCapital == cap ? AppTheme.accentBlue.opacity(0.25) : Color.white.opacity(0.04))
                                .foregroundColor(assumedCapital == cap ? AppTheme.accentBlue : .white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(assumedCapital == cap ? AppTheme.accentBlue.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.02))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Subtab Filter (VaR vs Historical Stress vs Sizing)
            Picker("Risk Section", selection: $selectedSubtab) {
                Text("Value-at-Risk (VaR)").tag("var")
                Text("Mô Phỏng 4 Cú Sập Lịch Sử").tag("stress")
                Text("Định Cỡ Vốn (Risk Parity)").tag("sizing")
            }
            .pickerStyle(.segmented)
            
            // Dynamic Subtab Rendering
            switch selectedSubtab {
            case "var":
                renderVaRSection(currentProfile.varMetrics)
            case "stress":
                renderStressSection(currentProfile.stressScenarios)
            case "sizing":
                renderSizingSection(currentProfile.sizing)
            default:
                EmptyView()
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    // MARK: - VaR Section
    @ViewBuilder
    private func renderVaRSection(_ vm: ValueAtRiskMetrics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                // Card 1: 1D VaR 95%
                metricCard(
                    title: "1-DAY VAR (95% TIN CẬY)",
                    value: "-$\(formatUSD(vm.var95DailyUSD))",
                    subtext: "Lỗ tối đa 19 trong 20 ngày: \(String(format: "%.2f%%", vm.var95DailyPercent))",
                    color: AppTheme.warningYellow
                )
                
                // Card 2: 1D VaR 99%
                metricCard(
                    title: "1-DAY VAR (99% TIN CẬY)",
                    value: "-$\(formatUSD(vm.var99DailyUSD))",
                    subtext: "Lỗ cực đoan 99%: \(String(format: "%.2f%%", vm.var99DailyPercent))",
                    color: AppTheme.downRed
                )
                
                // Card 3: Expected Shortfall (CVaR)
                metricCard(
                    title: "EXPECTED SHORTFALL (CVAR)",
                    value: "-$\(formatUSD(vm.expectedShortfallCVaRUSD))",
                    subtext: "Lỗ TB khi thủng VaR: \(String(format: "%.2f%%", vm.expectedShortfallPercent))",
                    color: AppTheme.downRed
                )
            }
            
            HStack {
                Text("Độ biến động lịch sử niên độ hóa (Historical Volatility 120D):")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.6))
                Spacer()
                Text("\(String(format: "%.1f%%", vm.annualizedVolatility)) p.a.")
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.accentBlue)
            }
            .padding(8)
            .background(Color.white.opacity(0.02))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
    
    // MARK: - Stress Testing Section
    @ViewBuilder
    private func renderStressSection(_ scenarios: [CrisisStressResult]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(scenarios) { s in
                HStack(alignment: .center, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(s.scenario.name)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                            Text("(\(s.scenario.dateRange))")
                                .font(.system(size: 9.5))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        Text(s.scenario.description)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("-$\(formatUSD(s.projectedLossUSD))")
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.downRed)
                        Text("Sụt giảm: \(String(format: "-%.1f%%", s.projectedDrawdownPercent))")
                            .font(.system(size: 9.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Đòn bẩy an toàn:")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                        Text(String(format: "≤ %.1fx", s.safeMaxLeverage))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(s.safeMaxLeverage < 1.5 ? AppTheme.downRed : AppTheme.upGreen)
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
    }
    
    // MARK: - Sizing Section
    @ViewBuilder
    private func renderSizingSection(_ sizing: RiskParitySizing) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                metricCard(
                    title: "TỶ TRỌNG RISK PARITY ĐỀ XUẤT",
                    value: "\(String(format: "%.1f%%", sizing.recommendedPortfolioWeightPercent))",
                    subtext: "Phân bổ tối đa: $\(formatUSD(sizing.maxAllocationUSD))",
                    color: AppTheme.upGreen
                )
                
                metricCard(
                    title: "HALF-KELLY CRITERION",
                    value: "\(String(format: "%.1f%%", sizing.halfKellyFractionPercent))",
                    subtext: "Ngưỡng tăng trưởng tối ưu",
                    color: AppTheme.accentBlue
                )
            }
            
            HStack(spacing: 8) {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.upGreen)
                    .font(.system(size: 12))
                Text(sizing.sizingRational)
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(10)
            .background(AppTheme.upGreen.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
    
    private func metricCard(title: String, value: String, subtext: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(color)
            Text(subtext)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.03))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func formatCapital(_ cap: Double) -> String {
        if cap >= 1_000_000 {
            return "$\(Int(cap / 1_000_000.0))M"
        } else {
            return "$\(Int(cap / 1_000.0))K"
        }
    }
    
    private func formatUSD(_ val: Double) -> String {
        if val >= 1_000_000_000 {
            return String(format: "%.2fB", val / 1_000_000_000.0)
        } else if val >= 1_000_000 {
            return String(format: "%.2fM", val / 1_000_000.0)
        } else if val >= 1_000 {
            return String(format: "%.1fK", val / 1_000.0)
        } else {
            return String(format: "%.0f", val)
        }
    }
}

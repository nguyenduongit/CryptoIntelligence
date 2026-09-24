import SwiftUI

public struct ScenarioProjectionsCardView: View {
    public let scenarios: [ScenarioProjection]
    
    public init(scenarios: [ScenarioProjection]) {
        self.scenarios = scenarios
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Dự Phóng 3 Kịch Bản Tương Lai (Scenario Projections)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Tầm nhìn 6 - 12 tháng")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // 3 Scenario Cards Grid
            HStack(alignment: .top, spacing: 10) {
                ForEach(scenarios) { sc in
                    VStack(alignment: .leading, spacing: 8) {
                        // Title & Probability Badge
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: sc.scenarioType.iconName)
                                    .foregroundColor(sc.scenarioType.color)
                                    .font(.system(size: 11))
                                Text(sc.scenarioType.rawValue)
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                            
                            Text("\(sc.probabilityPercent)% Xác suất")
                                .font(.system(size: 9, weight: .semibold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(sc.scenarioType.color.opacity(0.15))
                                .foregroundColor(sc.scenarioType.color)
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        
                        // Price Target & Return
                        VStack(alignment: .leading, spacing: 1) {
                            Text(Formatters.formatPrice(sc.targetPriceUSD))
                                .font(.system(size: 16, weight: .heavy, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text((sc.expectedReturnPercent >= 0 ? "+" : "") + String(format: "%.1f%%", sc.expectedReturnPercent))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(sc.expectedReturnPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                        .padding(.vertical, 4)
                        
                        Divider()
                            .background(AppTheme.darkBorder.opacity(0.6))
                        
                        // Key Drivers
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Động lực chính:")
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(.white.opacity(0.5))
                            
                            ForEach(sc.keyDrivers, id: \.self) { driver in
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .font(.system(size: 9, weight: .bold))
                                        .foregroundColor(sc.scenarioType.color)
                                    Text(driver)
                                        .font(.system(size: 9.5))
                                        .foregroundColor(.white.opacity(0.75))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.darkHeaderBg.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(sc.scenarioType.color.opacity(0.3), lineWidth: 1)
                    )
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

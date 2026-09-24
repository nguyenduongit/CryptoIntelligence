import SwiftUI

public struct VestingEmissionCurveView: View {
    public let schedule: [VestingSchedulePoint]
    
    public init(schedule: [VestingSchedulePoint]) {
        self.schedule = schedule
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Lộ Trình Pha Loãng & Phát Hành 5 Năm (Vesting Curve)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Legend
                HStack(spacing: 12) {
                    legendItem(title: "Đang lưu hành", color: AppTheme.upGreen)
                    legendItem(title: "Khóa Team/Founders", color: AppTheme.purple)
                    legendItem(title: "Khóa Quỹ VCs", color: AppTheme.accentBlue)
                    legendItem(title: "Khóa Ngân quỹ Treasury", color: AppTheme.orange)
                }
            }
            
            // Stacked Bar Chart for Years
            VStack(spacing: 8) {
                ForEach(schedule) { pt in
                    HStack(spacing: 10) {
                        // Year Label
                        Text(pt.yearLabel)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                            .frame(width: 40, alignment: .leading)
                        
                        // Stacked Multi-color Bar
                        GeometryReader { geo in
                            let totalW = geo.size.width
                            let circW = totalW * (pt.circulatingPercent / 100.0)
                            let teamW = totalW * (pt.teamLockedPercent / 100.0)
                            let invW = totalW * (pt.investorsLockedPercent / 100.0)
                            let trsW = max(0, totalW - circW - teamW - invW)
                            
                            HStack(spacing: 1) {
                                if circW > 0 {
                                    Rectangle()
                                        .fill(AppTheme.upGreen.opacity(0.9))
                                        .frame(width: circW)
                                }
                                if teamW > 0 {
                                    Rectangle()
                                        .fill(AppTheme.purple.opacity(0.85))
                                        .frame(width: teamW)
                                }
                                if invW > 0 {
                                    Rectangle()
                                        .fill(AppTheme.accentBlue.opacity(0.85))
                                        .frame(width: invW)
                                }
                                if trsW > 0 {
                                    Rectangle()
                                        .fill(AppTheme.orange.opacity(0.85))
                                        .frame(width: trsW)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .frame(height: 18)
                        
                        // Percentage Indicator
                        Text(String(format: "%.1f%% Lưu hành", pt.circulatingPercent))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(pt.circulatingPercent >= 90 ? AppTheme.upGreen : .white.opacity(0.7))
                            .frame(width: 105, alignment: .trailing)
                    }
                }
            }
            .padding(12)
            .background(AppTheme.darkBackground.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func legendItem(title: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 10))
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

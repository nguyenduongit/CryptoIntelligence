import SwiftUI

public struct GovernanceDecentralizationCardView: View {
    public let risks: [GovernanceRiskFactor]
    
    public init(risks: [GovernanceRiskFactor]) {
        self.risks = risks
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "key.fill")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 13))
                Text("Quản Trị, Quyền Admin & Độ Phân Quyền (Governance Risks)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            VStack(spacing: 8) {
                ForEach(risks) { risk in
                    GovernanceRiskRowView(risk: risk)
                }
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

private struct GovernanceRiskRowView: View {
    let risk: GovernanceRiskFactor
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(risk.factorName)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(risk.riskLevel.color)
                        .frame(width: 6, height: 6)
                    Text(risk.riskLevel.rawValue)
                        .font(.system(size: 10, weight: .semibold))
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(risk.riskLevel.color.opacity(0.15))
                .foregroundColor(risk.riskLevel.color)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            Text(risk.description)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.75))
                .lineSpacing(2)
        }
        .padding(8)
        .background(AppTheme.darkHeaderBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

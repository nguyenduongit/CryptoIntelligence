import SwiftUI

public struct VCBackersGridView: View {
    public let backers: [VCBackerHolding]
    
    public init(backers: [VCBackerHolding]) {
        self.backers = backers
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Quỹ Đầu Tư & Tổ Chức Hàng Đầu (VC Backers)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(backers.count) tổ chức theo dõi")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Grid of VC Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(backers) { vc in
                    VCCardView(vc: vc)
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

private struct VCCardView: View {
    let vc: VCBackerHolding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Row: Fund Name & Lead Badge
            HStack {
                Text(vc.fundName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                if vc.isLeadInvestor {
                    Text("Lead Investor")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(AppTheme.orange.opacity(0.2))
                        .foregroundColor(AppTheme.orange)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            
            // Middle Row: Round & ROI Multiplier
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vòng gọi vốn")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    Text(vc.investmentRound)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Hiệu suất ROI")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    Text(String(format: "%.1fx", vc.roiMultiplier))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(roiColor(vc.roiMultiplier))
                }
            }
            
            // Bottom Row: Estimated Holding & Fund Status
            HStack {
                HStack(spacing: 3) {
                    Text("Vị thế ước tính:")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(vc.estimatedHoldingUSD) + " USD")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(vc.status.color)
                        .frame(width: 6, height: 6)
                    Text(vc.status.rawValue)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(vc.status.color)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(vc.status.color.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
        }
        .padding(10)
        .background(AppTheme.darkHeaderBg.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.darkBorder.opacity(0.5), lineWidth: 1)
        )
    }
    
    private func roiColor(_ m: Double) -> Color {
        if m >= 50.0 { return AppTheme.orange }
        if m >= 10.0 { return AppTheme.upGreen }
        if m >= 2.0 { return AppTheme.cyan }
        return .white
    }
}

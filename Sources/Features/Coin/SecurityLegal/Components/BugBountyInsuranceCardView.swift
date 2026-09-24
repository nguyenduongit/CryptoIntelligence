import SwiftUI

public struct BugBountyInsuranceCardView: View {
    public let bugBounty: BugBountyInfo
    
    public init(bugBounty: BugBountyInfo) {
        self.bugBounty = bugBounty
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundColor(AppTheme.orange)
                    .font(.system(size: 13))
                Text("Chương Trình Săn Lỗi Nhận Thưởng & Lịch Sử Khai Thác (Bug Bounty)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            HStack(spacing: 14) {
                // Bug Bounty Platform & Max Reward
                HStack(spacing: 10) {
                    Image(systemName: "dollarsign.arrow.circlepath")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.upGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Chương Trình Bug Bounty (\(bugBounty.platformName))")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Text("Phần thưởng tối đa: " + Formatters.formatVolume(bugBounty.maxBountyUSD) + " USD")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Exploit History Status
                HStack(spacing: 10) {
                    Image(systemName: bugBounty.hasExploitHistory ? "exclamationmark.triangle.fill" : "checkmark.seal.fill")
                        .font(.system(size: 20))
                        .foregroundColor(bugBounty.hasExploitHistory ? AppTheme.warningYellow : AppTheme.upGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(bugBounty.hasExploitHistory ? "Đã Khắc Phục Sự Cố Trong Quá Khứ" : "Lịch Sử Vận Hành 100% An Toàn")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                        Text(bugBounty.exploitSummary ?? "Chưa từng ghi nhận sự cố khai thác lỗ hổng nào.")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(2)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
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

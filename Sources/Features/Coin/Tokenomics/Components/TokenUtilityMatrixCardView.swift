import SwiftUI

public struct TokenUtilityMatrixCardView: View {
    public let utility: TokenUtilityInfo
    
    public init(utility: TokenUtilityInfo) {
        self.utility = utility
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "bolt.badge.clock.fill")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.cyan)
                Text("Ma Trận Tiện Ích & Động Lực Nắm Giữ (Token Utility)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Grid of 3 Pillars: Staking APR, Fee Burn / Deflation, Governance Power
            HStack(alignment: .top, spacing: 12) {
                // 1. Staking Yield
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Staking Rewards")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        if let apr = utility.stakingAPR {
                            Text(String(format: "%.2f%% APR", apr))
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(AppTheme.upGreen)
                        } else {
                            Text("N/A (PoW/DAO)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.4))
                        }
                    }
                    Text(utility.stakingAPR != nil ? "Ủy quyền validator PoS để bảo mật mạng lưới và nhận thưởng lạm phát gốc." : "Không áp dụng cơ chế Staking tạo lãi thụ động.")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(2)
                }
                .padding(10)
                .background(AppTheme.darkBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // 2. Fee Burn / Deflation
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Cơ Chế Đốt (Burn)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(utility.hasFeeBurnMechanism ? "Đang hoạt động" : "Không áp dụng")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(utility.hasFeeBurnMechanism ? AppTheme.orange : .white.opacity(0.4))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((utility.hasFeeBurnMechanism ? AppTheme.orange : Color.white).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    Text(utility.feeBurnDetails)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(2)
                }
                .padding(10)
                .background(AppTheme.darkBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // 3. Governance DAO
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Quyền Quản Trị (DAO)")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text(utility.hasGovernanceRights ? "Có quyền biểu quyết" : "Không có DAO")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(utility.hasGovernanceRights ? AppTheme.accentBlue : .white.opacity(0.4))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((utility.hasGovernanceRights ? AppTheme.accentBlue : Color.white).opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    Text(utility.governanceDetails)
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.55))
                        .lineSpacing(2)
                }
                .padding(10)
                .background(AppTheme.darkBackground.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

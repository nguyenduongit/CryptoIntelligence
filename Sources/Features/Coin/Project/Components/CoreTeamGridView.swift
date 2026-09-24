import SwiftUI

public struct CoreTeamGridView: View {
    public let founders: [TeamMember]
    
    public init(founders: [TeamMember]) {
        self.founders = founders
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "person.2.fill")
                    .foregroundColor(AppTheme.purple)
                    .font(.system(size: 13))
                Text("Đội Ngũ Sáng Lập & Nhân Sự Cốt Lõi")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(founders) { member in
                    TeamMemberCardView(member: member)
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

private struct TeamMemberCardView: View {
    let member: TeamMember
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: member.avatarIconName)
                    .font(.system(size: 28))
                    .foregroundColor(AppTheme.accentBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(member.name)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(member.role)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.cyan)
                }
            }
            
            Text(member.bio)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(2)
            
            // Previous Experience Badges
            if !member.previousExperience.isEmpty {
                HStack(spacing: 4) {
                    ForEach(member.previousExperience, id: \.self) { exp in
                        Text(exp)
                            .font(.system(size: 9, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.purple.opacity(0.18))
                            .foregroundColor(AppTheme.purple)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
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
}

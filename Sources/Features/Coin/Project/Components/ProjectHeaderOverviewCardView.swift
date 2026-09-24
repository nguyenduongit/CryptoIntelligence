import SwiftUI

public struct ProjectHeaderOverviewCardView: View {
    public let profile: ProjectProfile
    
    public init(profile: ProjectProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Project Name & Tagline
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(profile.projectName)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Năm ra mắt: \(profile.launchYear)")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppTheme.accentBlue.opacity(0.18))
                        .foregroundColor(AppTheme.accentBlue)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Text(profile.tagline)
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.85))
            }
            
            // Meta Pills: Consensus & Language
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "cpu.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.cyan)
                    Text("Cơ chế đồng thuận:")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text(profile.consensusMechanism)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppTheme.darkHeaderBg.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left.forwardslash.chevron.right")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.purple)
                    Text("Ngôn ngữ phát triển:")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text(profile.programmingLanguage)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppTheme.darkHeaderBg.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Problem Solved Box
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 5) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(AppTheme.upGreen)
                        .font(.system(size: 12))
                    Text("Bài Toán & Sứ Mệnh Giải Quyết:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.upGreen)
                }
                
                Text(profile.problemSolved)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(3)
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

import SwiftUI

public struct DeveloperActivityCardView: View {
    public let metrics: DeveloperActivityMetrics
    
    public init(metrics: DeveloperActivityMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "curlybraces.square.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.purple)
                    Text("Hoạt Động Lập Trình & Sức Khỏe Mã Nguồn Mở (Dev Activity)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle().fill(AppTheme.upGreen).frame(width: 5, height: 5)
                    Text("Commit gần nhất: \(metrics.lastCommitAgo)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            // 4 Stats Cards
            HStack(spacing: 10) {
                statCard(
                    title: "Commits Hàng Tháng",
                    value: "\(metrics.monthlyCommits)",
                    subtitle: "Code updates",
                    iconName: "arrow.triangle.pull",
                    color: AppTheme.purple
                )
                
                statCard(
                    title: "Active Core Devs",
                    value: "\(metrics.activeMonthlyDevelopers)",
                    subtitle: "Kỹ sư đóng góp",
                    iconName: "person.2.fill",
                    color: AppTheme.accentBlue
                )
                
                statCard(
                    title: "GitHub Stars",
                    value: formatNumber(metrics.totalGitHubStars),
                    subtitle: "Độ phổ biến",
                    iconName: "star.fill",
                    color: AppTheme.warningYellow
                )
                
                statCard(
                    title: "Open Pull Requests",
                    value: "\(metrics.openPullRequests)",
                    subtitle: "Tính năng đang xem xét",
                    iconName: "tray.full.fill",
                    color: AppTheme.cyan
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
    
    private func statCard(title: String, value: String, subtitle: String, iconName: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: iconName)
                    .font(.system(size: 11))
                    .foregroundColor(color)
                Spacer()
            }
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(title)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            Text(subtitle)
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.4))
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.darkBackground.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func formatNumber(_ val: Int) -> String {
        if val >= 1_000 {
            return String(format: "%.1fk", Double(val) / 1000.0)
        }
        return "\(val)"
    }
}

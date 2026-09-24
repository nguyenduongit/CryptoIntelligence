import SwiftUI

public struct ProjectRoadmapTimelineView: View {
    public let roadmap: [ProjectMilestone]
    
    public init(roadmap: [ProjectMilestone]) {
        self.roadmap = roadmap
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "map.fill")
                    .foregroundColor(AppTheme.orange)
                    .font(.system(size: 13))
                Text("Lộ Trình Phát Triển (Project Roadmap)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            VStack(spacing: 8) {
                ForEach(roadmap) { milestone in
                    MilestoneRowView(milestone: milestone)
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

private struct MilestoneRowView: View {
    let milestone: ProjectMilestone
    
    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "clock.badge.checkmark.fill")
                .font(.system(size: 16))
                .foregroundColor(milestone.isCompleted ? AppTheme.upGreen : AppTheme.warningYellow)
            
            // Period Badge
            Text(milestone.quarterYear)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppTheme.darkHeaderBg)
                .foregroundColor(.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // Title & Description
            VStack(alignment: .leading, spacing: 2) {
                Text(milestone.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                Text(milestone.description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            // Status Pill
            Text(milestone.isCompleted ? "Đã hoàn thành" : "Kế hoạch sắp tới")
                .font(.system(size: 9, weight: .semibold))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(milestone.isCompleted ? AppTheme.upGreen.opacity(0.15) : AppTheme.warningYellow.opacity(0.15))
                .foregroundColor(milestone.isCompleted ? AppTheme.upGreen : AppTheme.warningYellow)
                .clipShape(RoundedRectangle(cornerRadius: 3))
        }
        .padding(10)
        .background(AppTheme.darkHeaderBg.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
}

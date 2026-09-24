import SwiftUI

public struct AuditReportsCardView: View {
    public let audits: [AuditReportItem]
    
    public init(audits: [AuditReportItem]) {
        self.audits = audits
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(AppTheme.upGreen)
                        .font(.system(size: 13))
                    Text("Báo Cáo Kiểm Toán Bảo Mật Độc Lập (Security Audits)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(audits.count) báo cáo hoàn tất")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Grid of Audit Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(audits) { audit in
                    AuditCardView(audit: audit)
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

private struct AuditCardView: View {
    let audit: AuditReportItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top Row: Auditor Name & Score Badge
            HStack {
                Text(audit.auditorName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(audit.score)/100")
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.upGreen.opacity(0.2))
                    .foregroundColor(AppTheme.upGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Middle Row: Resolved Status & Date
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.cyan)
                    Text("Đã vá lỗi: \(String(format: "%.0f%%", audit.resolvedPercentage))")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.cyan)
                }
                
                Spacer()
                
                Text(formatDate(audit.auditDate))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Bottom Row: Issues Count Pills
            HStack(spacing: 6) {
                IssuePill(label: "Critical", count: audit.criticalIssues, color: AppTheme.downRed)
                IssuePill(label: "High", count: audit.highIssues, color: AppTheme.orange)
                IssuePill(label: "Medium", count: audit.mediumIssues, color: AppTheme.warningYellow)
                Spacer()
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
    
    private func formatDate(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df.string(from: d)
    }
}

private struct IssuePill: View {
    let label: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 3) {
            Text(label + ":")
                .font(.system(size: 9))
                .foregroundColor(.white.opacity(0.5))
            Text("\(count)")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundColor(count > 0 ? color : .white.opacity(0.4))
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 2)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 3))
    }
}

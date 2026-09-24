import SwiftUI

public struct SecurityScoreBannerView: View {
    public let profile: SecurityLegalProfile
    
    public init(profile: SecurityLegalProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                // Circular Gauge Meter
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 5)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(profile.overallSecurityScore) / 100.0)
                        .stroke(scoreColor(profile.overallSecurityScore), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(profile.overallSecurityScore)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Title, Rating Label & Howey Pill
                VStack(alignment: .leading, spacing: 3) {
                    Text("Đánh Giá An Toàn & Bảo Mật Toàn Diện")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(scoreColor(profile.overallSecurityScore))
                            .frame(width: 7, height: 7)
                        Text(profile.securityRatingLabel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(scoreColor(profile.overallSecurityScore))
                    }
                }
                
                Spacer()
                
                // Howey Score & MiCA Badges
                HStack(spacing: 10) {
                    // Howey Test Pill
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Điểm Howey Test (SEC)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        HStack(spacing: 4) {
                            Text("\(profile.regulatory.howeyTestScore)/100")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(howeyColor(profile.regulatory.howeyTestScore))
                            Text(profile.regulatory.howeyTestScore <= 20 ? "(Ít rủi ro CK)" : "(Cần theo dõi)")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkHeaderBg.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    // MiCA Status
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Chuẩn Pháp Lý EU (MiCA)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text("Hợp Chuẩn MiCA")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.cyan)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkHeaderBg.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Executive Summary Text
            Text(profile.executiveSummary)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(3)
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func scoreColor(_ s: Int) -> Color {
        if s >= 90 { return AppTheme.upGreen }
        if s >= 80 { return AppTheme.cyan }
        if s >= 65 { return AppTheme.warningYellow }
        return AppTheme.downRed
    }
    
    private func howeyColor(_ s: Int) -> Color {
        if s <= 20 { return AppTheme.upGreen }
        if s <= 40 { return AppTheme.cyan }
        if s <= 60 { return AppTheme.warningYellow }
        return AppTheme.downRed
    }
}

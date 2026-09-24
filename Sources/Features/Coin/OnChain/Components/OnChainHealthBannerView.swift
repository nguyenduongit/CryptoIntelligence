import SwiftUI

public struct OnChainHealthBannerView: View {
    public let profile: OnChainProfile
    
    public init(profile: OnChainProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                // Circular Health Gauge
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 5)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(profile.onChainHealthScore) / 100.0)
                        .stroke(scoreColor(profile.onChainHealthScore), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(profile.onChainHealthScore)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Title, Health Label & Network
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text("Điểm Sức Khỏe On-chain")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text(profile.networkName)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(AppTheme.accentBlue.opacity(0.15))
                            .foregroundColor(AppTheme.accentBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        DataSourceBadge(type: .liveBinance, text: "On-Chain & Lệnh Cá Voi Live")
                    }
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(scoreColor(profile.onChainHealthScore))
                            .frame(width: 7, height: 7)
                        Text(profile.onChainHealthLabel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(scoreColor(profile.onChainHealthScore))
                    }
                }
                
                Spacer()
                
                // TVL or 24h Transactions highlight
                if let tvl = profile.networkActivity.totalValueLockedUSD {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Tổng Giá Trị Khóa (TVL)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatVolume(tvl) + " USD")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.cyan)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.darkHeaderBg.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Summary Text
            Text(profile.onChainSummary)
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
        if s >= 80 { return AppTheme.upGreen }
        if s >= 65 { return AppTheme.cyan }
        if s >= 50 { return AppTheme.warningYellow }
        return AppTheme.downRed
    }
}

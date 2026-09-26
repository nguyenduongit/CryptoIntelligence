import SwiftUI

public struct RelativeStrengthRibbonView: View {
    public let symbol: String
    public let coinChange24h: Double
    public let btcChange24h: Double
    public let ethChange24h: Double
    
    public init(
        symbol: String,
        coinChange24h: Double,
        btcChange24h: Double = 1.8,
        ethChange24h: Double = 2.4
    ) {
        self.symbol = symbol
        self.coinChange24h = coinChange24h
        self.btcChange24h = btcChange24h
        self.ethChange24h = ethChange24h
    }
    
    private var vsBTC: Double {
        coinChange24h - btcChange24h
    }
    
    private var vsETH: Double {
        coinChange24h - ethChange24h
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            // Title
            HStack(spacing: 6) {
                Image(systemName: "scalemass.fill")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 11))
                Text("SỨC MẠNH TƯƠNG ĐỐI (RELATIVE STRENGTH 24H):")
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            // vs BTC
            HStack(spacing: 4) {
                Text("vs BTC:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%+.2f%%", vsBTC))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(vsBTC >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                Text(vsBTC >= 0 ? "🟢 (Khỏe hơn)" : "🔴 (Yếu hơn)")
                    .font(.system(size: 9.5))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            // vs ETH
            HStack(spacing: 4) {
                Text("vs ETH:")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                Text(String(format: "%+.2f%%", vsETH))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                    .foregroundColor(vsETH >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                Text(vsETH >= 0 ? "🟢 (Khỏe hơn)" : "🔴 (Yếu hơn)")
                    .font(.system(size: 9.5))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Color.white.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.darkCard.opacity(0.7))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

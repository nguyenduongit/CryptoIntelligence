import SwiftUI

public struct CexVsDexVolumeCardView: View {
    public let cexVolumeUSD: Double
    public let dexVolumeUSD: Double
    public let dexToCexRatio: Double
    
    public init(cexVolumeUSD: Double, dexVolumeUSD: Double, dexToCexRatio: Double) {
        self.cexVolumeUSD = cexVolumeUSD
        self.dexVolumeUSD = dexVolumeUSD
        self.dexToCexRatio = dexToCexRatio
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "arrow.left.arrow.right.circle.fill")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 13))
                Text("PHÂN BỔ KHỐI LƯỢNG GIAO DỊCH: CEX (TẬP TRUNG) VS DEX (PHI TẬP TRUNG)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("DEX Chiếm \(String(format: "%.1f%%", dexToCexRatio * 100.0))")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.cyan)
            }
            
            // Progress distribution bar
            VStack(spacing: 6) {
                GeometryReader { geo in
                    HStack(spacing: 2) {
                        let cexWidth = geo.size.width * CGFloat(1.0 - dexToCexRatio)
                        let dexWidth = geo.size.width * CGFloat(dexToCexRatio)
                        
                        // CEX bar
                        Rectangle()
                            .fill(AppTheme.accentBlue)
                            .frame(width: max(10, cexWidth))
                            .overlay(
                                Text("CEX: \(String(format: "%.1f%%", (1.0 - dexToCexRatio) * 100.0))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white),
                                alignment: .center
                            )
                        
                        // DEX bar
                        Rectangle()
                            .fill(AppTheme.cyan)
                            .frame(width: max(10, dexWidth))
                            .overlay(
                                Text("DEX: \(String(format: "%.1f%%", dexToCexRatio * 100.0))")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.black),
                                alignment: .center
                            )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .frame(height: 22)
            }
            
            // Two cards side by side
            HStack(spacing: 12) {
                // CEX Card
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle().fill(AppTheme.accentBlue).frame(width: 6, height: 6)
                        Text("Volume Sàn Tập Trung (CEX)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Text(Formatters.formatVolume(cexVolumeUSD) + " USD")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("Binance Spot, Bybit, OKX, Coinbase")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // DEX Card
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Circle().fill(AppTheme.cyan).frame(width: 6, height: 6)
                        Text("Volume Sàn Phi Tập Trung (DEX)")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    Text(Formatters.formatVolume(dexVolumeUSD) + " USD")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("Uniswap, Raydium, PancakeSwap, Curve")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

import SwiftUI

public struct DEXLiquidityCardView: View {
    public let metrics: DEXLiquidityMetrics
    
    public init(metrics: DEXLiquidityMetrics) {
        self.metrics = metrics
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .foregroundColor(AppTheme.cyan)
                    .font(.system(size: 13))
                Text("Thanh Khoản & Khối Lượng Sàn Phi Tập Trung (DEX Pools)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Grid of Metrics
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                // 1. Total DEX Liquidity
                VStack(alignment: .leading, spacing: 3) {
                    Text("Tổng Thanh Khoản (DEX TVL)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 6) {
                        Text(Formatters.formatVolume(metrics.totalLiquidityUSD) + " USD")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(String(format: "%@%.1f%% (24h)", metrics.liquidity24hChangePercent > 0 ? "+" : "", metrics.liquidity24hChangePercent))
                            .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            .foregroundColor(metrics.liquidity24hChangePercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 2. 24h DEX Volume
                VStack(alignment: .leading, spacing: 3) {
                    Text("Khối Lượng Giao Dịch DEX 24h")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(Formatters.formatVolume(metrics.volume24hDEXUSD) + " USD")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 3. Volume / Liquidity Ratio
                VStack(alignment: .leading, spacing: 3) {
                    Text("Hiệu Suất Vốn (Vol/Liq Ratio)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 4) {
                        Text(String(format: "%.2fx", metrics.volumeToLiquidityRatio))
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        Text(metrics.volumeToLiquidityRatio > 1.0 ? "(Thanh khoản xoay vòng cao)" : "(Thanh khoản ổn định)")
                            .font(.system(size: 9))
                            .foregroundColor(metrics.volumeToLiquidityRatio > 1.0 ? AppTheme.upGreen : .white.opacity(0.5))
                    }
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 4. Top Liquidity Pool
                VStack(alignment: .leading, spacing: 3) {
                    Text("Bể Thanh Khoản Lớn Nhất")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Text(metrics.topPoolPair)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                        .lineLimit(1)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
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

import SwiftUI

public struct LiquidationHuntRadarCardView: View {
    public let data: LiquidationHeatmapData
    
    public init(data: LiquidationHeatmapData) {
        self.data = data
    }
    
    private var shortSqueezeDistance: Double {
        ((data.shortSqueezeTriggerPriceUSD - data.currentPriceUSD) / data.currentPriceUSD) * 100.0
    }
    
    private var longSqueezeDistance: Double {
        ((data.currentPriceUSD - data.longSqueezeTriggerPriceUSD) / data.currentPriceUSD) * 100.0
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "bolt.shield.fill")
                    .foregroundColor(AppTheme.orange)
                    .font(.system(size: 13))
                Text("RADAR PHÁT HIỆN SĂN THANH LÝ & QUÉT RÂU NẾN (LIQUIDATION HUNT)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("Phân tích bẫy Market Maker")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // 3 Critical Actionable Target Cards
            HStack(spacing: 12) {
                // Short Squeeze Target
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.up.forward.circle.fill")
                            .foregroundColor(AppTheme.upGreen)
                            .font(.system(size: 12))
                        Text("ĐIỂM NỔ SHORT SQUEEZE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(Formatters.formatPrice(data.shortSqueezeTriggerPriceUSD))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                    
                    Text("Cách giá hiện tại +\(String(format: "%.1f%%", max(0, shortSqueezeDistance))) (Vùng thanh lý lệnh Short)")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.upGreen.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.upGreen.opacity(0.3), lineWidth: 1))
                
                // Max Pain / Liquidity Magnet
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundColor(AppTheme.cyan)
                            .font(.system(size: 12))
                        Text("VÙNG HÚT THANH KHOẢN (MAX PAIN)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(Formatters.formatPrice(data.maxPainPriceUSD))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    
                    Text("Nơi tập trung thanh lý của cả 2 phe Long & Short")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.cyan.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.cyan.opacity(0.3), lineWidth: 1))
                
                // Long Squeeze Target
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.down.forward.circle.fill")
                            .foregroundColor(AppTheme.downRed)
                            .font(.system(size: 12))
                        Text("ĐIỂM SẬP LONG SQUEEZE")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(Formatters.formatPrice(data.longSqueezeTriggerPriceUSD))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.downRed)
                    
                    Text("Cách giá hiện tại -\(String(format: "%.1f%%", max(0, longSqueezeDistance))) (Vùng thanh lý lệnh Long)")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.downRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.downRed.opacity(0.3), lineWidth: 1))
            }
            
            // Strategic Alert Box
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(AppTheme.orange)
                        .font(.system(size: 12))
                    Text("Bẫy săn râu nến (Wick Hunt Trap):")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Khi các vị thế đòn bẩy cao (>20x-50x) dồn về một phía, Market Maker thường đẩy các cú giật giá nhanh trong khung M5-M15 để quét sạch thanh lý trước khi đẩy giá đi đúng xu hướng chính. Hãy tránh đặt Stop Loss sát các cụm giá trên.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
                    .lineSpacing(2)
            }
            .padding(10)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

import SwiftUI

public struct LiquidationHeatmapCardView: View {
    public let data: LiquidationHeatmapData
    
    public init(data: LiquidationHeatmapData) {
        self.data = data
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppTheme.warningYellow)
                        .font(.system(size: 13))
                    Text("Bản Đồ Mật Độ Thanh Lý (Liquidation Heatmap & Squeeze Targets)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text(data.primarySqueezeRisk)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.accentBlue.opacity(0.15))
                    .foregroundColor(AppTheme.accentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Top Overview Metric Cards
            HStack(spacing: 10) {
                // Short Liquidation Overhang (Above)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Thanh Lý Short (Phía Trên)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(data.totalShortLiquidationUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                    Text("Điểm kích hoạt: " + Formatters.formatPrice(data.shortSqueezeTriggerPriceUSD))
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.upGreen.opacity(0.8))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Max Pain Price Level
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vùng Giá Max Pain")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatPrice(data.maxPainPriceUSD))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("Mức gây thanh lý 2 chiều lớn nhất")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Long Liquidation Overhang (Below)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Thanh Lý Long (Phía Dưới)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(data.totalLongLiquidationUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.downRed)
                    Text("Điểm kích hoạt: " + Formatters.formatPrice(data.longSqueezeTriggerPriceUSD))
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.downRed.opacity(0.8))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Visual Liquidation Clusters Density Heatmap
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Các Cụm Mật Độ Đòn Bẩy (5x - 100x)")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.upGreen).frame(width: 5, height: 5)
                            Text("Thanh lý Short (Mua ép)").font(.system(size: 9)).foregroundColor(.white.opacity(0.6))
                        }
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.downRed).frame(width: 5, height: 5)
                            Text("Thanh lý Long (Bán ép)").font(.system(size: 9)).foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                
                let maxClusterVol = data.clusters.map { $0.volumeUSD }.max() ?? 1.0
                
                VStack(spacing: 4) {
                    // Reversed so higher prices appear on top
                    ForEach(data.clusters.reversed()) { cl in
                        HStack(spacing: 8) {
                            // Leverage & Side Badge
                            Text(cl.leverageTier)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .frame(width: 38, alignment: .leading)
                                .foregroundColor(cl.side.color)
                            
                            // Price Level
                            Text(Formatters.formatPrice(cl.priceLevel))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 80, alignment: .leading)
                            
                            // Distance %
                            Text((cl.distancePercent >= 0 ? "+" : "") + String(format: "%.1f%%", cl.distancePercent))
                                .font(.system(size: 9, design: .monospaced))
                                .foregroundColor((cl.distancePercent >= 0 ? AppTheme.upGreen : AppTheme.downRed).opacity(0.8))
                                .frame(width: 48, alignment: .leading)
                            
                            // Visual Volume Heat Bar
                            GeometryReader { geo in
                                let barW = max(8.0, geo.size.width * CGFloat(cl.volumeUSD / maxClusterVol))
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.05))
                                        .frame(height: 14)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    cl.side.color.opacity(0.4),
                                                    cl.side.color
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: barW, height: 14)
                                }
                            }
                            .frame(height: 14)
                            
                            // Volume USD
                            Text(Formatters.formatVolume(cl.volumeUSD) + " USD")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 75, alignment: .trailing)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(cl.intensity >= 0.9 ? cl.side.color.opacity(0.08) : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
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

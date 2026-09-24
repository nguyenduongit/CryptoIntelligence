import SwiftUI

public struct OrderbookDepthWallsCardView: View {
    public let walls: [OrderbookWallItem]
    
    public init(walls: [OrderbookWallItem]) {
        self.walls = walls
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "square.stack.3d.down.right.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Tường Sổ Lệnh Thể Chế (Orderbook Institutional Walls)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Độ sâu thanh khoản Spot & Futures")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Walls Table
            VStack(spacing: 5) {
                // Table Headers
                HStack {
                    Text("Phía Tường")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 140, alignment: .leading)
                    
                    Text("Mức Giá (USD)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 90, alignment: .leading)
                    
                    Text("Khoảng Cách")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 80, alignment: .leading)
                    
                    Text("Độ Dày Thanh Khoản (USD)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                
                Divider()
                    .background(AppTheme.darkBorder)
                
                // Reversed so Ask walls (above price) appear on top, Bid walls (below) appear at bottom
                ForEach(walls.reversed()) { w in
                    HStack(spacing: 8) {
                        // Side
                        HStack(spacing: 5) {
                            Circle()
                                .fill(w.side.color)
                                .frame(width: 6, height: 6)
                            Text(w.side.rawValue)
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(w.side.color)
                                .lineLimit(1)
                        }
                        .frame(width: 140, alignment: .leading)
                        
                        // Price Level
                        Text(Formatters.formatPrice(w.priceUSD))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 90, alignment: .leading)
                        
                        // Distance %
                        Text((w.distancePercent >= 0 ? "+" : "") + String(format: "%.1f%%", w.distancePercent))
                            .font(.system(size: 9.5, design: .monospaced))
                            .foregroundColor((w.distancePercent >= 0 ? AppTheme.downRed : AppTheme.upGreen).opacity(0.85))
                            .frame(width: 80, alignment: .leading)
                        
                        // Visual Depth Bar + Volume
                        HStack(spacing: 6) {
                            GeometryReader { geo in
                                ZStack(alignment: .trailing) {
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(Color.white.opacity(0.06))
                                        .frame(height: 12)
                                    
                                    RoundedRectangle(cornerRadius: 2)
                                        .fill(w.side.color.opacity(0.5))
                                        .frame(width: max(4.0, geo.size.width * CGFloat(w.depthPercent / 100.0)), height: 12)
                                }
                            }
                            .frame(height: 12)
                            
                            Text(Formatters.formatVolume(w.totalValueUSD) + " USD")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 75, alignment: .trailing)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.darkHeaderBg.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
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

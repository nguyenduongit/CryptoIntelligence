import SwiftUI

public struct CrossAssetCorrelationCardView: View {
    public let crossAssets: [CrossAssetTickerItem]
    
    public init(crossAssets: [CrossAssetTickerItem]) {
        self.crossAssets = crossAssets
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.swap")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.purple)
                    Text("Tài Sản Truyền Thống & Ma Trận Tương Quan vs Bitcoin")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Hệ số Tương quan 30 Ngày (Pearson)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Grid of Asset Cards
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(crossAssets) { asset in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: asset.iconName)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.accentBlue)
                                Text(asset.symbol)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Correlation Badge with BTC
                            HStack(spacing: 3) {
                                Text("Corr vs BTC:")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.5))
                                Text(String(format: "%@%.2f", asset.correlationWithBTC_30d >= 0 ? "+" : "", asset.correlationWithBTC_30d))
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(asset.correlationColor)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(asset.correlationColor.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        
                        HStack(alignment: .firstTextBaseline) {
                            Text(formatAssetPrice(asset))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 2) {
                                Image(systemName: asset.change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                                    .font(.system(size: 8, weight: .bold))
                                Text(String(format: "%@%.2f%%", asset.change24h >= 0 ? "+" : "", asset.change24h))
                                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                            }
                            .foregroundColor(asset.change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            
                            Spacer()
                            
                            Text("30D: \(String(format: "%@%.1f%%", asset.change30d >= 0 ? "+" : "", asset.change30d))")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        
                        Text(asset.note)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.65))
                            .lineLimit(2)
                    }
                    .padding(10)
                    .background(AppTheme.darkBackground.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.6), lineWidth: 1)
                    )
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func formatAssetPrice(_ asset: CrossAssetTickerItem) -> String {
        if asset.priceUnit == "USD/oz" || asset.priceUnit == "USD/bbl" {
            return String(format: "$%.2f", asset.currentPrice)
        } else if asset.priceUnit == "%" {
            return String(format: "%.2f%%", asset.currentPrice)
        } else {
            return String(format: "%.2f %@", asset.currentPrice, asset.priceUnit)
        }
    }
}

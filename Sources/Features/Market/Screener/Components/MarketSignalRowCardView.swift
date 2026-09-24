import SwiftUI

public struct MarketSignalRowCardView: View {
    public let signal: MarketSignalItem
    public let onSelectSymbol: (String) -> Void
    
    public init(signal: MarketSignalItem, onSelectSymbol: @escaping (String) -> Void) {
        self.signal = signal
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // 1. Asset & Timeframe
            Button(action: { onSelectSymbol(signal.symbol) }) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(signal.category.color.opacity(0.2))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: signal.category.iconName)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(signal.category.color)
                        )
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text(signal.baseAsset)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(signal.timeframe)
                                .font(.system(size: 9, weight: .black))
                                .foregroundColor(AppTheme.accentBlue)
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(AppTheme.accentBlue.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 3))
                        }
                        
                        Text(signal.symbol)
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .buttonStyle(.plain)
            .frame(width: 120, alignment: .leading)
            
            // 2. Category & Direction Badges
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(signal.category.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(signal.category.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(signal.category.color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    
                    Text(signal.direction.rawValue)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(signal.direction.color)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(signal.direction.color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Text(signal.title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            .frame(width: 260, alignment: .leading)
            
            // 3. Technical Reason & Description
            Text(signal.reason)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.7))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // 4. Price & 24h Change
            VStack(alignment: .trailing, spacing: 2) {
                Text("$\(Formatters.formatPrice(signal.currentPriceUSD))")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                let isUp = signal.priceChange24h >= 0
                Text("\(isUp ? "+" : "")\(String(format: "%.2f", signal.priceChange24h))%")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(isUp ? AppTheme.upGreen : AppTheme.downRed)
            }
            .frame(width: 90, alignment: .trailing)
            
            // 5. Strength Score Gauge
            VStack(alignment: .center, spacing: 2) {
                Text("\(signal.strengthScore)")
                    .font(.system(size: 13, weight: .heavy, design: .monospaced))
                    .foregroundColor(scoreColor(signal.strengthScore))
                
                Text("SCORE")
                    .font(.system(size: 8, weight: .black))
                    .foregroundColor(.white.opacity(0.4))
            }
            .frame(width: 50)
            .padding(.vertical, 4)
            .background(scoreColor(signal.strengthScore).opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(scoreColor(signal.strengthScore).opacity(0.4), lineWidth: 1)
            )
            
            // 6. Action Button (Open Chart)
            Button(action: { onSelectSymbol(signal.symbol) }) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(8)
                    .background(AppTheme.accentBlue)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .help("Xem biểu đồ kỹ thuật & nghiên cứu chi tiết")
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder.opacity(0.8), lineWidth: 1)
        )
    }
    
    private func scoreColor(_ score: Int) -> Color {
        if score >= 90 { return AppTheme.cyan }
        if score >= 80 { return AppTheme.upGreen }
        if score >= 65 { return AppTheme.warningYellow }
        return Color.white.opacity(0.5)
    }
}

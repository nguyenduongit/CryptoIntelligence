import SwiftUI

public struct SectorFlowView: View {
    public let sectorPerformances: [SectorPerformance]
    public let onSelectSector: (CryptoSector) -> Void
    
    public init(
        sectorPerformances: [SectorPerformance],
        onSelectSector: @escaping (CryptoSector) -> Void
    ) {
        self.sectorPerformances = sectorPerformances
        self.onSelectSector = onSelectSector
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Section Title & Insights
                VStack(alignment: .leading, spacing: 4) {
                    Text("Dòng Tiền & Hiệu Suất Các Phân Khúc")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.white)
                    Text("Theo dõi dòng vốn luân chuyển giữa các narrative chính (Layer 1, DeFi, AI, Meme, RWA...)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                
                // Grid of Sector Cards
                LazyVGrid(
                    columns: [
                        GridItem(.adaptive(minimum: 280, maximum: 400), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(sectorPerformances) { perf in
                        SectorCardView(performance: perf) {
                            onSelectSector(perf.sector)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 20)
            }
        }
        .background(AppTheme.darkBackground)
    }
}

private struct SectorCardView: View {
    let performance: SectorPerformance
    let onSelect: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 10) {
                // Top Row: Sector Icon, Name & Avg Return Pill
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: performance.sector.iconName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.accentBlue)
                            .frame(width: 28, height: 28)
                            .background(AppTheme.accentBlue.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(performance.sector.rawValue)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("\(performance.tokenCount) mã niêm yết")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                    // Average Return Pill
                    HStack(spacing: 4) {
                        Image(systemName: performance.isBullish ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 10, weight: .bold))
                        Text(Formatters.formatPercentage(performance.avgChangePercent))
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(performance.isBullish ? AppTheme.upGreen.opacity(0.2) : AppTheme.downRed.opacity(0.2))
                    .foregroundColor(performance.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Divider()
                    .background(AppTheme.darkBorder)
                
                // Middle Row: Total 24h Volume & Top Gainer
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Khối lượng 24h")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatVolume(performance.totalQuoteVolume) + " USDT")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    if let topSym = performance.topGainerSymbol, let topChg = performance.topGainerChangePercent {
                        VStack(alignment: .trailing, spacing: 3) {
                            Text("Dẫn đầu nhóm")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.5))
                            HStack(spacing: 4) {
                                Text(topSym.replacingOccurrences(of: "USDT", with: ""))
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.white)
                                Text(Formatters.formatPercentage(topChg))
                                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                    .foregroundColor(topChg >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                            }
                        }
                    }
                }
                
                // Bottom Breadth Bar (Gainers vs Losers ratio)
                VStack(spacing: 4) {
                    GeometryReader { geo in
                        let total = max(1, performance.gainersCount + performance.losersCount)
                        let greenWidth = (CGFloat(performance.gainersCount) / CGFloat(total)) * geo.size.width
                        
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(AppTheme.upGreen)
                                .frame(width: max(2, greenWidth))
                            Rectangle()
                                .fill(AppTheme.downRed)
                                .frame(width: max(2, geo.size.width - greenWidth))
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 5)
                    
                    HStack {
                        Text("\(performance.gainersCount) tăng")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.upGreen)
                        Spacer()
                        Text("\(performance.losersCount) giảm")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.downRed)
                    }
                }
            }
            .padding(12)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isHovered ? AppTheme.accentBlue.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
            )
            .shadow(color: isHovered ? AppTheme.accentBlue.opacity(0.15) : Color.clear, radius: 6, x: 0, y: 2)
            .scaleEffect(isHovered ? 1.01 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .help("Lọc bản đồ nhiệt theo phân khúc \(performance.sector.rawValue)")
    }
}

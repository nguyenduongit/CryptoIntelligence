import SwiftUI

/// A modern, high-impact widget displaying capital allocation and money flow
/// across crypto sectors (Layer 1, DeFi, AI, Meme, Layer 2, DePIN, etc.)
public struct SectorCapitalAllocationView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    private var totalMarketVolume: Double {
        viewModel.sectorPerformances.reduce(0.0) { $0 + $1.totalQuoteVolume }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Title & Total Capital Flow
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Phân Bổ Vốn & Dòng Tiền Phân Khúc")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                if totalMarketVolume > 0 {
                    HStack(spacing: 5) {
                        Text("Tổng Vol Phân Khúc:")
                            .font(.system(size: 10.5))
                            .foregroundColor(.white.opacity(0.5))
                        Text(Formatters.formatVolume(totalMarketVolume) + " USDT")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.cyan)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.darkHeaderBg.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
            }
            
            // ── Segmented Capital Allocation Bar ──────────────────────────────
            if totalMarketVolume > 0 {
                allocationSegmentedBar
            }
            
            // ── Sector Cards Horizontal Scroll Row ────────────────────────────
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.sectorPerformances) { item in
                        sectorCard(item)
                    }
                }
                .padding(.vertical, 2)
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
    
    // MARK: - Segmented Allocation Bar
    
    private var allocationSegmentedBar: some View {
        GeometryReader { geo in
            let totalW = geo.size.width
            HStack(spacing: 2) {
                ForEach(viewModel.sectorPerformances) { item in
                    let share = item.totalQuoteVolume / totalMarketVolume
                    let segW = max(4.0, totalW * CGFloat(share))
                    
                    Rectangle()
                        .fill(item.sector.color)
                        .frame(width: segW, height: 7)
                        .overlay(
                            Rectangle()
                                .stroke(viewModel.selectedSector == item.sector ? Color.white : Color.clear, lineWidth: 1.5)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 1.5))
                        .help("\(item.sector.rawValue): \(Formatters.formatVolume(item.totalQuoteVolume)) (\(String(format: "%.1f%%", share * 100)))")
                }
            }
        }
        .frame(height: 7)
    }
    
    // MARK: - Individual Sector Card
    
    private func sectorCard(_ item: SectorPerformance) -> some View {
        let isSelected = viewModel.selectedSector == item.sector
        let sharePercent = totalMarketVolume > 0 ? (item.totalQuoteVolume / totalMarketVolume * 100) : 0
        let isBullish = item.avgChangePercent >= 0
        
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                if viewModel.selectedSector == item.sector {
                    viewModel.selectedSector = .all
                } else {
                    viewModel.selectedSector = item.sector
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                // Top: Icon + Name + Share % Badge
                HStack(spacing: 5) {
                    Image(systemName: item.sector.iconName)
                        .font(.system(size: 11))
                        .foregroundColor(item.sector.color)
                    
                    Text(item.sector.rawValue)
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer(minLength: 4)
                    
                    Text(String(format: "%.1f%%", sharePercent))
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(item.sector.color)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(item.sector.color.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                // Middle: 24h Volume + Avg Change %
                HStack(alignment: .firstTextBaseline) {
                    Text(Formatters.formatVolume(item.totalQuoteVolume))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Spacer()
                    
                    HStack(spacing: 2) {
                        Image(systemName: isBullish ? "arrow.up.right" : "arrow.down.right")
                            .font(.system(size: 9, weight: .bold))
                        Text(String(format: "%@%.2f%%", isBullish ? "+" : "", item.avgChangePercent))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                    }
                    .foregroundColor(isBullish ? AppTheme.upGreen : AppTheme.downRed)
                }
                
                // Bottom: Gainers / Losers ratio bar + Top Gainer coin
                HStack(spacing: 6) {
                    // Ratio bar
                    let totalCount = max(1, item.tokenCount)
                    let gRatio = CGFloat(item.gainersCount) / CGFloat(totalCount)
                    
                    GeometryReader { geo in
                        HStack(spacing: 1) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(AppTheme.upGreen)
                                .frame(width: max(2, geo.size.width * gRatio))
                            RoundedRectangle(cornerRadius: 1)
                                .fill(AppTheme.downRed)
                        }
                    }
                    .frame(width: 44, height: 3.5)
                    
                    Text("\(item.gainersCount)▲ \(item.losersCount)▼")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundColor(.white.opacity(0.45))
                    
                    Spacer()
                    
                    if let topG = item.topGainerSymbol, let topP = item.topGainerChangePercent {
                        let cleanSym = topG.replacingOccurrences(of: "USDT", with: "")
                        let sign = topP >= 0 ? "+" : ""
                        Text("Top: \(cleanSym) \(sign)\(String(format: "%.1f%%", topP))")
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(topP >= 0 ? AppTheme.upGreen.opacity(0.9) : AppTheme.downRed.opacity(0.9))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .frame(width: 175)
            .background(isSelected ? item.sector.color.opacity(0.12) : AppTheme.darkHeaderBg.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay(
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isSelected ? item.sector.color : AppTheme.darkBorder.opacity(0.6), lineWidth: isSelected ? 1.5 : 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 7))
        }
        .buttonStyle(.plain)
    }
}

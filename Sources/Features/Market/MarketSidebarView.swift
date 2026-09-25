import SwiftUI

public struct MarketSidebarView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    sectorsSection
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - 1. Clean Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.accentBlue)
                Text("Phân Khúc")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            if !viewModel.tickers.isEmpty {
                Text("\(viewModel.tickers.count) mã")
                    .font(.system(size: 10, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppTheme.darkCard)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - 2. Sectors Filter Section
    private var sectorsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            sectorsHeader
            
            ForEach(CryptoSector.allCases) { sector in
                sectorButton(for: sector)
            }
        }
    }
    
    private var sectorsHeader: some View {
        HStack {
            Text("LỌC BẢN ĐỒ NHIỆT")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
            
            Spacer()
            
            if viewModel.selectedSector != .all {
                Button("Tất cả") {
                    viewModel.selectedSector = .all
                }
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.accentBlue)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 4)
    }
    
    @ViewBuilder
    private func sectorButton(for sector: CryptoSector) -> some View {
        let isSelected = (viewModel.selectedSector == sector)
        let count = (sector == .all) ? viewModel.tickers.count : viewModel.tickers.filter { $0.sector == sector }.count
        let sectorPerf = viewModel.sectorPerformances.first(where: { $0.sector == sector })
        
        Button(action: {
            viewModel.selectedSector = sector
            if viewModel.selectedViewMode != .heatmap {
                withAnimation(.easeInOut(duration: 0.15)) {
                    viewModel.selectedViewMode = .heatmap
                }
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: sector.iconName)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? AppTheme.cyan : .white.opacity(0.5))
                    .frame(width: 16)
                
                Text(sector.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                
                Spacer()
                
                // 24h Average Sector Performance
                if let perf = sectorPerf, sector != .all {
                    Text(String(format: "%+.1f%%", perf.avgChangePercent))
                        .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                        .foregroundColor(perf.avgChangePercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                }
                
                if count > 0 {
                    Text("\(count)")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(isSelected ? AppTheme.cyan.opacity(0.2) : AppTheme.darkCard)
                        .foregroundColor(isSelected ? AppTheme.cyan : .white.opacity(0.5))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5.5)
            .background(isSelected ? AppTheme.cyan.opacity(0.12) : Color.clear)
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

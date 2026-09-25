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
                VStack(alignment: .leading, spacing: 14) {
                    viewModesSection
                    
                    Divider()
                        .background(AppTheme.darkBorder)
                        .padding(.horizontal, 10)
                    
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
                Image(systemName: "globe.asia.australia.fill")
                    .font(.system(size: 13))
                    .foregroundColor(AppTheme.accentBlue)
                Text("Thị Trường")
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
    
    // MARK: - 2. View Modes Section
    private var viewModesSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("CHẾ ĐỘ XEM")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 10)
                .padding(.top, 4)
            
            ForEach(MarketViewMode.allCases) { mode in
                viewModeButton(for: mode)
            }
        }
    }
    
    @ViewBuilder
    private func viewModeButton(for mode: MarketViewMode) -> some View {
        let isSelected = (viewModel.selectedViewMode == mode)
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                viewModel.selectedViewMode = mode
            }
        }) {
            HStack(spacing: 8) {
                Image(systemName: mode.iconName)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.6))
                    .frame(width: 18)
                
                Text(mode.rawValue)
                    .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                
                Spacer()
                
                if isSelected {
                    Circle()
                        .fill(AppTheme.accentBlue)
                        .frame(width: 6, height: 6)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6.5)
            .background(isSelected ? AppTheme.darkCard : Color.clear)
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.4) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - 3. Sectors Filter Section
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
            Text("LỌC PHÂN KHÚC (SECTORS)")
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
    }
    
    @ViewBuilder
    private func sectorButton(for sector: CryptoSector) -> some View {
        let isSelected = (viewModel.selectedSector == sector)
        let count = (sector == .all) ? viewModel.tickers.count : viewModel.tickers.filter { $0.sector == sector }.count
        let sectorPerf = viewModel.sectorPerformances.first(where: { $0.sector == sector })
        
        Button(action: {
            viewModel.selectedSector = sector
            if viewModel.selectedViewMode == .macro {
                viewModel.selectedViewMode = .heatmap
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
            .padding(.vertical, 5)
            .background(isSelected ? AppTheme.cyan.opacity(0.12) : Color.clear)
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }
}

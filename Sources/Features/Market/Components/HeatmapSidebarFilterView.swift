import SwiftUI

public struct HeatmapSidebarFilterView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    // 1. Search Box
                    searchBox
                    
                    // 2. Sizing Mode (Market Cap vs Volume)
                    sizingModeSection
                    
                    // 3. Sector Categories Filter
                    sectorCategorySection
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            
            Spacer(minLength: 0)
            
            // Bottom Quick Stats
            bottomMarketSummary
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.purple)
                Text("BỘ LỌC BẢN ĐỒ")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("BỘ LỌC")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(Color.purple)
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(Color.purple.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Search Box
    private var searchBox: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
            
            TextField("Tìm coin (BTC, ETH, SOL...)", text: $viewModel.searchQuery)
                .font(.system(size: 11.5))
                .textFieldStyle(.plain)
                .foregroundColor(.white)
            
            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    // MARK: - Sizing Mode
    private var sizingModeSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("KÍCH THƯỚC Ô HEATMAP")
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 4)
            
            HStack(spacing: 4) {
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.isHeatmapSizingByVolume = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chart.pie.fill")
                            .font(.system(size: 10))
                        Text("Vốn Hóa")
                            .font(.system(size: 11, weight: !viewModel.isHeatmapSizingByVolume ? .bold : .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5.5)
                    .background(!viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.25) : Color.clear)
                    .foregroundColor(!viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(!viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        viewModel.isHeatmapSizingByVolume = true
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 10))
                        Text("Volume 24h")
                            .font(.system(size: 11, weight: viewModel.isHeatmapSizingByVolume ? .bold : .medium))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5.5)
                    .background(viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.25) : Color.clear)
                    .foregroundColor(viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.6) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(2)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        }
    }
    
    // MARK: - Sector Category Filter List
    private var sectorCategorySection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("PHÂN KHÚC & NARRATIVE")
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 4)
            
            ForEach(CryptoSector.allCases) { sector in
                let isSelected = (viewModel.selectedSector == sector)
                let count = sectorTokenCount(sector)
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        viewModel.selectedSector = sector
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: sector.iconName)
                            .font(.system(size: 11))
                            .foregroundColor(isSelected ? Color.purple : .white.opacity(0.5))
                            .frame(width: 16)
                        
                        Text(sector.rawValue)
                            .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(count)")
                            .font(.system(size: 9.5, design: .monospaced))
                            .foregroundColor(isSelected ? Color.purple : .white.opacity(0.4))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1.5)
                            .background(isSelected ? Color.purple.opacity(0.2) : Color.white.opacity(0.04))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(isSelected ? Color.purple.opacity(0.15) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? Color.purple.opacity(0.4) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Bottom Market Summary
    private var bottomMarketSummary: some View {
        VStack(spacing: 6) {
            Divider().background(AppTheme.darkBorder)
            
            let gainers = viewModel.tickers.filter { $0.priceChangePercent > 0 }.count
            let losers = viewModel.tickers.filter { $0.priceChangePercent < 0 }.count
            
            HStack {
                HStack(spacing: 4) {
                    Circle().fill(AppTheme.upGreen).frame(width: 6, height: 6)
                    Text("Tăng: \(gainers)")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle().fill(AppTheme.downRed).frame(width: 6, height: 6)
                    Text("Giảm: \(losers)")
                        .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.downRed)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.darkCard.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
    }
    
    private func sectorTokenCount(_ sector: CryptoSector) -> Int {
        if sector == .all {
            return viewModel.tickers.count
        }
        return viewModel.tickers.filter { $0.sector == sector }.count
    }
}

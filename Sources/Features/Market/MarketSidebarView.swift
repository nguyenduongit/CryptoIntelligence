import SwiftUI

public struct MarketSidebarView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Dynamic Header based on active mode
            headerView
            
            // Dynamic Navigation Sidebar Content per Mode
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    switch viewModel.selectedViewMode {
                    case .valuation:
                        ValuationSidebarNavigation(viewModel: viewModel)
                    case .globalMacro:
                        GlobalMacroSidebarNavigation(viewModel: viewModel)
                    case .heatmap:
                        HeatmapSidebarNavigation(viewModel: viewModel)
                    case .sectors:
                        SectorFlowSidebarNavigation(viewModel: viewModel)
                    case .movers:
                        MoversSidebarNavigation(viewModel: viewModel)
                    case .screener:
                        ScreenerSidebarNavigation(viewModel: viewModel)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 6)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - Dynamic Navigation Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: viewModel.selectedViewMode.iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.accentBlue)
                Text(headerTitle)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("ĐIỀU HƯỚNG")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.accentBlue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(AppTheme.accentBlue.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    private var headerTitle: String {
        switch viewModel.selectedViewMode {
        case .valuation: return "Điều Hướng Vốn Hóa"
        case .globalMacro: return "Điều Hướng Kinh Tế"
        case .heatmap: return "Điều Hướng Bản Đồ"
        case .sectors: return "Điều Hướng Phân Khúc"
        case .movers: return "Điều Hướng Biến Động"
        case .screener: return "Điều Hướng Bộ Lọc"
        }
    }
}

// MARK: - 1. Valuation Dedicated Navigation Sidebar (2 Mục Chính: Tổng Quan & Biểu Đồ)
private struct ValuationSidebarNavigation: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 2 Mục Chính
            VStack(alignment: .leading, spacing: 5) {
                Text("DANH MỤC VỐN HÓA")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                
                ForEach(MarketValuationSection.allCases) { sec in
                    let isSelected = (viewModel.selectedValuationSection == sec)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedValuationSection = sec
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: sec.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(isSelected ? AppTheme.cyan : .white.opacity(0.5))
                                .frame(width: 16)
                            
                            Text(sec.rawValue)
                                .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                            
                            Spacer()
                            
                            if isSelected {
                                Circle()
                                    .fill(AppTheme.cyan)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(isSelected ? AppTheme.cyan.opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Nếu đang ở mục Biểu Đồ -> Hiển thị các tuỳ chọn chọn chỉ số và khung nến
            if viewModel.selectedValuationSection == .kline {
                Divider().background(AppTheme.darkBorder).padding(.horizontal, 8)
                
                // Chọn Chỉ Số
                VStack(alignment: .leading, spacing: 4) {
                    Text("CHỈ SỐ NẾN K-LINE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 8)
                    
                    ForEach(MacroIndexType.allCases) { idx in
                        let isSelected = (viewModel.selectedMacroIndex == idx)
                        Button(action: {
                            viewModel.selectedMacroIndex = idx
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: idx.iconName)
                                    .font(.system(size: 11))
                                    .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.5))
                                    .frame(width: 16)
                                
                                Text(idx.rawValue)
                                    .font(.system(size: 11.5, weight: isSelected ? .bold : .medium, design: .monospaced))
                                
                                Spacer()
                                
                                if isSelected {
                                    Text("Đang xem")
                                        .font(.system(size: 9, weight: .semibold))
                                        .foregroundColor(AppTheme.accentBlue)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5.5)
                            .background(isSelected ? AppTheme.accentBlue.opacity(0.18) : Color.clear)
                            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Divider().background(AppTheme.darkBorder).padding(.horizontal, 8)
                
                // Khung Thời Gian
                VStack(alignment: .leading, spacing: 6) {
                    Text("KHUNG THỜI GIAN NẾN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 8)
                    
                    HStack(spacing: 4) {
                        ForEach(["1h", "4h", "1d", "1w"], id: \.self) { tf in
                            let isSelected = (viewModel.selectedKLineTimeframe.lowercased() == tf)
                            Button(action: {
                                viewModel.selectedKLineTimeframe = tf
                            }) {
                                Text(tf.uppercased())
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium, design: .monospaced))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(isSelected ? AppTheme.accentBlue : AppTheme.darkCard)
                                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(isSelected ? AppTheme.accentBlue : AppTheme.darkBorder, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
    }
}

// MARK: - 2. Global Macro Dedicated Navigation Sidebar
private struct GlobalMacroSidebarNavigation: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("PHÂN VÙNG VĨ MÔ")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                
                ForEach(GlobalMacroSection.allCases) { sec in
                    let isSelected = (viewModel.selectedGlobalMacroSection == sec)
                    Button(action: {
                        viewModel.selectedGlobalMacroSection = sec
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: sec.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(isSelected ? AppTheme.cyan : .white.opacity(0.5))
                                .frame(width: 16)
                            
                            Text(sec.rawValue)
                                .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                                .lineLimit(1)
                            
                            Spacer()
                            
                            if isSelected {
                                Circle()
                                    .fill(AppTheme.cyan)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(isSelected ? AppTheme.cyan.opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - 3. Heatmap Dedicated Navigation Sidebar
private struct HeatmapSidebarNavigation: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Sizing Mode Navigation
            VStack(alignment: .leading, spacing: 6) {
                Text("CHẾ ĐỘ TÍNH KÍCH THƯỚC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                
                HStack(spacing: 6) {
                    Button(action: {
                        viewModel.isHeatmapSizingByVolume = false
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 10))
                            Text("Vốn Hóa")
                                .font(.system(size: 11, weight: !viewModel.isHeatmapSizingByVolume ? .bold : .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(!viewModel.isHeatmapSizingByVolume ? AppTheme.accentBlue : AppTheme.darkCard)
                        .foregroundColor(!viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        viewModel.isHeatmapSizingByVolume = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 10))
                            Text("Khối Lượng")
                                .font(.system(size: 11, weight: viewModel.isHeatmapSizingByVolume ? .bold : .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                        .background(viewModel.isHeatmapSizingByVolume ? AppTheme.accentBlue : AppTheme.darkCard)
                        .foregroundColor(viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 8)
            }
            
            Divider().background(AppTheme.darkBorder).padding(.horizontal, 8)
            
            // Sector Filter Navigation
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("LỌC THEO PHÂN KHÚC")
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
                .padding(.horizontal, 8)
                
                ForEach(CryptoSector.allCases) { sector in
                    let isSelected = (viewModel.selectedSector == sector)
                    let count = (sector == .all) ? viewModel.tickers.count : viewModel.tickers.filter { $0.sector == sector }.count
                    
                    Button(action: {
                        viewModel.selectedSector = sector
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: sector.iconName)
                                .font(.system(size: 11))
                                .foregroundColor(isSelected ? AppTheme.cyan : .white.opacity(0.5))
                                .frame(width: 16)
                            
                            Text(sector.rawValue)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            
                            Spacer()
                            
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
        }
    }
}

// MARK: - 4. Sector Flow Dedicated Navigation Sidebar
private struct SectorFlowSidebarNavigation: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("ĐIỀU HƯỚNG PHÂN KHÚC")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                
                ForEach(CryptoSector.allCases) { sector in
                    let isSelected = (viewModel.selectedSector == sector)
                    Button(action: {
                        viewModel.selectedSector = sector
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: sector.iconName)
                                .font(.system(size: 11))
                                .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.5))
                                .frame(width: 16)
                            
                            Text(sector.rawValue)
                                .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                            
                            Spacer()
                            
                            if isSelected {
                                Circle()
                                    .fill(AppTheme.accentBlue)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(isSelected ? AppTheme.accentBlue.opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - 5. Movers Dedicated Navigation Sidebar
private struct MoversSidebarNavigation: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("BẢNG XẾP HẠNG BIẾN ĐỘNG")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                
                ForEach(MoversCategorySelection.allCases) { cat in
                    let isSelected = (viewModel.selectedMoversCategory == cat)
                    Button(action: {
                        viewModel.selectedMoversCategory = cat
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(isSelected ? AppTheme.cyan : .white.opacity(0.5))
                                .frame(width: 16)
                            
                            Text(cat.rawValue)
                                .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                            
                            Spacer()
                            
                            if isSelected {
                                Circle()
                                    .fill(AppTheme.cyan)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(isSelected ? AppTheme.cyan.opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// MARK: - 6. Screener Dedicated Navigation Sidebar
private struct ScreenerSidebarNavigation: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("BỘ LỌC RADAR PRESETS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 8)
                
                ForEach(ScreenerPresetSelection.allCases) { preset in
                    let isSelected = (viewModel.selectedScreenerPreset == preset)
                    Button(action: {
                        viewModel.selectedScreenerPreset = preset
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: preset.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.5))
                                .frame(width: 16)
                            
                            Text(preset.rawValue)
                                .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                            
                            Spacer()
                            
                            if isSelected {
                                Circle()
                                    .fill(AppTheme.accentBlue)
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(isSelected ? AppTheme.accentBlue.opacity(0.15) : Color.clear)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

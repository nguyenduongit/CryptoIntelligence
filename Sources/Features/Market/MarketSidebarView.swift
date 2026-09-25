import SwiftUI

public struct MarketSidebarView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Dynamic Header based on active tab
            headerView
            
            // Dynamic Sidebar Content per Mode
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    switch viewModel.selectedViewMode {
                    case .heatmap:
                        HeatmapSidebarContent(viewModel: viewModel)
                    case .screener:
                        ScreenerSidebarContent(viewModel: viewModel)
                    case .movers:
                        MoversSidebarContent(viewModel: viewModel)
                    case .sectors:
                        SectorFlowSidebarContent(viewModel: viewModel)
                    case .macro:
                        MacroSidebarContent(viewModel: viewModel)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 4)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - Dynamic Header
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
    
    private var headerTitle: String {
        switch viewModel.selectedViewMode {
        case .heatmap: return "Phân Khúc Heatmap"
        case .screener: return "Bộ Lọc Radar"
        case .movers: return "Xếp Hạng & Độ Rộng"
        case .sectors: return "Sức Mạnh Dòng Vốn"
        case .macro: return "Chỉ Số Vĩ Mô"
        }
    }
}

// MARK: - 1. Heatmap Dedicated Sidebar
private struct HeatmapSidebarContent: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
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
            .padding(.top, 4)
            
            ForEach(CryptoSector.allCases) { sector in
                let isSelected = (viewModel.selectedSector == sector)
                let count = (sector == .all) ? viewModel.tickers.count : viewModel.tickers.filter { $0.sector == sector }.count
                let sectorPerf = viewModel.sectorPerformances.first(where: { $0.sector == sector })
                
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
    }
}

// MARK: - 2. Screener Dedicated Sidebar
private struct ScreenerSidebarContent: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Signal Categories Section
            VStack(alignment: .leading, spacing: 4) {
                Text("DANH MỤC TÍN HIỆU RADAR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
                
                signalCategoryItem(icon: "arrow.up.forward.app.fill", title: "Breakout & Đột phá", count: "12", color: AppTheme.upGreen)
                signalCategoryItem(icon: "gauge.with.dots.needle.50percent", title: "Quá mua / Quá bán RSI", count: "8", color: AppTheme.cyan)
                signalCategoryItem(icon: "arrow.triangle.swap", title: "Giao cắt MA / Cross", count: "6", color: AppTheme.accentBlue)
                signalCategoryItem(icon: "flame.fill", title: "Gom hàng Cá voi / Vol Spike", count: "9", color: AppTheme.orange)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
                .padding(.horizontal, 10)
            
            // Direction Summary
            VStack(alignment: .leading, spacing: 6) {
                Text("CHIỀU HƯỚNG TÍN HIỆU")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 10)
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tăng giá (Bull)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text("21 tín hiệu")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.upGreen.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Giảm giá (Bear)")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text("14 tín hiệu")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.downRed)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppTheme.downRed.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .padding(.horizontal, 10)
            }
        }
    }
    
    private func signalCategoryItem(icon: String, title: String, count: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11))
                .foregroundColor(color)
                .frame(width: 16)
            
            Text(title)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
            
            Spacer()
            
            Text(count)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(AppTheme.darkCard)
                .foregroundColor(.white.opacity(0.6))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5.5)
    }
}

// MARK: - 3. Movers Dedicated Sidebar
private struct MoversSidebarContent: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Market Breadth Overview
            VStack(alignment: .leading, spacing: 6) {
                Text("ĐỘ RỘNG THỊ TRƯỜNG 24H")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
                
                if let m = viewModel.globalMetrics {
                    VStack(spacing: 6) {
                        HStack {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.upGreen)
                                Text("\(m.topGainersCount) tăng")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.upGreen)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.right")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.downRed)
                                Text("\(m.topLosersCount) giảm")
                                    .font(.system(size: 11, weight: .bold))
                                    .foregroundColor(AppTheme.downRed)
                            }
                        }
                        
                        // Ratio Bar
                        let total = Double(max(1, m.topGainersCount + m.topLosersCount))
                        let gainRatio = Double(m.topGainersCount) / total
                        GeometryReader { geo in
                            HStack(spacing: 1) {
                                Rectangle()
                                    .fill(AppTheme.upGreen)
                                    .frame(width: geo.size.width * gainRatio)
                                Rectangle()
                                    .fill(AppTheme.downRed)
                                    .frame(width: geo.size.width * (1.0 - gainRatio))
                            }
                        }
                        .frame(height: 4)
                        .clipShape(Capsule())
                    }
                    .padding(10)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .padding(.horizontal, 8)
                }
            }
            
            Divider()
                .background(AppTheme.darkBorder)
                .padding(.horizontal, 10)
            
            // Sort Quick Links
            VStack(alignment: .leading, spacing: 4) {
                Text("TIÊU CHÍ BẢNG XẾP HẠNG")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 10)
                
                moversCategoryRow(title: "🏆 Top 15 Tăng giá (+%)", count: "\(viewModel.topGainers.count) coin", color: AppTheme.upGreen)
                moversCategoryRow(title: "🔻 Top 15 Giảm giá (-%)", count: "\(viewModel.topLosers.count) coin", color: AppTheme.downRed)
                moversCategoryRow(title: "📊 Top 15 Khối lượng (Vol)", count: "\(viewModel.topVolumes.count) coin", color: AppTheme.accentBlue)
            }
        }
    }
    
    private func moversCategoryRow(title: String, count: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 11.5, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
            Spacer()
            Text(count)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.darkCard.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .padding(.horizontal, 6)
    }
}

// MARK: - 4. Sector Flow Dedicated Sidebar
private struct SectorFlowSidebarContent: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("XẾP HẠNG SỨC MẠNH NGÀNH")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 10)
                .padding(.top, 4)
            
            let sortedSectors = viewModel.sectorPerformances.sorted { $0.avgChangePercent > $1.avgChangePercent }
            
            ForEach(Array(sortedSectors.enumerated()), id: \.element.id) { index, perf in
                HStack(spacing: 8) {
                    Text("#\(index + 1)")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(index < 3 ? AppTheme.warningYellow : .white.opacity(0.4))
                        .frame(width: 22, alignment: .leading)
                    
                    Image(systemName: perf.sector.iconName)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.cyan)
                        .frame(width: 14)
                    
                    Text(perf.sector.rawValue)
                        .font(.system(size: 11.5, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text(String(format: "%+.1f%%", perf.avgChangePercent))
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(perf.avgChangePercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.darkCard.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.horizontal, 6)
            }
        }
    }
}

// MARK: - 5. Macro Dedicated Sidebar
private struct MacroSidebarContent: View {
    @Bindable var viewModel: MarketViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Key Indicators
            VStack(alignment: .leading, spacing: 6) {
                Text("CHỈ SỐ VĨ MÔ TOÀN CẦU")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 10)
                    .padding(.top, 4)
                
                macroItemCard(title: "Lãi suất Fed (Fed Funds)", value: "5.25% - 5.50%", subtitle: "Thắt chặt tiền tệ", color: AppTheme.orange)
                macroItemCard(title: "Lạm phát CPI Mỹ", value: "2.9%", subtitle: "Mục tiêu dài hạn 2.0%", color: AppTheme.warningYellow)
                macroItemCard(title: "Chỉ số USD (DXY)", value: "101.4", subtitle: "Xu hướng hạ nhiệt", color: AppTheme.cyan)
                macroItemCard(title: "Trái phiếu US10Y", value: "3.78%", subtitle: "Lợi suất kỳ hạn 10 năm", color: AppTheme.accentBlue)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
                .padding(.horizontal, 10)
            
            // Macro Risk Gauge
            VStack(alignment: .leading, spacing: 6) {
                Text("ĐÁNH GIÁ RỦI RO VĨ MÔ")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 10)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(AppTheme.upGreen)
                        .frame(width: 8, height: 8)
                    Text("Trung Lập / Tích Cực")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.upGreen)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.upGreen.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(.horizontal, 8)
            }
        }
    }
    
    private func macroItemCard(title: String, value: String, subtitle: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.5))
            HStack {
                Text(value)
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                Spacer()
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(8)
        .background(AppTheme.darkCard.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .padding(.horizontal, 6)
    }
}

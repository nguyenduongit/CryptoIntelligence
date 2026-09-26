import SwiftUI

public struct MarketSidebarView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView
            
            // 6 Main Market Sections Navigation List
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text("PHÂN HỆ THỊ TRƯỜNG")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .padding(.bottom, 2)
                    
                    ForEach(MarketViewMode.allCases) { mode in
                        let isSelected = (viewModel.selectedViewMode == mode)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedViewMode = mode
                            }
                        }) {
                            HStack(spacing: 10) {
                                // Icon Box
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isSelected ? modeColor(mode).opacity(0.2) : Color.white.opacity(0.04))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: mode.iconName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isSelected ? modeColor(mode) : .white.opacity(0.6))
                                }
                                
                                // Text Content
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(modeTitle(mode))
                                        .font(.system(size: 12.5, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                                    
                                    Text(modeSubtitle(mode))
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.45))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Circle()
                                        .fill(modeColor(mode))
                                        .frame(width: 6, height: 6)
                                        .shadow(color: modeColor(mode).opacity(0.8), radius: 3)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? modeColor(mode).opacity(0.12) : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? modeColor(mode).opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            
            Spacer(minLength: 0)
            
            // Bottom Market Health Summary Widget
            bottomMarketSummary
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.accentBlue)
                Text("THỊ TRƯỜNG CRYPTO")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("6 PHÂN HỆ")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.accentBlue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(AppTheme.accentBlue.opacity(0.15))
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
    
    // MARK: - Bottom Market Health Summary
    private var bottomMarketSummary: some View {
        VStack(spacing: 8) {
            Divider()
                .background(AppTheme.darkBorder)
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("TỔNG QUAN NHANH")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                    
                    Spacer()
                    
                    Button(action: {
                        viewModel.loadData()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.clockwise")
                                .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                                .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                            Text("Làm mới")
                        }
                        .font(.system(size: 9.5, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .buttonStyle(.plain)
                }
                
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 1) {
                        Text("24h Volume")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                        Text(viewModel.globalMetrics != nil ? Formatters.formatVolume(viewModel.globalMetrics!.total24hVolumeUSDT) : "$84.2B")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 1) {
                        Text("BTC Dominance")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                        Text(viewModel.globalMetrics != nil ? String(format: "%.1f%%", viewModel.globalMetrics!.btcDominancePercent) : "58.3%")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.orange)
                    }
                }
                .padding(8)
                .background(AppTheme.darkCard.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
    }
    
    // MARK: - Metadata Helpers
    private func modeTitle(_ mode: MarketViewMode) -> String {
        switch mode {
        case .valuation: return "Vốn Hóa & Tỷ Trọng"
        case .globalMacro: return "Kinh Tế Vĩ Mô"
        case .heatmap: return "Bản Đồ Nhiệt"
        case .sectors: return "Ngành & Phân Khúc"
        case .movers: return "Top Biến Động"
        case .screener: return "Bộ Lọc & Radar"
        }
    }
    
    private func modeSubtitle(_ mode: MarketViewMode) -> String {
        switch mode {
        case .valuation: return "TOTAL, TOTAL2/3, Dominance"
        case .globalMacro: return "Lãi suất, CPI, M2, Lịch sự kiện"
        case .heatmap: return "Trực quan hóa biến động & Volume"
        case .sectors: return "Layer 1, DeFi, AI, Meme, GameFi"
        case .movers: return "Top Tăng/Giảm 24h & Đột biến Vol"
        case .screener: return "Quét tín hiệu kỹ thuật & On-chain"
        }
    }
    
    private func modeColor(_ mode: MarketViewMode) -> Color {
        switch mode {
        case .valuation: return AppTheme.cyan
        case .globalMacro: return AppTheme.accentBlue
        case .heatmap: return Color.purple
        case .sectors: return AppTheme.orange
        case .movers: return AppTheme.upGreen
        case .screener: return Color.yellow
        }
    }
}

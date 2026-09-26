import SwiftUI

public struct MarketHeatmapMainHubView: View {
    @Bindable var viewModel: MarketViewModel
    public let onSelectSymbol: (String) -> Void
    
    public init(viewModel: MarketViewModel, onSelectSymbol: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Top Toolbar (Information, Sizing Mode Selector & Status)
            heatmapTopToolbar
            
            // 2. Heatmap Grid Content with Dynamic Sizing
            MarketHeatmapView(
                tickers: viewModel.filteredHeatmapTickers,
                isSizingByVolume: viewModel.isHeatmapSizingByVolume,
                onSelectSymbol: onSelectSymbol
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            if viewModel.tickers.isEmpty {
                viewModel.loadData()
            }
        }
    }
    
    // MARK: - Top Toolbar
    private var heatmapTopToolbar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "square.grid.3x3.fill")
                    .foregroundColor(Color.purple)
                    .font(.system(size: 13))
                Text("BẢN ĐỒ NHIỆT THỊ TRƯỜNG")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                Text("(\(viewModel.filteredHeatmapTickers.count) tài sản)")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Sizing Mode Quick Switcher
            HStack(spacing: 3) {
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
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(!viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.3) : Color.clear)
                    .foregroundColor(!viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(!viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.7) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help("Kích thước ô heatmap tỷ lệ theo Vốn Hóa Thị Trường (Market Cap)")
                
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
                    .padding(.horizontal, 9)
                    .padding(.vertical, 4)
                    .background(viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.3) : Color.clear)
                    .foregroundColor(viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.7) : Color.clear, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .help("Kích thước ô heatmap tỷ lệ theo Khối Lượng Giao Dịch 24h (24h Volume)")
            }
            .padding(2)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1)
            )
            
            // Live Source Badges & Refresh
            HStack(spacing: 8) {
                DataSourceBadge(type: .liveBinance, text: "Binance Realtime")
                
                Button(action: {
                    viewModel.loadData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                        .rotationEffect(.degrees(viewModel.isLoading ? 360 : 0))
                        .animation(viewModel.isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: viewModel.isLoading)
                }
                .buttonStyle(.plain)
                .help("Làm mới dữ liệu")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
}

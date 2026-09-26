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
            // 1. Top Toolbar (Information & Status)
            heatmapTopToolbar
            
            // 2. Heatmap Grid Content
            MarketHeatmapView(
                tickers: viewModel.filteredTickers,
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
                
                Text("(\(viewModel.filteredTickers.count) tài sản)")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
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
        .padding(.vertical, 8)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
}

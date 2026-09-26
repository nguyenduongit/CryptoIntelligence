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
            // 1. Top Toolbar (Mode Switcher, Sizing Metric, Status)
            heatmapTopToolbar
            
            // 2. Main Visualization Content (Bubbles vs Grid)
            ZStack(alignment: .bottom) {
                if viewModel.heatmapDisplayMode == .bubbles {
                    CryptoBubblesView(
                        tickers: viewModel.filteredBubbleTickers,
                        sizingMetric: viewModel.bubbleSizingMetric,
                        onSelectSymbol: onSelectSymbol
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    // Floating Physics Interaction Hint
                    HStack(spacing: 6) {
                        Image(systemName: "hand.draw.fill")
                            .font(.system(size: 11))
                            .foregroundColor(Color.cyan)
                        Text("Kéo quăng bong bóng để tương tác đàn hồi • Nhấn để mở biểu đồ nến")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkCard.opacity(0.85))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    .padding(.bottom, 12)
                    .allowsHitTesting(false)
                } else {
                    MarketHeatmapView(
                        tickers: viewModel.filteredHeatmapTickers,
                        isSizingByVolume: viewModel.isHeatmapSizingByVolume,
                        onSelectSymbol: onSelectSymbol
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
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
            // Left Title & Asset Count
            HStack(spacing: 6) {
                Image(systemName: viewModel.heatmapDisplayMode.iconName)
                    .foregroundColor(Color.purple)
                    .font(.system(size: 13))
                Text(viewModel.heatmapDisplayMode == .bubbles ? "CRYPTO BUBBLES" : "BẢN ĐỒ NHIỆT")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                let count = viewModel.heatmapDisplayMode == .bubbles
                    ? viewModel.filteredBubbleTickers.count
                    : viewModel.filteredHeatmapTickers.count
                Text("(\(count) tài sản)")
                    .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // 1. Display Mode Switcher (Bubbles vs Grid)
            HStack(spacing: 2) {
                ForEach(MarketHeatmapDisplayMode.allCases) { mode in
                    let isSelected = (viewModel.heatmapDisplayMode == mode)
                    Button(action: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            viewModel.heatmapDisplayMode = mode
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: mode.iconName)
                                .font(.system(size: 10.5))
                            Text(mode.rawValue)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(isSelected ? Color.purple.opacity(0.3) : Color.clear)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(isSelected ? Color.purple.opacity(0.7) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(2)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
            
            // 2. Metric Sizing Switcher (Vốn Hóa vs Volume 24h vs % Biến Động)
            if viewModel.heatmapDisplayMode == .bubbles {
                HStack(spacing: 2) {
                    ForEach(BubbleSizingMetric.allCases) { metric in
                        let isSelected = (viewModel.bubbleSizingMetric == metric)
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                viewModel.bubbleSizingMetric = metric
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: metric.iconName)
                                    .font(.system(size: 10))
                                Text(metric.rawValue)
                                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isSelected ? AppTheme.accentBlue.opacity(0.3) : Color.clear)
                            .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.7) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(2)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
            } else {
                // Grid sizing switcher (Vốn Hóa vs Volume)
                HStack(spacing: 2) {
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(!viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.3) : Color.clear)
                        .foregroundColor(!viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(!viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.7) : Color.clear, lineWidth: 1)
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
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.3) : Color.clear)
                        .foregroundColor(viewModel.isHeatmapSizingByVolume ? .white : .white.opacity(0.65))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(viewModel.isHeatmapSizingByVolume ? Color.purple.opacity(0.7) : Color.clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(2)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
            }
            
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

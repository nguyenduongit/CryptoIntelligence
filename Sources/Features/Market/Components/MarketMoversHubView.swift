import SwiftUI

public struct MarketMoversHubView: View {
    @Bindable var viewModel: MarketViewModel
    public let onSelectSymbol: (String) -> Void
    
    public init(viewModel: MarketViewModel, onSelectSymbol: @escaping (String) -> Void) {
        self.viewModel = viewModel
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Top Subtabs Toolbar
            moversSubtabsToolbar
            
            // 2. Main Movers List Content
            MarketMoversView(
                topGainers: viewModel.topGainers,
                topLosers: viewModel.topLosers,
                topVolumes: viewModel.topVolumes,
                selectedCategory: viewModel.selectedMoversCategory,
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
    
    // MARK: - Subtabs Toolbar
    private var moversSubtabsToolbar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(MoversCategorySelection.allCases) { cat in
                    let isSelected = (viewModel.selectedMoversCategory == cat)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedMoversCategory = cat
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: cat.iconName)
                                .font(.system(size: 11))
                            Text(cat.rawValue)
                                .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5.5)
                        .background(isSelected ? AppTheme.upGreen.opacity(0.2) : AppTheme.darkCard)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? AppTheme.upGreen.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            // Status Badges & Refresh
            HStack(spacing: 8) {
                DataSourceBadge(type: .liveBinance, text: "Ticker 24h Realtime")
                
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

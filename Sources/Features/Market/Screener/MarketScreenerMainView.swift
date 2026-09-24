import SwiftUI

public struct MarketScreenerMainView: View {
    @Bindable var router: NavigationRouter
    @Binding var selectedSymbol: String
    @State private var viewModel: MarketScreenerViewModel
    
    public init(
        router: NavigationRouter,
        selectedSymbol: Binding<String>,
        viewModel: MarketScreenerViewModel = MarketScreenerViewModel()
    ) {
        self.router = router
        self._selectedSymbol = selectedSymbol
        _viewModel = State(initialValue: viewModel)
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(spacing: 16) {
                // 1. Radar Banner
                SignalRadarBannerView(summary: viewModel.summary)
                
                // 2. Filters Bar
                ScreenerFiltersBarView(config: $viewModel.config)
                
                // 3. Signals List Header
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .foregroundColor(AppTheme.accentBlue)
                        Text("Tín Hiệu Đang Kích Hoạt (\(viewModel.filteredSignals.count))")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        
                        DataSourceBadge(type: .realTimeAlgorithm, text: "Radar Tín Hiệu Live")
                        DataSourceBadge(type: .liveBinance, text: "Ticker 24h Binance")
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await viewModel.loadData() }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.clockwise")
                            Text("Quét lại")
                        }
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .buttonStyle(.plain)
                }
                
                // 4. Signals Items
                if viewModel.filteredSignals.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 28))
                            .foregroundColor(.white.opacity(0.3))
                        Text("Không tìm thấy tín hiệu phù hợp với bộ lọc")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Text("Thử giảm độ mạnh tối thiểu hoặc xóa tìm kiếm.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    VStack(spacing: 8) {
                        ForEach(viewModel.filteredSignals) { signal in
                            MarketSignalRowCardView(
                                signal: signal,
                                onSelectSymbol: { sym in
                                    selectedSymbol = sym
                                    router.selectedTab = .coin
                                }
                            )
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.darkBackground)
        .task {
            await viewModel.loadData()
        }
    }
}

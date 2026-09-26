import SwiftUI

public struct DerivativesView: View {
    public let symbol: String
    @State private var viewModel: DerivativesViewModel
    @State private var selectedSectionId: String = "futures"
    
    private let sections: [SubtabSectionItem] = [
        SubtabSectionItem(id: "futures", title: "Tổng Quan Futures & Funding", iconName: "chart.line.uptrend.xyaxis"),
        SubtabSectionItem(id: "heatmap", title: "Bản Đồ Cụm Thanh Lý", iconName: "flame.fill"),
        SubtabSectionItem(id: "huntRadar", title: "Radar Săn Thanh Lý", iconName: "bolt.shield.fill"),
        SubtabSectionItem(id: "orderbook", title: "Sổ Lệnh & Tường Mua/Bán", iconName: "square.stack.3d.down.right.fill")
    ]
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: DerivativesViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tải dữ liệu Phái sinh & Bản đồ thanh lý cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Header Status & Source Badges
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Phái Sinh, Funding Rate & Bản Đồ Thanh Lý (\(symbol))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Dữ liệu phái sinh tham chiếu tổng hợp đa sàn, bản đồ cụm thanh lý và radar phát hiện bẫy săn râu nến.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .liveBinance, text: "Binance Spot Orderbook")
                        DataSourceBadge(type: .liveBinance, text: "Binance Futures OI/Funding")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // Sub-navigation Section Selector
                    SubtabSectionSelector(items: sections, selectedId: $selectedSectionId)
                    
                    // Dynamic Content based on selected section
                    switch selectedSectionId {
                    case "futures":
                        // 1. Funding Rate Arbitrage & Multi-Exchange
                        FundingRateArbitrageCardView(rates: profile.exchangeFundingRates, history: profile.fundingHistory)
                        
                        // 2. Open Interest & Long/Short Sentiment
                        OpenInterestSentimentCardView(metrics: profile.openInterest)
                        
                    case "heatmap":
                        // 1. Full Liquidation Heatmap (2D Canvas Coinglass + 1D Clusters)
                        LiquidationHeatmapCardView(
                            data: profile.heatmapData,
                            heatmap2D: profile.heatmap2D,
                            symbol: symbol
                        )
                        
                        // 2. Quick Targets
                        LiquidationHuntRadarCardView(data: profile.heatmapData)
                        
                    case "huntRadar":
                        // 1. Liquidation Hunt Radar & Squeeze Target Cards
                        LiquidationHuntRadarCardView(data: profile.heatmapData)
                        
                        // 2. Heatmap Visualizer
                        LiquidationHeatmapCardView(
                            data: profile.heatmapData,
                            heatmap2D: profile.heatmap2D,
                            symbol: symbol
                        )
                        
                    case "orderbook":
                        // Institutional Orderbook Depth Walls
                        OrderbookDepthWallsCardView(walls: profile.orderbookWalls)
                        
                    default:
                        EmptyView()
                    }
                } else if let err = viewModel.errorMessage {
                    DataUnavailableView(
                        title: "Phái Sinh & Thanh Lý",
                        symbol: symbol,
                        iconName: "bolt.shield.fill",
                        message: err,
                        onRetry: { viewModel.loadData() }
                    )
                } else {
                    DataUnavailableView(
                        title: "Phái Sinh & Thanh Lý",
                        symbol: symbol,
                        iconName: "bolt.shield.fill",
                        onRetry: { viewModel.loadData() }
                    )
                }
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: symbol) { _, newSym in
            viewModel.setSymbol(newSym)
        }
    }
}

import SwiftUI

public struct DerivativesView: View {
    public let symbol: String
    @State private var viewModel: DerivativesViewModel
    
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
                            Text("Dữ liệu phái sinh tham chiếu tổng hợp đa sàn và phân tích liquidation clusters.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .liveBinance, text: "Live Spot Mark")
                        DataSourceBadge(type: .simulatedCatalog, text: "Mô Hình Phái Sinh Tham Chiếu")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // Top Section Filter Selector Bar
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(DerivativesSectionFilter.allCases) { sec in
                                Button {
                                    viewModel.selectedSection = sec
                                } label: {
                                    HStack(spacing: 5) {
                                        Image(systemName: iconForSection(sec))
                                            .font(.system(size: 10))
                                        Text(sec.rawValue)
                                            .font(.system(size: 11, weight: viewModel.selectedSection == sec ? .bold : .medium))
                                    }
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(viewModel.selectedSection == sec ? AppTheme.accentBlue : AppTheme.darkCard)
                                    .foregroundColor(viewModel.selectedSection == sec ? .white : .white.opacity(0.7))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(viewModel.selectedSection == sec ? AppTheme.accentBlue : AppTheme.darkBorder, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // 1. Liquidation Heatmap & Squeeze Targets
                    if viewModel.selectedSection == .all || viewModel.selectedSection == .heatmap {
                        LiquidationHeatmapCardView(data: profile.heatmapData)
                    }
                    
                    // 2. Multi-Exchange Funding Rates & Arbitrage
                    if viewModel.selectedSection == .all || viewModel.selectedSection == .funding {
                        FundingRateArbitrageCardView(rates: profile.exchangeFundingRates, history: profile.fundingHistory)
                    }
                    
                    // 3. Open Interest & Long/Short Sentiment
                    if viewModel.selectedSection == .all || viewModel.selectedSection == .openInterest {
                        OpenInterestSentimentCardView(metrics: profile.openInterest)
                    }
                    
                    // 4. Institutional Orderbook Depth Walls
                    if viewModel.selectedSection == .all || viewModel.selectedSection == .orderbook {
                        OrderbookDepthWallsCardView(walls: profile.orderbookWalls)
                    }
                } else if let err = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.warningYellow)
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        Button("Thử lại") {
                            viewModel.loadData()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .frame(maxWidth: .infinity, minHeight: 250)
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
    
    private func iconForSection(_ sec: DerivativesSectionFilter) -> String {
        switch sec {
        case .all: return "square.grid.2x2.fill"
        case .heatmap: return "flame.fill"
        case .funding: return "percent"
        case .openInterest: return "chart.xyaxis.line"
        case .orderbook: return "square.stack.3d.down.right.fill"
        }
    }
}

import SwiftUI

public struct ChartView: View {
    @Bindable var viewModel: ChartViewModel
    var watchlistVM: WatchlistViewModel? = nil
    private let priceAxisWidth: CGFloat = 65.0
    
    public init(viewModel: ChartViewModel, watchlistVM: WatchlistViewModel? = nil) {
        self.viewModel = viewModel
        self.watchlistVM = watchlistVM
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Controls Bar (Timeframe, Log, Indicators, Watchlist Star)
            TimeframePickerView(viewModel: viewModel, watchlistVM: watchlistVM)
            
            // 2. Main Price Chart Stack
            ZStack(alignment: .topLeading) {
                // Background & Grid Layer
                GridAxisLayer(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
                
                // Candlestick & Volume Layer
                CandlestickLayer(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
                
                // Overlay Indicators (SMA, EMA, EMA Ribbon, Bollinger, VWAP)
                OverlayIndicatorsLayer(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
                
                // Drawing Tools Layer (Trendlines, Horizontal Rays, Price Rulers, Fibonacci)
                DrawingLayer(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
                
                // Crosshair & Tooltip Overlay Layer
                CrosshairTooltipLayer(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
                
                // AppKit Mouse & Trackpad Event Capture Layer
                ChartInteractionView(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
                
                // Floating Drawing Toolbar
                DrawingToolbarView(viewModel: viewModel)
                    .padding(.leading, 12)
                    .padding(.top, 45)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppTheme.darkBackground)
            
            // 3. Optional Sub-panes
            if viewModel.indicatorConfig.showRSI {
                RSIPaneView(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
            }
            
            if viewModel.indicatorConfig.showStochRSI {
                StochRSIPaneView(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
            }
            
            if viewModel.indicatorConfig.showMACD {
                MACDPaneView(viewModel: viewModel, priceAxisWidth: priceAxisWidth)
            }
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            viewModel.loadData()
        }
        .onDisappear {
            viewModel.cleanup()
        }
    }
}

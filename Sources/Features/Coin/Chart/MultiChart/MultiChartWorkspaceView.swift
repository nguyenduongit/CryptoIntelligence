import SwiftUI

public struct MultiChartWorkspaceView: View {
    public let primarySymbol: String
    @Binding public var layout: MultiChartLayout
    @Binding public var showRelativeStrength: Bool
    
    @State private var relativeStrengthSummary: RelativeStrengthSummary? = nil
    @State private var panes: [MultiChartPaneConfig] = []
    @State private var showFootprint = false
    
    private let availableSymbols = ["BTCUSDT", "ETHUSDT", "SOLUSDT", "BNBUSDT", "XRPUSDT", "DOGEUSDT", "AVAXUSDT", "LINKUSDT", "SUIUSDT", "NEARUSDT"]
    
    public init(
        primarySymbol: String,
        layout: Binding<MultiChartLayout>,
        showRelativeStrength: Binding<Bool>
    ) {
        self.primarySymbol = primarySymbol
        self._layout = layout
        self._showRelativeStrength = showRelativeStrength
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Top Toolbar for Layout & Relative Strength
            HStack(spacing: 8) {
                MultiChartLayoutSelectorBar(
                    layout: $layout,
                    showRelativeStrength: $showRelativeStrength
                )
                Button(showFootprint ? "Chart" : "Footprint") {
                    showFootprint.toggle()
                }
                .buttonStyle(.bordered)
                .padding(.trailing, 12)
            }
            
            // Relative Strength Overlay (if enabled)
            if showRelativeStrength, let summary = relativeStrengthSummary {
                RelativeStrengthOverlayCardView(summary: summary)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
            
            // Multi-Pane Content
            if showFootprint {
                OrderFlowFootprintView(symbol: primarySymbol)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                layoutContainer
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(AppTheme.darkBackground)
        .task(id: primarySymbol) {
            panes = await MultiChartDataProvider.shared.createDefaultPanes(for: primarySymbol)
            relativeStrengthSummary = await MultiChartDataProvider.shared.fetchRelativeStrength(for: primarySymbol)
        }
    }
    
    @ViewBuilder
    private var layoutContainer: some View {
        switch layout {
        case .single:
            paneView(index: 0)
        case .splitVertical:
            HStack(spacing: 4) {
                paneView(index: 0)
                paneView(index: 1)
            }
        case .splitHorizontal:
            VStack(spacing: 4) {
                paneView(index: 0)
                paneView(index: 1)
            }
        case .grid2x2:
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    paneView(index: 0)
                    paneView(index: 1)
                }
                HStack(spacing: 4) {
                    paneView(index: 2)
                    paneView(index: 3)
                }
            }
        case .focusOnePlusThree:
            HStack(spacing: 4) {
                paneView(index: 0)
                    .frame(maxWidth: .infinity)
                VStack(spacing: 4) {
                    paneView(index: 1)
                    paneView(index: 2)
                    paneView(index: 3)
                }
                .frame(width: 320)
            }
        }
    }
    
    @ViewBuilder
    private func paneView(index: Int) -> some View {
        if panes.indices.contains(index) {
            let pSymbol = panes[index].symbol
            let pTimeframe = panes[index].timeframe
            
            VStack(spacing: 0) {
                if layout != .single {
                    HStack(spacing: 6) {
                        Picker("Symbol", selection: symbolBinding(for: index)) {
                            ForEach(availableSymbols, id: \.self) { sym in
                                Text(sym).tag(sym)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 110)
                        
                        Picker("Timeframe", selection: timeframeBinding(for: index)) {
                            ForEach(Timeframe.allCases) { tf in
                                Text(tf.displayName).tag(tf)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 150)
                        
                        Spacer()
                        
                        Text("\(pSymbol) • \(pTimeframe.displayName)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(AppTheme.accentBlue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.darkHeaderBg)
                    .overlay(Rectangle().fill(AppTheme.darkBorder).frame(height: 1), alignment: .bottom)
                }
                
                MultiChartPaneInnerView(symbol: pSymbol, timeframe: pTimeframe)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        } else {
            Color.clear
        }
    }
    
    private func symbolBinding(for index: Int) -> Binding<String> {
        Binding(
            get: { self.panes.indices.contains(index) ? self.panes[index].symbol : "BTCUSDT" },
            set: { if self.panes.indices.contains(index) { self.panes[index].symbol = $0 } }
        )
    }
    
    private func timeframeBinding(for index: Int) -> Binding<Timeframe> {
        Binding(
            get: { self.panes.indices.contains(index) ? self.panes[index].timeframe : .h4 },
            set: { if self.panes.indices.contains(index) { self.panes[index].timeframe = $0 } }
        )
    }
}

public struct MultiChartPaneInnerView: View {
    public let symbol: String
    public let timeframe: Timeframe
    @State private var viewModel: ChartViewModel
    
    public init(symbol: String, timeframe: Timeframe) {
        self.symbol = symbol
        self.timeframe = timeframe
        let vm = ChartViewModel(symbol: symbol)
        vm.timeframe = timeframe
        _viewModel = State(initialValue: vm)
    }
    
    public var body: some View {
        ChartView(viewModel: viewModel)
            .onChange(of: symbol) { _, newSym in
                viewModel.setSymbol(newSym)
            }
            .onChange(of: timeframe) { _, newTf in
                viewModel.setTimeframe(newTf)
            }
    }
}

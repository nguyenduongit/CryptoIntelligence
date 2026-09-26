import SwiftUI

public enum HeatmapDisplayMode: String, CaseIterable, Identifiable, Sendable {
    case canvas2D = "Bản Đồ Nhiệt 2D (Coinglass)"
    case clusters1D = "Cụm Đòn Bẩy (1D)"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .canvas2D: return "flame.fill"
        case .clusters1D: return "chart.bar.xaxis"
        }
    }
}

public struct LiquidationHeatmapCardView: View {
    public let data: LiquidationHeatmapData
    public let heatmap2D: LiquidationHeatmap2DData?
    public let symbol: String
    
    @State private var displayMode: HeatmapDisplayMode = .canvas2D
    @State private var selectedTimeframe: LiquidationTimeframe = .hours24
    @State private var selectedPalette: LiquidationHeatmapPalette = .coinglass
    @State private var liquidityThreshold: Double = 0.20
    @State private var showCandleOverlay: Bool = true
    @State private var showHeatmapBands: Bool = true
    
    public init(
        data: LiquidationHeatmapData,
        heatmap2D: LiquidationHeatmap2DData? = nil,
        symbol: String = "BTCUSDT"
    ) {
        self.data = data
        self.heatmap2D = heatmap2D
        self.symbol = symbol
    }
    
    private var resolved2DData: LiquidationHeatmap2DData {
        if let h2d = heatmap2D, h2d.timeframe == selectedTimeframe {
            return h2d
        }
        // Fallback or dynamically generated for selected timeframe
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        return DerivativesDataProvider.shared.generateLiquidationHeatmap2D(
            symbol: cleanSymbol,
            currentPrice: data.currentPriceUSD,
            baseAsset: baseAsset,
            cachedCandlePoints: heatmap2D?.candles ?? [],
            timeframe: selectedTimeframe
        )
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with Display Mode Switcher
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppTheme.warningYellow)
                        .font(.system(size: 13))
                    Text("Bản Đồ Mật Độ Thanh Lý (Liquidation Heatmap & Squeeze Targets)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Display Mode Segmented Switcher (2D vs 1D)
                HStack(spacing: 2) {
                    ForEach(HeatmapDisplayMode.allCases) { mode in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                displayMode = mode
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: mode.iconName)
                                    .font(.system(size: 9.5))
                                Text(mode.rawValue)
                                    .font(.system(size: 10.5, weight: displayMode == mode ? .bold : .medium))
                            }
                            .foregroundColor(displayMode == mode ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3.5)
                            .background(displayMode == mode ? AppTheme.accentBlue : Color.white.opacity(0.001))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .contentShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(2)
                .background(AppTheme.darkHeaderBg)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // Risk Badge
                Text(data.primarySqueezeRisk)
                    .font(.system(size: 10, weight: .semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppTheme.accentBlue.opacity(0.15))
                    .foregroundColor(AppTheme.accentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // Top Overview Metric Cards
            HStack(spacing: 10) {
                // Short Liquidation Overhang (Above)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Thanh Lý Short (Phía Trên)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(data.totalShortLiquidationUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                    Text("Điểm kích hoạt: " + Formatters.formatPrice(data.shortSqueezeTriggerPriceUSD))
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.upGreen.opacity(0.8))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Max Pain Price Level
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vùng Giá Max Pain")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatPrice(data.maxPainPriceUSD))
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("Mức gây thanh lý 2 chiều lớn nhất")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Long Liquidation Overhang (Below)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tổng Thanh Lý Long (Phía Dưới)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatVolume(data.totalLongLiquidationUSD) + " USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.downRed)
                    Text("Điểm kích hoạt: " + Formatters.formatPrice(data.longSqueezeTriggerPriceUSD))
                        .font(.system(size: 9))
                        .foregroundColor(AppTheme.downRed.opacity(0.8))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Content Switcher: 2D Canvas Heatmap vs 1D Bar Clusters
            switch displayMode {
            case .canvas2D:
                // Coinglass-Style 2D Heatmap
                VStack(spacing: 10) {
                    // Control bar (Pair, Timeframe, Palettes, Threshold Slider, Supercharts toggle)
                    LiquidationHeatmapControlsView(
                        symbol: symbol,
                        selectedTimeframe: $selectedTimeframe,
                        selectedPalette: $selectedPalette,
                        liquidityThreshold: $liquidityThreshold,
                        showCandleOverlay: $showCandleOverlay,
                        showHeatmapBands: $showHeatmapBands,
                        onRefresh: {
                            // Trigger redraw with state nudge
                            selectedTimeframe = selectedTimeframe
                        }
                    )
                    
                    // Main Canvas View
                    LiquidationHeatmap2DCanvasView(
                        data: resolved2DData,
                        palette: selectedPalette,
                        liquidityThreshold: liquidityThreshold,
                        showCandleOverlay: showCandleOverlay,
                        showHeatmapBands: showHeatmapBands
                    )
                }
                
            case .clusters1D:
                // Traditional 1D Bar Clusters
                clusters1DView
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    // MARK: - 1D Clusters Bar View
    
    private var clusters1DView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Các Cụm Mật Độ Đòn Bẩy (5x - 100x)")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Circle().fill(AppTheme.upGreen).frame(width: 5, height: 5)
                        Text("Thanh lý Short (Mua ép)").font(.system(size: 9)).foregroundColor(.white.opacity(0.6))
                    }
                    HStack(spacing: 4) {
                        Circle().fill(AppTheme.downRed).frame(width: 5, height: 5)
                        Text("Thanh lý Long (Bán ép)").font(.system(size: 9)).foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            
            let maxClusterVol = data.clusters.map { $0.volumeUSD }.max() ?? 1.0
            
            VStack(spacing: 4) {
                ForEach(data.clusters.reversed()) { cl in
                    HStack(spacing: 8) {
                        Text(cl.leverageTier)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .frame(width: 38, alignment: .leading)
                            .foregroundColor(cl.side.color)
                        
                        Text(Formatters.formatPrice(cl.priceLevel))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 80, alignment: .leading)
                        
                        Text((cl.distancePercent >= 0 ? "+" : "") + String(format: "%.1f%%", cl.distancePercent))
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor((cl.distancePercent >= 0 ? AppTheme.upGreen : AppTheme.downRed).opacity(0.8))
                            .frame(width: 48, alignment: .leading)
                        
                        GeometryReader { geo in
                            let barW = max(8.0, geo.size.width * CGFloat(cl.volumeUSD / maxClusterVol))
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 14)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                cl.side.color.opacity(0.4),
                                                cl.side.color
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: barW, height: 14)
                            }
                        }
                        .frame(height: 14)
                        
                        Text(Formatters.formatVolume(cl.volumeUSD) + " USD")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 75, alignment: .trailing)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(cl.intensity >= 0.9 ? cl.side.color.opacity(0.08) : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            .padding(8)
            .background(AppTheme.darkHeaderBg.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

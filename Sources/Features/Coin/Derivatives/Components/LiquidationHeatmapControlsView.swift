import SwiftUI

/// Top control toolbar for Coinglass 2D Liquidation Heatmap
/// Matches the exact layout, controls, and sliders in Coinglass.
public struct LiquidationHeatmapControlsView: View {
    public let symbol: String
    @Binding var selectedTimeframe: LiquidationTimeframe
    @Binding var selectedPalette: LiquidationHeatmapPalette
    @Binding var liquidityThreshold: Double
    @Binding var showCandleOverlay: Bool
    @Binding var showHeatmapBands: Bool
    let onRefresh: () -> Void
    
    public init(
        symbol: String,
        selectedTimeframe: Binding<LiquidationTimeframe>,
        selectedPalette: Binding<LiquidationHeatmapPalette>,
        liquidityThreshold: Binding<Double>,
        showCandleOverlay: Binding<Bool>,
        showHeatmapBands: Binding<Bool>,
        onRefresh: @escaping () -> Void
    ) {
        self.symbol = symbol
        self._selectedTimeframe = selectedTimeframe
        self._selectedPalette = selectedPalette
        self._liquidityThreshold = liquidityThreshold
        self._showCandleOverlay = showCandleOverlay
        self._showHeatmapBands = showHeatmapBands
        self.onRefresh = onRefresh
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Row 1: Title + Pair + Timeframe + Refresh
            HStack(spacing: 10) {
                // Title
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppTheme.warningYellow)
                        .font(.system(size: 13))
                    Text("Binance \(symbol.replacingOccurrences(of: "USDT", with: ""))/USDT Liquidation Heatmap")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Pair badge
                HStack(spacing: 4) {
                    Text("Binance \(symbol.replacingOccurrences(of: "USDT", with: ""))/USDT Perpetual")
                        .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.darkHeaderBg)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // Timeframe Selector
                Picker("", selection: $selectedTimeframe) {
                    ForEach(LiquidationTimeframe.allCases) { tf in
                        Text(tf.rawValue).tag(tf)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 95)
                .font(.system(size: 11))
                
                // Refresh button
                Button {
                    onRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.75))
                        .padding(5)
                        .background(AppTheme.darkHeaderBg)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(AppTheme.darkBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Row 2: Color Palettes + Liquidity Threshold Slider + Toggles
            HStack(spacing: 14) {
                // Palette buttons
                HStack(spacing: 6) {
                    ForEach(LiquidationHeatmapPalette.allCases) { palette in
                        paletteSwatchButton(palette)
                    }
                }
                
                // Threshold Slider
                HStack(spacing: 6) {
                    Text(String(format: "Liquidity Threshold = %.2f", liquidityThreshold))
                        .font(.system(size: 10.5, weight: .medium, design: .monospaced))
                        .foregroundColor(.white.opacity(0.75))
                    
                    Slider(value: $liquidityThreshold, in: 0.0...0.90, step: 0.05)
                        .frame(width: 110)
                        .controlSize(.small)
                }
                
                Spacer()
                
                // Supercharts (Candle) Toggle
                Button {
                    showCandleOverlay.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showCandleOverlay ? "checkmark.square.fill" : "square")
                            .font(.system(size: 11))
                            .foregroundColor(showCandleOverlay ? AppTheme.upGreen : .white.opacity(0.4))
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(AppTheme.upGreen)
                                .frame(width: 8, height: 8)
                            Text("Supercharts (Nến)")
                                .font(.system(size: 10.5))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // Liquidation Heatmap Toggle
                Button {
                    showHeatmapBands.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: showHeatmapBands ? "checkmark.square.fill" : "square")
                            .font(.system(size: 11))
                            .foregroundColor(showHeatmapBands ? AppTheme.accentBlue : .white.opacity(0.4))
                        HStack(spacing: 3) {
                            RoundedRectangle(cornerRadius: 1)
                                .fill(selectedPalette.previewColors[1])
                                .frame(width: 8, height: 8)
                            Text("Liquidation Map")
                                .font(.system(size: 10.5))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(AppTheme.darkHeaderBg.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }
    
    private func paletteSwatchButton(_ palette: LiquidationHeatmapPalette) -> some View {
        let isSelected = selectedPalette == palette
        return Button {
            selectedPalette = palette
        } label: {
            HStack(spacing: 0) {
                ForEach(0..<palette.previewColors.count, id: \.self) { idx in
                    Rectangle()
                        .fill(palette.previewColors[idx])
                        .frame(width: 5.5, height: 16)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(isSelected ? Color.white : Color.white.opacity(0.2), lineWidth: isSelected ? 1.5 : 0.8)
            )
        }
        .buttonStyle(.plain)
        .help(palette.rawValue)
    }
}

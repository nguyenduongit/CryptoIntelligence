import SwiftUI

public struct IndicatorSettingsModal: View {
    @Bindable var viewModel: ChartViewModel
    @Binding var isPresented: Bool
    
    public init(viewModel: ChartViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Cài đặt Chỉ báo Kỹ thuật")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.5))
                        .padding(2)
                        .background(Color.white.opacity(0.001))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
            
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // 1. Overlay Indicators
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chỉ báo chồng lên giá (Overlays)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.accentBlue)
                        
                        ToggleRow(title: "SMA (20)", color: AppTheme.ma20, isOn: $viewModel.indicatorConfig.showSMA20)
                        ToggleRow(title: "SMA (50)", color: AppTheme.ma50, isOn: $viewModel.indicatorConfig.showSMA50)
                        ToggleRow(title: "SMA (200)", color: AppTheme.ma200, isOn: $viewModel.indicatorConfig.showSMA200)
                        ToggleRow(title: "EMA (12)", color: AppTheme.ema12, isOn: $viewModel.indicatorConfig.showEMA12)
                        ToggleRow(title: "EMA (26)", color: AppTheme.ema26, isOn: $viewModel.indicatorConfig.showEMA26)
                        ToggleRow(title: "EMA Ribbon (20, 50, 100, 200)", color: AppTheme.purple, isOn: $viewModel.indicatorConfig.showEMARibbon)
                        ToggleRow(title: "Bollinger Bands (20, 2)", color: AppTheme.bollingerBand, isOn: $viewModel.indicatorConfig.showBollinger)
                        ToggleRow(title: "VWAP (Volume-Weighted Price)", color: AppTheme.orange, isOn: $viewModel.indicatorConfig.showVWAP)
                    }
                    
                    Rectangle()
                        .fill(AppTheme.darkBorder)
                        .frame(height: 1)
                    
                    // 2. Sub-pane Indicators
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Chỉ báo Pane riêng (Sub-panes)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.purple)
                        
                        ToggleRow(title: "Khối lượng (Volume)", color: .white, isOn: $viewModel.indicatorConfig.showVolume)
                        ToggleRow(title: "RSI (14)", color: AppTheme.rsiColor, isOn: $viewModel.indicatorConfig.showRSI)
                        ToggleRow(title: "Stochastic RSI (14, 3, 3)", color: AppTheme.cyan, isOn: $viewModel.indicatorConfig.showStochRSI)
                        ToggleRow(title: "MACD (12, 26, 9)", color: AppTheme.macdLine, isOn: $viewModel.indicatorConfig.showMACD)
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(height: 320)
            
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1)
            
            HStack {
                Spacer()
                Button("Áp dụng") {
                    viewModel.recomputeIndicators()
                    viewModel.updatePriceRange()
                    isPresented = false
                }
                .font(.system(size: 12, weight: .semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(AppTheme.accentBlue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .contentShape(RoundedRectangle(cornerRadius: 6))
                .buttonStyle(.plain)
            }
        }
        .padding(14)
        .frame(width: 300)
        .background(AppTheme.darkSidebarBg)
        .onChange(of: viewModel.indicatorConfig) { _, _ in
            viewModel.recomputeIndicators()
            viewModel.updatePriceRange()
        }
    }
}

private struct ToggleRow: View {
    let title: String
    let color: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            Toggle("", isOn: $isOn)
                .toggleStyle(.switch)
                .labelsHidden()
                .controlSize(.mini)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(AppTheme.darkCard.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .contentShape(RoundedRectangle(cornerRadius: 6))
        .onTapGesture {
            isOn.toggle()
        }
    }
}

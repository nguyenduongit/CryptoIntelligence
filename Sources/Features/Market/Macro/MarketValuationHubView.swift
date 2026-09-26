import SwiftUI

public struct MarketValuationHubView: View {
    @Bindable var viewModel: MarketViewModel
    
    @State private var snapshots: [MacroIndexSnapshot] = []
    @State private var seasonReport: MarketSeasonReport? = nil
    @State private var isLoading: Bool = false
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // 1. Top Subtabs Toolbar
            valuationSubtabsToolbar
            
            // 2. Scrollable Content Area
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if isLoading && snapshots.isEmpty {
                        VStack(spacing: 12) {
                            ProgressView().controlSize(.large)
                            Text("Đang tổng hợp dữ liệu vốn hóa và tính toán chỉ số...")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, minHeight: 280)
                    } else {
                        switch viewModel.selectedValuationSection {
                        case .overview:
                            if let report = seasonReport {
                                MacroValuationCorrelationView(snapshots: snapshots, seasonReport: report)
                            }
                            
                        case .kline:
                            MacroIndexKLineChartView(
                                selectedIndex: $viewModel.selectedMacroIndex,
                                selectedTimeframe: $viewModel.selectedKLineTimeframe
                            )
                        }
                    }
                }
                .padding(14)
            }
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            loadMacroData()
        }
    }
    
    // MARK: - Subtabs Toolbar
    private var valuationSubtabsToolbar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                ForEach(MarketValuationSection.allCases) { sec in
                    let isSelected = (viewModel.selectedValuationSection == sec)
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            viewModel.selectedValuationSection = sec
                        }
                    }) {
                        HStack(spacing: 5) {
                            Image(systemName: sec.iconName)
                                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            Text(sec.rawValue == "Tổng quan" ? "Tổng Quan Vốn Hóa & Tỷ Trọng" : "Biểu Đồ Nến K-Line Chỉ Số")
                                .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 5.5)
                        .background(isSelected ? AppTheme.cyan.opacity(0.2) : AppTheme.darkCard)
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(isSelected ? AppTheme.cyan.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Spacer()
            
            // Live Source Badges
            HStack(spacing: 8) {
                DataSourceBadge(type: .liveCoinGecko, text: "CoinGecko Global")
                DataSourceBadge(type: .liveBinance, text: "Binance Spot Realtime")
                
                Button(action: {
                    loadMacroData()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                        .rotationEffect(.degrees(isLoading ? 360 : 0))
                        .animation(isLoading ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isLoading)
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
    
    private func loadMacroData() {
        isLoading = true
        Task { @MainActor in
            async let sFetch = MacroIndicesDataProvider.shared.fetchMacroSnapshots()
            async let rFetch = MacroIndicesDataProvider.shared.fetchSeasonReport()
            
            let (snaps, rep) = await (sFetch, rFetch)
            self.snapshots = snaps
            self.seasonReport = rep
            self.isLoading = false
        }
    }
}

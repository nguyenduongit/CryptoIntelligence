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
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Header Banner
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Phân Tích Vốn Hóa Thị Trường & Luân Chuyển Dòng Tiền")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Tổng vốn hóa TOTAL 1/2/3, tỷ trọng chiếm lĩnh Dominance, thước đo Altseason và biểu đồ nến K-Line.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    DataSourceBadge(type: .liveCoinGecko, text: "CoinGecko Global")
                    DataSourceBadge(type: .liveBinance, text: "Binance Spot Realtime")
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // Dynamic Main Content based on Sidebar navigation
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
        .background(AppTheme.darkBackground)
        .onAppear {
            loadMacroData()
        }
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

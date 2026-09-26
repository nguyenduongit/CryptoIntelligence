import SwiftUI

public struct MacroHubView: View {
    @State private var snapshots: [MacroIndexSnapshot] = []
    @State private var seasonReport: MarketSeasonReport? = nil
    @State private var selectedSectionId: String = "correlation"
    @State private var isLoading: Bool = false
    
    private let sections: [SubtabSectionItem] = [
        SubtabSectionItem(id: "correlation", title: "Vốn Hóa & Tương Quan", iconName: "chart.pie.fill"),
        SubtabSectionItem(id: "kline", title: "Biểu Đồ K-Line Chỉ Số", iconName: "chart.line.uptrend.xyaxis"),
        SubtabSectionItem(id: "globalEconomy", title: "Kinh Tế Toàn Cầu", iconName: "globe.americas.fill")
    ]
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // Header Banner
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Phân Tích Vĩ Mô, Vốn Hóa & Luân Chuyển Dòng Tiền")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Tổng vốn hóa TOTAL 1/2/3, tỷ trọng Dominance, ma trận mùa Altseason và kinh tế vĩ mô quốc tế.")
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
                
                // Sub-navigation Section Selector
                SubtabSectionSelector(items: sections, selectedId: $selectedSectionId)
                
                // Dynamic Content
                if isLoading && snapshots.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView().controlSize(.large)
                        Text("Đang tổng hợp dữ liệu vĩ mô và tính toán chỉ số...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 280)
                } else {
                    switch selectedSectionId {
                    case "correlation":
                        if let report = seasonReport {
                            MacroValuationCorrelationView(snapshots: snapshots, seasonReport: report)
                        }
                        
                    case "kline":
                        MacroIndexKLineChartView()
                        
                        if let report = seasonReport {
                            MacroValuationCorrelationView(snapshots: snapshots, seasonReport: report)
                        }
                        
                    case "globalEconomy":
                        GlobalMacroView()
                        
                    default:
                        EmptyView()
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

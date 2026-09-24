import SwiftUI

public struct CoinOverviewView: View {
    public let symbol: String
    public let item: WatchlistItem?
    
    @State private var report: ConfluenceResearchReport? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    public init(symbol: String, item: WatchlistItem?) {
        self.symbol = symbol
        self.item = item
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // 1. Header Price & Metric Banner
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(item?.baseAsset ?? symbol.replacingOccurrences(of: "USDT", with: ""))
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            
                            DataSourceBadge(type: .liveBinance, text: "Live Binance Spot")
                            DataSourceBadge(type: .realTimeAlgorithm, text: "Thuật Toán Nến 4H")
                        }
                        Text("\(symbol) · Phân tích định lượng & Hợp lưu 5 Trụ")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    // Current Price & 24h change
                    VStack(alignment: .trailing, spacing: 4) {
                        if let price = item?.lastPrice ?? report?.currentPriceUSD {
                            Text(Formatters.formatPrice(price))
                                .font(.system(size: 26, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                        } else {
                            Text("--")
                                .font(.system(size: 26, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        if let change = item?.priceChange24h {
                            HStack(spacing: 4) {
                                Image(systemName: change >= 0 ? "arrow.up.right" : "arrow.down.right")
                                Text(Formatters.formatPercentage(change))
                            }
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(change >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                if isLoading && report == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tổng hợp dữ liệu 5 trụ cột và tính điểm Hợp lưu Định lượng cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 280)
                } else if let r = report {
                    // 2. Confluence Score & 5-Pillar Breakdown
                    ConfluenceScoreGaugeCardView(report: r)
                    
                    // 3. Scenario Projections (Bull / Base / Bear)
                    ScenarioProjectionsCardView(scenarios: r.scenarios)
                    
                    // 4. Trade Execution & DCA Plan
                    TradeExecutionPlanCardView(plan: r.tradePlan)
                    
                    // 5. Investment Thesis & Catalysts
                    InvestmentThesisCardView(thesis: r.thesisSummary, catalysts: r.keyCatalysts, risks: r.keyRisks)
                } else if let err = errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppTheme.warningYellow)
                        Text(err)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        Button("Tải lại báo cáo") {
                            loadReport()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                }
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            loadReport()
        }
        .onChange(of: symbol) { _, _ in
            loadReport()
        }
    }
    
    private func loadReport() {
        isLoading = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                let fetched = try await ConfluenceResearchEngine.shared.generateResearchReport(for: symbol)
                self.report = fetched
                self.isLoading = false
            } catch {
                self.isLoading = false
                self.errorMessage = "Không thể tạo báo cáo hợp lưu: \(error.localizedDescription)"
            }
        }
    }
}

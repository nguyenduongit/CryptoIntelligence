import SwiftUI

public struct MarketGlobalMacroHubView: View {
    @Bindable var viewModel: MarketViewModel
    @State private var macroData: GlobalMacroOverviewData = GlobalMacroDataProvider.shared.fetchGlobalMacroData()
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                // 1. Header Banner
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Tình Báo Kinh Tế Toàn Cầu & Thị Trường Liên Tài Sản")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                        Text("Chính sách lãi suất Fed/ECB/BOJ, lạm phát CPI, tỷ giá DXY, S&P 500, Vàng và thanh khoản cung tiền M2.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    Spacer()
                    
                    DataSourceBadge(type: .macroSnapshot, text: "FRED & Global Central Banks")
                }
                .padding(12)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // 2. Top Macro Ticker Ribbon
                macroTickerRibbon
                
                // 4. Macro Risk-On / Risk-Off Sentiment Gauge
                macroRiskGaugeBanner
                
                // 5. Dynamic Content Grid based on selected section
                switch viewModel.selectedGlobalMacroSection {
                case .all:
                    HStack(alignment: .top, spacing: 14) {
                        VStack(spacing: 14) {
                            CentralBanksPolicyCardView(centralBanks: macroData.centralBanks)
                            InflationLaborCardView(
                                inflationMetrics: macroData.inflationMetrics,
                                unemploymentRate: macroData.unemploymentRate,
                                nonFarmPayrollsK: macroData.nonFarmPayrollsK
                            )
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack(spacing: 14) {
                            GlobalLiquidityM2ChartCardView(m2History: macroData.m2History)
                            CrossAssetCorrelationCardView(crossAssets: macroData.crossAssets)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    MacroEconomicCalendarCardView(events: macroData.upcomingEvents)
                    
                case .centralBanks:
                    CentralBanksPolicyCardView(centralBanks: macroData.centralBanks)
                    
                case .inflation:
                    InflationLaborCardView(
                        inflationMetrics: macroData.inflationMetrics,
                        unemploymentRate: macroData.unemploymentRate,
                        nonFarmPayrollsK: macroData.nonFarmPayrollsK
                    )
                    
                case .intermarket:
                    CrossAssetCorrelationCardView(crossAssets: macroData.crossAssets)
                    
                case .liquidityM2:
                    GlobalLiquidityM2ChartCardView(m2History: macroData.m2History)
                    
                case .calendar:
                    MacroEconomicCalendarCardView(events: macroData.upcomingEvents)
                }
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
    }
    
    // MARK: - 1. Top Macro Ticker Ribbon
    private var macroTickerRibbon: some View {
        HStack(spacing: 10) {
            ForEach(macroData.crossAssets) { asset in
                HStack(spacing: 8) {
                    Image(systemName: asset.iconName)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.accentBlue)
                    
                    VStack(alignment: .leading, spacing: 1) {
                        Text(asset.symbol)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.6))
                        
                        HStack(spacing: 4) {
                            Text(formatRibbonPrice(asset))
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text(String(format: "%@%.2f%%", asset.change24h >= 0 ? "+" : "", asset.change24h))
                                .font(.system(size: 9, weight: .semibold, design: .monospaced))
                                .foregroundColor(asset.change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.6), lineWidth: 1)
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - 2. Macro Risk-On / Risk-Off Sentiment Gauge
    private var macroRiskGaugeBanner: some View {
        HStack(spacing: 14) {
            // Risk Score Meter
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .stroke(AppTheme.darkBackground, lineWidth: 6)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(macroData.macroRiskScore) / 100.0)
                        .stroke(
                            LinearGradient(
                                colors: [AppTheme.upGreen, AppTheme.cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(macroData.macroRiskScore)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("CHỈ SỐ RỦI RO VĨ MÔ")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white.opacity(0.45))
                    Text("Risk-On Toàn Cầu (Thuận lợi)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppTheme.upGreen)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Sentiment Statement
            HStack(spacing: 8) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 14))
                    .foregroundColor(AppTheme.accentBlue)
                
                Text(macroData.macroSentimentSummary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(2)
                
                Spacer()
                
                DataSourceBadge(type: .macroSnapshot, text: "Snapshot Lãi Suất & Lịch Họp")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.6), lineWidth: 1)
        )
    }
    
    private func formatRibbonPrice(_ asset: CrossAssetTickerItem) -> String {
        if asset.currentPrice >= 1000 {
            return String(format: "%.1f", asset.currentPrice)
        } else if asset.currentPrice >= 1 {
            return String(format: "%.2f", asset.currentPrice)
        } else {
            return String(format: "%.4f", asset.currentPrice)
        }
    }
}

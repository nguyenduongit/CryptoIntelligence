import SwiftUI

public struct MarketGlobalMacroHubView: View {
    @Bindable var viewModel: MarketViewModel
    public var onSelectSymbol: ((String) -> Void)? = nil
    @State private var macroData: GlobalMacroOverviewData = GlobalMacroDataProvider.shared.fetchGlobalMacroData()
    
    public init(viewModel: MarketViewModel, onSelectSymbol: ((String) -> Void)? = nil) {
        self.viewModel = viewModel
        self.onSelectSymbol = onSelectSymbol
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if viewModel.selectedGlobalMacroSection == .valuation {
                MarketValuationHubView(viewModel: viewModel, onSelectSymbol: onSelectSymbol)
            } else {
                macroSubHeaderBar
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        // 1. Full-Width 6-Block Macro Ticker Grid (DXY, Gold, US10Y, SPX, NDX, Oil)
                        macroTickerRibbon
                        
                        // 2. Macro Risk-On / Risk-Off Sentiment Gauge
                        macroRiskGaugeBanner
                        
                        // 3. Dynamic Content Grid based on selected section
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
                            
                        case .valuation:
                            EmptyView()
                            
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
            }
        }
        .background(AppTheme.darkBackground)
    }
    
    // MARK: - Unified Level 2 Sub-Header Bar (Matches Sidebar Height)
    private var macroSubHeaderBar: some View {
        HStack(spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: viewModel.selectedGlobalMacroSection.iconName)
                    .font(.system(size: 11.5, weight: .bold))
                    .foregroundColor(AppTheme.accentBlue)
                Text(viewModel.selectedGlobalMacroSection.rawValue)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                DataSourceBadge(type: .realTimeAlgorithm, text: "Macro Intelligence Live")
                DataSourceBadge(type: .liveBinance, text: "US & Global Feeds")
                
                Button(action: {
                    withAnimation {
                        macroData = GlobalMacroDataProvider.shared.fetchGlobalMacroData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                        .padding(5)
                        .background(Color.white.opacity(0.001))
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .help("Cập nhật dữ liệu vĩ mô")
            }
        }
        .padding(.horizontal, 14)
        .frame(height: AppTheme.subHeaderHeight)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - 1. Full-Width 6-Block Macro Ticker Grid
    private var macroTickerRibbon: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 6), spacing: 10) {
            ForEach(macroData.crossAssets) { asset in
                macroTickerCard(asset)
            }
        }
    }
    
    private func macroTickerCard(_ asset: CrossAssetTickerItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header Row: Icon + Symbol + 24h Change Pill
            HStack(alignment: .center) {
                HStack(spacing: 5) {
                    Image(systemName: asset.iconName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(assetColor(asset))
                    
                    Text(asset.symbol)
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 24h Change Badge
                Text(String(format: "%@%.2f%%", asset.change24h >= 0 ? "+" : "", asset.change24h))
                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                    .foregroundColor(asset.change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2.5)
                    .background(asset.change24h >= 0 ? AppTheme.upGreen.opacity(0.15) : AppTheme.downRed.opacity(0.15))
                    .clipShape(Capsule())
            }
            
            // Name / Category Subtitle
            Text(asset.name)
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
            
            // Price & Unit
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(formatRibbonPrice(asset))
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text(asset.priceUnit)
                    .font(.system(size: 9.5, design: .monospaced))
                    .foregroundColor(.white.opacity(0.45))
            }
            
            Divider()
                .background(AppTheme.darkBorder.opacity(0.6))
            
            // Bottom Info: Correlation with BTC & 30D Trend
            HStack {
                HStack(spacing: 3) {
                    Circle()
                        .fill(asset.correlationColor)
                        .frame(width: 5, height: 5)
                    Text(String(format: "T/q BTC: %+.2f", asset.correlationWithBTC_30d))
                        .font(.system(size: 9, weight: .semibold, design: .monospaced))
                        .foregroundColor(asset.correlationColor)
                }
                
                Spacer()
                
                Text(String(format: "30D: %+.1f%%", asset.change30d))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(asset.change30d >= 0 ? AppTheme.upGreen.opacity(0.8) : AppTheme.downRed.opacity(0.8))
            }
        }
        .padding(11)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func assetColor(_ asset: CrossAssetTickerItem) -> Color {
        switch asset.symbol {
        case "DXY": return AppTheme.upGreen
        case "XAU/USD": return Color.yellow
        case "US10Y": return AppTheme.orange
        case "S&P 500": return AppTheme.accentBlue
        case "Nasdaq 100": return Color.purple
        default: return AppTheme.cyan
        }
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
            return String(format: "%.2f", asset.currentPrice)
        } else if asset.currentPrice >= 1 {
            return String(format: "%.2f", asset.currentPrice)
        } else {
            return String(format: "%.4f", asset.currentPrice)
        }
    }
}

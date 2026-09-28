import SwiftUI

public struct MarketImpactTWAPSimulatorView: View {
    public let orderbook: AggregatedOrderbook
    
    @State private var selectedCapital: Double = 1_000_000.0 // Default 1M USD
    @State private var selectedSide: ExecutionOrderSide = .buy
    
    private let capitalPresets: [Double] = [
        50_000,
        250_000,
        1_000_000,
        2_500_000,
        5_000_000,
        10_000_000
    ]
    
    public init(orderbook: AggregatedOrderbook) {
        self.orderbook = orderbook
    }
    
    private var simulation: MarketImpactSimulationResult {
        MultiExchangeOrderbookProvider.shared.simulateExecution(
            capitalUSD: selectedCapital,
            side: selectedSide,
            book: orderbook
        )
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "cpu.fill")
                    .foregroundColor(AppTheme.warningYellow)
                    .font(.system(size: 13))
                Text("MÔ PHỎNG TRƯỢT GIÁ & THUẬT TOÁN GIẢI NGÂN TWAP (MARKET IMPACT)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                Text("Square-Root Impact Law & L2 Depth Walking")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Interactive Controls: Capital Presets & Buy/Sell Toggle
            VStack(alignment: .leading, spacing: 10) {
                // Side Toggle & Label
                HStack {
                    Text("Hướng lệnh:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Picker("Order Side", selection: $selectedSide) {
                        ForEach(ExecutionOrderSide.allCases) { side in
                            Text(side.rawValue).tag(side)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 240)
                    
                    Spacer()
                    
                    Text("Vốn giải ngân:")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Text("$\(Int(selectedCapital).formatted()) USD")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue)
                }
                
                // Capital Preset Buttons
                HStack(spacing: 8) {
                    ForEach(capitalPresets, id: \.self) { cap in
                        Button(action: {
                            selectedCapital = cap
                        }) {
                            Text(formatCapitalLabel(cap))
                                .font(.system(size: 10.5, weight: selectedCapital == cap ? .bold : .medium, design: .monospaced))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(selectedCapital == cap ? AppTheme.accentBlue.opacity(0.25) : Color.white.opacity(0.04))
                                .foregroundColor(selectedCapital == cap ? AppTheme.accentBlue : .white.opacity(0.8))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedCapital == cap ? AppTheme.accentBlue.opacity(0.8) : Color.white.opacity(0.1), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(12)
            .background(Color.white.opacity(0.02))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // 3-Way Strategy Comparison Cards
            HStack(spacing: 12) {
                // Card 1: Single CEX Market Order
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("1. LỆNH THƯỜNG (1 SÀN)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("Xấu nhất")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.downRed)
                    }
                    
                    Text(String(format: "%.2f%%", simulation.singleExchangeSlippagePercent))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.downRed)
                    
                    Text("Trượt giá tức thì")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Divider().background(AppTheme.darkBorder)
                    
                    metricRow(label: "Giá khớp TB:", value: "$\(String(format: "%.2f", simulation.singleExchangeFillPrice))")
                    metricRow(label: "Thiệt hại trượt:", value: "-$\(formatUSD(selectedCapital * simulation.singleExchangeSlippagePercent / 100.0))", color: AppTheme.downRed)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Card 2: Aggregated Smart Routing
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("2. GỘP SÀN THÔNG MINH")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("Đa sàn")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.accentBlue)
                    }
                    
                    Text(String(format: "%.2f%%", simulation.aggregatedSlippagePercent))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue)
                    
                    Text("Trượt giá hợp nhất")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Divider().background(AppTheme.darkBorder)
                    
                    metricRow(label: "Giá khớp TB:", value: "$\(String(format: "%.2f", simulation.aggregatedFillPrice))")
                    metricRow(label: "Tiết kiệm:", value: "+$\(formatUSD(simulation.smartRoutingSavingsUSD))", color: AppTheme.upGreen)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Card 3: TWAP Algorithmic Execution
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("3. THUẬT TOÁN TWAP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text("Tối ưu cá voi")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    
                    Text(String(format: "%.2f%%", simulation.twapPlan.estimatedTWAPSlippagePercent))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                    
                    Text("Trượt giá tối ưu")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                    
                    Divider().background(AppTheme.darkBorder)
                    
                    metricRow(label: "Số lệnh con:", value: "\(simulation.twapPlan.numberOfSlices) lát (\(simulation.twapPlan.intervalSeconds)s/lát)")
                    metricRow(label: "Tổng thời gian:", value: "\(simulation.twapPlan.totalDurationMinutes) phút")
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.upGreen.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.upGreen.opacity(0.3), lineWidth: 1))
            }
            
            // TWAP Execution Plan & Smart Routing Breakdown
            VStack(alignment: .leading, spacing: 8) {
                Text("CHI TIẾT KẾ HOẠCH GIẢI NGÂN TWAP & ĐIỀU PHỐI SÀN (SMART ROUTING)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                
                HStack(spacing: 8) {
                    ForEach(simulation.twapPlan.routingAllocations) { alloc in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(alloc.exchange.color)
                                .frame(width: 6, height: 6)
                            Text(alloc.exchange.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                            Text("$\(formatUSD(alloc.allocatedAmountUSD)) (\(alloc.allocatedSharePercent, specifier: "%.1f")%)")
                                .font(.system(size: 9.5, design: .monospaced))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.03))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    Spacer()
                    
                    Text("Tỷ lệ hút vol: < \(simulation.twapPlan.targetParticipationRatePercent, specifier: "%.1f")%")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                }
            }
            
            // Big Savings Highlight Banner
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppTheme.upGreen)
                    .font(.system(size: 16))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("TIẾT KIỆM DỰ KIẾN KHI DÙNG THUẬT TOÁN TWAP & SMART ROUTING")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Text("+$\(formatUSD(simulation.twapPlan.estimatedSlippageSavingsUSD + simulation.smartRoutingSavingsUSD)) USD")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                }
                
                Spacer()
                
                Text("Giảm thiểu tối đa footprint cá voi trên sổ lệnh L2")
                    .font(.system(size: 9.5))
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(12)
            .background(AppTheme.upGreen.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.upGreen.opacity(0.35), lineWidth: 1))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func metricRow(label: String, value: String, color: Color = .white) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                .foregroundColor(color)
        }
    }
    
    private func formatCapitalLabel(_ cap: Double) -> String {
        if cap >= 1_000_000 {
            let m = Int(cap / 1_000_000.0)
            return "$\(m)M"
        } else {
            let k = Int(cap / 1_000.0)
            return "$\(k)K"
        }
    }
    
    private func formatUSD(_ val: Double) -> String {
        if val >= 1_000_000_000 {
            return String(format: "%.2fB", val / 1_000_000_000.0)
        } else if val >= 1_000_000 {
            return String(format: "%.2fM", val / 1_000_000.0)
        } else if val >= 1_000 {
            return String(format: "%.1fK", val / 1_000.0)
        } else {
            return String(format: "%.0f", val)
        }
    }
}

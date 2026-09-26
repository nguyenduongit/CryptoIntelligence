import SwiftUI

public struct SlippageCalculatorView: View {
    public let slippage10k: Double
    public let slippage50k: Double
    public let slippage100k: Double
    public let totalLiquidityUSD: Double
    
    @State private var customOrderSize: Double = 25000.0
    
    public init(
        slippage10k: Double,
        slippage50k: Double,
        slippage100k: Double,
        totalLiquidityUSD: Double
    ) {
        self.slippage10k = slippage10k
        self.slippage50k = slippage50k
        self.slippage100k = slippage100k
        self.totalLiquidityUSD = totalLiquidityUSD
    }
    
    private var customSlippage: Double {
        let poolDepth = max(500_000.0, totalLiquidityUSD * 0.5)
        let impact = (customOrderSize / (poolDepth + customOrderSize)) * 100.0
        return max(0.01, impact)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "gauge.with.dots.needle.bottom.50percent")
                    .foregroundColor(AppTheme.orange)
                    .font(.system(size: 13))
                Text("MÁY TÍNH TRƯỢT GIÁ & ĐỘ SÂU THANH KHOẢN (SLIPPAGE SIMULATOR)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("Mô hình AMM x*y=k Invariant")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // 3 Predefined Order Impact Cards
            HStack(spacing: 12) {
                // $10k
                VStack(alignment: .leading, spacing: 4) {
                    Text("LỆNH XẢ $10,000")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2f%%", slippage10k))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(slippageColor(slippage10k))
                    Text(slippageSeverity(slippage10k))
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // $50k
                VStack(alignment: .leading, spacing: 4) {
                    Text("LỆNH XẢ $50,000")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2f%%", slippage50k))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(slippageColor(slippage50k))
                    Text(slippageSeverity(slippage50k))
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // $100k
                VStack(alignment: .leading, spacing: 4) {
                    Text("LỆNH XẢ $100,000")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.2f%%", slippage100k))
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                        .foregroundColor(slippageColor(slippage100k))
                    Text(slippageSeverity(slippage100k))
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Custom Slider Simulator
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Thử nghiệm quy mô lệnh bán tùy chỉnh:")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("$\(Int(customOrderSize).formatted()) USD  ➜  Trượt giá ước tính: ")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                    Text(String(format: "%.2f%%", customSlippage))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(slippageColor(customSlippage))
                }
                
                Slider(value: $customOrderSize, in: 1000...500000, step: 1000)
                    .accentColor(AppTheme.accentBlue)
            }
            .padding(10)
            .background(Color.white.opacity(0.02))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func slippageColor(_ slip: Double) -> Color {
        if slip < 0.5 {
            return AppTheme.upGreen
        } else if slip < 2.0 {
            return AppTheme.accentBlue
        } else if slip < 5.0 {
            return AppTheme.orange
        } else {
            return AppTheme.downRed
        }
    }
    
    private func slippageSeverity(_ slip: Double) -> String {
        if slip < 0.5 {
            return "Thanh khoản dồi dào"
        } else if slip < 2.0 {
            return "Trượt giá chấp nhận được"
        } else if slip < 5.0 {
            return "Trượt giá cao (Cảnh báo)"
        } else {
            return "Thanh khoản mỏng (Rất rủi ro)"
        }
    }
}

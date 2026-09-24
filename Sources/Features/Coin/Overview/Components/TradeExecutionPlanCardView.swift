import SwiftUI

public struct TradeExecutionPlanCardView: View {
    public let plan: TradeExecutionPlan
    
    public init(plan: TradeExecutionPlan) {
        self.plan = plan
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 13))
                    Text("Kế Hoạch Mua Gom & Quản Trị Rủi Ro (Trade & Risk Plan)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text("Tỷ lệ R:R:")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text("1 : \(String(format: "%.1f", plan.riskRewardRatio))")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(plan.isAttractiveRiskReward ? AppTheme.upGreen : AppTheme.warningYellow)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background((plan.isAttractiveRiskReward ? AppTheme.upGreen : AppTheme.warningYellow).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // 4 Grid Parameters
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                // 1. Optimal DCA Zone
                VStack(alignment: .leading, spacing: 2) {
                    Text("Vùng Mua Tối Ưu (DCA)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(Formatters.formatPrice(plan.optimalDCAMinUSD)) - \(Formatters.formatPrice(plan.optimalDCAMaxUSD))")
                        .font(.system(size: 11.5, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.upGreen)
                    Text("Tích lũy từng phần khi pullback")
                        .font(.system(size: 8.5))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 2. Recommended Allocation
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tỷ Trọng Khuyến Nghị")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(String(format: "%.0f%% Danh mục", plan.recommendedAllocationPercent))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Tối đa trong rổ Crypto")
                        .font(.system(size: 8.5))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 3. Stop Loss
                VStack(alignment: .leading, spacing: 2) {
                    Text("Cắt Lỗ (Stop Loss)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(Formatters.formatPrice(plan.stopLossPriceUSD))
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.downRed)
                    Text("Bảo vệ vốn nếu thủng hỗ trợ")
                        .font(.system(size: 8.5))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 4. Take Profit Targets
                VStack(alignment: .leading, spacing: 2) {
                    Text("Mục Tiêu Chốt Lời (TP)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text("TP1: \(Formatters.formatPrice(plan.takeProfit1USD))")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(AppTheme.cyan)
                    Text("TP2: \(Formatters.formatPrice(plan.takeProfit2USD))")
                        .font(.system(size: 10, weight: .medium, design: .monospaced))
                        .foregroundColor(AppTheme.cyan.opacity(0.7))
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

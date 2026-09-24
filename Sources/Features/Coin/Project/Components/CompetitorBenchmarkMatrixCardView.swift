import SwiftUI

public struct CompetitorBenchmarkMatrixCardView: View {
    public let competitors: [CompetitorBenchmarkItem]
    
    public init(competitors: [CompetitorBenchmarkItem]) {
        self.competitors = competitors
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.left.arrow.right.circle.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Bảng So Sánh Thông Số Đối Thủ Cạnh Tranh Trực Tiếp")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("Hiệu năng thực tế Mainnet")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // Comparison Table
            VStack(spacing: 0) {
                // Table Header
                HStack(spacing: 8) {
                    Text("BLOCKCHAIN / GIAO THỨC")
                        .frame(minWidth: 150, alignment: .leading)
                    Spacer()
                    Text("TPS THỰC TẾ")
                        .frame(width: 90, alignment: .trailing)
                    Text("FINALITY")
                        .frame(width: 80, alignment: .trailing)
                    Text("NAKAMOTO COEFF")
                        .frame(width: 105, alignment: .trailing)
                    Text("PHÍ TRUNG BÌNH")
                        .frame(width: 95, alignment: .trailing)
                }
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(AppTheme.darkBackground.opacity(0.6))
                
                Divider().background(AppTheme.darkBorder)
                
                // Rows
                ForEach(competitors) { c in
                    HStack(spacing: 8) {
                        // Protocol Name
                        HStack(spacing: 6) {
                            if c.isTargetCoin {
                                Circle().fill(AppTheme.accentBlue).frame(width: 6, height: 6)
                            }
                            Text(c.name)
                                .font(.system(size: 11, weight: c.isTargetCoin ? .bold : .medium))
                                .foregroundColor(c.isTargetCoin ? AppTheme.accentBlue : .white)
                            if c.isTargetCoin {
                                Text("(Đang xem)")
                                    .font(.system(size: 9))
                                    .foregroundColor(AppTheme.accentBlue.opacity(0.8))
                            }
                        }
                        .frame(minWidth: 150, alignment: .leading)
                        
                        Spacer()
                        
                        // Real-world TPS
                        Text("\(c.tpsRealWorld) TPS")
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(c.tpsRealWorld > 1000 ? AppTheme.upGreen : .white.opacity(0.85))
                            .frame(width: 90, alignment: .trailing)
                        
                        // Time to Finality
                        Text(c.timeToFinality)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))
                            .frame(width: 80, alignment: .trailing)
                        
                        // Nakamoto Coefficient
                        HStack(spacing: 3) {
                            Text("\(c.nakamotoCoefficient)")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(c.nakamotoCoefficient >= 15 ? AppTheme.upGreen : (c.nakamotoCoefficient >= 8 ? AppTheme.warningYellow : AppTheme.downRed))
                            Text("nodes")
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .frame(width: 105, alignment: .trailing)
                        
                        // Avg Fee
                        Text(formatFee(c.avgTransactionFeeUSD))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(c.avgTransactionFeeUSD < 0.01 ? AppTheme.upGreen : .white.opacity(0.85))
                            .frame(width: 95, alignment: .trailing)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(c.isTargetCoin ? AppTheme.accentBlue.opacity(0.12) : Color.clear)
                    
                    if c.id != competitors.last?.id {
                        Divider().background(AppTheme.darkBorder.opacity(0.5))
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(AppTheme.darkBorder, lineWidth: 1)
            )
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func formatFee(_ fee: Double) -> String {
        if fee < 0.001 {
            return String(format: "$%.4f", fee)
        } else if fee < 1.0 {
            return String(format: "$%.3f", fee)
        } else {
            return String(format: "$%.2f", fee)
        }
    }
}

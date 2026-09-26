import SwiftUI

public struct WhaleTrapsRadarCardView: View {
    public let symbol: String
    public let pumpDumpRiskLevel: String // "Thấp", "Trung bình", "Cao"
    public let washTradingScore: Int // 0..100
    public let top10ConcentrationPercent: Double
    
    public init(
        symbol: String,
        pumpDumpRiskLevel: String = "Thấp",
        washTradingScore: Int = 12,
        top10ConcentrationPercent: Double = 18.5
    ) {
        self.symbol = symbol
        self.pumpDumpRiskLevel = pumpDumpRiskLevel
        self.washTradingScore = washTradingScore
        self.top10ConcentrationPercent = top10ConcentrationPercent
    }
    
    private var washColor: Color {
        if washTradingScore < 20 {
            return AppTheme.upGreen
        } else if washTradingScore < 50 {
            return AppTheme.orange
        } else {
            return AppTheme.downRed
        }
    }
    
    private var concentrationColor: Color {
        if top10ConcentrationPercent < 30.0 {
            return AppTheme.upGreen
        } else if top10ConcentrationPercent < 60.0 {
            return AppTheme.orange
        } else {
            return AppTheme.downRed
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "radar.fill")
                    .foregroundColor(AppTheme.orange)
                    .font(.system(size: 13))
                Text("RADAR PHÁT HIỆN BẪY THAO TÚNG CÁ VOI (WHALE TRAPS)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("AI Pattern Engine")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
            
            // 3 Radar Pillar Cards
            HStack(spacing: 12) {
                // Card 1: Pump & Dump Detector
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "chart.line.flattrend.xyaxis")
                            .foregroundColor(pumpDumpRiskLevel == "Thấp" ? AppTheme.upGreen : AppTheme.orange)
                            .font(.system(size: 12))
                        Text("BẪY PUMP & DUMP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(pumpDumpRiskLevel == "Thấp" ? "AN TOÀN" : "CẢNH BÁO")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(pumpDumpRiskLevel == "Thấp" ? AppTheme.upGreen : AppTheme.orange)
                    
                    Text(pumpDumpRiskLevel == "Thấp" ? "Không có dấu hiệu kéo xả bất thường" : "Khối lượng tăng đột biến không đi kèm dòng vốn tổ chức")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Card 2: Wash Trading (Volume Ảo)
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .foregroundColor(washColor)
                            .font(.system(size: 12))
                        Text("WASH TRADING (VOLUME ẢO)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(washTradingScore) / 100")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(washColor)
                    }
                    
                    Text(washTradingScore < 20 ? "Volume giao dịch thực chất (>80% tự nhiên)" : "Nghi vấn bot đảo lệnh tự mua bán để tạo volume ảo")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Card 3: Top 10 Holder Concentration
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Image(systemName: "person.3.sequence.fill")
                            .foregroundColor(concentrationColor)
                            .font(.system(size: 12))
                        Text("TẬP TRUNG VÍ TOP 10")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(String(format: "%.1f%% Nguồn Cung", top10ConcentrationPercent))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(concentrationColor)
                    
                    Text(top10ConcentrationPercent < 30 ? "Phân tán tốt, rủi ro thao túng thấp" : "Rủi ro cá voi độc quyền xả hàng cao")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.5))
                        .lineLimit(2)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Strategic Alert Box
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "shield.lefthalf.filled.trianglebadge.exclamationmark")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 12))
                    Text("Nguyên tắc phòng thủ cá voi:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("• Không bao giờ mua theo các cây nến tăng dựng đứng (God Candle) nếu Wash Trading Score > 50 hoặc Top 10 ví nắm > 60% cung.\n• Theo dõi sát sao dòng tiền chuyển vào ví nạp sàn CEX (Exchange Inflows) trước các thời điểm then chốt.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
                    .lineSpacing(2)
            }
            .padding(10)
            .background(Color.white.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

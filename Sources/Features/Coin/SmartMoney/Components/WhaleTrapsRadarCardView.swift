import SwiftUI

public struct WhaleTrapsRadarCardView: View {
    public let symbol: String
    public let metrics: WhaleTrapMetrics
    
    public init(symbol: String, metrics: WhaleTrapMetrics) {
        self.symbol = symbol
        self.metrics = metrics
    }
    
    public init(
        symbol: String,
        pumpDumpRiskLevel: String = "Thấp",
        washTradingScore: Int = 12,
        top10ConcentrationPercent: Double = 18.5
    ) {
        self.symbol = symbol
        let status = pumpDumpRiskLevel == "Thấp" ? "AN TOÀN" : (pumpDumpRiskLevel == "Cao" ? "NGUY HIỂM" : "CẢNH BÁO")
        self.metrics = WhaleTrapMetrics(
            pumpDumpRiskLevel: pumpDumpRiskLevel,
            pumpDumpStatusText: status,
            pumpDumpDetail: pumpDumpRiskLevel == "Thấp" ? "Biên độ giá và thanh khoản ổn định, không có dấu hiệu thao túng kéo xả bất thường." : "Khối lượng tăng đột biến không đi kèm dòng vốn tổ chức.",
            washTradingScore: washTradingScore,
            washTradingDetail: washTradingScore < 25 ? "Volume giao dịch thực chất (>80% tự nhiên)" : "Nghi vấn bot đảo lệnh tự mua bán để tạo volume ảo",
            top10ConcentrationPercent: top10ConcentrationPercent,
            top10Detail: top10ConcentrationPercent < 30 ? "Phân tán tốt, rủi ro thao túng thấp" : "Rủi ro cá voi độc quyền xả hàng cao"
        )
    }
    
    private var pumpDumpColor: Color {
        switch metrics.pumpDumpRiskLevel {
        case "Thấp": return AppTheme.upGreen
        case "Cao": return AppTheme.downRed
        default: return AppTheme.orange
        }
    }
    
    private var washColor: Color {
        if metrics.washTradingScore < 25 {
            return AppTheme.upGreen
        } else if metrics.washTradingScore < 50 {
            return AppTheme.orange
        } else {
            return AppTheme.downRed
        }
    }
    
    private var concentrationColor: Color {
        if metrics.top10ConcentrationPercent < 25.0 {
            return AppTheme.upGreen
        } else if metrics.top10ConcentrationPercent < 50.0 {
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
                            .foregroundColor(pumpDumpColor)
                            .font(.system(size: 12))
                        Text("BẪY PUMP & DUMP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Text(metrics.pumpDumpStatusText)
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(pumpDumpColor)
                    
                    Text(metrics.pumpDumpDetail)
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
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
                        Text("\(metrics.washTradingScore) / 100")
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundColor(washColor)
                    }
                    
                    Text(metrics.washTradingDetail)
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
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
                    
                    Text(String(format: "%.1f%% Nguồn Cung", metrics.top10ConcentrationPercent))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(concentrationColor)
                    
                    Text(metrics.top10Detail)
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.6))
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

import SwiftUI

public struct RegulatoryComplianceCardView: View {
    public let compliance: RegulatoryCompliance
    
    public init(compliance: RegulatoryCompliance) {
        self.compliance = compliance
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "building.columns.circle.fill")
                    .foregroundColor(AppTheme.purple)
                    .font(.system(size: 13))
                Text("Tình Trạng Pháp Lý & Tuân Thủ Quy Định (Regulatory & Legal)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Grid of Compliance Aspects
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                // 1. SEC Status
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ủy Ban Chứng Khoán Mỹ (SEC)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(compliance.secStatus)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 2. MiCA Compliance
                VStack(alignment: .leading, spacing: 3) {
                    Text("Quy Chế Thị Trường EU (MiCA)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(compliance.micaCompliance)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.cyan)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 3. CFTC Status
                VStack(alignment: .leading, spacing: 3) {
                    Text("Ủy Ban Giao Dịch Hàng Hóa Tương Lai (CFTC)")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text(compliance.cftcStatus)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // 4. Howey Test Assessment
                VStack(alignment: .leading, spacing: 3) {
                    Text("Thang Điểm Bài Kiểm Tra Howey")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.5))
                    Text("\(compliance.howeyTestScore)/100 - " + (compliance.howeyTestScore <= 20 ? "Tài sản Hàng hóa" : "Phân loại Hỗn hợp"))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(compliance.howeyTestScore <= 20 ? AppTheme.upGreen : AppTheme.warningYellow)
                }
                .padding(8)
                .background(AppTheme.darkHeaderBg.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Jurisdiction Notes
            VStack(alignment: .leading, spacing: 3) {
                Text("Nhận định Pháp Lý Quốc Tế:")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white.opacity(0.6))
                Text(compliance.jurisdictionNotes)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(2)
            }
            .padding(.top, 2)
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

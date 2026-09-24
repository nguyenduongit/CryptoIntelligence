import SwiftUI

public struct InvestmentThesisCardView: View {
    public let thesis: String
    public let catalysts: [String]
    public let risks: [String]
    
    public init(thesis: String, catalysts: [String], risks: [String]) {
        self.thesis = thesis
        self.catalysts = catalysts
        self.risks = risks
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.image.fill")
                        .foregroundColor(AppTheme.warningYellow)
                        .font(.system(size: 13))
                    Text("Luận Điểm Đầu Tư & Xúc Tác Tăng Trưởng (Investment Thesis)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                DataSourceBadge(type: .simulatedCatalog, text: "Hồ Sơ Nghiên Cứu")
            }
            
            // Executive Thesis Box
            Text(thesis)
                .font(.system(size: 11.5))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.darkHeaderBg.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Catalysts vs Risks Columns
            HStack(alignment: .top, spacing: 12) {
                // Catalysts
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(AppTheme.upGreen)
                            .font(.system(size: 11))
                        Text("Xúc Tác Tăng Trưởng (Key Catalysts)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(catalysts, id: \.self) { cat in
                            HStack(alignment: .top, spacing: 5) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppTheme.upGreen.opacity(0.8))
                                    .font(.system(size: 9))
                                    .padding(.top, 2)
                                Text(cat)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.upGreen.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.upGreen.opacity(0.2), lineWidth: 1)
                )
                
                // Risks
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 5) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(AppTheme.warningYellow)
                            .font(.system(size: 11))
                        Text("Yếu Tố Cần Theo Dõi (Key Risks)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.warningYellow)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        ForEach(risks, id: \.self) { rsk in
                            HStack(alignment: .top, spacing: 5) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(AppTheme.warningYellow.opacity(0.8))
                                    .font(.system(size: 9))
                                    .padding(.top, 2)
                                Text(rsk)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.warningYellow.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.warningYellow.opacity(0.2), lineWidth: 1)
                )
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

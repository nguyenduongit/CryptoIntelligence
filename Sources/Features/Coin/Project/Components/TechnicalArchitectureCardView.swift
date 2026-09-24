import SwiftUI

public struct TechnicalArchitectureCardView: View {
    public let architecture: String
    
    public init(architecture: String) {
        self.architecture = architecture
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: "square.stack.3d.up.fill")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 13))
                Text("Kiến Trúc Kỹ Thuật & Công Nghệ Cốt Lõi")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            Text(architecture)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
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

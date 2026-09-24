import SwiftUI

public struct SubtabPlaceholderView: View {
    public let title: String
    public let symbol: String
    public let iconName: String
    
    public init(title: String, symbol: String, iconName: String) {
        self.title = title
        self.symbol = symbol
        self.iconName = iconName
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 48))
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.accentBlue.opacity(0.8), AppTheme.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.bottom, 8)
            
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            Text("Tính năng phân tích \(title.lowercased()) cho \(symbol) đang được phát triển và sẽ sẵn sàng trong Phase tiếp theo.")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            HStack(spacing: 8) {
                Circle()
                    .fill(AppTheme.accentBlue)
                    .frame(width: 8, height: 8)
                Text("Trạng thái: Phase 2 Roadmap")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.accentBlue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppTheme.darkCard)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(AppTheme.accentBlue.opacity(0.3), lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkBackground)
    }
}

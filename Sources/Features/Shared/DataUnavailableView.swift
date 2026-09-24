import SwiftUI

public struct DataUnavailableView: View {
    public let title: String
    public let symbol: String
    public let iconName: String
    public let message: String
    public var onRetry: (() -> Void)? = nil
    
    public init(
        title: String,
        symbol: String,
        iconName: String = "chart.line.downtrend.xyaxis",
        message: String? = nil,
        onRetry: (() -> Void)? = nil
    ) {
        self.title = title
        self.symbol = symbol
        self.iconName = iconName
        self.message = message ?? "Dữ liệu phân tích chuyên sâu cho \(symbol) chưa có trong danh mục nghiên cứu (Data Unavailable)."
        self.onRetry = onRetry
    }
    
    public init(
        symbol: String,
        moduleName: String,
        iconName: String = "chart.line.downtrend.xyaxis",
        retryAction: (() -> Void)? = nil
    ) {
        self.title = "Chưa có dữ liệu \(moduleName)"
        self.symbol = symbol
        self.iconName = iconName
        self.message = "Dữ liệu \(moduleName.lowercased()) cho \(symbol) hiện chưa có trong cơ sở dữ liệu kiểm chứng độc lập."
        self.onRetry = retryAction
    }
    
    public var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.darkCard)
                    .frame(width: 72, height: 72)
                    .overlay(
                        Circle()
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                
                Image(systemName: iconName)
                    .font(.system(size: 30))
                    .foregroundColor(.white.opacity(0.4))
            }
            .padding(.bottom, 4)
            
            Text(title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 380)
            
            HStack(spacing: 6) {
                Circle()
                    .fill(AppTheme.warningYellow)
                    .frame(width: 6, height: 6)
                Text("Không có dữ liệu giả lập (Strict Data Integrity)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(AppTheme.warningYellow)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(AppTheme.warningYellow.opacity(0.12))
            .clipShape(Capsule())
            
            if let retry = onRetry {
                Button(action: retry) {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 11))
                        Text("Thử tải lại")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkCard)
                    .foregroundColor(AppTheme.accentBlue)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.accentBlue.opacity(0.4), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 320)
        .padding(24)
        .background(AppTheme.darkBackground)
    }
}

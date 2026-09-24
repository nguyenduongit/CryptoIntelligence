import SwiftUI

public struct StatusBarView: View {
    @Bindable var router: NavigationRouter
    
    public init(router: NavigationRouter) {
        self.router = router
    }
    
    public var body: some View {
        HStack(spacing: 16) {
            // WebSocket Status
            HStack(spacing: 6) {
                Circle()
                    .fill(router.isWebSocketConnected ? AppTheme.upGreen : AppTheme.warningYellow)
                    .frame(width: 7, height: 7)
                    .shadow(color: (router.isWebSocketConnected ? AppTheme.upGreen : AppTheme.warningYellow).opacity(0.6), radius: 3)
                
                Text(router.isWebSocketConnected ? "WebSocket: Đã kết nối" : "WebSocket: Đang kết nối lại...")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Divider()
                .frame(height: 12)
                .background(AppTheme.darkBorder)
            
            // Last Updated Time
            HStack(spacing: 4) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
                
                Text(router.lastUpdatedTime != nil
                     ? "Cập nhật: \(Formatters.formatTime(ms: Int64(router.lastUpdatedTime!.timeIntervalSince1970 * 1000))) UTC"
                     : "Cập nhật: Sẵn sàng")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Last Network Error (if any)
            if let error = router.lastNetworkError, !error.isEmpty {
                Divider()
                    .frame(height: 12)
                    .background(AppTheme.darkBorder)
                
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.warningYellow)
                    
                    Text(error)
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.warningYellow)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Binance Weight Tracker
            HStack(spacing: 6) {
                Image(systemName: "speedometer")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
                
                Text("Binance Weight (1m):")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
                
                Text("\(router.usedWeight1m) / \(router.maxWeight1m)")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(
                        router.usedWeight1m > router.maxWeight1m / 2
                        ? AppTheme.warningYellow
                        : AppTheme.upGreen
                    )
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 24)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .top
        )
    }
}

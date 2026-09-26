import SwiftUI

public struct HeaderBarView: View {
    @Bindable var router: NavigationRouter
    
    public init(router: NavigationRouter) {
        self.router = router
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            // Left Column: Exact alignment with sidebar width
            HStack(spacing: 10) {
                Button(action: { router.toggleSidebar() }) {
                    Image(systemName: "sidebar.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
                .help("Ẩn/Hiện Sidebar (Cmd+Opt+S)")
                
                Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [AppTheme.accentBlue, AppTheme.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                Text("CryptoIntelligence")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(
                width: router.isSidebarCollapsed ? 60 : router.sidebarWidth,
                alignment: .leading
            )
            .background(AppTheme.darkHeaderBg)
            
            // Divider line between Header Left & Header Right
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(width: 1)
            
            // Right Column: Main Tabs + Settings Gear
            HStack(spacing: 6) {
                ForEach([MainTab.coin, .heatmap, .valuation, .globalMacro, .movers, .screener], id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            router.selectedTab = tab
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: tab.iconName)
                                .font(.system(size: 12))
                                .foregroundColor(router.selectedTab == tab ? tabColor(tab) : .white.opacity(0.6))
                            Text(tab.rawValue)
                                .font(.system(size: 12.5, weight: router.selectedTab == tab ? .semibold : .medium))
                        }
                        .padding(.horizontal, 11)
                        .padding(.vertical, 6)
                        .background(
                            router.selectedTab == tab
                            ? tabColor(tab).opacity(0.18)
                            : Color.clear
                        )
                        .foregroundColor(
                            router.selectedTab == tab
                            ? .white
                            : .white.opacity(0.65)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(
                                    router.selectedTab == tab ? tabColor(tab).opacity(0.5) : Color.clear,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
                
                // Settings button (Gear icon)
                Button(action: { router.selectedTab = .settings }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15))
                        .padding(8)
                        .background(
                            router.selectedTab == .settings
                            ? AppTheme.darkCard
                            : Color.clear
                        )
                        .foregroundColor(
                            router.selectedTab == .settings
                            ? AppTheme.accentBlue
                            : .white.opacity(0.7)
                        )
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .help("Cài đặt ứng dụng")
            }
            .padding(.horizontal, 16)
            .background(AppTheme.darkHeaderBg)
        }
        .frame(height: 48)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func tabColor(_ tab: MainTab) -> Color {
        switch tab {
        case .coin: return AppTheme.accentBlue
        case .heatmap: return Color.purple
        case .valuation: return AppTheme.cyan
        case .globalMacro: return AppTheme.accentBlue
        case .movers: return AppTheme.upGreen
        case .screener: return Color.yellow
        case .settings: return AppTheme.accentBlue
        }
    }
}

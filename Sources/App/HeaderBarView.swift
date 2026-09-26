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
                        .padding(6)
                        .background(Color.white.opacity(0.001))
                        .contentShape(Rectangle())
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
                mainTabButtons
                
                Spacer()
                
                // Settings button (Gear icon)
                Button(action: { router.selectedTab = .settings }) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 15))
                        .padding(8)
                        .background(
                            router.selectedTab == .settings
                            ? AppTheme.darkCard
                            : Color.white.opacity(0.001)
                        )
                        .foregroundColor(
                            router.selectedTab == .settings
                            ? AppTheme.accentBlue
                            : .white.opacity(0.7)
                        )
                        .clipShape(Circle())
                        .contentShape(Circle())
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
    
    // MARK: - Computed tab buttons (extracted to help Swift type-checker)
    @ViewBuilder
    private var mainTabButtons: some View {
        let tabs: [MainTab] = [.coin, .globalMacro, .market, .screener]
        ForEach(tabs, id: \.self) { tab in
            tabButton(tab)
        }
    }

    private func tabButton(_ tab: MainTab) -> some View {
        let isSelected = router.selectedTab == tab
        let color = tabColor(tab)
        return Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                router.selectedTab = tab
            }
        }) {
            HStack(spacing: 6) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? color : .white.opacity(0.6))
                Text(tab.rawValue)
                    .font(.system(size: 12.5, weight: isSelected ? .semibold : .medium))
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.18) : Color.white.opacity(0.001))
            .foregroundColor(isSelected ? .white : .white.opacity(0.65))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? color.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
    }

    private func tabColor(_ tab: MainTab) -> Color {
        switch tab {
        case .coin: return AppTheme.accentBlue
        case .globalMacro: return AppTheme.accentBlue
        case .market: return AppTheme.upGreen
        case .screener: return Color.yellow
        case .settings: return AppTheme.accentBlue
        }
    }
}

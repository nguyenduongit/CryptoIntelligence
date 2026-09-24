import SwiftUI

public struct SidebarContainerView: View {
    @Bindable var router: NavigationRouter
    @Bindable var watchlistVM: WatchlistViewModel
    var marketVM: MarketViewModel? = nil
    @Binding var selectedSymbol: String
    
    @State private var isDraggingHandle: Bool = false
    
    public init(
        router: NavigationRouter,
        watchlistVM: WatchlistViewModel,
        marketVM: MarketViewModel? = nil,
        selectedSymbol: Binding<String>
    ) {
        self.router = router
        self.watchlistVM = watchlistVM
        self.marketVM = marketVM
        self._selectedSymbol = selectedSymbol
    }
    
    public var body: some View {
        HStack(spacing: 0) {
            if !router.isSidebarCollapsed {
                VStack(spacing: 0) {
                    switch router.selectedTab {
                    case .coin:
                        WatchlistView(viewModel: watchlistVM, selectedSymbol: $selectedSymbol)
                    case .market:
                        if let marketVM {
                            MarketSidebarView(viewModel: marketVM)
                        } else {
                            PlaceholderSidebar(title: "Bộ lọc Thị trường", icon: "globe.asia.australia.fill")
                        }
                    case .settings:
                        PlaceholderSidebar(title: "Cài đặt Chung", icon: "gearshape.fill")
                    }
                }
                .frame(width: router.sidebarWidth)
                .background(AppTheme.darkSidebarBg)
                
                // Draggable Resize Handle (1px crisp border line with 8px invisible hit area)
                ZStack {
                    Rectangle()
                        .fill(isDraggingHandle ? AppTheme.accentBlue : AppTheme.darkBorder)
                        .frame(width: 1)
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 8)
                        .contentShape(Rectangle())
                }
                .frame(width: 1)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDraggingHandle = true
                            let newWidth = router.sidebarWidth + value.translation.width
                            router.sidebarWidth = max(200.0, min(300.0, newWidth))
                        }
                        .onEnded { _ in
                            isDraggingHandle = false
                        }
                )
                .onHover { hovering in
                    if hovering {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            }
        }
    }
}

private struct PlaceholderSidebar: View {
    let title: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white.opacity(0.3))
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            Text("Không có mục nào")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.4))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
}

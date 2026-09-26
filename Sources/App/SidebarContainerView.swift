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
                        
                    case .globalMacro:
                        if let marketVM {
                            GlobalMacroSidebarView(viewModel: marketVM)
                        } else {
                            PlaceholderSidebar(title: "Kinh Tế Vĩ Mô", icon: "globe.americas.fill", note: "Đang tải dữ liệu...")
                        }
                        
                    case .movers:
                        PlaceholderSidebar(title: "Top Biến Động", icon: "flame.fill", note: "Sidebar phân hệ biến động tạm thời để trống theo thiết kế")
                        
                    case .screener:
                        if let marketVM {
                            ScreenerSidebarView(viewModel: marketVM)
                        } else {
                            PlaceholderSidebar(title: "Radar Tín Hiệu", icon: "dot.radiowaves.left.and.right", note: "Đang tải dữ liệu...")
                        }
                        
                    case .settings:
                        PlaceholderSidebar(title: "Cài Đặt Hệ Thống", icon: "gearshape.fill", note: "Tuỳ chọn cấu hình ứng dụng")
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
    var note: String = "Sidebar tạm thời để trống"
    
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.04))
                    .frame(width: 54, height: 54)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white.opacity(0.35))
            }
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.75))
                
                Text(note)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
}

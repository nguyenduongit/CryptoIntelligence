import SwiftUI
import Observation

public enum MainTab: String, CaseIterable, Identifiable, Sendable {
    case coin = "Nghiên cứu"
    case heatmap = "Heatmap"
    case valuation = "Vốn hóa"
    case globalMacro = "Kinh tế vĩ mô"
    case movers = "Top biến động"
    case screener = "Radar"
    case settings = "Cài đặt"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .coin: return "chart.candlestick.fill"
        case .heatmap: return "square.grid.3x3.fill"
        case .valuation: return "chart.pie.fill"
        case .globalMacro: return "globe.americas.fill"
        case .movers: return "flame.fill"
        case .screener: return "dot.radiowaves.left.and.right"
        case .settings: return "gearshape.fill"
        }
    }
}

public enum CoinSubtab: String, CaseIterable, Identifiable {
    case overview = "Tổng quan"
    case chart = "Biểu đồ"
    case valuation = "Định giá"
    case liquidity = "Thanh khoản"
    case derivatives = "Phái sinh"
    case whales = "Cá voi"
    case profile = "Hồ sơ"
    case notes = "Ghi chú"
    
    public var id: String { rawValue }
}

@Observable
public final class NavigationRouter {
    public var selectedTab: MainTab = .coin
    public var selectedSubtab: CoinSubtab = .chart
    public var isSidebarCollapsed: Bool = false
    public var sidebarWidth: CGFloat = 260.0 // Clamped 200..300
    
    // Status bar state
    public var lastUpdatedTime: Date? = nil
    public var isWebSocketConnected: Bool = false
    public var lastNetworkError: String? = nil
    public var usedWeight1m: Int = 0
    public var maxWeight1m: Int = 6000
    
    public init() {}
    
    public func toggleSidebar() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isSidebarCollapsed.toggle()
        }
    }
}

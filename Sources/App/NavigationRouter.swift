import SwiftUI
import Observation

public enum MainTab: String, CaseIterable, Identifiable {
    case coin = "Nghiên cứu"
    case market = "Thị trường"
    case settings = "Cài đặt"
    
    public var id: String { rawValue }
}

public enum CoinSubtab: String, CaseIterable, Identifiable {
    case overview = "Tổng quan"
    case chart = "Chart"
    case derivatives = "Phái sinh & Thanh lý"
    case tokenomics = "Tokenomics"
    case onchain = "On-chain"
    case smartMoney = "Smart Money"
    case project = "Dự án"
    case securityLegal = "Bảo mật & Pháp lý"
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

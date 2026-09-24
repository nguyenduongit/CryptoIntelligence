import SwiftUI

public enum DataSourceType: String, Sendable, Codable {
    case liveBinance = "Live Binance Spot"
    case realTimeAlgorithm = "Thuật Toán Live"
    case simulatedCatalog = "Dữ Liệu Mô Phỏng"
    case macroSnapshot = "Snapshot Thống Kê"
    
    public var iconName: String {
        switch self {
        case .liveBinance: return "dot.radiowaves.left.and.right"
        case .realTimeAlgorithm: return "cpu.fill"
        case .simulatedCatalog: return "flask.fill"
        case .macroSnapshot: return "calendar.badge.clock"
        }
    }
    
    public var color: Color {
        switch self {
        case .liveBinance: return AppTheme.upGreen
        case .realTimeAlgorithm: return AppTheme.accentBlue
        case .simulatedCatalog: return AppTheme.warningYellow
        case .macroSnapshot: return Color.purple
        }
    }
}

public struct DataSourceBadge: View {
    public let type: DataSourceType
    public var text: String? = nil
    
    public init(type: DataSourceType, text: String? = nil) {
        self.type = type
        self.text = text
    }
    
    public var body: some View {
        HStack(spacing: 4) {
            Image(systemName: type.iconName)
                .font(.system(size: 8, weight: .bold))
            Text(text ?? type.rawValue)
                .font(.system(size: 9, weight: .semibold))
        }
        .foregroundColor(type.color)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(type.color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(type.color.opacity(0.25), lineWidth: 0.8)
        )
    }
}

import SwiftUI

public enum DataSourceType: String, Sendable, Codable {
    case liveBinance = "Live Binance API"
    case liveCoinGecko = "Live CoinGecko API"
    case liveDeFiLlama = "Live DeFiLlama API"
    case realTimeAlgorithm = "Thuật Toán Real-Time"
    case verifiedIntelligence = "Hồ Sơ On-Chain & Pháp Lý"
    case simulatedCatalog = "Dữ Liệu Kiểm Chứng"
    case macroSnapshot = "Dữ Liệu Vĩ Mô Toàn Cầu"
    
    public var iconName: String {
        switch self {
        case .liveBinance: return "dot.radiowaves.left.and.right"
        case .liveCoinGecko: return "chart.line.uptrend.xyaxis.circle.fill"
        case .liveDeFiLlama: return "link.circle.fill"
        case .realTimeAlgorithm: return "cpu.fill"
        case .verifiedIntelligence: return "checkmark.seal.fill"
        case .simulatedCatalog: return "doc.text.magnifyingglass"
        case .macroSnapshot: return "globe.americas.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .liveBinance: return AppTheme.upGreen
        case .liveCoinGecko: return AppTheme.accentBlue
        case .liveDeFiLlama: return Color.orange
        case .realTimeAlgorithm: return AppTheme.accentCyan
        case .verifiedIntelligence: return Color.purple
        case .simulatedCatalog: return AppTheme.upGreen
        case .macroSnapshot: return Color.indigo
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

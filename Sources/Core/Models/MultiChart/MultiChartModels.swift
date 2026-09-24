import Foundation
import SwiftUI

// MARK: - Multi-Chart Layout Modes
public enum MultiChartLayout: String, Sendable, Codable, CaseIterable, Identifiable {
    case single = "Đơn Biểu Đồ (Single)"
    case splitVertical = "2 Cột (2x1 Side-by-Side)"
    case splitHorizontal = "2 Hàng (1x2 Stacked)"
    case grid2x2 = "Lưới 4 Biểu Đồ (2x2 Grid)"
    case focusOnePlusThree = "1 Chính + 3 Phụ (1+3 Layout)"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .single: return "rectangle.fill"
        case .splitVertical: return "rectangle.split.2x1.fill"
        case .splitHorizontal: return "rectangle.split.1x2.fill"
        case .grid2x2: return "rectangle.split.2x2.fill"
        case .focusOnePlusThree: return "rectangle.split.3x1.fill"
        }
    }
}

// MARK: - Pane Configuration
public struct MultiChartPaneConfig: Identifiable, Sendable, Codable, Equatable {
    public let id: String
    public var symbol: String
    public var timeframe: Timeframe
    public var showRelativeStrengthToBTC: Bool
    
    public init(
        id: String = UUID().uuidString,
        symbol: String,
        timeframe: Timeframe = .h4,
        showRelativeStrengthToBTC: Bool = false
    ) {
        self.id = id
        self.symbol = symbol
        self.timeframe = timeframe
        self.showRelativeStrengthToBTC = showRelativeStrengthToBTC
    }
}

// MARK: - Relative Strength Model
public enum RelativePerformanceGrade: String, Sendable, Codable, CaseIterable {
    case strongOutperformance = "Tăng Vượt Trội BTC (Strong Alpha)"
    case moderateOutperformance = "Mạnh Hơn BTC (Moderate Alpha)"
    case inLine = "Đi Cùng Pha BTC (In-Line)"
    case underperformance = "Yếu Hơn BTC (Lagging Beta)"
    
    public var color: Color {
        switch self {
        case .strongOutperformance: return AppTheme.cyan
        case .moderateOutperformance: return AppTheme.upGreen
        case .inLine: return Color.white.opacity(0.7)
        case .underperformance: return AppTheme.downRed
        }
    }
}

public struct RelativeStrengthItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(timestamp)" }
    public let timestamp: Int64
    public let assetPriceUSD: Double
    public let btcPriceUSD: Double
    public let ratio: Double // assetPrice / btcPrice (e.g. 0.00227 SOL/BTC)
    public let changePercentSinceBase: Double // % outperformance vs base candle
    
    public init(
        timestamp: Int64,
        assetPriceUSD: Double,
        btcPriceUSD: Double,
        ratio: Double,
        changePercentSinceBase: Double
    ) {
        self.timestamp = timestamp
        self.assetPriceUSD = assetPriceUSD
        self.btcPriceUSD = btcPriceUSD
        self.ratio = ratio
        self.changePercentSinceBase = changePercentSinceBase
    }
}

public struct RelativeStrengthSummary: Sendable, Codable, Equatable {
    public let symbol: String
    public let baseAsset: String
    public let benchmarkSymbol: String // e.g. "BTCUSDT"
    public let currentRatio: Double
    public let change7dPercent: Double
    public let change30dPercent: Double
    public let performanceGrade: RelativePerformanceGrade
    public let history: [RelativeStrengthItem]
    public let isLiveCandleData: Bool
    
    public init(
        symbol: String,
        baseAsset: String,
        benchmarkSymbol: String = "BTCUSDT",
        currentRatio: Double,
        change7dPercent: Double,
        change30dPercent: Double,
        performanceGrade: RelativePerformanceGrade,
        history: [RelativeStrengthItem],
        isLiveCandleData: Bool = false
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.benchmarkSymbol = benchmarkSymbol
        self.currentRatio = currentRatio
        self.change7dPercent = change7dPercent
        self.change30dPercent = change30dPercent
        self.performanceGrade = performanceGrade
        self.history = history
        self.isLiveCandleData = isLiveCandleData
    }
}

import Foundation

public enum DrawingToolType: String, CaseIterable, Identifiable, Sendable, Codable {
    case cursor = "Con trỏ"
    case trendline = "Đường xu hướng"
    case horizontalLine = "Đường ngang"
    case priceRuler = "Thước đo giá"
    case fibonacci = "Fibonacci"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .cursor: return "arrow.up.left"
        case .trendline: return "line.diagonal"
        case .horizontalLine: return "line.horizontal.3"
        case .priceRuler: return "ruler"
        case .fibonacci: return "chart.bar.xaxis"
        }
    }
}

public struct CandlePoint: Sendable, Codable, Equatable {
    public var openTime: Int64
    public var price: Double
    
    public init(openTime: Int64, price: Double) {
        self.openTime = openTime
        self.price = price
    }
}

public struct DrawingElement: Identifiable, Sendable, Codable, Equatable {
    public var id: UUID
    public var symbol: String
    public var type: DrawingToolType
    public var startPoint: CandlePoint
    public var endPoint: CandlePoint?
    public var colorHex: String
    public var isCompleted: Bool
    
    public init(
        id: UUID = UUID(),
        symbol: String,
        type: DrawingToolType,
        startPoint: CandlePoint,
        endPoint: CandlePoint? = nil,
        colorHex: String = "#3B82F6",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.symbol = symbol
        self.type = type
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.colorHex = colorHex
        self.isCompleted = isCompleted
    }
}

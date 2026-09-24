import Foundation
import GRDB

public struct DrawingRecord: Codable, FetchableRecord, PersistableRecord {
    public static let databaseTableName = "drawings"
    
    public var id: String
    public var symbol: String
    public var type: String
    public var startTime: Int64
    public var startPrice: Double
    public var endTime: Int64?
    public var endPrice: Double?
    public var colorHex: String
    public var isCompleted: Bool
    
    public init(element: DrawingElement) {
        self.id = element.id.uuidString
        self.symbol = element.symbol
        self.type = element.type.rawValue
        self.startTime = element.startPoint.openTime
        self.startPrice = element.startPoint.price
        self.endTime = element.endPoint?.openTime
        self.endPrice = element.endPoint?.price
        self.colorHex = element.colorHex
        self.isCompleted = element.isCompleted
    }
    
    public func toModel() -> DrawingElement? {
        guard let toolType = DrawingToolType(rawValue: type),
              let uuid = UUID(uuidString: id) else { return nil }
        
        var endPoint: CandlePoint? = nil
        if let et = endTime, let ep = endPrice {
            endPoint = CandlePoint(openTime: et, price: ep)
        }
        
        return DrawingElement(
            id: uuid,
            symbol: symbol,
            type: toolType,
            startPoint: CandlePoint(openTime: startTime, price: startPrice),
            endPoint: endPoint,
            colorHex: colorHex,
            isCompleted: isCompleted
        )
    }
}

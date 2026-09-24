import Foundation
import GRDB

public struct ResearchNoteRecord: Codable, FetchableRecord, PersistableRecord, Sendable {
    public static let databaseTableName = "research_notes"
    
    public var id: String
    public var symbol: String
    public var title: String
    public var content: String
    public var sentiment: String
    public var tagsJson: String
    public var targetPrice: Double?
    public var stopLoss: Double?
    public var timeHorizon: String
    public var isPinned: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(note: ResearchNote) {
        self.id = note.id.uuidString
        self.symbol = note.symbol
        self.title = note.title
        self.content = note.content
        self.sentiment = note.sentiment.rawValue
        
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(note.tags), let str = String(data: data, encoding: .utf8) {
            self.tagsJson = str
        } else {
            self.tagsJson = "[]"
        }
        
        self.targetPrice = note.targetPrice
        self.stopLoss = note.stopLoss
        self.timeHorizon = note.timeHorizon
        self.isPinned = note.isPinned
        self.createdAt = note.createdAt
        self.updatedAt = note.updatedAt
    }
    
    public func toModel() -> ResearchNote? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        let parsedSentiment = ResearchSentiment(rawValue: sentiment) ?? .bullish
        
        var parsedTags: [String] = []
        if let data = tagsJson.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([String].self, from: data) {
            parsedTags = decoded
        }
        
        return ResearchNote(
            id: uuid,
            symbol: symbol,
            title: title,
            content: content,
            sentiment: parsedSentiment,
            tags: parsedTags,
            targetPrice: targetPrice,
            stopLoss: stopLoss,
            timeHorizon: timeHorizon,
            isPinned: isPinned,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}

import Foundation
import SwiftUI

public enum ResearchSentiment: String, Sendable, Codable, CaseIterable {
    case bullish = "Tăng giá (Bullish)"
    case neutral = "Trung lập (Neutral)"
    case bearish = "Giảm giá (Bearish)"
    
    public var shortLabel: String {
        switch self {
        case .bullish: return "Bullish"
        case .neutral: return "Neutral"
        case .bearish: return "Bearish"
        }
    }
    
    public var iconName: String {
        switch self {
        case .bullish: return "arrow.up.right.circle.fill"
        case .neutral: return "minus.circle.fill"
        case .bearish: return "arrow.down.right.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .bullish: return AppTheme.upGreen
        case .neutral: return Color(red: 0.95, green: 0.75, blue: 0.1)
        case .bearish: return AppTheme.downRed
        }
    }
}

public struct ResearchNote: Identifiable, Sendable, Codable, Equatable {
    public let id: UUID
    public var symbol: String
    public var title: String
    public var content: String
    public var sentiment: ResearchSentiment
    public var tags: [String]
    public var targetPrice: Double?
    public var stopLoss: Double?
    public var timeHorizon: String
    public var isPinned: Bool
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        symbol: String,
        title: String,
        content: String,
        sentiment: ResearchSentiment = .bullish,
        tags: [String] = [],
        targetPrice: Double? = nil,
        stopLoss: Double? = nil,
        timeHorizon: String = "Trung hạn (1-6 tháng)",
        isPinned: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.symbol = symbol
        self.title = title
        self.content = content
        self.sentiment = sentiment
        self.tags = tags
        self.targetPrice = targetPrice
        self.stopLoss = stopLoss
        self.timeHorizon = timeHorizon
        self.isPinned = isPinned
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

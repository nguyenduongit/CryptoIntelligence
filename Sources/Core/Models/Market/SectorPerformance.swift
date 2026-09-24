import Foundation

public struct SectorPerformance: Identifiable, Sendable, Codable, Equatable {
    public var id: String { sector.rawValue }
    
    public let sector: CryptoSector
    public var avgChangePercent: Double
    public var totalQuoteVolume: Double
    public var gainersCount: Int
    public var losersCount: Int
    public var tokenCount: Int
    public var topGainerSymbol: String?
    public var topGainerChangePercent: Double?
    
    public var isBullish: Bool {
        avgChangePercent >= 0
    }
    
    public init(
        sector: CryptoSector,
        avgChangePercent: Double,
        totalQuoteVolume: Double,
        gainersCount: Int,
        losersCount: Int,
        tokenCount: Int,
        topGainerSymbol: String? = nil,
        topGainerChangePercent: Double? = nil
    ) {
        self.sector = sector
        self.avgChangePercent = avgChangePercent
        self.totalQuoteVolume = totalQuoteVolume
        self.gainersCount = gainersCount
        self.losersCount = losersCount
        self.tokenCount = tokenCount
        self.topGainerSymbol = topGainerSymbol
        self.topGainerChangePercent = topGainerChangePercent
    }
}

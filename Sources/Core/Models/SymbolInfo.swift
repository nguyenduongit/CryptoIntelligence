import Foundation

public struct SymbolInfo: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    
    public let symbol: String
    public let status: String
    public let baseAsset: String
    public let quoteAsset: String
    public let baseAssetPrecision: Int
    public let quotePrecision: Int
    public let tickSize: Double
    public let stepSize: Double
    
    public init(
        symbol: String,
        status: String,
        baseAsset: String,
        quoteAsset: String,
        baseAssetPrecision: Int,
        quotePrecision: Int,
        tickSize: Double,
        stepSize: Double
    ) {
        self.symbol = symbol
        self.status = status
        self.baseAsset = baseAsset
        self.quoteAsset = quoteAsset
        self.baseAssetPrecision = baseAssetPrecision
        self.quotePrecision = quotePrecision
        self.tickSize = tickSize
        self.stepSize = stepSize
    }
}

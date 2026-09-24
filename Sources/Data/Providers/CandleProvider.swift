import Foundation

public protocol CandleProvider: Sendable {
    func fetchHistoricalCandles(
        symbol: String,
        timeframe: Timeframe,
        limit: Int,
        endTime: Int64?
    ) async throws -> [Candle]
    
    func fetchExchangeInfo() async throws -> [SymbolInfo]
    
    func fetch24hrTicker(symbol: String) async throws -> (price: Double, changePercent: Double, volume: Double)
}

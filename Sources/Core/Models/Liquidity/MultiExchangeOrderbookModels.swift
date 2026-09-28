import Foundation
import SwiftUI

// MARK: - Exchange Venue
public enum ExchangeVenue: String, Sendable, Codable, CaseIterable, Identifiable {
    case binance = "Binance"
    case okx = "OKX"
    case bybit = "Bybit"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .binance: return Color(red: 0.95, green: 0.73, blue: 0.18) // Binance Gold
        case .okx: return .white
        case .bybit: return Color(red: 0.97, green: 0.65, blue: 0.0) // Bybit Orange
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .binance: return Color.yellow.opacity(0.18)
        case .okx: return Color.blue.opacity(0.18)
        case .bybit: return Color.orange.opacity(0.18)
        }
    }
}

// MARK: - Orderbook Level
public struct OrderbookLevel: Sendable, Codable, Equatable, Identifiable {
    public var id: String { "\(exchange.rawValue)_\(price)" }
    public let price: Double
    public let amountToken: Double
    public let amountUSD: Double
    public let exchange: ExchangeVenue
    
    public init(price: Double, amountToken: Double, amountUSD: Double, exchange: ExchangeVenue) {
        self.price = price
        self.amountToken = amountToken
        self.amountUSD = amountUSD
        self.exchange = exchange
    }
}

// MARK: - Exchange Depth Summary
public struct ExchangeDepthSummary: Sendable, Codable, Equatable, Identifiable {
    public var id: String { exchange.rawValue }
    public let exchange: ExchangeVenue
    public let bidDepthUSD: Double
    public let askDepthUSD: Double
    public let spreadUSD: Double
    public let spreadBps: Double
    public let sharePercent: Double
    
    public init(
        exchange: ExchangeVenue,
        bidDepthUSD: Double,
        askDepthUSD: Double,
        spreadUSD: Double,
        spreadBps: Double,
        sharePercent: Double
    ) {
        self.exchange = exchange
        self.bidDepthUSD = bidDepthUSD
        self.askDepthUSD = askDepthUSD
        self.spreadUSD = spreadUSD
        self.spreadBps = spreadBps
        self.sharePercent = sharePercent
    }
}

// MARK: - Aggregated Orderbook
public struct AggregatedOrderbook: Sendable, Codable, Equatable {
    public let symbol: String
    public let timestamp: Date
    public let bids: [OrderbookLevel] // Sorted descending price
    public let asks: [OrderbookLevel] // Sorted ascending price
    public let bestBidPrice: Double
    public let bestAskPrice: Double
    public let midPrice: Double
    public let aggregatedSpreadUSD: Double
    public let aggregatedSpreadBps: Double
    public let totalBidDepthUSD: Double
    public let totalAskDepthUSD: Double
    public let depth1PercentUSD: Double // Total liquidity within 1% of midPrice
    public let depth2PercentUSD: Double // Total liquidity within 2% of midPrice
    public let exchangeSummaries: [ExchangeDepthSummary]
    
    public init(
        symbol: String,
        timestamp: Date,
        bids: [OrderbookLevel],
        asks: [OrderbookLevel],
        bestBidPrice: Double,
        bestAskPrice: Double,
        midPrice: Double,
        aggregatedSpreadUSD: Double,
        aggregatedSpreadBps: Double,
        totalBidDepthUSD: Double,
        totalAskDepthUSD: Double,
        depth1PercentUSD: Double,
        depth2PercentUSD: Double,
        exchangeSummaries: [ExchangeDepthSummary]
    ) {
        self.symbol = symbol
        self.timestamp = timestamp
        self.bids = bids
        self.asks = asks
        self.bestBidPrice = bestBidPrice
        self.bestAskPrice = bestAskPrice
        self.midPrice = midPrice
        self.aggregatedSpreadUSD = aggregatedSpreadUSD
        self.aggregatedSpreadBps = aggregatedSpreadBps
        self.totalBidDepthUSD = totalBidDepthUSD
        self.totalAskDepthUSD = totalAskDepthUSD
        self.depth1PercentUSD = depth1PercentUSD
        self.depth2PercentUSD = depth2PercentUSD
        self.exchangeSummaries = exchangeSummaries
    }
}

// MARK: - Execution Order Side
public enum ExecutionOrderSide: String, Sendable, Codable, CaseIterable, Identifiable {
    case buy = "Lệnh Mua (Buy)"
    case sell = "Lệnh Bán (Sell)"
    
    public var id: String { rawValue }
    
    public var color: Color {
        switch self {
        case .buy: return AppTheme.upGreen
        case .sell: return AppTheme.downRed
        }
    }
}

// MARK: - Smart Routing Allocation
public struct SmartRoutingAllocation: Sendable, Codable, Equatable, Identifiable {
    public var id: String { exchange.rawValue }
    public let exchange: ExchangeVenue
    public let allocatedAmountUSD: Double
    public let allocatedSharePercent: Double
    public let averagePrice: Double
    
    public init(exchange: ExchangeVenue, allocatedAmountUSD: Double, allocatedSharePercent: Double, averagePrice: Double) {
        self.exchange = exchange
        self.allocatedAmountUSD = allocatedAmountUSD
        self.allocatedSharePercent = allocatedSharePercent
        self.averagePrice = averagePrice
    }
}

// MARK: - TWAP Execution Plan
public struct TWAPExecutionPlan: Sendable, Codable, Equatable {
    public let totalAmountUSD: Double
    public let side: ExecutionOrderSide
    public let numberOfSlices: Int
    public let sliceAmountUSD: Double
    public let intervalSeconds: Int
    public let totalDurationMinutes: Int
    public let targetParticipationRatePercent: Double
    public let estimatedTWAPSlippagePercent: Double
    public let estimatedSlippageSavingsUSD: Double
    public let routingAllocations: [SmartRoutingAllocation]
    
    public init(
        totalAmountUSD: Double,
        side: ExecutionOrderSide,
        numberOfSlices: Int,
        sliceAmountUSD: Double,
        intervalSeconds: Int,
        totalDurationMinutes: Int,
        targetParticipationRatePercent: Double,
        estimatedTWAPSlippagePercent: Double,
        estimatedSlippageSavingsUSD: Double,
        routingAllocations: [SmartRoutingAllocation]
    ) {
        self.totalAmountUSD = totalAmountUSD
        self.side = side
        self.numberOfSlices = numberOfSlices
        self.sliceAmountUSD = sliceAmountUSD
        self.intervalSeconds = intervalSeconds
        self.totalDurationMinutes = totalDurationMinutes
        self.targetParticipationRatePercent = targetParticipationRatePercent
        self.estimatedTWAPSlippagePercent = estimatedTWAPSlippagePercent
        self.estimatedSlippageSavingsUSD = estimatedSlippageSavingsUSD
        self.routingAllocations = routingAllocations
    }
}

// MARK: - Market Impact Simulation Result
public struct MarketImpactSimulationResult: Sendable, Codable, Equatable {
    public let capitalAmountUSD: Double
    public let side: ExecutionOrderSide
    public let singleExchangeSlippagePercent: Double
    public let aggregatedSlippagePercent: Double
    public let singleExchangeFillPrice: Double
    public let aggregatedFillPrice: Double
    public let instantCostOfSlippageUSD: Double
    public let smartRoutingSavingsUSD: Double
    public let twapPlan: TWAPExecutionPlan
    
    public init(
        capitalAmountUSD: Double,
        side: ExecutionOrderSide,
        singleExchangeSlippagePercent: Double,
        aggregatedSlippagePercent: Double,
        singleExchangeFillPrice: Double,
        aggregatedFillPrice: Double,
        instantCostOfSlippageUSD: Double,
        smartRoutingSavingsUSD: Double,
        twapPlan: TWAPExecutionPlan
    ) {
        self.capitalAmountUSD = capitalAmountUSD
        self.side = side
        self.singleExchangeSlippagePercent = singleExchangeSlippagePercent
        self.aggregatedSlippagePercent = aggregatedSlippagePercent
        self.singleExchangeFillPrice = singleExchangeFillPrice
        self.aggregatedFillPrice = aggregatedFillPrice
        self.instantCostOfSlippageUSD = instantCostOfSlippageUSD
        self.smartRoutingSavingsUSD = smartRoutingSavingsUSD
        self.twapPlan = twapPlan
    }
}

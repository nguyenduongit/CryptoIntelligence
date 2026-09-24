import Foundation
import SwiftUI

public enum WhaleTxType: String, Sendable, Codable, CaseIterable {
    case exchangeInflow = "Nạp lên sàn (Inflow)"
    case exchangeOutflow = "Rút khỏi sàn (Outflow)"
    case whaleToWhale = "Chuyển ví cá voi (Whale Transfer)"
    case internalTransfer = "Chuyển nội bộ (Internal)"
    
    public var iconName: String {
        switch self {
        case .exchangeInflow: return "arrow.down.right.circle.fill"
        case .exchangeOutflow: return "arrow.up.left.circle.fill"
        case .whaleToWhale: return "arrow.left.and.right.circle.fill"
        case .internalTransfer: return "arrow.triangle.swap"
        }
    }
    
    public var color: Color {
        switch self {
        case .exchangeInflow: return Color(red: 0.95, green: 0.3, blue: 0.3) // Red - potential selling pressure
        case .exchangeOutflow: return Color(red: 0.1, green: 0.8, blue: 0.4) // Green - accumulation
        case .whaleToWhale: return Color(red: 0.2, green: 0.6, blue: 0.95)
        case .internalTransfer: return Color.white.opacity(0.6)
        }
    }
}

public struct WhaleTransaction: Identifiable, Sendable, Codable, Equatable {
    public let id: String // txHash
    public let timestamp: Date
    public let amountToken: Double
    public var amountUSD: Double
    public let fromLabel: String
    public let toLabel: String
    public let type: WhaleTxType
    
    public init(
        id: String,
        timestamp: Date,
        amountToken: Double,
        amountUSD: Double,
        fromLabel: String,
        toLabel: String,
        type: WhaleTxType
    ) {
        self.id = id
        self.timestamp = timestamp
        self.amountToken = amountToken
        self.amountUSD = amountUSD
        self.fromLabel = fromLabel
        self.toLabel = toLabel
        self.type = type
    }
}

public struct ExchangeFlowMetrics: Sendable, Codable, Equatable {
    public var netFlow24hUSD: Double // positive = Net Inflow (Bearish), negative = Net Outflow (Bullish)
    public var inflow24hUSD: Double
    public var outflow24hUSD: Double
    public var exchangeReserveTotal: Double
    public var exchangeReserveChange7dPercent: Double
    
    public var isAccumulation: Bool {
        netFlow24hUSD < 0
    }
    
    public init(
        netFlow24hUSD: Double,
        inflow24hUSD: Double,
        outflow24hUSD: Double,
        exchangeReserveTotal: Double,
        exchangeReserveChange7dPercent: Double
    ) {
        self.netFlow24hUSD = netFlow24hUSD
        self.inflow24hUSD = inflow24hUSD
        self.outflow24hUSD = outflow24hUSD
        self.exchangeReserveTotal = exchangeReserveTotal
        self.exchangeReserveChange7dPercent = exchangeReserveChange7dPercent
    }
}

public struct NetworkActivityMetrics: Sendable, Codable, Equatable {
    public var dailyActiveAddresses: Int
    public var daaChange7dPercent: Double
    public var dailyTransactionsCount: Int
    public var averageGasFeeUSD: Double?
    public var totalValueLockedUSD: Double?
    public var nvtRatio: Double? // Network Value to Transactions
    
    public init(
        dailyActiveAddresses: Int,
        daaChange7dPercent: Double,
        dailyTransactionsCount: Int,
        averageGasFeeUSD: Double? = nil,
        totalValueLockedUSD: Double? = nil,
        nvtRatio: Double? = nil
    ) {
        self.dailyActiveAddresses = dailyActiveAddresses
        self.daaChange7dPercent = daaChange7dPercent
        self.dailyTransactionsCount = dailyTransactionsCount
        self.averageGasFeeUSD = averageGasFeeUSD
        self.totalValueLockedUSD = totalValueLockedUSD
        self.nvtRatio = nvtRatio
    }
}

public struct HolderConcentrationMetrics: Sendable, Codable, Equatable {
    public var top10HoldersPercent: Double
    public var top50HoldersPercent: Double
    public var top100HoldersPercent: Double
    public var retailHoldersPercent: Double
    public var totalHoldersCount: Int
    public var holdersGrowth30d: Double
    
    public init(
        top10HoldersPercent: Double,
        top50HoldersPercent: Double,
        top100HoldersPercent: Double,
        retailHoldersPercent: Double,
        totalHoldersCount: Int,
        holdersGrowth30d: Double
    ) {
        self.top10HoldersPercent = top10HoldersPercent
        self.top50HoldersPercent = top50HoldersPercent
        self.top100HoldersPercent = top100HoldersPercent
        self.retailHoldersPercent = retailHoldersPercent
        self.totalHoldersCount = totalHoldersCount
        self.holdersGrowth30d = holdersGrowth30d
    }
}

public struct OnChainProfile: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public let networkName: String
    public var exchangeFlow: ExchangeFlowMetrics
    public var networkActivity: NetworkActivityMetrics
    public var holderConcentration: HolderConcentrationMetrics
    public var recentWhaleTransactions: [WhaleTransaction]
    public var onChainHealthScore: Int // 0..100
    public var onChainHealthLabel: String
    public var onChainSummary: String
    public var cycleMetrics: MVRVCycleMetrics?
    public var lthSupply: LTHSupplyMetrics?
    public var spotETFFlows: SpotETFFlowSummary?
    public var entityHoldings: [EntityWhaleHolding]?
    
    public init(
        symbol: String,
        baseAsset: String,
        networkName: String,
        exchangeFlow: ExchangeFlowMetrics,
        networkActivity: NetworkActivityMetrics,
        holderConcentration: HolderConcentrationMetrics,
        recentWhaleTransactions: [WhaleTransaction],
        onChainHealthScore: Int,
        onChainHealthLabel: String,
        onChainSummary: String,
        cycleMetrics: MVRVCycleMetrics? = nil,
        lthSupply: LTHSupplyMetrics? = nil,
        spotETFFlows: SpotETFFlowSummary? = nil,
        entityHoldings: [EntityWhaleHolding]? = nil
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.networkName = networkName
        self.exchangeFlow = exchangeFlow
        self.networkActivity = networkActivity
        self.holderConcentration = holderConcentration
        self.recentWhaleTransactions = recentWhaleTransactions
        self.onChainHealthScore = onChainHealthScore
        self.onChainHealthLabel = onChainHealthLabel
        self.onChainSummary = onChainSummary
        self.cycleMetrics = cycleMetrics
        self.lthSupply = lthSupply
        self.spotETFFlows = spotETFFlows
        self.entityHoldings = entityHoldings
    }
}

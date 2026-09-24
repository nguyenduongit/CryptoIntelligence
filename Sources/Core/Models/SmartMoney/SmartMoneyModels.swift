import Foundation
import SwiftUI

public enum VCHoldingStatus: String, Sendable, Codable, CaseIterable {
    case accumulating = "Đang tích lũy thêm"
    case holding = "Đang nắm giữ vị thế"
    case partiallyRealized = "Đã chốt lời một phần"
    case fullyExited = "Đã thoái vốn"
    
    public var color: Color {
        switch self {
        case .accumulating: return Color(red: 0.1, green: 0.8, blue: 0.4)
        case .holding: return Color(red: 0.2, green: 0.6, blue: 0.95)
        case .partiallyRealized: return Color(red: 0.95, green: 0.75, blue: 0.1)
        case .fullyExited: return Color.white.opacity(0.5)
        }
    }
}

public enum DEXSwapType: String, Sendable, Codable, CaseIterable {
    case buy = "Mua (Buy)"
    case sell = "Bán (Sell)"
    
    public var color: Color {
        switch self {
        case .buy: return Color(red: 0.1, green: 0.8, blue: 0.4)
        case .sell: return Color(red: 0.95, green: 0.3, blue: 0.3)
        }
    }
}

public struct VCBackerHolding: Identifiable, Sendable, Codable, Equatable {
    public var id: String { fundName }
    public let fundName: String
    public let fundTier: String // "Tier 1", "Tier 2", "Corporate"
    public let isLeadInvestor: Bool
    public let investmentRound: String
    public let estimatedHoldingUSD: Double
    public let roiMultiplier: Double
    public let status: VCHoldingStatus
    
    public init(
        fundName: String,
        fundTier: String = "Tier 1",
        isLeadInvestor: Bool = false,
        investmentRound: String,
        estimatedHoldingUSD: Double,
        roiMultiplier: Double,
        status: VCHoldingStatus
    ) {
        self.fundName = fundName
        self.fundTier = fundTier
        self.isLeadInvestor = isLeadInvestor
        self.investmentRound = investmentRound
        self.estimatedHoldingUSD = estimatedHoldingUSD
        self.roiMultiplier = roiMultiplier
        self.status = status
    }
}

public struct SmartMoneyDEXSwap: Identifiable, Sendable, Codable, Equatable {
    public let id: String // txHash
    public let timestamp: Date
    public let traderLabel: String
    public let type: DEXSwapType
    public let dexName: String
    public let amountToken: Double
    public var amountUSD: Double
    public let executionPriceUSD: Double
    
    public init(
        id: String,
        timestamp: Date,
        traderLabel: String,
        type: DEXSwapType,
        dexName: String,
        amountToken: Double,
        amountUSD: Double,
        executionPriceUSD: Double
    ) {
        self.id = id
        self.timestamp = timestamp
        self.traderLabel = traderLabel
        self.type = type
        self.dexName = dexName
        self.amountToken = amountToken
        self.amountUSD = amountUSD
        self.executionPriceUSD = executionPriceUSD
    }
}

public struct DEXLiquidityMetrics: Sendable, Codable, Equatable {
    public var totalLiquidityUSD: Double
    public var liquidity24hChangePercent: Double
    public var volume24hDEXUSD: Double
    public var topPoolPair: String
    public var volumeToLiquidityRatio: Double
    
    public init(
        totalLiquidityUSD: Double,
        liquidity24hChangePercent: Double,
        volume24hDEXUSD: Double,
        topPoolPair: String,
        volumeToLiquidityRatio: Double
    ) {
        self.totalLiquidityUSD = totalLiquidityUSD
        self.liquidity24hChangePercent = liquidity24hChangePercent
        self.volume24hDEXUSD = volume24hDEXUSD
        self.topPoolPair = topPoolPair
        self.volumeToLiquidityRatio = volumeToLiquidityRatio
    }
}

public struct SmartMoneySentimentSignal: Sendable, Codable, Equatable {
    public var score: Int // 0..100
    public var signalLabel: String
    public var netDEXVolume24hUSD: Double // positive = net buy, negative = net sell
    public var smartMoneyHoldersCount: Int
    public var smartHoldersChange7d: Int
    public var analysisSummary: String
    
    public var isBullish: Bool {
        score >= 60
    }
    
    public init(
        score: Int,
        signalLabel: String,
        netDEXVolume24hUSD: Double,
        smartMoneyHoldersCount: Int,
        smartHoldersChange7d: Int,
        analysisSummary: String
    ) {
        self.score = score
        self.signalLabel = signalLabel
        self.netDEXVolume24hUSD = netDEXVolume24hUSD
        self.smartMoneyHoldersCount = smartMoneyHoldersCount
        self.smartHoldersChange7d = smartHoldersChange7d
        self.analysisSummary = analysisSummary
    }
}

public struct SmartMoneyWalletLeader: Identifiable, Sendable, Codable, Equatable {
    public var id: String { address }
    public let address: String
    public let label: String // e.g. "0x7a25... (Legendary Trader)", "Jump Trading Sub-wallet"
    public let winRatePercent: Double // e.g. 78.5%
    public let pnl30dUSD: Double // e.g. +$1,420,000
    public let totalBalanceUSD: Double
    public let topHoldingAsset: String
    public let lastActiveAgo: String
    
    public init(
        address: String,
        label: String,
        winRatePercent: Double,
        pnl30dUSD: Double,
        totalBalanceUSD: Double,
        topHoldingAsset: String,
        lastActiveAgo: String
    ) {
        self.address = address
        self.label = label
        self.winRatePercent = winRatePercent
        self.pnl30dUSD = pnl30dUSD
        self.totalBalanceUSD = totalBalanceUSD
        self.topHoldingAsset = topHoldingAsset
        self.lastActiveAgo = lastActiveAgo
    }
}

public struct FreshWalletAlert: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(address)_\(timestamp.timeIntervalSince1970)" }
    public let address: String
    public let ageHours: Int // e.g. 24h
    public let sourceExchange: String // e.g. "Binance Hot Wallet 6"
    public let accumulatedAmountUSD: Double
    public let averageEntryPrice: Double
    public let timestamp: Date
    
    public init(
        address: String,
        ageHours: Int,
        sourceExchange: String,
        accumulatedAmountUSD: Double,
        averageEntryPrice: Double,
        timestamp: Date = Date()
    ) {
        self.address = address
        self.ageHours = ageHours
        self.sourceExchange = sourceExchange
        self.accumulatedAmountUSD = accumulatedAmountUSD
        self.averageEntryPrice = averageEntryPrice
        self.timestamp = timestamp
    }
}

public struct SmartMoneyProfile: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public var sentimentSignal: SmartMoneySentimentSignal
    public var vcBackers: [VCBackerHolding]
    public var dexLiquidity: DEXLiquidityMetrics
    public var recentDEXSwaps: [SmartMoneyDEXSwap]
    public var topWallets: [SmartMoneyWalletLeader]
    public var freshWallets: [FreshWalletAlert]
    
    public init(
        symbol: String,
        baseAsset: String,
        sentimentSignal: SmartMoneySentimentSignal,
        vcBackers: [VCBackerHolding],
        dexLiquidity: DEXLiquidityMetrics,
        recentDEXSwaps: [SmartMoneyDEXSwap],
        topWallets: [SmartMoneyWalletLeader] = [],
        freshWallets: [FreshWalletAlert] = []
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.sentimentSignal = sentimentSignal
        self.vcBackers = vcBackers
        self.dexLiquidity = dexLiquidity
        self.recentDEXSwaps = recentDEXSwaps
        self.topWallets = topWallets
        self.freshWallets = freshWallets
    }
}

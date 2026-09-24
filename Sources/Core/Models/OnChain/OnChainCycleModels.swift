import Foundation
import SwiftUI

// MARK: - MVRV & Valuation Cycle Metrics
public struct MVRVCycleMetrics: Sendable, Codable, Equatable {
    public var mvrvZScore: Double // e.g. 2.14
    public var realizedPriceUSD: Double // e.g. 34,850.0
    public var currentPriceUSD: Double // e.g. 66,400.0
    public var nupl: Double // Net Unrealized Profit/Loss 0..1 (e.g. 0.52)
    public var puellMultiple: Double // e.g. 1.15
    public var piCycle111DMA: Double // e.g. 64,200.0
    public var piCycle2x350DMA: Double // e.g. 98,400.0
    public var cyclePhase: String // "Tích lũy tăng trưởng (Mid-Bull Accumulation)"
    public var cycleRiskScore: Double // 0.0 to 1.0 (e.g. 0.48 = Moderate Risk)
    
    public var mvrvRatio: Double {
        guard realizedPriceUSD > 0 else { return 1.0 }
        return currentPriceUSD / realizedPriceUSD
    }
    
    public var piCycleGapPercent: Double {
        guard piCycle111DMA > 0 else { return 0.0 }
        return ((piCycle2x350DMA - piCycle111DMA) / piCycle111DMA) * 100.0
    }
    
    public var isPiCycleCrossed: Bool {
        piCycle111DMA >= piCycle2x350DMA
    }
    
    public var nuplSentiment: (label: String, color: Color) {
        if nupl < 0 {
            return ("Đầu hàng / Capitulation (Đáy chu kỳ)", Color(red: 0.95, green: 0.3, blue: 0.3))
        } else if nupl < 0.25 {
            return ("Hy vọng / Sợ hãi (Hope / Fear)", Color(red: 0.95, green: 0.6, blue: 0.2))
        } else if nupl < 0.50 {
            return ("Lạc quan / Nghi ngờ (Optimism)", Color(red: 0.2, green: 0.7, blue: 0.9))
        } else if nupl < 0.75 {
            return ("Niềm tin / Hưng phấn vừa (Belief)", Color(red: 0.1, green: 0.8, blue: 0.4))
        } else {
            return ("Hưng phấn tột độ / Vùng đỉnh (Euphoria)", Color(red: 0.95, green: 0.2, blue: 0.2))
        }
    }
    
    public init(
        mvrvZScore: Double,
        realizedPriceUSD: Double,
        currentPriceUSD: Double,
        nupl: Double,
        puellMultiple: Double,
        piCycle111DMA: Double,
        piCycle2x350DMA: Double,
        cyclePhase: String,
        cycleRiskScore: Double
    ) {
        self.mvrvZScore = mvrvZScore
        self.realizedPriceUSD = realizedPriceUSD
        self.currentPriceUSD = currentPriceUSD
        self.nupl = nupl
        self.puellMultiple = puellMultiple
        self.piCycle111DMA = piCycle111DMA
        self.piCycle2x350DMA = piCycle2x350DMA
        self.cyclePhase = cyclePhase
        self.cycleRiskScore = cycleRiskScore
    }
}

// MARK: - LTH vs STH Supply Distribution
public struct LTHSupplyMetrics: Sendable, Codable, Equatable {
    public var longTermHolderSupply: Double // Coins held > 155 days (e.g. 14,820,000 BTC)
    public var shortTermHolderSupply: Double // Coins held < 155 days (e.g. 3,150,000 BTC)
    public var exchangeReserveSupply: Double // Coins held on exchanges (e.g. 1,820,000 BTC)
    public var totalSupply: Double // Total circulating supply (e.g. 19,790,000 BTC)
    public var lth30dNetChangeToken: Double // +42,500 BTC/month (Accumulation)
    public var sthRealizedPriceUSD: Double // e.g. $61,200.0 (Key bull market support)
    
    public var lthPercentage: Double {
        guard totalSupply > 0 else { return 0 }
        return (longTermHolderSupply / totalSupply) * 100.0
    }
    
    public var sthPercentage: Double {
        guard totalSupply > 0 else { return 0 }
        return (shortTermHolderSupply / totalSupply) * 100.0
    }
    
    public var exchangePercentage: Double {
        guard totalSupply > 0 else { return 0 }
        return (exchangeReserveSupply / totalSupply) * 100.0
    }
    
    public var isLTHAccumulating: Bool {
        lth30dNetChangeToken > 0
    }
    
    public init(
        longTermHolderSupply: Double,
        shortTermHolderSupply: Double,
        exchangeReserveSupply: Double,
        totalSupply: Double,
        lth30dNetChangeToken: Double,
        sthRealizedPriceUSD: Double
    ) {
        self.longTermHolderSupply = longTermHolderSupply
        self.shortTermHolderSupply = shortTermHolderSupply
        self.exchangeReserveSupply = exchangeReserveSupply
        self.totalSupply = totalSupply
        self.lth30dNetChangeToken = lth30dNetChangeToken
        self.sthRealizedPriceUSD = sthRealizedPriceUSD
    }
}

// MARK: - Spot ETF Flows Data Model
public struct DailyFlowDataPoint: Identifiable, Sendable, Codable, Equatable {
    public var id: String { dateString }
    public let dateString: String // e.g. "19/09"
    public let netFlowUSD: Double // in Millions USD (e.g. +158.2 or -45.6)
    
    public init(dateString: String, netFlowUSD: Double) {
        self.dateString = dateString
        self.netFlowUSD = netFlowUSD
    }
}

public struct SpotETFFlowItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { ticker }
    public let ticker: String // "IBIT"
    public let fundName: String // "iShares Bitcoin Trust"
    public let sponsor: String // "BlackRock"
    public let aumUSD: Double // Total AUM in USD (e.g. 24_800_000_000)
    public let btcHoldings: Double // e.g. 368,000 BTC
    public let netFlow24hUSD: Double // in USD (e.g. +125_400_000)
    public let netFlow24hBTC: Double // in BTC (e.g. +1,880)
    public let cumulativeNetInflowUSD: Double // e.g. 21_200_000_000
    public let feePercent: Double // e.g. 0.25%
    public let streakDays: Int // e.g. +7 days inflow
    
    public init(
        ticker: String,
        fundName: String,
        sponsor: String,
        aumUSD: Double,
        btcHoldings: Double,
        netFlow24hUSD: Double,
        netFlow24hBTC: Double,
        cumulativeNetInflowUSD: Double,
        feePercent: Double,
        streakDays: Int
    ) {
        self.ticker = ticker
        self.fundName = fundName
        self.sponsor = sponsor
        self.aumUSD = aumUSD
        self.btcHoldings = btcHoldings
        self.netFlow24hUSD = netFlow24hUSD
        self.netFlow24hBTC = netFlow24hBTC
        self.cumulativeNetInflowUSD = cumulativeNetInflowUSD
        self.feePercent = feePercent
        self.streakDays = streakDays
    }
}

public struct SpotETFFlowSummary: Sendable, Codable, Equatable {
    public var totalAUMUSD: Double // $65.4B
    public var totalBTCHeld: Double // 985,000 BTC (~5.0% of total supply)
    public var totalNetFlow24hUSD: Double // +$185.4M
    public var totalNetFlow24hBTC: Double // +2,780 BTC
    public var totalCumulativeInflowsUSD: Double // +$22.8B
    public var topInflowETF: String // "BlackRock (IBIT)"
    public var history14Days: [DailyFlowDataPoint]
    public var etfList: [SpotETFFlowItem]
    
    public init(
        totalAUMUSD: Double,
        totalBTCHeld: Double,
        totalNetFlow24hUSD: Double,
        totalNetFlow24hBTC: Double,
        totalCumulativeInflowsUSD: Double,
        topInflowETF: String,
        history14Days: [DailyFlowDataPoint],
        etfList: [SpotETFFlowItem]
    ) {
        self.totalAUMUSD = totalAUMUSD
        self.totalBTCHeld = totalBTCHeld
        self.totalNetFlow24hUSD = totalNetFlow24hUSD
        self.totalNetFlow24hBTC = totalNetFlow24hBTC
        self.totalCumulativeInflowsUSD = totalCumulativeInflowsUSD
        self.topInflowETF = topInflowETF
        self.history14Days = history14Days
        self.etfList = etfList
    }
}

// MARK: - Entity Attribution & Whale Directory
public enum EntityCategory: String, Sendable, Codable, CaseIterable {
    case corporate = "Doanh nghiệp (Corporate)"
    case government = "Chính phủ (Government)"
    case marketMaker = "Market Maker / VC"
    case custodian = "Quỹ lưu ký / ETF"
    case founder = "Tổ chức / Sáng lập"
    
    public var badgeColor: Color {
        switch self {
        case .corporate: return Color(red: 0.2, green: 0.6, blue: 0.95)
        case .government: return Color(red: 0.95, green: 0.55, blue: 0.2)
        case .marketMaker: return Color(red: 0.7, green: 0.4, blue: 0.95)
        case .custodian: return Color(red: 0.1, green: 0.8, blue: 0.4)
        case .founder: return Color.white.opacity(0.6)
        }
    }
}

public struct EntityWhaleHolding: Identifiable, Sendable, Codable, Equatable {
    public var id: String { entityName }
    public let entityName: String // "MicroStrategy"
    public let category: EntityCategory
    public let holdingsToken: Double // 252,220 BTC
    public let holdingsUSD: Double // $16.75B
    public let avgPurchasePriceUSD: Double? // $39,266
    public let unrealizedPnLUSD: Double? // +$6.85B
    public let change30dToken: Double // +18,300 BTC
    public let addressSnippet: String // "1P5ZEDWTKTFGx..."
    public let riskSignal: String // "Tích lũy mạnh mẽ dài hạn"
    
    public init(
        entityName: String,
        category: EntityCategory,
        holdingsToken: Double,
        holdingsUSD: Double,
        avgPurchasePriceUSD: Double?,
        unrealizedPnLUSD: Double?,
        change30dToken: Double,
        addressSnippet: String,
        riskSignal: String
    ) {
        self.entityName = entityName
        self.category = category
        self.holdingsToken = holdingsToken
        self.holdingsUSD = holdingsUSD
        self.avgPurchasePriceUSD = avgPurchasePriceUSD
        self.unrealizedPnLUSD = unrealizedPnLUSD
        self.change30dToken = change30dToken
        self.addressSnippet = addressSnippet
        self.riskSignal = riskSignal
    }
}

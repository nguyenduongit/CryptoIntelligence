import Foundation
import SwiftUI

public enum MacroIndexType: String, CaseIterable, Identifiable, Sendable, Codable {
    case total = "TOTAL"
    case total2 = "TOTAL2"
    case total3 = "TOTAL3"
    case btcD = "BTC.D"
    case ethD = "ETH.D"
    case stableD = "STABLE.D"
    case usdtD = "USDT.D"
    case othersD = "OTHERS.D"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .total: return "TOTAL (Tổng Vốn Hóa)"
        case .total2: return "TOTAL2 (Vốn Hóa Altcoin - Trừ BTC)"
        case .total3: return "TOTAL3 (Altcoin Vừa & Nhỏ - Trừ BTC & ETH)"
        case .btcD: return "BTC.D (Thị Phần Bitcoin)"
        case .ethD: return "ETH.D (Thị Phần Ethereum)"
        case .stableD: return "STABLE.D (Toàn Bộ Stablecoins: USDT, USDC, USDS...)"
        case .usdtD: return "USDT.D (Thị Phần Tether USDT)"
        case .othersD: return "OTHERS.D (Altcoins Ngoài Top 10)"
        }
    }
    
    public var shortName: String { rawValue }
    
    public var subtitle: String {
        switch self {
        case .total: return "Tổng quy mô toàn bộ thị trường Crypto"
        case .total2: return "Sức mạnh dòng tiền toàn bộ Altcoin"
        case .total3: return "Sức sống nhóm Mid-cap & Low-cap"
        case .btcD: return "Tỷ trọng chiếm lĩnh thị phần Bitcoin"
        case .ethD: return "Tỷ trọng chiếm lĩnh hệ sinh thái Ethereum"
        case .stableD: return "Tổng tiền mặt & quỹ thanh khoản toàn thị trường"
        case .usdtD: return "Thị phần riêng lẻ của Tether USDT"
        case .othersD: return "Tỷ trọng nhóm Altcoins nhỏ"
        }
    }
    
    public var iconName: String {
        switch self {
        case .total: return "chart.line.uptrend.xyaxis"
        case .total2: return "sparkles"
        case .total3: return "circle.grid.cross.fill"
        case .btcD: return "bitcoinsign.circle.fill"
        case .ethD: return "diamond.fill"
        case .stableD: return "banknote.fill"
        case .usdtD: return "dollarsign.circle.fill"
        case .othersD: return "square.stack.3d.up.fill"
        }
    }
    
    public var isPercentage: Bool {
        switch self {
        case .btcD, .ethD, .stableD, .usdtD, .othersD: return true
        case .total, .total2, .total3: return false
        }
    }
}

public struct StablecoinBreakdownItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let name: String
    public let circulatingUSD: Double
    public let dominancePercentage: Double // % of total crypto market cap
    public let shareOfStablesPercentage: Double // % of total stablecoins supply
    public let change7dPercent: Double
    public let iconName: String
    
    public init(
        symbol: String,
        name: String,
        circulatingUSD: Double,
        dominancePercentage: Double,
        shareOfStablesPercentage: Double,
        change7dPercent: Double,
        iconName: String = "dollarsign.circle.fill"
    ) {
        self.symbol = symbol
        self.name = name
        self.circulatingUSD = circulatingUSD
        self.dominancePercentage = dominancePercentage
        self.shareOfStablesPercentage = shareOfStablesPercentage
        self.change7dPercent = change7dPercent
        self.iconName = iconName
    }
}

public struct MacroIndexSnapshot: Identifiable, Sendable, Codable, Equatable {
    public var id: String { indexType.rawValue }
    public let indexType: MacroIndexType
    public let currentValue: Double
    public let change24h: Double
    public let change7d: Double
    public let formattedValue: String
    public let sparkline: [Double]
    
    public init(
        indexType: MacroIndexType,
        currentValue: Double,
        change24h: Double,
        change7d: Double,
        formattedValue: String,
        sparkline: [Double] = []
    ) {
        self.indexType = indexType
        self.currentValue = currentValue
        self.change24h = change24h
        self.change7d = change7d
        self.formattedValue = formattedValue
        self.sparkline = sparkline
    }
}

public enum MarketSeasonState: String, Sendable, Codable, CaseIterable {
    case bitcoinSeason = "Mùa Bitcoin (BTC Season)"
    case altcoinSeason = "Mùa Altcoin Bùng Nổ (Altseason)"
    case riskOffPanic = "Phòng Thủ / Rút Tiền Mặt (Risk-Off)"
    case capitalRotation = "Dòng Tiền Luân Chuyển Tích Lũy (Rotation)"
    
    public var iconName: String {
        switch self {
        case .bitcoinSeason: return "bitcoinsign.circle.fill"
        case .altcoinSeason: return "sparkles"
        case .riskOffPanic: return "shield.slash.fill"
        case .capitalRotation: return "arrow.triangle.2.circlepath"
        }
    }
    
    public var color: Color {
        switch self {
        case .bitcoinSeason: return AppTheme.orange
        case .altcoinSeason: return AppTheme.upGreen
        case .riskOffPanic: return AppTheme.downRed
        case .capitalRotation: return AppTheme.accentBlue
        }
    }
}

public struct MarketSeasonReport: Sendable, Codable, Equatable {
    public let currentState: MarketSeasonState
    public let altcoinSeasonIndex: Int // 0..100 (>75 = Altseason, <25 = BTC season)
    public let totalMarketCapUSD: Double
    public let altcoinMarketCapUSD: Double
    public let btcDPercentage: Double
    public let ethDPercentage: Double
    public let usdtDPercentage: Double
    public let stablecoinDominancePercentage: Double // e.g. 10.88% (All stablecoins combined)
    public let totalStablecoinLiquidityUSD: Double // e.g. $313.9B
    public let topStablecoins: [StablecoinBreakdownItem]
    public let actionableSummary: String
    
    public init(
        currentState: MarketSeasonState,
        altcoinSeasonIndex: Int,
        totalMarketCapUSD: Double,
        altcoinMarketCapUSD: Double,
        btcDPercentage: Double,
        ethDPercentage: Double = 11.32,
        usdtDPercentage: Double,
        stablecoinDominancePercentage: Double = 10.88,
        totalStablecoinLiquidityUSD: Double = 313_900_000_000,
        topStablecoins: [StablecoinBreakdownItem] = [],
        actionableSummary: String
    ) {
        self.currentState = currentState
        self.altcoinSeasonIndex = altcoinSeasonIndex
        self.totalMarketCapUSD = totalMarketCapUSD
        self.altcoinMarketCapUSD = altcoinMarketCapUSD
        self.btcDPercentage = btcDPercentage
        self.ethDPercentage = ethDPercentage
        self.usdtDPercentage = usdtDPercentage
        self.stablecoinDominancePercentage = stablecoinDominancePercentage
        self.totalStablecoinLiquidityUSD = totalStablecoinLiquidityUSD
        self.topStablecoins = topStablecoins
        self.actionableSummary = actionableSummary
    }
    
    // Backward compatibility accessor
    public var stablecoinLiquidityUSD: Double {
        totalStablecoinLiquidityUSD
    }
    
    public var usdtPercentage: Double {
        usdtDPercentage
    }
}

public struct MacroIndexCandle: Identifiable, Sendable, Codable, Equatable {
    public var id: Double { timestamp.timeIntervalSince1970 }
    public let timestamp: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Double
    
    public init(
        timestamp: Date,
        open: Double,
        high: Double,
        low: Double,
        close: Double,
        volume: Double
    ) {
        self.timestamp = timestamp
        self.open = open
        self.high = high
        self.low = low
        self.close = close
        self.volume = volume
    }
    
    public var isBullish: Bool { close >= open }
}

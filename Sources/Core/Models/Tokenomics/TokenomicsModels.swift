import Foundation
import SwiftUI

public enum UnlockType: String, Sendable, Codable, CaseIterable {
    case cliff = "Mở khóa một lần (Cliff)"
    case linear = "Mở khóa tuyến tính (Linear)"
}

public enum UnlockRiskLevel: String, Sendable, Codable, CaseIterable {
    case low = "Áp lực thấp"
    case medium = "Áp lực trung bình"
    case high = "Áp lực cao"
    case extreme = "Áp lực cực lớn"
    
    public var color: Color {
        switch self {
        case .low: return Color(red: 0.1, green: 0.8, blue: 0.4)
        case .medium: return Color(red: 0.95, green: 0.75, blue: 0.1)
        case .high: return Color(red: 0.95, green: 0.5, blue: 0.1)
        case .extreme: return Color(red: 0.95, green: 0.2, blue: 0.2)
        }
    }
}

public struct TokenSupplyMetrics: Sendable, Codable, Equatable {
    public var circulatingSupply: Double
    public var totalSupply: Double
    public var maxSupply: Double?
    public var marketCapUSD: Double
    public var fdvUSD: Double
    public var mcFdvRatio: Double // Circulating / Total or Max
    public var annualInflationRate: Double?
    public var isBurnActive: Bool
    public var burnedTokens: Double?
    
    public init(
        circulatingSupply: Double,
        totalSupply: Double,
        maxSupply: Double?,
        marketCapUSD: Double,
        fdvUSD: Double,
        mcFdvRatio: Double,
        annualInflationRate: Double? = nil,
        isBurnActive: Bool = false,
        burnedTokens: Double? = nil
    ) {
        self.circulatingSupply = circulatingSupply
        self.totalSupply = totalSupply
        self.maxSupply = maxSupply
        self.marketCapUSD = marketCapUSD
        self.fdvUSD = fdvUSD
        self.mcFdvRatio = mcFdvRatio
        self.annualInflationRate = annualInflationRate
        self.isBurnActive = isBurnActive
        self.burnedTokens = burnedTokens
    }
}

public struct TokenAllocationItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { category }
    public let category: String
    public let percentage: Double
    public let tokenAmount: Double
    public let colorHex: String
    public let description: String
    
    public init(category: String, percentage: Double, tokenAmount: Double, colorHex: String, description: String) {
        self.category = category
        self.percentage = percentage
        self.tokenAmount = tokenAmount
        self.colorHex = colorHex
        self.description = description
    }
}

public struct TokenUnlockEvent: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(unlockDate.timeIntervalSince1970)_\(category)" }
    public let unlockDate: Date
    public let category: String
    public let tokenAmount: Double
    public var valueUSD: Double
    public let percentOfCirculating: Double
    public let unlockType: UnlockType
    public let riskLevel: UnlockRiskLevel
    
    public init(
        unlockDate: Date,
        category: String,
        tokenAmount: Double,
        valueUSD: Double,
        percentOfCirculating: Double,
        unlockType: UnlockType,
        riskLevel: UnlockRiskLevel
    ) {
        self.unlockDate = unlockDate
        self.category = category
        self.tokenAmount = tokenAmount
        self.valueUSD = valueUSD
        self.percentOfCirculating = percentOfCirculating
        self.unlockType = unlockType
        self.riskLevel = riskLevel
    }
}

public struct VestingSchedulePoint: Identifiable, Sendable, Codable, Equatable {
    public var id: String { yearLabel }
    public let yearLabel: String // e.g. "2024", "2025", "2026", "2027", "2028"
    public let circulatingPercent: Double // 0..100
    public let teamLockedPercent: Double
    public let investorsLockedPercent: Double
    public let treasuryLockedPercent: Double
    
    public init(
        yearLabel: String,
        circulatingPercent: Double,
        teamLockedPercent: Double,
        investorsLockedPercent: Double,
        treasuryLockedPercent: Double
    ) {
        self.yearLabel = yearLabel
        self.circulatingPercent = circulatingPercent
        self.teamLockedPercent = teamLockedPercent
        self.investorsLockedPercent = investorsLockedPercent
        self.treasuryLockedPercent = treasuryLockedPercent
    }
}

public struct TokenUtilityInfo: Sendable, Codable, Equatable {
    public var stakingAPR: Double? // e.g. 5.2%
    public var hasGovernanceRights: Bool
    public var governanceDetails: String
    public var hasFeeBurnMechanism: Bool
    public var feeBurnDetails: String
    public var feeDiscountPercentage: Double?
    
    public init(
        stakingAPR: Double? = nil,
        hasGovernanceRights: Bool = true,
        governanceDetails: String = "Bỏ phiếu tham gia các đề xuất nâng cấp mạng lưới và phân bổ quỹ ngân sách DAO.",
        hasFeeBurnMechanism: Bool = false,
        feeBurnDetails: String = "Không có cơ chế đốt token định kỳ.",
        feeDiscountPercentage: Double? = nil
    ) {
        self.stakingAPR = stakingAPR
        self.hasGovernanceRights = hasGovernanceRights
        self.governanceDetails = governanceDetails
        self.hasFeeBurnMechanism = hasFeeBurnMechanism
        self.feeBurnDetails = feeBurnDetails
        self.feeDiscountPercentage = feeDiscountPercentage
    }
}

public struct TokenomicsProfile: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public let tokenStandard: String
    public let primaryUseCases: [String]
    public var supplyMetrics: TokenSupplyMetrics
    public var allocations: [TokenAllocationItem]
    public var upcomingUnlocks: [TokenUnlockEvent]
    public var vestingSchedule: [VestingSchedulePoint]
    public var utilityInfo: TokenUtilityInfo
    public var vestingNotes: String
    
    public init(
        symbol: String,
        baseAsset: String,
        tokenStandard: String,
        primaryUseCases: [String],
        supplyMetrics: TokenSupplyMetrics,
        allocations: [TokenAllocationItem],
        upcomingUnlocks: [TokenUnlockEvent],
        vestingSchedule: [VestingSchedulePoint] = [],
        utilityInfo: TokenUtilityInfo = TokenUtilityInfo(),
        vestingNotes: String
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.tokenStandard = tokenStandard
        self.primaryUseCases = primaryUseCases
        self.supplyMetrics = supplyMetrics
        self.allocations = allocations
        self.upcomingUnlocks = upcomingUnlocks
        self.vestingSchedule = vestingSchedule
        self.utilityInfo = utilityInfo
        self.vestingNotes = vestingNotes
    }
}

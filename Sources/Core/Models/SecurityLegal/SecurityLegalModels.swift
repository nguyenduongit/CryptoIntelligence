import Foundation
import SwiftUI

public enum SecurityRiskLevel: String, Sendable, Codable, CaseIterable {
    case low = "Rủi ro thấp"
    case medium = "Rủi ro trung bình"
    case high = "Rủi ro cao"
    
    public var color: Color {
        switch self {
        case .low: return Color(red: 0.1, green: 0.8, blue: 0.4)
        case .medium: return Color(red: 0.95, green: 0.75, blue: 0.1)
        case .high: return Color(red: 0.95, green: 0.3, blue: 0.3)
        }
    }
}

public struct AuditReportItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { auditorName }
    public let auditorName: String
    public let auditDate: Date
    public let score: Int // 0..100
    public let criticalIssues: Int
    public let highIssues: Int
    public let mediumIssues: Int
    public let resolvedPercentage: Double
    public let reportUrl: String?
    
    public var totalIssues: Int {
        criticalIssues + highIssues + mediumIssues
    }
    
    public var isClean: Bool {
        totalIssues == 0
    }
    
    public init(
        auditorName: String,
        auditDate: Date,
        score: Int,
        criticalIssues: Int,
        highIssues: Int,
        mediumIssues: Int,
        resolvedPercentage: Double,
        reportUrl: String? = nil
    ) {
        self.auditorName = auditorName
        self.auditDate = auditDate
        self.score = score
        self.criticalIssues = criticalIssues
        self.highIssues = highIssues
        self.mediumIssues = mediumIssues
        self.resolvedPercentage = resolvedPercentage
        self.reportUrl = reportUrl
    }
}

public struct GovernanceRiskFactor: Identifiable, Sendable, Codable, Equatable {
    public var id: String { factorName }
    public let factorName: String
    public let riskLevel: SecurityRiskLevel
    public let description: String
    
    public init(factorName: String, riskLevel: SecurityRiskLevel, description: String) {
        self.factorName = factorName
        self.riskLevel = riskLevel
        self.description = description
    }
}

public struct RegulatoryCompliance: Sendable, Codable, Equatable {
    public var secStatus: String
    public var howeyTestScore: Int // 0..100 (lower = safer)
    public var micaCompliance: String
    public var cftcStatus: String
    public var jurisdictionNotes: String
    
    public init(
        secStatus: String,
        howeyTestScore: Int,
        micaCompliance: String,
        cftcStatus: String,
        jurisdictionNotes: String
    ) {
        self.secStatus = secStatus
        self.howeyTestScore = howeyTestScore
        self.micaCompliance = micaCompliance
        self.cftcStatus = cftcStatus
        self.jurisdictionNotes = jurisdictionNotes
    }
}

public struct BugBountyInfo: Sendable, Codable, Equatable {
    public var platformName: String
    public var maxBountyUSD: Double
    public var insuranceFundUSD: Double?
    public var hasExploitHistory: Bool
    public var exploitSummary: String?
    
    public init(
        platformName: String,
        maxBountyUSD: Double,
        insuranceFundUSD: Double? = nil,
        hasExploitHistory: Bool = false,
        exploitSummary: String? = nil
    ) {
        self.platformName = platformName
        self.maxBountyUSD = maxBountyUSD
        self.insuranceFundUSD = insuranceFundUSD
        self.hasExploitHistory = hasExploitHistory
        self.exploitSummary = exploitSummary
    }
}

public struct SmartContractSafetyScan: Sendable, Codable, Equatable {
    public var isHoneypot: Bool
    public var canMint: Bool
    public var isBlacklistable: Bool
    public var buyTaxPercent: Double
    public var sellTaxPercent: Double
    public var isProxyUpgradeable: Bool
    public var isOpenSourceVerified: Bool
    public var lpLockedPercentage: Double?
    public var scanSummary: String
    
    public init(
        isHoneypot: Bool = false,
        canMint: Bool = false,
        isBlacklistable: Bool = false,
        buyTaxPercent: Double = 0.0,
        sellTaxPercent: Double = 0.0,
        isProxyUpgradeable: Bool = false,
        isOpenSourceVerified: Bool = true,
        lpLockedPercentage: Double? = 100.0,
        scanSummary: String = "Mã nguồn mở được xác minh 100%, không chứa hàm bẫy Honeypot, không có thuế mua bán ẩn và thanh khoản được khóa an toàn."
    ) {
        self.isHoneypot = isHoneypot
        self.canMint = canMint
        self.isBlacklistable = isBlacklistable
        self.buyTaxPercent = buyTaxPercent
        self.sellTaxPercent = sellTaxPercent
        self.isProxyUpgradeable = isProxyUpgradeable
        self.isOpenSourceVerified = isOpenSourceVerified
        self.lpLockedPercentage = lpLockedPercentage
        self.scanSummary = scanSummary
    }
}

public struct SecurityLegalProfile: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public var overallSecurityScore: Int // 0..100
    public var securityRatingLabel: String
    public var audits: [AuditReportItem]
    public var governanceRisks: [GovernanceRiskFactor]
    public var regulatory: RegulatoryCompliance
    public var bugBounty: BugBountyInfo
    public var contractScan: SmartContractSafetyScan
    public var executiveSummary: String
    
    public init(
        symbol: String,
        baseAsset: String,
        overallSecurityScore: Int,
        securityRatingLabel: String,
        audits: [AuditReportItem],
        governanceRisks: [GovernanceRiskFactor],
        regulatory: RegulatoryCompliance,
        bugBounty: BugBountyInfo,
        contractScan: SmartContractSafetyScan = SmartContractSafetyScan(),
        executiveSummary: String
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.overallSecurityScore = overallSecurityScore
        self.securityRatingLabel = securityRatingLabel
        self.audits = audits
        self.governanceRisks = governanceRisks
        self.regulatory = regulatory
        self.bugBounty = bugBounty
        self.contractScan = contractScan
        self.executiveSummary = executiveSummary
    }
}

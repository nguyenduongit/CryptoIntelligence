import Testing
import Foundation
@testable import CryptoResearch

@Suite("SecurityLegalTests")
struct SecurityLegalTests {
    
    @Test("Test SecurityLegalDataProvider profile retrieval for major assets")
    func testSecurityLegalDataProviderProfiles() async throws {
        let provider = SecurityLegalDataProvider()
        
        // BTC Test
        let btc = try await provider.fetchSecurityLegalProfile(for: "BTCUSDT")
        #expect(btc.baseAsset == "BTC")
        #expect(btc.overallSecurityScore >= 95)
        #expect(btc.regulatory.howeyTestScore <= 10)
        #expect(!btc.audits.isEmpty)
        #expect(!btc.governanceRisks.isEmpty)
        
        // ETH Test
        let eth = try await provider.fetchSecurityLegalProfile(for: "ETHUSDT")
        #expect(eth.baseAsset == "ETH")
        #expect(eth.overallSecurityScore >= 90)
        #expect(eth.audits.count >= 2)
        #expect(eth.bugBounty.maxBountyUSD >= 500_000)
        
        // SOL Test
        let sol = try await provider.fetchSecurityLegalProfile(for: "SOLUSDT")
        #expect(sol.baseAsset == "SOL")
        #expect(sol.overallSecurityScore >= 80)
        #expect(sol.bugBounty.hasExploitHistory == true)
        
        // Generic fallback
        let doge = try await provider.fetchSecurityLegalProfile(for: "DOGEUSDT")
        #expect(doge.baseAsset == "DOGE")
        #expect(doge.overallSecurityScore > 0)
    }
    
    @Test("Test SecurityLegalModel data structures")
    func testSecurityLegalModelStructures() {
        let audit = AuditReportItem(
            auditorName: "OpenZeppelin",
            auditDate: Date(),
            score: 95,
            criticalIssues: 0,
            highIssues: 1,
            mediumIssues: 2,
            resolvedPercentage: 100.0,
            reportUrl: "https://example.com"
        )
        #expect(audit.isClean == false)
        #expect(audit.totalIssues == 3)
        
        let cleanAudit = AuditReportItem(
            auditorName: "Trail of Bits",
            auditDate: Date(),
            score: 100,
            criticalIssues: 0,
            highIssues: 0,
            mediumIssues: 0,
            resolvedPercentage: 100.0,
            reportUrl: "https://example.com"
        )
        #expect(cleanAudit.isClean == true)
        
        let govRisk = GovernanceRiskFactor(
            factorName: "Timelock Delay",
            riskLevel: .low,
            description: "48h timelock"
        )
        #expect(govRisk.riskLevel == .low)
        
        let regulatory = RegulatoryCompliance(
            secStatus: "Under Review",
            howeyTestScore: 35,
            micaCompliance: "Compliant",
            cftcStatus: "Commodity",
            jurisdictionNotes: "Notes"
        )
        #expect(regulatory.howeyTestScore == 35)
        
        let bugBounty = BugBountyInfo(
            platformName: "Immunefi",
            maxBountyUSD: 2_000_000,
            insuranceFundUSD: 50_000_000,
            hasExploitHistory: false,
            exploitSummary: nil
        )
        #expect(bugBounty.maxBountyUSD == 2_000_000)
        
        let scan = SmartContractSafetyScan(
            isHoneypot: false,
            canMint: false,
            isBlacklistable: false,
            buyTaxPercent: 0.0,
            sellTaxPercent: 0.0,
            isOpenSourceVerified: true
        )
        #expect(scan.isHoneypot == false)
        #expect(scan.buyTaxPercent == 0.0)
        #expect(scan.isOpenSourceVerified == true)
    }
    
    @Test("Test SecurityLegalDataProvider throws dataUnavailable for unknown assets")
    func testSecurityLegalDataProviderUnknownAsset() async {
        let provider = SecurityLegalDataProvider()
        await #expect(throws: SecurityLegalError.self) {
            try await provider.fetchSecurityLegalProfile(for: "UNKNOWNCOINUSDT")
        }
    }
}

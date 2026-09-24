import Testing
import Foundation
@testable import CryptoResearch

@Suite("ProjectProfileTests")
struct ProjectProfileTests {
    
    @Test("Test ProjectDataProvider profile retrieval for major assets")
    func testProjectDataProviderProfiles() async throws {
        let provider = ProjectDataProvider()
        
        // BTC Test
        let btc = try await provider.fetchProjectProfile(for: "BTCUSDT")
        #expect(btc.baseAsset == "BTC")
        #expect(btc.launchYear == 2009)
        #expect(btc.founders.first?.name == "Satoshi Nakamoto")
        #expect(!btc.roadmap.isEmpty)
        #expect(!btc.officialLinks.isEmpty)
        
        // ETH Test
        let eth = try await provider.fetchProjectProfile(for: "ETHUSDT")
        #expect(eth.baseAsset == "ETH")
        #expect(eth.launchYear == 2015)
        #expect(eth.founders.first?.name == "Vitalik Buterin")
        
        // SOL Test
        let sol = try await provider.fetchProjectProfile(for: "SOLUSDT")
        #expect(sol.baseAsset == "SOL")
        #expect(sol.founders.first?.name == "Anatoly Yakovenko")
        #expect(sol.programmingLanguage.contains("Rust"))
        
        // SUI Test
        let sui = try await provider.fetchProjectProfile(for: "SUIUSDT")
        #expect(sui.baseAsset == "SUI")
        #expect(sui.founders.first?.name == "Evan Cheng")
        #expect(sui.founders.first?.previousExperience.contains("Meta Director of R&D") == true)
    }
    
    @Test("Test ProjectProfile model properties")
    func testProjectProfileModelProperties() {
        let member = TeamMember(name: "Alice", role: "CEO", bio: "Tech leader", previousExperience: ["Ex-Google"])
        let milestone = ProjectMilestone(quarterYear: "Q1 2024", title: "Launch", description: "Mainnet", isCompleted: true)
        let partner = EcosystemPartner(name: "DEX Partner", category: "DeFi", description: "Liquidity")
        let link = OfficialResourceLink(title: "Website", url: "https://example.com", iconName: "globe")
        
        let profile = ProjectProfile(
            symbol: "TESTUSDT",
            baseAsset: "TEST",
            projectName: "Test Protocol",
            tagline: "High speed network",
            launchYear: 2024,
            consensusMechanism: "PoS",
            programmingLanguage: "Rust",
            problemSolved: "Scalability",
            technicalArchitecture: "Modular DAG",
            founders: [member],
            roadmap: [milestone],
            partners: [partner],
            officialLinks: [link]
        )
        
        #expect(profile.symbol == "TESTUSDT")
        #expect(profile.founders.count == 1)
        #expect(profile.roadmap.first?.isCompleted == true)
        #expect(profile.officialLinks.first?.url == "https://example.com")
    }
    
    @Test("Test Competitor Benchmark and Developer Activity metrics")
    func testCompetitorsAndDeveloperActivity() async throws {
        let provider = ProjectDataProvider()
        let sol = try await provider.fetchProjectProfile(for: "SOLUSDT")
        
        #expect(!sol.competitors.isEmpty)
        #expect(sol.competitors.contains { $0.isTargetCoin == true })
        #expect(sol.developerActivity.monthlyCommits > 500)
        #expect(sol.developerActivity.activeMonthlyDevelopers > 100)
        
        let sui = try await provider.fetchProjectProfile(for: "SUIUSDT")
        #expect(sui.competitors.first?.tpsRealWorld ?? 0 > 2000)
    }
}

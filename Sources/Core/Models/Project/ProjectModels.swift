import Foundation

public struct TeamMember: Identifiable, Sendable, Codable, Equatable {
    public var id: String { name }
    public let name: String
    public let role: String
    public let bio: String
    public let previousExperience: [String]
    public let avatarIconName: String
    public let socialLink: String?
    
    public init(
        name: String,
        role: String,
        bio: String,
        previousExperience: [String],
        avatarIconName: String = "person.crop.circle.fill",
        socialLink: String? = nil
    ) {
        self.name = name
        self.role = role
        self.bio = bio
        self.previousExperience = previousExperience
        self.avatarIconName = avatarIconName
        self.socialLink = socialLink
    }
}

public struct ProjectMilestone: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(quarterYear)_\(title)" }
    public let quarterYear: String
    public let title: String
    public let description: String
    public let isCompleted: Bool
    
    public init(quarterYear: String, title: String, description: String, isCompleted: Bool) {
        self.quarterYear = quarterYear
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
    }
}

public struct EcosystemPartner: Identifiable, Sendable, Codable, Equatable {
    public var id: String { name }
    public let name: String
    public let category: String
    public let description: String
    public let badgeColorHex: String
    
    public init(name: String, category: String, description: String, badgeColorHex: String = "#2979FF") {
        self.name = name
        self.category = category
        self.description = description
        self.badgeColorHex = badgeColorHex
    }
}

public struct OfficialResourceLink: Identifiable, Sendable, Codable, Equatable {
    public var id: String { title }
    public let title: String
    public let url: String
    public let iconName: String
    
    public init(title: String, url: String, iconName: String) {
        self.title = title
        self.url = url
        self.iconName = iconName
    }
}

public struct CompetitorBenchmarkItem: Identifiable, Sendable, Codable, Equatable {
    public var id: String { name }
    public let name: String // e.g. "Solana (SOL)", "Sui (SUI)", "Ethereum (ETH)"
    public let tpsRealWorld: Int // e.g. 3500
    public let timeToFinality: String // e.g. "400 ms"
    public let nakamotoCoefficient: Int // e.g. 19
    public let avgTransactionFeeUSD: Double // e.g. 0.00025
    public let isTargetCoin: Bool
    
    public init(
        name: String,
        tpsRealWorld: Int,
        timeToFinality: String,
        nakamotoCoefficient: Int,
        avgTransactionFeeUSD: Double,
        isTargetCoin: Bool = false
    ) {
        self.name = name
        self.tpsRealWorld = tpsRealWorld
        self.timeToFinality = timeToFinality
        self.nakamotoCoefficient = nakamotoCoefficient
        self.avgTransactionFeeUSD = avgTransactionFeeUSD
        self.isTargetCoin = isTargetCoin
    }
}

public struct DeveloperActivityMetrics: Sendable, Codable, Equatable {
    public var monthlyCommits: Int
    public var activeMonthlyDevelopers: Int
    public var totalGitHubStars: Int
    public var openPullRequests: Int
    public var lastCommitAgo: String
    
    public init(
        monthlyCommits: Int,
        activeMonthlyDevelopers: Int,
        totalGitHubStars: Int,
        openPullRequests: Int,
        lastCommitAgo: String = "12 phút trước"
    ) {
        self.monthlyCommits = monthlyCommits
        self.activeMonthlyDevelopers = activeMonthlyDevelopers
        self.totalGitHubStars = totalGitHubStars
        self.openPullRequests = openPullRequests
        self.lastCommitAgo = lastCommitAgo
    }
}

public struct ProjectProfile: Identifiable, Sendable, Codable, Equatable {
    public var id: String { symbol }
    public let symbol: String
    public let baseAsset: String
    public let projectName: String
    public let tagline: String
    public let launchYear: Int
    public let consensusMechanism: String
    public let programmingLanguage: String
    public let problemSolved: String
    public let technicalArchitecture: String
    public var founders: [TeamMember]
    public var roadmap: [ProjectMilestone]
    public var partners: [EcosystemPartner]
    public var officialLinks: [OfficialResourceLink]
    public var competitors: [CompetitorBenchmarkItem]
    public var developerActivity: DeveloperActivityMetrics
    
    public init(
        symbol: String,
        baseAsset: String,
        projectName: String,
        tagline: String,
        launchYear: Int,
        consensusMechanism: String,
        programmingLanguage: String,
        problemSolved: String,
        technicalArchitecture: String,
        founders: [TeamMember],
        roadmap: [ProjectMilestone],
        partners: [EcosystemPartner],
        officialLinks: [OfficialResourceLink],
        competitors: [CompetitorBenchmarkItem] = [],
        developerActivity: DeveloperActivityMetrics = DeveloperActivityMetrics(monthlyCommits: 450, activeMonthlyDevelopers: 85, totalGitHubStars: 14200, openPullRequests: 32)
    ) {
        self.symbol = symbol
        self.baseAsset = baseAsset
        self.projectName = projectName
        self.tagline = tagline
        self.launchYear = launchYear
        self.consensusMechanism = consensusMechanism
        self.programmingLanguage = programmingLanguage
        self.problemSolved = problemSolved
        self.technicalArchitecture = technicalArchitecture
        self.founders = founders
        self.roadmap = roadmap
        self.partners = partners
        self.officialLinks = officialLinks
        self.competitors = competitors
        self.developerActivity = developerActivity
    }
}

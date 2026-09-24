import Foundation
import SwiftUI

public struct DerivativesMetrics: Sendable, Codable, Equatable {
    public var symbol: String
    public var fundingRate: Double // e.g. 0.0001 = +0.01%
    public var predictedFundingRate: Double
    public var openInterestUSD: Double
    public var openInterestChange24h: Double // % change
    public var longRatio: Double // e.g. 0.54 (54%)
    public var shortRatio: Double // e.g. 0.46 (46%)
    public var liquidations24hLongUSD: Double
    public var liquidations24hShortUSD: Double
    
    public var totalLiquidations24hUSD: Double {
        liquidations24hLongUSD + liquidations24hShortUSD
    }
    
    public var fundingRatePercentage: Double {
        fundingRate * 100.0
    }
    
    public var isPositiveFunding: Bool {
        fundingRate >= 0
    }
    
    public init(
        symbol: String,
        fundingRate: Double,
        predictedFundingRate: Double,
        openInterestUSD: Double,
        openInterestChange24h: Double,
        longRatio: Double,
        shortRatio: Double,
        liquidations24hLongUSD: Double,
        liquidations24hShortUSD: Double
    ) {
        self.symbol = symbol
        self.fundingRate = fundingRate
        self.predictedFundingRate = predictedFundingRate
        self.openInterestUSD = openInterestUSD
        self.openInterestChange24h = openInterestChange24h
        self.longRatio = longRatio
        self.shortRatio = shortRatio
        self.liquidations24hLongUSD = liquidations24hLongUSD
        self.liquidations24hShortUSD = liquidations24hShortUSD
    }
}

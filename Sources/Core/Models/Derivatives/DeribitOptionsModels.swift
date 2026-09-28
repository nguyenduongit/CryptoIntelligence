import Foundation
import SwiftUI

// MARK: - DVOL History Point
public struct DVOLHistoryPoint: Sendable, Codable, Equatable, Identifiable {
    public var id: Date { date }
    public let date: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    
    public init(date: Date, open: Double, high: Double, low: Double, close: Double) {
        self.date = date
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
}

// MARK: - DVOL Index Data
public struct DeribitDVOLData: Sendable, Codable, Equatable {
    public let symbol: String
    public let currentDVOL: Double
    public let dvolChange24h: Double
    public let realizedVol30d: Double
    public let volRiskPremium: Double // DVOL - RV30D
    public let sentiment: String
    public let historyPoints: [DVOLHistoryPoint]
    
    public init(
        symbol: String,
        currentDVOL: Double,
        dvolChange24h: Double,
        realizedVol30d: Double,
        volRiskPremium: Double,
        sentiment: String,
        historyPoints: [DVOLHistoryPoint]
    ) {
        self.symbol = symbol
        self.currentDVOL = currentDVOL
        self.dvolChange24h = dvolChange24h
        self.realizedVol30d = realizedVol30d
        self.volRiskPremium = volRiskPremium
        self.sentiment = sentiment
        self.historyPoints = historyPoints
    }
    
    public var sentimentColor: Color {
        if volRiskPremium > 5.0 {
            return AppTheme.downRed // High fear / Expensive options
        } else if volRiskPremium < -3.0 {
            return AppTheme.warningYellow // Exceptionally cheap options, volatility explosion imminent
        } else {
            return AppTheme.upGreen
        }
    }
}

// MARK: - Options 25-Delta Skew Item
public struct OptionsSkewItem: Sendable, Codable, Equatable, Identifiable {
    public var id: String { tenor }
    public let tenor: String // "7D", "30D", "90D"
    public let putIV: Double
    public let callIV: Double
    public let skewPercent: Double // Put IV - Call IV
    public let interpretation: String
    
    public init(tenor: String, putIV: Double, callIV: Double, skewPercent: Double, interpretation: String) {
        self.tenor = tenor
        self.putIV = putIV
        self.callIV = callIV
        self.skewPercent = skewPercent
        self.interpretation = interpretation
    }
    
    public var skewColor: Color {
        if skewPercent > 2.0 {
            return AppTheme.downRed // Heavy put buying (Bearish/Fear)
        } else if skewPercent < -2.0 {
            return AppTheme.upGreen // Call buying spree (Bullish)
        } else {
            return AppTheme.accentBlue // Neutral
        }
    }
}

// MARK: - Max Pain Analysis
public struct MaxPainAnalysis: Sendable, Codable, Equatable {
    public let expiryDateString: String
    public let daysToExpiry: Int
    public let maxPainStrike: Double
    public let currentUnderlyingPrice: Double
    public let distancePercent: Double // (MaxPain - Current) / Current * 100
    public let totalCallOIUSD: Double
    public let totalPutOIUSD: Double
    public let putCallRatio: Double
    public let gravitationalNote: String
    
    public init(
        expiryDateString: String,
        daysToExpiry: Int,
        maxPainStrike: Double,
        currentUnderlyingPrice: Double,
        distancePercent: Double,
        totalCallOIUSD: Double,
        totalPutOIUSD: Double,
        putCallRatio: Double,
        gravitationalNote: String
    ) {
        self.expiryDateString = expiryDateString
        self.daysToExpiry = daysToExpiry
        self.maxPainStrike = maxPainStrike
        self.currentUnderlyingPrice = currentUnderlyingPrice
        self.distancePercent = distancePercent
        self.totalCallOIUSD = totalCallOIUSD
        self.totalPutOIUSD = totalPutOIUSD
        self.putCallRatio = putCallRatio
        self.gravitationalNote = gravitationalNote
    }
    
    public var pcrColor: Color {
        if putCallRatio > 1.0 {
            return AppTheme.downRed // Bearish hedge
        } else if putCallRatio < 0.65 {
            return AppTheme.upGreen // Bullish
        } else {
            return AppTheme.accentBlue
        }
    }
}

// MARK: - Deribit Options Surface Profile
public struct DeribitOptionsSurfaceProfile: Sendable, Codable, Equatable {
    public let baseAsset: String
    public let timestamp: Date
    public let dvol: DeribitDVOLData
    public let skews: [OptionsSkewItem]
    public let maxPain: MaxPainAnalysis
    public let isFallback: Bool
    
    public init(
        baseAsset: String,
        timestamp: Date,
        dvol: DeribitDVOLData,
        skews: [OptionsSkewItem],
        maxPain: MaxPainAnalysis,
        isFallback: Bool = false
    ) {
        self.baseAsset = baseAsset
        self.timestamp = timestamp
        self.dvol = dvol
        self.skews = skews
        self.maxPain = maxPain
        self.isFallback = isFallback
    }
}

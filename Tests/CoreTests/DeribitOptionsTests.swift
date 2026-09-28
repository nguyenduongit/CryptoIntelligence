import Testing
import Foundation
@testable import CryptoResearch

@Suite("DeribitOptionsTests")
struct DeribitOptionsTests {
    
    @Test("Test DeribitDVOLData properties and color calculation")
    func testDeribitDVOLDataProperties() {
        let history = [
            DVOLHistoryPoint(date: Date().addingTimeInterval(-86400), open: 34.0, high: 36.0, low: 33.5, close: 35.0),
            DVOLHistoryPoint(date: Date(), open: 35.0, high: 37.0, low: 34.5, close: 36.5)
        ]
        
        let dvol = DeribitDVOLData(
            symbol: "BTC",
            currentDVOL: 36.5,
            dvolChange24h: 1.5,
            realizedVol30d: 32.0,
            volRiskPremium: 4.5,
            sentiment: "Vol Hợp Lý",
            historyPoints: history
        )
        
        #expect(dvol.symbol == "BTC")
        #expect(dvol.currentDVOL == 36.5)
        #expect(dvol.dvolChange24h == 1.5)
        #expect(dvol.volRiskPremium == 4.5)
        #expect(dvol.historyPoints.count == 2)
    }
    
    @Test("Test OptionsSkewItem and 25-Delta interpretation")
    func testOptionsSkewItem() {
        let fearSkew = OptionsSkewItem(
            tenor: "7D",
            putIV: 52.0,
            callIV: 47.0,
            skewPercent: 5.0,
            interpretation: "Phe Mua phòng hộ sập ngắn hạn"
        )
        #expect(fearSkew.skewPercent == 5.0)
        #expect(fearSkew.tenor == "7D")
        
        let greedSkew = OptionsSkewItem(
            tenor: "30D",
            putIV: 44.0,
            callIV: 48.0,
            skewPercent: -4.0,
            interpretation: "Đầu cơ Call bứt phá"
        )
        #expect(greedSkew.skewPercent == -4.0)
    }
    
    @Test("Test MaxPainAnalysis calculations")
    func testMaxPainAnalysis() {
        let analysis = MaxPainAnalysis(
            expiryDateString: "28MAR25",
            daysToExpiry: 3,
            maxPainStrike: 84000.0,
            currentUnderlyingPrice: 86500.0,
            distancePercent: -2.89,
            totalCallOIUSD: 1_500_000_000.0,
            totalPutOIUSD: 1_100_000_000.0,
            putCallRatio: 0.733,
            gravitationalNote: "Lực dìm giá tự nhiên"
        )
        
        #expect(analysis.maxPainStrike == 84000.0)
        #expect(analysis.currentUnderlyingPrice == 86500.0)
        #expect(analysis.putCallRatio > 0.7 && analysis.putCallRatio < 0.8)
        #expect(analysis.totalCallOIUSD > analysis.totalPutOIUSD)
    }
    
    @Test("Test DeribitOptionsProvider fetch profile")
    func testDeribitOptionsProviderFetch() async {
        let provider = DeribitOptionsProvider.shared
        let profile = await provider.fetchOptionsProfile(for: "BTCUSDT")
        
        #expect(profile.baseAsset == "BTC")
        #expect(profile.dvol.currentDVOL > 0)
        #expect(!profile.skews.isEmpty)
        #expect(profile.maxPain.maxPainStrike > 0)
        #expect(profile.maxPain.putCallRatio > 0)
    }
}

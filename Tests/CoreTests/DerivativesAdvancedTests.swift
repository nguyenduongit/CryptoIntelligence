import Testing
import Foundation
@testable import CryptoResearch

@Suite("DerivativesAdvancedTests")
struct DerivativesAdvancedTests {
    
    @Test("Test LiquidationCluster properties and side calculations")
    func testLiquidationClusterProperties() {
        let cluster = LiquidationCluster(
            priceLevel: 72_000.0,
            volumeUSD: 450_000_000,
            volumeToken: 6_250,
            side: .shortLiquidation,
            leverageTier: "25x",
            intensity: 0.95,
            distancePercent: 3.5
        )
        
        #expect(cluster.priceLevel == 72_000.0)
        #expect(cluster.volumeUSD == 450_000_000)
        #expect(cluster.side == .shortLiquidation)
        #expect(cluster.leverageTier == "25x")
        #expect(cluster.distancePercent == 3.5)
    }
    
    @Test("Test LiquidationHeatmapData imbalance and squeeze risk")
    func testLiquidationHeatmapImbalanceRatio() {
        let data1 = LiquidationHeatmapData(
            currentPriceUSD: 68_000.0,
            totalLongLiquidationUSD: 1_000_000_000,
            totalShortLiquidationUSD: 1_800_000_000,
            maxPainPriceUSD: 68_500.0,
            shortSqueezeTriggerPriceUSD: 70_500.0,
            longSqueezeTriggerPriceUSD: 65_800.0,
            clusters: []
        )
        
        // Imbalance = 1.8B / 1.0B = 1.8 -> Short Squeeze risk
        #expect(abs(data1.liquidationImbalanceRatio - 1.8) < 0.001)
        #expect(data1.primarySqueezeRisk.contains("Short Squeeze"))
        
        let data2 = LiquidationHeatmapData(
            currentPriceUSD: 68_000.0,
            totalLongLiquidationUSD: 2_000_000_000,
            totalShortLiquidationUSD: 1_000_000_000,
            maxPainPriceUSD: 68_500.0,
            shortSqueezeTriggerPriceUSD: 70_500.0,
            longSqueezeTriggerPriceUSD: 65_800.0,
            clusters: []
        )
        
        // Imbalance = 1.0B / 2.0B = 0.5 -> Long Squeeze risk
        #expect(abs(data2.liquidationImbalanceRatio - 0.5) < 0.001)
        #expect(data2.primarySqueezeRisk.contains("Long Squeeze"))
    }
    
    @Test("Test FundingRateItem APR calculations")
    func testFundingRateItemAnnualized() {
        let item = FundingRateItem(
            exchangeName: "Binance Futures",
            currentRate8hPercent: 0.0100,
            annualizedRatePercent: 0.0100 * 3 * 365,
            nextFundingCountdownMinutes: 240,
            sentiment: .healthyLong
        )
        
        #expect(abs(item.annualizedRatePercent - 10.95) < 0.001)
        #expect(item.sentiment == .healthyLong)
    }
    
    @Test("Test OpenInterestMetrics expansion and ratios")
    func testOpenInterestMetrics() {
        let oi = OpenInterestMetrics(
            totalOpenInterestUSD: 32_000_000_000,
            totalOpenInterestToken: 480_000,
            oiChange24hPercent: 5.4,
            oiMarketCapRatio: 2.4,
            globalLongAccountPercent: 53.0,
            globalShortAccountPercent: 47.0,
            topTraderLongPositionPercent: 59.0,
            topTraderShortPositionPercent: 41.0
        )
        
        #expect(oi.isOIExpanding == true)
        #expect(oi.globalLongAccountPercent == 53.0)
        #expect(oi.topTraderLongPositionPercent == 59.0)
    }
    
    @Test("Test OrderbookWallItem properties and depth clamping")
    func testOrderbookWallItem() {
        let wall = OrderbookWallItem(
            priceUSD: 65_000.0,
            quantityToken: 2_000.0,
            totalValueUSD: 130_000_000,
            side: .bidWall,
            distancePercent: -2.5,
            depthPercent: 85.0
        )
        
        #expect(wall.side == .bidWall)
        #expect(wall.distancePercent == -2.5)
        #expect(wall.depthPercent == 85.0)
    }
    
    @Test("Test DerivativesDataProvider profile retrieval for BTC")
    func testDerivativesDataProviderBTC() async throws {
        let provider = DerivativesDataProvider.shared
        let profile = try await provider.fetchDerivativesProfile(for: "BTCUSDT")
        
        #expect(profile.symbol == "BTCUSDT")
        #expect(profile.baseAsset == "BTC")
        #expect(profile.heatmapData.clusters.count >= 6)
        #expect(profile.heatmapData.totalLongLiquidationUSD > 0)
        #expect(profile.heatmapData.totalShortLiquidationUSD > 0)
        #expect(profile.exchangeFundingRates.count >= 3)
        #expect(!profile.fundingHistory.isEmpty)
        #expect(profile.openInterest.totalOpenInterestUSD > 0)
        #expect(!profile.orderbookWalls.isEmpty)
    }
    
    @Test("Test DerivativesDataProvider throws dataUnavailable for unknown assets")
    func testDerivativesDataProviderUnknownAsset() async {
        let provider = DerivativesDataProvider.shared
        await #expect(throws: DerivativesError.self) {
            try await provider.fetchDerivativesProfile(for: "UNKNOWNCOINUSDT")
        }
    }
    
    @Test("Test LiquidationHeatmap2D generation and properties")
    func testLiquidationHeatmap2DGeneration() {
        let provider = DerivativesDataProvider.shared
        let heatmap2D = provider.generateLiquidationHeatmap2D(
            symbol: "BTCUSDT",
            currentPrice: 84_000.0,
            baseAsset: "BTC",
            timeframe: .hours24
        )
        
        #expect(heatmap2D.symbol == "BTCUSDT")
        #expect(heatmap2D.currentPrice == 84_000.0)
        #expect(heatmap2D.slices.count == 24)
        #expect(heatmap2D.candles.count == 24)
        #expect(heatmap2D.minPrice < 84_000.0)
        #expect(heatmap2D.maxPrice > 84_000.0)
        #expect(heatmap2D.peakVolumeUSD > 0)
        
        if let firstSlice = heatmap2D.slices.first {
            #expect(!firstSlice.bands.isEmpty)
            #expect(firstSlice.bands.contains(where: { $0.leverageTier == "100x" }))
            #expect(firstSlice.bands.contains(where: { $0.leverageTier == "25x" }))
        }
    }
    
    @Test("Test LiquidationHeatmapPalette interpolation")
    func testLiquidationHeatmapPalette() {
        let palette = LiquidationHeatmapPalette.coinglass
        #expect(palette.previewColors.count == 4)
        
        let c0 = palette.color(for: 0.0)
        let cMax = palette.color(for: 1.0)
        #expect(c0 != cMax)
        
        let cSuppressed = palette.color(for: 0.1, threshold: 0.5)
        #expect(cSuppressed == palette.previewColors[0].opacity(0.15))
    }
    
    @Test("Test CryptoSector colors coverage")
    func testCryptoSectorColors() {
        for s in CryptoSector.allCases {
            _ = s.color
            #expect(!s.rawValue.isEmpty)
        }
    }
}


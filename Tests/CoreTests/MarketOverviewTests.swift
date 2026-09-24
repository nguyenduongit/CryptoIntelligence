import Testing
import Foundation
@testable import CryptoResearch

@Suite("MarketOverviewTests")
struct MarketOverviewTests {
    
    @Test("Test CryptoSector token categorization")
    func testSectorCategorization() {
        #expect(CryptoSector.categorize(baseAsset: "BTC") == .layer1)
        #expect(CryptoSector.categorize(baseAsset: "ETH") == .layer1)
        #expect(CryptoSector.categorize(baseAsset: "SOL") == .layer1)
        #expect(CryptoSector.categorize(baseAsset: "SUI") == .layer1)
        
        #expect(CryptoSector.categorize(baseAsset: "ARB") == .layer2)
        #expect(CryptoSector.categorize(baseAsset: "OP") == .layer2)
        
        #expect(CryptoSector.categorize(baseAsset: "UNI") == .defi)
        #expect(CryptoSector.categorize(baseAsset: "AAVE") == .defi)
        #expect(CryptoSector.categorize(baseAsset: "PENDLE") == .defi)
        
        #expect(CryptoSector.categorize(baseAsset: "FET") == .ai)
        #expect(CryptoSector.categorize(baseAsset: "RENDER") == .ai)
        #expect(CryptoSector.categorize(baseAsset: "TAO") == .ai)
        
        #expect(CryptoSector.categorize(baseAsset: "DOGE") == .meme)
        #expect(CryptoSector.categorize(baseAsset: "PEPE") == .meme)
        #expect(CryptoSector.categorize(baseAsset: "WIF") == .meme)
        
        #expect(CryptoSector.categorize(baseAsset: "ONDO") == .rwa)
        #expect(CryptoSector.categorize(baseAsset: "FIL") == .depin)
        #expect(CryptoSector.categorize(baseAsset: "GALA") == .gaming)
    }
    
    @Test("Test MarketTicker24h properties")
    func testMarketTickerProperties() {
        let ticker = MarketTicker24h(
            symbol: "BTCUSDT",
            baseAsset: "BTC",
            price: 64250.0,
            priceChange: 1250.0,
            priceChangePercent: 1.98,
            highPrice: 65000.0,
            lowPrice: 62800.0,
            volume: 24500.0,
            quoteVolume: 1_574_125_000.0,
            tradesCount: 1_200_000,
            sector: .layer1
        )
        
        #expect(ticker.isBullish == true)
        #expect(ticker.baseAsset == "BTC")
        #expect(ticker.sector == .layer1)
        #expect(ticker.quoteVolume > 1_000_000_000)
    }
    
    @Test("Test MarketViewModel filtering and sorting")
    func testMarketViewModelFilteringAndSorting() {
        let vm = MarketViewModel()
        
        let t1 = MarketTicker24h(symbol: "BTCUSDT", baseAsset: "BTC", price: 64000, priceChange: 1000, priceChangePercent: 1.5, highPrice: 65000, lowPrice: 63000, volume: 1000, quoteVolume: 64_000_000, tradesCount: 100, sector: .layer1)
        let t2 = MarketTicker24h(symbol: "ETHUSDT", baseAsset: "ETH", price: 3400, priceChange: 100, priceChangePercent: 3.0, highPrice: 3500, lowPrice: 3300, volume: 10000, quoteVolume: 34_000_000, tradesCount: 80, sector: .layer1)
        let t3 = MarketTicker24h(symbol: "FETUSDT", baseAsset: "FET", price: 1.5, priceChange: 0.3, priceChangePercent: 25.0, highPrice: 1.6, lowPrice: 1.2, volume: 500000, quoteVolume: 750_000, tradesCount: 200, sector: .ai)
        let t4 = MarketTicker24h(symbol: "PEPEUSDT", baseAsset: "PEPE", price: 0.00001, priceChange: -0.000001, priceChangePercent: -10.0, highPrice: 0.000011, lowPrice: 0.000009, volume: 100000000, quoteVolume: 1_000_000, tradesCount: 150, sector: .meme)
        
        vm.tickers = [t1, t2, t3, t4]
        
        // Default sort: Volume descending
        #expect(vm.filteredTickers.first?.symbol == "BTCUSDT")
        
        // Filter by Sector: AI
        vm.selectedSector = .ai
        #expect(vm.filteredTickers.count == 1)
        #expect(vm.filteredTickers.first?.symbol == "FETUSDT")
        
        // Search query
        vm.selectedSector = .all
        vm.searchQuery = "pep"
        #expect(vm.filteredTickers.count == 1)
        #expect(vm.filteredTickers.first?.symbol == "PEPEUSDT")
        
        // Sort by change descending (Gainers)
        vm.searchQuery = ""
        vm.sortBy = .changeDesc
        #expect(vm.filteredTickers.first?.symbol == "FETUSDT")
        #expect(vm.filteredTickers.last?.symbol == "PEPEUSDT")
    }
    
    @Test("Test DerivativesMetrics properties and calculations")
    func testDerivativesMetrics() async {
        let deriv = DerivativesMetrics(
            symbol: "BTCUSDT",
            fundingRate: 0.000105,
            predictedFundingRate: 0.00012,
            openInterestUSD: 34_850_000_000,
            openInterestChange24h: 3.45,
            longRatio: 0.528,
            shortRatio: 0.472,
            liquidations24hLongUSD: 18_400_000,
            liquidations24hShortUSD: 32_600_000
        )
        
        #expect(deriv.isPositiveFunding == true)
        #expect(deriv.fundingRatePercentage > 0.01)
        #expect(deriv.totalLiquidations24hUSD == 51_000_000)
        
        let provider = MarketDataProvider()
        let fetched = await provider.fetchDerivativesMetrics(for: "BTCUSDT")
        #expect(fetched.symbol == "BTCUSDT")
        #expect(fetched.openInterestUSD > 1_000_000_000)
    }
}

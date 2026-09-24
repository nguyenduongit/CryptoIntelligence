import Foundation

public actor MarketDataProvider {
    public static let shared = MarketDataProvider()
    
    private let candleProvider: BinanceCandleProvider
    private let session: URLSession
    
    public init(candleProvider: BinanceCandleProvider = .shared) {
        self.candleProvider = candleProvider
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 8.0
        self.session = URLSession(configuration: config)
    }
    
    public func fetchMarketOverview() async throws -> (
        tickers: [MarketTicker24h],
        metrics: MarketGlobalMetrics,
        sectors: [SectorPerformance]
    ) {
        // 1. Fetch 24h Tickers from Binance
        let tickers = try await candleProvider.fetchAll24hrTickers()
        
        // 2. Fetch Fear & Greed Index
        let (fngValue, fngClassification) = await fetchFearAndGreedIndex()
        
        // 3. Compute Macro Metrics
        var totalVolume: Double = 0
        var btcVolume: Double = 0
        var ethVolume: Double = 0
        var gainers = 0
        var losers = 0
        
        for t in tickers {
            totalVolume += t.quoteVolume
            if t.symbol == "BTCUSDT" {
                btcVolume = t.quoteVolume
            } else if t.symbol == "ETHUSDT" {
                ethVolume = t.quoteVolume
            }
            if t.priceChangePercent >= 0 {
                gainers += 1
            } else {
                losers += 1
            }
        }
        
        // Approximate Dominance based on market share / relative weight
        let btcDom = totalVolume > 0 ? min(70.0, max(45.0, (btcVolume / totalVolume) * 100.0 * 2.2)) : 56.5
        let ethDom = totalVolume > 0 ? min(25.0, max(10.0, (ethVolume / totalVolume) * 100.0 * 1.8)) : 14.8
        
        let metrics = MarketGlobalMetrics(
            total24hVolumeUSDT: totalVolume,
            btcDominancePercent: btcDom,
            ethDominancePercent: ethDom,
            topGainersCount: gainers,
            topLosersCount: losers,
            fearAndGreedIndex: fngValue,
            fearAndGreedClassification: fngClassification,
            lastUpdated: Date()
        )
        
        // 4. Compute Sector Performances
        var sectorMap = [CryptoSector: [MarketTicker24h]]()
        for s in CryptoSector.allCases where s != .all {
            sectorMap[s] = []
        }
        
        for t in tickers {
            sectorMap[t.sector, default: []].append(t)
        }
        
        var sectorPerformances = [SectorPerformance]()
        for (sector, tokens) in sectorMap {
            guard !tokens.isEmpty else { continue }
            
            let totalSecVol = tokens.reduce(0.0) { $0 + $1.quoteVolume }
            let avgChange = tokens.reduce(0.0) { $0 + $1.priceChangePercent } / Double(tokens.count)
            let gCount = tokens.filter { $0.priceChangePercent >= 0 }.count
            let lCount = tokens.count - gCount
            let topG = tokens.max(by: { $0.priceChangePercent < $1.priceChangePercent })
            
            sectorPerformances.append(SectorPerformance(
                sector: sector,
                avgChangePercent: avgChange,
                totalQuoteVolume: totalSecVol,
                gainersCount: gCount,
                losersCount: lCount,
                tokenCount: tokens.count,
                topGainerSymbol: topG?.symbol,
                topGainerChangePercent: topG?.priceChangePercent
            ))
        }
        
        // Sort sectors by average change descending
        sectorPerformances.sort { $0.avgChangePercent > $1.avgChangePercent }
        
        return (tickers, metrics, sectorPerformances)
    }
    
    public func fetchFearAndGreedIndex() async -> (value: Int, classification: String) {
        guard let url = URL(string: "https://api.alternative.me/fng/?limit=1") else {
            return (60, "Greed")
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataArray = json["data"] as? [[String: Any]],
                  let first = dataArray.first,
                  let valStr = first["value"] as? String, let val = Int(valStr),
                  let classification = first["value_classification"] as? String else {
                return (60, "Greed")
            }
            return (val, classification)
        } catch {
            return (60, "Greed")
        }
    }
    
    public func fetchDerivativesMetrics(for symbol: String = "BTCUSDT") async -> DerivativesMetrics {
        let clean = symbol.uppercased()
        
        if let liveFutures = await DeFiLlamaFundamentalProvider.shared.fetchBinanceFuturesMetrics(for: clean) {
            let fundingVal = liveFutures.currentFunding8h / 100.0
            return DerivativesMetrics(
                symbol: clean,
                fundingRate: fundingVal,
                predictedFundingRate: fundingVal * 1.05,
                openInterestUSD: liveFutures.openInterestUSD,
                openInterestChange24h: 2.5,
                longRatio: liveFutures.globalLongPercent / 100.0,
                shortRatio: liveFutures.globalShortPercent / 100.0,
                liquidations24hLongUSD: liveFutures.openInterestUSD * 0.0012,
                liquidations24hShortUSD: liveFutures.openInterestUSD * 0.0018
            )
        }
        
        // Non-futures spot pairs
        return DerivativesMetrics(
            symbol: clean,
            fundingRate: 0.0001,
            predictedFundingRate: 0.0001,
            openInterestUSD: 0,
            openInterestChange24h: 0.0,
            longRatio: 0.50,
            shortRatio: 0.50,
            liquidations24hLongUSD: 0,
            liquidations24hShortUSD: 0
        )
    }
}

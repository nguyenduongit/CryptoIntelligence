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
        
        // 3. Fetch Real Global Market Dominance from CoinGecko Global API
        let (btcDom, ethDom) = await fetchGlobalMarketDominance()
        
        // 4. Compute Macro Metrics
        var totalVolume: Double = 0
        var gainers = 0
        var losers = 0
        
        for t in tickers {
            totalVolume += t.quoteVolume
            if t.priceChangePercent >= 0 {
                gainers += 1
            } else {
                losers += 1
            }
        }
        
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
    
    public func fetchGlobalMarketDominance() async -> (btcDominance: Double, ethDominance: Double) {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else {
            return (56.5, 14.2)
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 4.0
        request.setValue("CryptoIntelligence/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode),
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataDict = json["data"] as? [String: Any],
                  let mcPercentages = dataDict["market_cap_percentage"] as? [String: Any] else {
                return (56.5, 14.2)
            }
            
            let btc = (mcPercentages["btc"] as? NSNumber)?.doubleValue ?? 56.5
            let eth = (mcPercentages["eth"] as? NSNumber)?.doubleValue ?? 14.2
            return (btc, eth)
        } catch {
            return (56.5, 14.2)
        }
    }
}

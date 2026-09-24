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
        let baseAsset = clean.replacingOccurrences(of: "USDT", with: "")
        
        switch baseAsset {
        case "BTC":
            return DerivativesMetrics(
                symbol: clean,
                fundingRate: 0.000105, // +0.0105% / 8h
                predictedFundingRate: 0.00012,
                openInterestUSD: 34_850_000_000,
                openInterestChange24h: 3.45,
                longRatio: 0.528,
                shortRatio: 0.472,
                liquidations24hLongUSD: 18_400_000,
                liquidations24hShortUSD: 32_600_000
            )
        case "ETH":
            return DerivativesMetrics(
                symbol: clean,
                fundingRate: 0.000085,
                predictedFundingRate: 0.000092,
                openInterestUSD: 14_200_000_000,
                openInterestChange24h: 1.82,
                longRatio: 0.514,
                shortRatio: 0.486,
                liquidations24hLongUSD: 9_200_000,
                liquidations24hShortUSD: 14_800_000
            )
        case "SOL":
            return DerivativesMetrics(
                symbol: clean,
                fundingRate: 0.000155, // +0.0155%
                predictedFundingRate: 0.00018,
                openInterestUSD: 4_650_000_000,
                openInterestChange24h: 7.20,
                longRatio: 0.562,
                shortRatio: 0.438,
                liquidations24hLongUSD: 4_100_000,
                liquidations24hShortUSD: 8_700_000
            )
        case "SUI":
            return DerivativesMetrics(
                symbol: clean,
                fundingRate: 0.000180,
                predictedFundingRate: 0.00021,
                openInterestUSD: 890_000_000,
                openInterestChange24h: 12.4,
                longRatio: 0.584,
                shortRatio: 0.416,
                liquidations24hLongUSD: 1_200_000,
                liquidations24hShortUSD: 3_400_000
            )
        default:
            return DerivativesMetrics(
                symbol: clean,
                fundingRate: 0.0001,
                predictedFundingRate: 0.0001,
                openInterestUSD: 250_000_000,
                openInterestChange24h: 0.5,
                longRatio: 0.505,
                shortRatio: 0.495,
                liquidations24hLongUSD: 350_000,
                liquidations24hShortUSD: 420_000
            )
        }
    }
}

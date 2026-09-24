import Foundation

public actor BinanceCandleProvider: CandleProvider {
    public static let shared = BinanceCandleProvider()
    
    private var primaryBaseURL: String = "https://data-api.binance.vision"
    private var fallbackBaseURL: String = "https://api.binance.com"
    private let session: URLSession
    private let rateLimiter: BinanceRateLimiter
    
    public init(rateLimiter: BinanceRateLimiter = .shared) {
        self.rateLimiter = rateLimiter
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15.0
        config.timeoutIntervalForResource = 30.0
        self.session = URLSession(configuration: config)
    }
    
    public func setBaseURL(primary: String, fallback: String) {
        self.primaryBaseURL = primary
        self.fallbackBaseURL = fallback
    }
    
    private func executeRequest(path: String, queryItems: [URLQueryItem], weight: Int = 2) async throws -> (Data, HTTPURLResponse) {
        try await rateLimiter.acquirePermit(weight: weight)
        
        let urlsToTry = [
            URL(string: "\(primaryBaseURL)\(path)")!,
            URL(string: "\(fallbackBaseURL)\(path)")!
        ]
        
        var lastError: Error?
        
        for baseURL in urlsToTry {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
            components.queryItems = queryItems
            
            guard let url = components.url else { continue }
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("CryptoIntelligence/1.0 (macOS)", forHTTPHeaderField: "User-Agent")
            
            do {
                let (data, response) = try await session.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {
                    continue
                }
                
                // Record weight used from response header
                await rateLimiter.recordUsedWeight(fromHeaders: httpResponse.allHeaderFields)
                
                if httpResponse.statusCode == 429 || httpResponse.statusCode == 418 {
                    let retryAfter = (httpResponse.allHeaderFields["Retry-After"] as? String).flatMap(Double.init)
                    await rateLimiter.recordBan(retryAfterSeconds: retryAfter)
                    throw NSError(
                        domain: "BinanceCandleProvider",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "Binance Rate Limit / Ban (HTTP \(httpResponse.statusCode)). Retry-After: \(retryAfter ?? 120)s"]
                    )
                }
                
                if (200...299).contains(httpResponse.statusCode) {
                    return (data, httpResponse)
                } else {
                    let errStr = String(data: data, encoding: .utf8) ?? "Unknown server error"
                    lastError = NSError(
                        domain: "BinanceCandleProvider",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: "HTTP \(httpResponse.statusCode): \(errStr)"]
                    )
                }
            } catch {
                lastError = error
            }
        }
        
        throw lastError ?? NSError(domain: "BinanceCandleProvider", code: -1, userInfo: [NSLocalizedDescriptionKey: "Network request failed on all endpoints"])
    }
    
    public func fetchHistoricalCandles(
        symbol: String,
        timeframe: Timeframe,
        limit: Int = 1000,
        endTime: Int64? = nil
    ) async throws -> [Candle] {
        var allCandles = [Candle]()
        var currentEndTime = endTime
        var remaining = limit
        
        while remaining > 0 {
            let batchLimit = min(remaining, 1000)
            var queryItems = [
                URLQueryItem(name: "symbol", value: symbol.uppercased()),
                URLQueryItem(name: "interval", value: timeframe.intervalString),
                URLQueryItem(name: "limit", value: "\(batchLimit)")
            ]
            if let end = currentEndTime {
                queryItems.append(URLQueryItem(name: "endTime", value: "\(end)"))
            }
            
            let (data, _) = try await executeRequest(path: "/api/v3/klines", queryItems: queryItems, weight: 2)
            guard let rawArray = try JSONSerialization.jsonObject(with: data) as? [[Any]] else {
                throw NSError(domain: "BinanceCandleProvider", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid klines JSON response"])
            }
            
            if rawArray.isEmpty {
                break
            }
            
            var batchCandles = [Candle]()
            for item in rawArray {
                guard item.count >= 6,
                      let openTime = item[0] as? Int64 ?? (item[0] as? NSNumber)?.int64Value,
                      let openStr = item[1] as? String, let open = Double(openStr),
                      let highStr = item[2] as? String, let high = Double(highStr),
                      let lowStr = item[3] as? String, let low = Double(lowStr),
                      let closeStr = item[4] as? String, let close = Double(closeStr),
                      let volumeStr = item[5] as? String, let volume = Double(volumeStr) else {
                    continue
                }
                
                let closeTime = (item.count > 6 ? (item[6] as? Int64 ?? (item[6] as? NSNumber)?.int64Value) : 0) ?? 0
                let quoteVolStr = (item.count > 7 ? item[7] as? String : "0") ?? "0"
                let trades = (item.count > 8 ? (item[8] as? Int ?? (item[8] as? NSNumber)?.intValue) : 0) ?? 0
                
                batchCandles.append(Candle(
                    openTime: openTime,
                    open: open,
                    high: high,
                    low: low,
                    close: close,
                    volume: volume,
                    closeTime: closeTime,
                    quoteVolume: Double(quoteVolStr) ?? 0,
                    trades: trades,
                    isClosed: true
                ))
            }
            
            if batchCandles.isEmpty {
                break
            }
            
            allCandles.insert(contentsOf: batchCandles, at: 0)
            remaining -= batchCandles.count
            
            if remaining <= 0 || batchCandles.count < batchLimit {
                break
            }
            
            // Set currentEndTime to 1ms before the earliest candle in this batch
            if let firstCandle = batchCandles.first {
                currentEndTime = firstCandle.openTime - 1
            } else {
                break
            }
        }
        
        // Remove duplicates and sort chronologically by openTime
        var seenTimes = Set<Int64>()
        var uniqueCandles = [Candle]()
        for candle in allCandles {
            if !seenTimes.contains(candle.openTime) {
                seenTimes.insert(candle.openTime)
                uniqueCandles.append(candle)
            }
        }
        uniqueCandles.sort { $0.openTime < $1.openTime }
        
        return uniqueCandles
    }
    
    public func fetchExchangeInfo() async throws -> [SymbolInfo] {
        let (data, _) = try await executeRequest(path: "/api/v3/exchangeInfo", queryItems: [], weight: 20)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let symbolsArray = json["symbols"] as? [[String: Any]] else {
            throw NSError(domain: "BinanceCandleProvider", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid exchangeInfo JSON"])
        }
        
        var result = [SymbolInfo]()
        for sym in symbolsArray {
            guard let symbol = sym["symbol"] as? String,
                  let status = sym["status"] as? String,
                  let baseAsset = sym["baseAsset"] as? String,
                  let quoteAsset = sym["quoteAsset"] as? String else {
                continue
            }
            
            // Only include USDT quote pairs with TRADING status
            guard quoteAsset == "USDT", status == "TRADING" else { continue }
            
            let baseAssetPrecision = sym["baseAssetPrecision"] as? Int ?? 8
            let quotePrecision = sym["quotePrecision"] as? Int ?? 8
            
            var tickSize: Double = 0.0001
            var stepSize: Double = 0.0001
            
            if let filters = sym["filters"] as? [[String: Any]] {
                for filter in filters {
                    if let filterType = filter["filterType"] as? String {
                        if filterType == "PRICE_FILTER", let ts = filter["tickSize"] as? String, let d = Double(ts) {
                            tickSize = d
                        } else if filterType == "LOT_SIZE", let ss = filter["stepSize"] as? String, let d = Double(ss) {
                            stepSize = d
                        }
                    }
                }
            }
            
            result.append(SymbolInfo(
                symbol: symbol,
                status: status,
                baseAsset: baseAsset,
                quoteAsset: quoteAsset,
                baseAssetPrecision: baseAssetPrecision,
                quotePrecision: quotePrecision,
                tickSize: tickSize,
                stepSize: stepSize
            ))
        }
        
        return result.sorted { $0.symbol < $1.symbol }
    }
    
    public func fetch24hrTicker(symbol: String) async throws -> (price: Double, changePercent: Double, volume: Double) {
        let (data, _) = try await executeRequest(
            path: "/api/v3/ticker/24hr",
            queryItems: [URLQueryItem(name: "symbol", value: symbol.uppercased())],
            weight: 2
        )
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let lastPriceStr = json["lastPrice"] as? String, let lastPrice = Double(lastPriceStr),
              let changePercentStr = json["priceChangePercent"] as? String, let changePercent = Double(changePercentStr),
              let volumeStr = json["volume"] as? String, let volume = Double(volumeStr) else {
            throw NSError(domain: "BinanceCandleProvider", code: -4, userInfo: [NSLocalizedDescriptionKey: "Invalid 24hr ticker JSON"])
        }
        
        return (lastPrice, changePercent, volume)
    }
    
    public func fetchAll24hrTickers() async throws -> [MarketTicker24h] {
        let (data, _) = try await executeRequest(
            path: "/api/v3/ticker/24hr",
            queryItems: [],
            weight: 40
        )
        
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            throw NSError(domain: "BinanceCandleProvider", code: -5, userInfo: [NSLocalizedDescriptionKey: "Invalid 24hr all tickers JSON"])
        }
        
        var tickers = [MarketTicker24h]()
        tickers.reserveCapacity(jsonArray.count)
        
        for item in jsonArray {
            guard let symbol = item["symbol"] as? String,
                  symbol.hasSuffix("USDT"),
                  let lastPriceStr = item["lastPrice"] as? String, let price = Double(lastPriceStr),
                  let priceChangeStr = item["priceChange"] as? String, let priceChange = Double(priceChangeStr),
                  let changePercentStr = item["priceChangePercent"] as? String, let changePercent = Double(changePercentStr),
                  let highStr = item["highPrice"] as? String, let high = Double(highStr),
                  let lowStr = item["lowPrice"] as? String, let low = Double(lowStr),
                  let volumeStr = item["volume"] as? String, let volume = Double(volumeStr),
                  let quoteVolStr = item["quoteVolume"] as? String, let quoteVolume = Double(quoteVolStr) else {
                continue
            }
            
            // Filter out negligible volume dead pairs (less than $10,000 24h volume)
            guard quoteVolume >= 10_000 else { continue }
            
            let baseAsset = String(symbol.dropLast(4))
            let tradesCount = (item["count"] as? Int ?? (item["count"] as? NSNumber)?.intValue) ?? 0
            let closeTime = (item["closeTime"] as? Int64 ?? (item["closeTime"] as? NSNumber)?.int64Value) ?? Int64(Date().timeIntervalSince1970 * 1000)
            let sector = CryptoSector.categorize(baseAsset: baseAsset)
            
            tickers.append(MarketTicker24h(
                symbol: symbol,
                baseAsset: baseAsset,
                price: price,
                priceChange: priceChange,
                priceChangePercent: changePercent,
                highPrice: high,
                lowPrice: low,
                volume: volume,
                quoteVolume: quoteVolume,
                tradesCount: tradesCount,
                sector: sector,
                closeTime: closeTime
            ))
        }
        
        return tickers
    }
}

import Foundation

public actor MacroIndicesDataProvider {
    public static let shared = MacroIndicesDataProvider()
    
    private var snapshotsCache: (data: [MacroIndexSnapshot], timestamp: Date)?
    private var seasonReportCache: (data: MarketSeasonReport, timestamp: Date)?
    private var stablecoinsCache: (data: [StablecoinBreakdownItem], totalUSD: Double, timestamp: Date)?
    private var candlesCache: [String: (data: [MacroIndexCandle], timestamp: Date)] = [:]
    
    private let cacheTTL: TimeInterval = 60 // 1 minute fresh cache
    
    public init() {}
    
    public func fetchMacroSnapshots() async -> [MacroIndexSnapshot] {
        if let cached = snapshotsCache, Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.data
        }
        
        let snapshots = await fetchLiveMacroSnapshots()
        snapshotsCache = (snapshots, Date())
        return snapshots
    }
    
    public func fetchSeasonReport() async -> MarketSeasonReport {
        if let cached = seasonReportCache, Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.data
        }
        
        let snapshots = await fetchMacroSnapshots()
        let (stablecoins, totalStablesUSD) = await fetchLiveStablecoinsData()
        let report = generateSeasonReport(snapshots: snapshots, stablecoins: stablecoins, totalStablesUSD: totalStablesUSD)
        seasonReportCache = (report, Date())
        return report
    }
    
    public func fetchIndexCandles(index: MacroIndexType, timeframe: String) async -> [MacroIndexCandle] {
        let key = "\(index.rawValue)_\(timeframe)"
        if let cached = candlesCache[key], Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.data
        }
        
        let snapshots = await fetchMacroSnapshots()
        let currentSnap = snapshots.first { $0.indexType == index }
        let currentPrice = currentSnap?.currentValue ?? defaultBaseValue(for: index)
        
        let candles = generateIndexCandles(index: index, timeframe: timeframe, currentLivePrice: currentPrice)
        candlesCache[key] = (candles, Date())
        return candles
    }
    
    // MARK: - Stablecoins Fetcher (DeFiLlama)
    public func fetchLiveStablecoinsData() async -> (items: [StablecoinBreakdownItem], totalUSD: Double) {
        if let cached = stablecoinsCache, Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return (cached.data, cached.totalUSD)
        }
        
        guard let url = URL(string: "https://stablecoins.llama.fi/stablecoins") else {
            return defaultStablecoins()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200,
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let peggedList = json["peggedAssets"] as? [[String: Any]] else {
                return defaultStablecoins()
            }
            
            var totalStablesUSD: Double = 0.0
            var validAssets: [(symbol: String, name: String, cur: Double, prev7d: Double)] = []
            
            for item in peggedList {
                let symbol = item["symbol"] as? String ?? ""
                let name = item["name"] as? String ?? ""
                let circulatingDict = item["circulating"] as? [String: Any] ?? [:]
                let curUSD = (circulatingDict["peggedUSD"] as? NSNumber)?.doubleValue ?? 0.0
                
                let prevWeekDict = item["circulatingPrevWeek"] as? [String: Any] ?? [:]
                let prevUSD = (prevWeekDict["peggedUSD"] as? NSNumber)?.doubleValue ?? curUSD
                
                if curUSD > 10_000_000 {
                    totalStablesUSD += curUSD
                    validAssets.append((symbol: symbol, name: name, cur: curUSD, prev7d: prevUSD))
                }
            }
            
            let totalCap = 2_884_000_000_000.0 // Baseline total market cap
            validAssets.sort { $0.cur > $1.cur }
            
            let topItems: [StablecoinBreakdownItem] = validAssets.prefix(6).map { a in
                let change7d = a.prev7d > 0 ? ((a.cur - a.prev7d) / a.prev7d) * 100.0 : 0.0
                let dom = (a.cur / totalCap) * 100.0
                let share = totalStablesUSD > 0 ? (a.cur / totalStablesUSD) * 100.0 : 0.0
                return StablecoinBreakdownItem(
                    symbol: a.symbol,
                    name: a.name,
                    circulatingUSD: a.cur,
                    dominancePercentage: dom,
                    shareOfStablesPercentage: share,
                    change7dPercent: change7d,
                    iconName: a.symbol == "USDT" ? "dollarsign.circle.fill" : (a.symbol == "USDC" ? "centsign.circle.fill" : "banknote.fill")
                )
            }
            
            let result = (topItems, totalStablesUSD)
            stablecoinsCache = (topItems, totalStablesUSD, Date())
            return result
        } catch {
            return defaultStablecoins()
        }
    }
    
    private func defaultStablecoins() -> (items: [StablecoinBreakdownItem], totalUSD: Double) {
        let totalStables = 313_900_000_000.0
        let totalCap = 2_884_000_000_000.0
        
        let items: [StablecoinBreakdownItem] = [
            StablecoinBreakdownItem(symbol: "USDT", name: "Tether USD", circulatingUSD: 183_750_000_000, dominancePercentage: (183.75e9 / totalCap) * 100, shareOfStablesPercentage: 58.5, change7dPercent: 0.24, iconName: "dollarsign.circle.fill"),
            StablecoinBreakdownItem(symbol: "USDC", name: "USD Coin (Circle)", circulatingUSD: 76_600_000_000, dominancePercentage: (76.6e9 / totalCap) * 100, shareOfStablesPercentage: 24.4, change7dPercent: 2.92, iconName: "centsign.circle.fill"),
            StablecoinBreakdownItem(symbol: "USDS", name: "Sky Dollar", circulatingUSD: 6_640_000_000, dominancePercentage: (6.64e9 / totalCap) * 100, shareOfStablesPercentage: 2.1, change7dPercent: 1.95, iconName: "banknote.fill"),
            StablecoinBreakdownItem(symbol: "USDe", name: "Ethena Synthetic USD", circulatingUSD: 4_930_000_000, dominancePercentage: (4.93e9 / totalCap) * 100, shareOfStablesPercentage: 1.6, change7dPercent: 2.71, iconName: "flame.fill"),
            StablecoinBreakdownItem(symbol: "DAI", name: "Dai (MakerDAO)", circulatingUSD: 4_790_000_000, dominancePercentage: (4.79e9 / totalCap) * 100, shareOfStablesPercentage: 1.5, change7dPercent: -0.05, iconName: "diamond.fill"),
            StablecoinBreakdownItem(symbol: "Khác", name: "USD1, FDUSD, PYUSD...", circulatingUSD: 37_190_000_000, dominancePercentage: (37.19e9 / totalCap) * 100, shareOfStablesPercentage: 11.9, change7dPercent: 1.10, iconName: "square.stack.3d.up.fill")
        ]
        return (items, totalStables)
    }
    
    // MARK: - Internal Live Fetchers
    private func fetchLiveMacroSnapshots() async -> [MacroIndexSnapshot] {
        // 1. Try fetching CoinGecko Global endpoint with browser-like headers
        if let snapshots = await fetchFromCoinGeckoGlobal() {
            return snapshots
        }
        
        // 2. Try fetching from Binance live 24hr tickers to compute real-time capitalization
        if let snapshots = await fetchFromBinanceAggregate() {
            return snapshots
        }
        
        // 3. Fallback to calibrated baseline
        return generateDefaultSnapshots()
    }
    
    private func fetchFromCoinGeckoGlobal() async -> [MacroIndexSnapshot]? {
        guard let url = URL(string: "https://api.coingecko.com/api/v3/global") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 8.0
        request.setValue("Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200,
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let gData = json["data"] as? [String: Any] else {
                return nil
            }
            
            let totalMcapDict = gData["total_market_cap"] as? [String: Any] ?? [:]
            guard let totalMcapUSD = (totalMcapDict["usd"] as? NSNumber)?.doubleValue, totalMcapUSD > 0 else {
                return nil
            }
            
            let mcapChange24h = (gData["market_cap_change_percentage_24h_usd"] as? NSNumber)?.doubleValue ?? 0.30
            
            let mcapPercDict = gData["market_cap_percentage"] as? [String: Any] ?? [:]
            let btcD = (mcapPercDict["btc"] as? NSNumber)?.doubleValue ?? 58.34
            let ethD = (mcapPercDict["eth"] as? NSNumber)?.doubleValue ?? 11.32
            let usdtD = (mcapPercDict["usdt"] as? NSNumber)?.doubleValue ?? 6.37
            let usdcD = (mcapPercDict["usdc"] as? NSNumber)?.doubleValue ?? 2.66
            let stableD = max(usdtD + usdcD + 1.85, 10.88)
            
            let btcCap = totalMcapUSD * (btcD / 100.0)
            let ethCap = totalMcapUSD * (ethD / 100.0)
            
            let total2 = max(100_000_000_000.0, totalMcapUSD - btcCap)
            let total3 = max(50_000_000_000.0, totalMcapUSD - btcCap - ethCap)
            let othersD = max(1.0, 100.0 - btcD - ethD - stableD)
            
            return [
                MacroIndexSnapshot(
                    indexType: .total,
                    currentValue: totalMcapUSD,
                    change24h: mcapChange24h,
                    change7d: mcapChange24h * 1.5,
                    formattedValue: formatTrillions(totalMcapUSD),
                    sparkline: generateSparkline(base: totalMcapUSD, trend: mcapChange24h)
                ),
                MacroIndexSnapshot(
                    indexType: .total2,
                    currentValue: total2,
                    change24h: mcapChange24h * 1.1,
                    change7d: mcapChange24h * 1.8,
                    formattedValue: formatTrillions(total2),
                    sparkline: generateSparkline(base: total2, trend: mcapChange24h * 1.1)
                ),
                MacroIndexSnapshot(
                    indexType: .total3,
                    currentValue: total3,
                    change24h: mcapChange24h * 1.25,
                    change7d: mcapChange24h * 2.0,
                    formattedValue: formatTrillions(total3),
                    sparkline: generateSparkline(base: total3, trend: mcapChange24h * 1.25)
                ),
                MacroIndexSnapshot(
                    indexType: .btcD,
                    currentValue: btcD,
                    change24h: -0.15,
                    change7d: -0.45,
                    formattedValue: String(format: "%.2f%%", btcD),
                    sparkline: generateSparkline(base: btcD, trend: -0.15)
                ),
                MacroIndexSnapshot(
                    indexType: .ethD,
                    currentValue: ethD,
                    change24h: +0.20,
                    change7d: +0.60,
                    formattedValue: String(format: "%.2f%%", ethD),
                    sparkline: generateSparkline(base: ethD, trend: +0.20)
                ),
                MacroIndexSnapshot(
                    indexType: .stableD,
                    currentValue: stableD,
                    change24h: -0.05,
                    change7d: -0.15,
                    formattedValue: String(format: "%.2f%%", stableD),
                    sparkline: generateSparkline(base: stableD, trend: -0.05)
                ),
                MacroIndexSnapshot(
                    indexType: .usdtD,
                    currentValue: usdtD,
                    change24h: -0.08,
                    change7d: -0.25,
                    formattedValue: String(format: "%.2f%%", usdtD),
                    sparkline: generateSparkline(base: usdtD, trend: -0.08)
                ),
                MacroIndexSnapshot(
                    indexType: .othersD,
                    currentValue: othersD,
                    change24h: +0.18,
                    change7d: +0.70,
                    formattedValue: String(format: "%.2f%%", othersD),
                    sparkline: generateSparkline(base: othersD, trend: +0.18)
                )
            ]
        } catch {
            return nil
        }
    }
    
    private func fetchFromBinanceAggregate() async -> [MacroIndexSnapshot]? {
        guard let url = URL(string: "https://api.binance.com/api/v3/ticker/24hr?symbols=[%22BTCUSDT%22,%22ETHUSDT%22]") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 6.0
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200,
                  let list = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                return nil
            }
            
            var btcPrice = 84_200.0
            var btcChange = 0.3
            var ethPrice = 2_690.0
            var ethChange = 0.7
            
            for item in list {
                let symbol = item["symbol"] as? String ?? ""
                let lastPrice = Double(item["lastPrice"] as? String ?? "") ?? 0.0
                let priceChangePercent = Double(item["priceChangePercent"] as? String ?? "") ?? 0.0
                
                if symbol == "BTCUSDT" && lastPrice > 0 {
                    btcPrice = lastPrice
                    btcChange = priceChangePercent
                } else if symbol == "ETHUSDT" && lastPrice > 0 {
                    ethPrice = lastPrice
                    ethChange = priceChangePercent
                }
            }
            
            let btcCirculatingSupply = 19_760_000.0
            let ethCirculatingSupply = 120_400_000.0
            let btcCap = btcPrice * btcCirculatingSupply
            let ethCap = ethPrice * ethCirculatingSupply
            
            let btcD = 58.34
            let total = btcCap / (btcD / 100.0)
            let ethD = (ethCap / total) * 100.0
            let stableD = 10.88
            let usdtD = 6.37
            let total2 = total - btcCap
            let total3 = total - btcCap - ethCap
            let othersD = max(1.0, 100.0 - btcD - ethD - stableD)
            
            return [
                MacroIndexSnapshot(indexType: .total, currentValue: total, change24h: btcChange, change7d: btcChange * 1.5, formattedValue: formatTrillions(total), sparkline: generateSparkline(base: total, trend: btcChange)),
                MacroIndexSnapshot(indexType: .total2, currentValue: total2, change24h: ethChange, change7d: ethChange * 1.8, formattedValue: formatTrillions(total2), sparkline: generateSparkline(base: total2, trend: ethChange)),
                MacroIndexSnapshot(indexType: .total3, currentValue: total3, change24h: ethChange * 1.2, change7d: ethChange * 2.0, formattedValue: formatTrillions(total3), sparkline: generateSparkline(base: total3, trend: ethChange * 1.2)),
                MacroIndexSnapshot(indexType: .btcD, currentValue: btcD, change24h: -0.15, change7d: -0.45, formattedValue: String(format: "%.2f%%", btcD), sparkline: generateSparkline(base: btcD, trend: -0.15)),
                MacroIndexSnapshot(indexType: .ethD, currentValue: ethD, change24h: ethChange, change7d: ethChange * 1.5, formattedValue: String(format: "%.2f%%", ethD), sparkline: generateSparkline(base: ethD, trend: ethChange)),
                MacroIndexSnapshot(indexType: .stableD, currentValue: stableD, change24h: -0.05, change7d: -0.15, formattedValue: String(format: "%.2f%%", stableD), sparkline: generateSparkline(base: stableD, trend: -0.05)),
                MacroIndexSnapshot(indexType: .usdtD, currentValue: usdtD, change24h: -0.08, change7d: -0.25, formattedValue: String(format: "%.2f%%", usdtD), sparkline: generateSparkline(base: usdtD, trend: -0.08)),
                MacroIndexSnapshot(indexType: .othersD, currentValue: othersD, change24h: +0.20, change7d: +0.70, formattedValue: String(format: "%.2f%%", othersD), sparkline: generateSparkline(base: othersD, trend: +0.20))
            ]
        } catch {
            return nil
        }
    }
    
    private func generateDefaultSnapshots() -> [MacroIndexSnapshot] {
        let total = 2_884_000_000_000.0
        let btcD = 58.34
        let ethD = 11.32
        let stableD = 10.88
        let usdtD = 6.37
        let btcCap = total * (btcD / 100.0)
        let ethCap = total * (ethD / 100.0)
        let total2 = total - btcCap
        let total3 = total - btcCap - ethCap
        let othersD = 19.46
        
        return [
            MacroIndexSnapshot(indexType: .total, currentValue: total, change24h: -0.33, change7d: 2.10, formattedValue: "$2.88T", sparkline: generateSparkline(base: total, trend: -0.33)),
            MacroIndexSnapshot(indexType: .total2, currentValue: total2, change24h: 0.45, change7d: 3.20, formattedValue: "$1.20T", sparkline: generateSparkline(base: total2, trend: 0.45)),
            MacroIndexSnapshot(indexType: .total3, currentValue: total3, change24h: 0.80, change7d: 4.10, formattedValue: "$875B", sparkline: generateSparkline(base: total3, trend: 0.80)),
            MacroIndexSnapshot(indexType: .btcD, currentValue: btcD, change24h: -0.25, change7d: -0.80, formattedValue: "58.34%", sparkline: generateSparkline(base: btcD, trend: -0.25)),
            MacroIndexSnapshot(indexType: .ethD, currentValue: ethD, change24h: 0.35, change7d: 1.10, formattedValue: "11.32%", sparkline: generateSparkline(base: ethD, trend: 0.35)),
            MacroIndexSnapshot(indexType: .stableD, currentValue: stableD, change24h: -0.05, change7d: -0.20, formattedValue: "10.88%", sparkline: generateSparkline(base: stableD, trend: -0.05)),
            MacroIndexSnapshot(indexType: .usdtD, currentValue: usdtD, change24h: -0.05, change7d: -0.20, formattedValue: "6.37%", sparkline: generateSparkline(base: usdtD, trend: -0.05)),
            MacroIndexSnapshot(indexType: .othersD, currentValue: othersD, change24h: 0.42, change7d: 1.25, formattedValue: "19.46%", sparkline: generateSparkline(base: othersD, trend: 0.42))
        ]
    }
    
    private func generateSeasonReport(
        snapshots: [MacroIndexSnapshot],
        stablecoins: [StablecoinBreakdownItem],
        totalStablesUSD: Double
    ) -> MarketSeasonReport {
        let totalSnap = snapshots.first(where: { $0.indexType == .total })
        let total2Snap = snapshots.first(where: { $0.indexType == .total2 })
        let btcDSnap = snapshots.first(where: { $0.indexType == .btcD })
        let ethDSnap = snapshots.first(where: { $0.indexType == .ethD })
        let stableDSnap = snapshots.first(where: { $0.indexType == .stableD })
        let usdtDSnap = snapshots.first(where: { $0.indexType == .usdtD })
        
        let total = totalSnap?.currentValue ?? 2_884_000_000_000.0
        let total2 = total2Snap?.currentValue ?? 1_200_000_000_000.0
        let btcD = btcDSnap?.currentValue ?? 58.34
        let ethD = ethDSnap?.currentValue ?? 11.32
        let usdtD = usdtDSnap?.currentValue ?? 6.37
        let stableD = stableDSnap?.currentValue ?? ((totalStablesUSD / total) * 100.0)
        
        let totalChange = totalSnap?.change24h ?? -0.33
        let btcDChange = btcDSnap?.change24h ?? -0.25
        let stableDChange = stableDSnap?.change24h ?? -0.05
        
        let state: MarketSeasonState
        let altIndex: Int
        let summary: String
        
        if stableDChange > 1.5 && totalChange < -1.5 {
            state = .riskOffPanic
            altIndex = 20
            summary = "Dòng tiền đang tháo chạy về Stablecoins (USDT/USDC). Nhà đầu tư chuyển sang tiền mặt phòng thủ. Khuyến nghị ưu tiên quản trị rủi ro và giữ thanh khoản an toàn."
        } else if btcDChange < -0.2 && totalChange >= 0 {
            state = .altcoinSeason
            altIndex = 72
            summary = "Tỷ trọng BTC.D đang sụt giảm trong khi tổng vốn hóa TOTAL tiếp tục ổn định. Dòng tiền từ Bitcoin và Stablecoin đang luân chuyển sang nhóm Altcoins."
        } else if btcD > 58.0 {
            state = .bitcoinSeason
            altIndex = 35
            summary = "Bitcoin đang dẫn dắt sóng thị trường với tỷ trọng BTC.D cao (>58%). Dòng tiền tập trung tích lũy BTC; nhóm Altcoin chịu áp lực hút thanh khoản."
        } else {
            state = .capitalRotation
            altIndex = 54
            summary = "Thị trường đang trong pha tích lũy và luân chuyển vốn nội bộ giữa các hệ sinh thái Layer 1, Layer 2 và AI. Phân bổ cân bằng giữa BTC và Top Altcoins."
        }
        
        return MarketSeasonReport(
            currentState: state,
            altcoinSeasonIndex: altIndex,
            totalMarketCapUSD: total,
            altcoinMarketCapUSD: total2,
            btcDPercentage: btcD,
            ethDPercentage: ethD,
            usdtDPercentage: usdtD,
            stablecoinDominancePercentage: stableD,
            totalStablecoinLiquidityUSD: totalStablesUSD,
            topStablecoins: stablecoins,
            actionableSummary: summary
        )
    }
    
    private func defaultBaseValue(for index: MacroIndexType) -> Double {
        switch index {
        case .total: return 2.88e12
        case .total2: return 1.20e12
        case .total3: return 8.75e11
        case .btcD: return 58.34
        case .ethD: return 11.32
        case .stableD: return 10.88
        case .usdtD: return 6.37
        case .othersD: return 19.46
        }
    }
    
    private func generateIndexCandles(index: MacroIndexType, timeframe: String, currentLivePrice: Double) -> [MacroIndexCandle] {
        let count = 60
        let now = Date()
        let interval: TimeInterval
        switch timeframe {
        case "1h": interval = 3600
        case "4h": interval = 14400
        case "1w": interval = 604800
        default: interval = 86400 // 1d
        }
        
        var volatility: Double
        switch index {
        case .total: volatility = 0.015
        case .total2: volatility = 0.022
        case .total3: volatility = 0.028
        case .btcD: volatility = 0.006
        case .ethD: volatility = 0.010
        case .stableD: volatility = 0.005
        case .usdtD: volatility = 0.006
        case .othersD: volatility = 0.018
        }
        
        var candles: [MacroIndexCandle] = []
        var currentPrice = currentLivePrice * 0.95
        
        for i in (0..<count).reversed() {
            let candleTime = now.addingTimeInterval(-Double(i) * interval)
            let deltaPercent = Double.random(in: -volatility...volatility * 1.05)
            let open = currentPrice
            let close = max(0.1, open * (1.0 + deltaPercent))
            let high = max(open, close) * (1.0 + Double.random(in: 0.001...volatility * 0.5))
            let low = min(open, close) * (1.0 - Double.random(in: 0.001...volatility * 0.5))
            let volume = open * Double.random(in: 0.02...0.06)
            
            candles.append(
                MacroIndexCandle(
                    timestamp: candleTime,
                    open: open,
                    high: high,
                    low: low,
                    close: close,
                    volume: volume
                )
            )
            currentPrice = close
        }
        
        return candles
    }
    
    private func generateSparkline(base: Double, trend: Double) -> [Double] {
        var points: [Double] = []
        var cur = base * (1.0 - (trend / 100.0))
        for _ in 0..<14 {
            let delta = (Double.random(in: -0.01...0.015) + (trend / 1400.0)) * cur
            cur = max(0.1, cur + delta)
            points.append(cur)
        }
        return points
    }
    
    private func formatTrillions(_ val: Double) -> String {
        if val >= 1_000_000_000_000 {
            return String(format: "$%.2fT", val / 1_000_000_000_000)
        } else if val >= 1_000_000_000 {
            return String(format: "$%.1fB", val / 1_000_000_000)
        } else {
            return String(format: "$%.1fM", val / 1_000_000)
        }
    }
}

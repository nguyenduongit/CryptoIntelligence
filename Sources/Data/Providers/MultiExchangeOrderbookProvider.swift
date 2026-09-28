import Foundation

public actor MultiExchangeOrderbookProvider {
    public static let shared = MultiExchangeOrderbookProvider()
    
    private var cache: [String: (book: AggregatedOrderbook, timestamp: Date)] = [:]
    private let cacheTTL: TimeInterval = 10.0 // 10 seconds cache for responsive UI
    
    private let session: URLSession
    
    public init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 4.0
        config.timeoutIntervalForResource = 5.0
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - Public Fetch Aggregated Orderbook
    public func fetchAggregatedOrderbook(for symbol: String) async -> AggregatedOrderbook? {
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        
        // Check cache
        if let cached = cache[cleanSymbol], Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.book
        }
        
        // Concurrently fetch Binance, OKX, Bybit L2 depth
        async let binanceTask = fetchBinanceDepth(symbol: cleanSymbol)
        async let okxTask = fetchOKXDepth(baseAsset: baseAsset)
        async let bybitTask = fetchBybitDepth(symbol: cleanSymbol)
        
        let (binanceRes, okxRes, bybitRes) = await (binanceTask, okxTask, bybitTask)
        
        var allBids: [OrderbookLevel] = []
        var allAsks: [OrderbookLevel] = []
        var summaries: [ExchangeDepthSummary] = []
        
        var totalDepthUSD: Double = 0.0
        
        // 1. Process Binance
        if let b = binanceRes, !b.bids.isEmpty, !b.asks.isEmpty {
            allBids.append(contentsOf: b.bids)
            allAsks.append(contentsOf: b.asks)
            let bidUSD = b.bids.reduce(0.0) { $0 + $1.amountUSD }
            let askUSD = b.asks.reduce(0.0) { $0 + $1.amountUSD }
            let spread = (b.asks.first?.price ?? 0) - (b.bids.first?.price ?? 0)
            let mid = ((b.asks.first?.price ?? 0) + (b.bids.first?.price ?? 0)) / 2.0
            let bps = mid > 0 ? (spread / mid) * 10_000.0 : 0
            summaries.append(ExchangeDepthSummary(exchange: .binance, bidDepthUSD: bidUSD, askDepthUSD: askUSD, spreadUSD: spread, spreadBps: bps, sharePercent: 0))
            totalDepthUSD += (bidUSD + askUSD)
        }
        
        // 2. Process OKX
        if let o = okxRes, !o.bids.isEmpty, !o.asks.isEmpty {
            allBids.append(contentsOf: o.bids)
            allAsks.append(contentsOf: o.asks)
            let bidUSD = o.bids.reduce(0.0) { $0 + $1.amountUSD }
            let askUSD = o.asks.reduce(0.0) { $0 + $1.amountUSD }
            let spread = (o.asks.first?.price ?? 0) - (o.bids.first?.price ?? 0)
            let mid = ((o.asks.first?.price ?? 0) + (o.bids.first?.price ?? 0)) / 2.0
            let bps = mid > 0 ? (spread / mid) * 10_000.0 : 0
            summaries.append(ExchangeDepthSummary(exchange: .okx, bidDepthUSD: bidUSD, askDepthUSD: askUSD, spreadUSD: spread, spreadBps: bps, sharePercent: 0))
            totalDepthUSD += (bidUSD + askUSD)
        }
        
        // 3. Process Bybit
        if let y = bybitRes, !y.bids.isEmpty, !y.asks.isEmpty {
            allBids.append(contentsOf: y.bids)
            allAsks.append(contentsOf: y.asks)
            let bidUSD = y.bids.reduce(0.0) { $0 + $1.amountUSD }
            let askUSD = y.asks.reduce(0.0) { $0 + $1.amountUSD }
            let spread = (y.asks.first?.price ?? 0) - (y.bids.first?.price ?? 0)
            let mid = ((y.asks.first?.price ?? 0) + (y.bids.first?.price ?? 0)) / 2.0
            let bps = mid > 0 ? (spread / mid) * 10_000.0 : 0
            summaries.append(ExchangeDepthSummary(exchange: .bybit, bidDepthUSD: bidUSD, askDepthUSD: askUSD, spreadUSD: spread, spreadBps: bps, sharePercent: 0))
            totalDepthUSD += (bidUSD + askUSD)
        }
        
        guard !allBids.isEmpty, !allAsks.isEmpty else {
            return nil
        }
        
        // Calculate market share percentages
        let finalSummaries = summaries.map { s in
            let depth = s.bidDepthUSD + s.askDepthUSD
            let share = totalDepthUSD > 0 ? (depth / totalDepthUSD) * 100.0 : 0
            return ExchangeDepthSummary(
                exchange: s.exchange,
                bidDepthUSD: s.bidDepthUSD,
                askDepthUSD: s.askDepthUSD,
                spreadUSD: s.spreadUSD,
                spreadBps: s.spreadBps,
                sharePercent: share
            )
        }
        
        // Sort merged bids descending and asks ascending
        let sortedBids = allBids.sorted { $0.price > $1.price }
        let sortedAsks = allAsks.sorted { $0.price < $1.price }
        
        let bestBid = sortedBids.first?.price ?? 0
        let bestAsk = sortedAsks.first?.price ?? 0
        let midPrice = (bestBid + bestAsk) / 2.0
        let spreadUSD = max(0, bestAsk - bestBid)
        let spreadBps = midPrice > 0 ? (spreadUSD / midPrice) * 10_000.0 : 0
        
        let totalBidUSD = sortedBids.reduce(0.0) { $0 + $1.amountUSD }
        let totalAskUSD = sortedAsks.reduce(0.0) { $0 + $1.amountUSD }
        
        // Depth within 1% and 2%
        let p1Lower = midPrice * 0.99
        let p1Upper = midPrice * 1.01
        let p2Lower = midPrice * 0.98
        let p2Upper = midPrice * 1.02
        
        let d1Bid = sortedBids.filter { $0.price >= p1Lower }.reduce(0.0) { $0 + $1.amountUSD }
        let d1Ask = sortedAsks.filter { $0.price <= p1Upper }.reduce(0.0) { $0 + $1.amountUSD }
        let depth1 = d1Bid + d1Ask
        
        let d2Bid = sortedBids.filter { $0.price >= p2Lower }.reduce(0.0) { $0 + $1.amountUSD }
        let d2Ask = sortedAsks.filter { $0.price <= p2Upper }.reduce(0.0) { $0 + $1.amountUSD }
        let depth2 = d2Bid + d2Ask
        
        let book = AggregatedOrderbook(
            symbol: cleanSymbol,
            timestamp: Date(),
            bids: sortedBids,
            asks: sortedAsks,
            bestBidPrice: bestBid,
            bestAskPrice: bestAsk,
            midPrice: midPrice,
            aggregatedSpreadUSD: spreadUSD,
            aggregatedSpreadBps: spreadBps,
            totalBidDepthUSD: totalBidUSD,
            totalAskDepthUSD: totalAskUSD,
            depth1PercentUSD: depth1,
            depth2PercentUSD: depth2,
            exchangeSummaries: finalSummaries
        )
        
        cache[cleanSymbol] = (book, Date())
        return book
    }
    
    // MARK: - Simulate Execution & Market Impact
    nonisolated public func simulateExecution(
        capitalUSD: Double,
        side: ExecutionOrderSide,
        book: AggregatedOrderbook
    ) -> MarketImpactSimulationResult {
        let levels = (side == .buy) ? book.asks : book.bids
        let midPrice = book.midPrice
        guard midPrice > 0, !levels.isEmpty else {
            return fallbackSimulation(capitalUSD: capitalUSD, side: side, midPrice: midPrice)
        }
        
        // 1. Single Exchange Simulation (Binance Only)
        let binanceLevels = levels.filter { $0.exchange == .binance }
        let (singleFillPrice, singleSlippage) = computeFill(capitalUSD: capitalUSD, levels: binanceLevels, midPrice: midPrice, side: side)
        
        // 2. Aggregated Multi-Exchange Smart Routing
        var remainingUSD = capitalUSD
        var totalTokensFilled = 0.0
        var exchangeAllocations: [ExchangeVenue: (usd: Double, tokens: Double)] = [:]
        
        for l in levels {
            guard remainingUSD > 0 else { break }
            let fillUSD = min(remainingUSD, l.amountUSD)
            let fillTokens = fillUSD / max(0.000001, l.price)
            
            totalTokensFilled += fillTokens
            remainingUSD -= fillUSD
            
            let currentAlloc = exchangeAllocations[l.exchange] ?? (0.0, 0.0)
            exchangeAllocations[l.exchange] = (currentAlloc.usd + fillUSD, currentAlloc.tokens + fillTokens)
        }
        
        let aggregatedFillPrice = totalTokensFilled > 0 ? (capitalUSD / totalTokensFilled) : midPrice
        let aggregatedSlippage = midPrice > 0 ? abs((aggregatedFillPrice - midPrice) / midPrice) * 100.0 : 0
        
        let instantCostOfSlippage = capitalUSD * (aggregatedSlippage / 100.0)
        let smartRoutingSavings = max(0, capitalUSD * (abs(singleSlippage - aggregatedSlippage) / 100.0))
        
        // Format allocations
        let allocations: [SmartRoutingAllocation] = ExchangeVenue.allCases.compactMap { venue in
            guard let alloc = exchangeAllocations[venue], alloc.usd > 0 else { return nil }
            let share = (alloc.usd / capitalUSD) * 100.0
            let avgP = alloc.tokens > 0 ? (alloc.usd / alloc.tokens) : midPrice
            return SmartRoutingAllocation(exchange: venue, allocatedAmountUSD: alloc.usd, allocatedSharePercent: share, averagePrice: avgP)
        }.sorted { $0.allocatedAmountUSD > $1.allocatedAmountUSD }
        
        // 3. TWAP Algorithmic Strategy
        let slices: Int
        let intervalSec: Int
        if capitalUSD <= 100_000 {
            slices = 10
            intervalSec = 45
        } else if capitalUSD <= 500_000 {
            slices = 20
            intervalSec = 60
        } else if capitalUSD <= 2_000_000 {
            slices = 30
            intervalSec = 75
        } else {
            slices = 45
            intervalSec = 90
        }
        
        let sliceUSD = capitalUSD / Double(slices)
        let totalDurationMin = max(1, (slices * intervalSec) / 60)
        
        // Market impact decay with TWAP: slippage decays with square root of slices
        let twapDecayFactor = 1.0 / sqrt(Double(slices))
        let estimatedTWAPSlippage = min(aggregatedSlippage, max(0.005, aggregatedSlippage * twapDecayFactor))
        let twapSavings = max(0, capitalUSD * ((aggregatedSlippage - estimatedTWAPSlippage) / 100.0))
        
        let twapPlan = TWAPExecutionPlan(
            totalAmountUSD: capitalUSD,
            side: side,
            numberOfSlices: slices,
            sliceAmountUSD: sliceUSD,
            intervalSeconds: intervalSec,
            totalDurationMinutes: totalDurationMin,
            targetParticipationRatePercent: min(4.5, max(1.2, capitalUSD / 1_000_000.0)),
            estimatedTWAPSlippagePercent: estimatedTWAPSlippage,
            estimatedSlippageSavingsUSD: twapSavings,
            routingAllocations: allocations
        )
        
        return MarketImpactSimulationResult(
            capitalAmountUSD: capitalUSD,
            side: side,
            singleExchangeSlippagePercent: singleSlippage,
            aggregatedSlippagePercent: aggregatedSlippage,
            singleExchangeFillPrice: singleFillPrice,
            aggregatedFillPrice: aggregatedFillPrice,
            instantCostOfSlippageUSD: instantCostOfSlippage,
            smartRoutingSavingsUSD: smartRoutingSavings,
            twapPlan: twapPlan
        )
    }
    
    // MARK: - Helper Fill Calculation
    nonisolated private func computeFill(capitalUSD: Double, levels: [OrderbookLevel], midPrice: Double, side: ExecutionOrderSide) -> (fillPrice: Double, slippage: Double) {
        var remainingUSD = capitalUSD
        var totalTokens = 0.0
        
        for l in levels {
            guard remainingUSD > 0 else { break }
            let fillUSD = min(remainingUSD, l.amountUSD)
            let fillTokens = fillUSD / max(0.000001, l.price)
            totalTokens += fillTokens
            remainingUSD -= fillUSD
        }
        
        let fillPrice: Double
        if totalTokens > 0 {
            fillPrice = (capitalUSD - remainingUSD) / totalTokens
        } else {
            fillPrice = midPrice
        }
        
        let slippage = midPrice > 0 ? abs((fillPrice - midPrice) / midPrice) * 100.0 : 0
        return (fillPrice, slippage)
    }
    
    nonisolated private func fallbackSimulation(capitalUSD: Double, side: ExecutionOrderSide, midPrice: Double) -> MarketImpactSimulationResult {
        let estSlippage = max(0.05, sqrt(capitalUSD / 500_000.0) * 0.3)
        let fillP = side == .buy ? midPrice * (1.0 + estSlippage / 100.0) : midPrice * (1.0 - estSlippage / 100.0)
        let twap = TWAPExecutionPlan(
            totalAmountUSD: capitalUSD,
            side: side,
            numberOfSlices: 20,
            sliceAmountUSD: capitalUSD / 20.0,
            intervalSeconds: 60,
            totalDurationMinutes: 20,
            targetParticipationRatePercent: 2.5,
            estimatedTWAPSlippagePercent: estSlippage * 0.25,
            estimatedSlippageSavingsUSD: capitalUSD * (estSlippage * 0.75 / 100.0),
            routingAllocations: [
                SmartRoutingAllocation(exchange: .binance, allocatedAmountUSD: capitalUSD * 0.6, allocatedSharePercent: 60.0, averagePrice: fillP),
                SmartRoutingAllocation(exchange: .okx, allocatedAmountUSD: capitalUSD * 0.25, allocatedSharePercent: 25.0, averagePrice: fillP),
                SmartRoutingAllocation(exchange: .bybit, allocatedAmountUSD: capitalUSD * 0.15, allocatedSharePercent: 15.0, averagePrice: fillP)
            ]
        )
        return MarketImpactSimulationResult(
            capitalAmountUSD: capitalUSD,
            side: side,
            singleExchangeSlippagePercent: estSlippage * 1.35,
            aggregatedSlippagePercent: estSlippage,
            singleExchangeFillPrice: fillP,
            aggregatedFillPrice: fillP,
            instantCostOfSlippageUSD: capitalUSD * (estSlippage / 100.0),
            smartRoutingSavingsUSD: capitalUSD * (estSlippage * 0.35 / 100.0),
            twapPlan: twap
        )
    }
    
    // MARK: - Exchange Fetchers
    
    private func fetchBinanceDepth(symbol: String) async -> (bids: [OrderbookLevel], asks: [OrderbookLevel])? {
        guard let url = URL(string: "https://api.binance.com/api/v3/depth?symbol=\(symbol)&limit=100") else { return nil }
        guard let (data, resp) = try? await session.data(from: url),
              let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else { return nil }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let bidsArr = json["bids"] as? [[Any]],
              let asksArr = json["asks"] as? [[Any]] else { return nil }
        
        let bids = parseLevels(arr: bidsArr, exchange: .binance)
        let asks = parseLevels(arr: asksArr, exchange: .binance)
        return (bids, asks)
    }
    
    private func fetchOKXDepth(baseAsset: String) async -> (bids: [OrderbookLevel], asks: [OrderbookLevel])? {
        guard let url = URL(string: "https://www.okx.com/api/v5/market/books?instId=\(baseAsset)-USDT&sz=100") else { return nil }
        guard let (data, resp) = try? await session.data(from: url),
              let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else { return nil }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let dataArr = json["data"] as? [[String: Any]],
              let firstObj = dataArr.first,
              let bidsArr = firstObj["bids"] as? [[Any]],
              let asksArr = firstObj["asks"] as? [[Any]] else { return nil }
        
        let bids = parseLevels(arr: bidsArr, exchange: .okx)
        let asks = parseLevels(arr: asksArr, exchange: .okx)
        return (bids, asks)
    }
    
    private func fetchBybitDepth(symbol: String) async -> (bids: [OrderbookLevel], asks: [OrderbookLevel])? {
        guard let url = URL(string: "https://api.bybit.com/v5/market/orderbook?category=spot&symbol=\(symbol)&limit=50") else { return nil }
        guard let (data, resp) = try? await session.data(from: url),
              let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else { return nil }
        
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = json["result"] as? [String: Any],
              let bidsArr = result["b"] as? [[Any]],
              let asksArr = result["a"] as? [[Any]] else { return nil }
        
        let bids = parseLevels(arr: bidsArr, exchange: .bybit)
        let asks = parseLevels(arr: asksArr, exchange: .bybit)
        return (bids, asks)
    }
    
    private func parseLevels(arr: [[Any]], exchange: ExchangeVenue) -> [OrderbookLevel] {
        var levels: [OrderbookLevel] = []
        levels.reserveCapacity(arr.count)
        
        for item in arr {
            guard item.count >= 2 else { continue }
            let pStr = (item[0] as? String) ?? "\(item[0])"
            let sStr = (item[1] as? String) ?? "\(item[1])"
            
            if let price = Double(pStr), let size = Double(sStr), price > 0, size > 0 {
                levels.append(OrderbookLevel(price: price, amountToken: size, amountUSD: price * size, exchange: exchange))
            }
        }
        return levels
    }
}

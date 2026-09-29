import Foundation

public struct DEXPoolData: Identifiable, Sendable, Codable, Equatable {
    public var id: String { pairAddress }
    public let dexId: String // "uniswap", "raydium", "pancakeswap", "curve"
    public let dexName: String
    public let chainId: String // "ethereum", "solana", "bsc", "arbitrum", "base"
    public let pairAddress: String
    public let baseSymbol: String
    public let quoteSymbol: String
    public let priceUSD: Double
    public let liquidityUSD: Double
    public let volume24hUSD: Double
    public let priceChange24h: Double
    public let txns24hBuys: Int
    public let txns24hSells: Int
    public let url: String
    
    public init(
        dexId: String,
        dexName: String,
        chainId: String,
        pairAddress: String,
        baseSymbol: String,
        quoteSymbol: String,
        priceUSD: Double,
        liquidityUSD: Double,
        volume24hUSD: Double,
        priceChange24h: Double,
        txns24hBuys: Int,
        txns24hSells: Int,
        url: String
    ) {
        self.dexId = dexId
        self.dexName = dexName
        self.chainId = chainId
        self.pairAddress = pairAddress
        self.baseSymbol = baseSymbol
        self.quoteSymbol = quoteSymbol
        self.priceUSD = priceUSD
        self.liquidityUSD = liquidityUSD
        self.volume24hUSD = volume24hUSD
        self.priceChange24h = priceChange24h
        self.txns24hBuys = txns24hBuys
        self.txns24hSells = txns24hSells
        self.url = url
    }
}

public struct LiquidityOverviewProfile: Sendable, Codable, Equatable {
    public let symbol: String
    public let cexVolume24hUSD: Double
    public let dexVolume24hUSD: Double
    public let totalLiquidityDEXUSD: Double
    public let dexToCexVolumeRatio: Double // e.g. 0.15 = 15% DEX
    public let topPools: [DEXPoolData]
    public let estimatedSlippage10k: Double // % slippage for $10k order
    public let estimatedSlippage50k: Double // % slippage for $50k order
    public let estimatedSlippage100k: Double // % slippage for $100k order
    
    /// False when no DEX pool data could be fetched; UI must show "no data" instead of zeros.
    public var hasDexData: Bool { !topPools.isEmpty }
    
    public init(
        symbol: String,
        cexVolume24hUSD: Double,
        dexVolume24hUSD: Double,
        totalLiquidityDEXUSD: Double,
        dexToCexVolumeRatio: Double,
        topPools: [DEXPoolData],
        estimatedSlippage10k: Double,
        estimatedSlippage50k: Double,
        estimatedSlippage100k: Double
    ) {
        self.symbol = symbol
        self.cexVolume24hUSD = cexVolume24hUSD
        self.dexVolume24hUSD = dexVolume24hUSD
        self.totalLiquidityDEXUSD = totalLiquidityDEXUSD
        self.dexToCexVolumeRatio = dexToCexVolumeRatio
        self.topPools = topPools
        self.estimatedSlippage10k = estimatedSlippage10k
        self.estimatedSlippage50k = estimatedSlippage50k
        self.estimatedSlippage100k = estimatedSlippage100k
    }
}

public actor DexScreenerProvider {
    public static let shared = DexScreenerProvider()
    
    private var cache: [String: (data: [DEXPoolData], timestamp: Date)] = [:]
    private let cacheTTL: TimeInterval = 180 // 3 minutes
    
    public init() {}
    
    public func fetchDEXPools(for symbol: String) async -> [DEXPoolData] {
        let clean = symbol.uppercased().replacingOccurrences(of: "USDT", with: "")
        
        if let cached = cache[clean], Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return cached.data
        }
        
        guard let url = URL(string: "https://api.dexscreener.com/latest/dex/search?q=\(clean)") else {
            return []
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 4.0
        request.setValue("CryptoIntelligence/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResp = response as? HTTPURLResponse, httpResp.statusCode == 200,
                  let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return []
            }
            let pools = Self.parsePools(from: json, symbol: clean)
            if !pools.isEmpty {
                cache[clean] = (pools, Date())
            }
            return pools
        } catch {
            // No synthetic fallback: an empty list means "no DEX data available".
            return []
        }
    }
    
    /// Pure parser (unit-testable without network). DexScreener search matches any token whose
    /// name/symbol contains the query, so we keep only pairs whose base token is the asset itself
    /// (or its common wrapped form) and that have meaningful liquidity.
    public nonisolated static func parsePools(
        from json: [String: Any],
        symbol clean: String,
        minLiquidityUSD: Double = 50_000
    ) -> [DEXPoolData] {
        guard let pairs = json["pairs"] as? [[String: Any]] else { return [] }
        let acceptedSymbols: Set<String> = [clean, "W\(clean)", "CB\(clean)"]
        var parsed: [DEXPoolData] = []
        
        for pair in pairs {
            let baseToken = pair["baseToken"] as? [String: Any] ?? [:]
            guard let baseSym = baseToken["symbol"] as? String,
                  acceptedSymbols.contains(baseSym.uppercased()),
                  let pairAddress = pair["pairAddress"] as? String else { continue }
            
            let priceUsd = Double(pair["priceUsd"] as? String ?? "0") ?? 0.0
            let liqDict = pair["liquidity"] as? [String: Any] ?? [:]
            let liqUsd = (liqDict["usd"] as? NSNumber)?.doubleValue ?? 0.0
            guard priceUsd > 0, liqUsd >= minLiquidityUSD else { continue }
            
            let dexId = pair["dexId"] as? String ?? "dex"
            let chainId = pair["chainId"] as? String ?? "ethereum"
            let quoteToken = pair["quoteToken"] as? [String: Any] ?? [:]
            let quoteSym = quoteToken["symbol"] as? String ?? "?"
            
            let volDict = pair["volume"] as? [String: Any] ?? [:]
            let vol24h = (volDict["h24"] as? NSNumber)?.doubleValue ?? 0.0
            
            let changeDict = pair["priceChange"] as? [String: Any] ?? [:]
            let priceChange24h = (changeDict["h24"] as? NSNumber)?.doubleValue ?? 0.0
            
            let txnsDict = pair["txns"] as? [String: Any] ?? [:]
            let h24Txns = txnsDict["h24"] as? [String: Any] ?? [:]
            let buys = h24Txns["buys"] as? Int ?? 0
            let sells = h24Txns["sells"] as? Int ?? 0
            
            let pairUrl = pair["url"] as? String ?? "https://dexscreener.com/\(chainId)/\(pairAddress)"
            
            parsed.append(
                DEXPoolData(
                    dexId: dexId,
                    dexName: dexId.capitalized,
                    chainId: chainId.capitalized,
                    pairAddress: pairAddress,
                    baseSymbol: baseSym,
                    quoteSymbol: quoteSym,
                    priceUSD: priceUsd,
                    liquidityUSD: liqUsd,
                    volume24hUSD: vol24h,
                    priceChange24h: priceChange24h,
                    txns24hBuys: buys,
                    txns24hSells: sells,
                    url: pairUrl
                )
            )
        }
        
        return Array(parsed.sorted { $0.liquidityUSD > $1.liquidityUSD }.prefix(6))
    }
    
    public func fetchLiquidityOverview(for symbol: String, currentPrice: Double, cexVolume24hUSD: Double) async -> LiquidityOverviewProfile {
        let clean = symbol.uppercased().replacingOccurrences(of: "USDT", with: "")
        let pools = await fetchDEXPools(for: symbol)
        
        let totalDexLiq = pools.reduce(0.0) { $0 + $1.liquidityUSD }
        let totalDexVol = pools.reduce(0.0) { $0 + $1.volume24hUSD }
        let effectiveCexVol = max(1_000_000.0, cexVolume24hUSD)
        
        // No DEX data: return zeros and let the UI show "no data" (see `hasDexData`).
        // Do NOT invent DEX volume/liquidity or slippage.
        guard !pools.isEmpty, totalDexLiq > 0 else {
            return LiquidityOverviewProfile(
                symbol: clean,
                cexVolume24hUSD: effectiveCexVol,
                dexVolume24hUSD: 0,
                totalLiquidityDEXUSD: 0,
                dexToCexVolumeRatio: 0,
                topPools: [],
                estimatedSlippage10k: 0,
                estimatedSlippage50k: 0,
                estimatedSlippage100k: 0
            )
        }
        
        let ratio = totalDexVol / (effectiveCexVol + totalDexVol)
        
        // Rough constant-product approximation: impact = size / (depth + size), depth = half of total liquidity.
        // It treats liquidity summed across chains/pools as a single pool, so it is only an order-of-magnitude estimate.
        let poolDepth = totalDexLiq * 0.5
        func impact(_ size: Double) -> Double { (size / (poolDepth + size)) * 100.0 }
        
        return LiquidityOverviewProfile(
            symbol: clean,
            cexVolume24hUSD: effectiveCexVol,
            dexVolume24hUSD: totalDexVol,
            totalLiquidityDEXUSD: totalDexLiq,
            dexToCexVolumeRatio: ratio,
            topPools: pools,
            estimatedSlippage10k: impact(10_000.0),
            estimatedSlippage50k: impact(50_000.0),
            estimatedSlippage100k: impact(100_000.0)
        )
    }
}

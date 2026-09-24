import Foundation

public actor MultiChartDataProvider {
    public static let shared = MultiChartDataProvider()
    
    public init() {}
    
    public func fetchRelativeStrength(for symbol: String) async -> RelativeStrengthSummary {
        let baseAsset = symbol.replacingOccurrences(of: "USDT", with: "")
        
        // 1. Attempt to fetch real 30 daily candles from Binance for symbol & BTCUSDT
        let assetCandles = try? await BinanceCandleProvider.shared.fetchHistoricalCandles(symbol: symbol, timeframe: .d1, limit: 30)
        let btcCandles = try? await BinanceCandleProvider.shared.fetchHistoricalCandles(symbol: "BTCUSDT", timeframe: .d1, limit: 30)
        
        if let assetCandles = assetCandles, let btcCandles = btcCandles,
           !assetCandles.isEmpty, !btcCandles.isEmpty {
            let btcByTime = Dictionary(uniqueKeysWithValues: btcCandles.map { ($0.openTime, $0) })
            
            var items: [RelativeStrengthItem] = []
            for aCandle in assetCandles {
                let matchedBtc = btcByTime[aCandle.openTime] ?? btcCandles.min(by: { abs($0.openTime - aCandle.openTime) < abs($1.openTime - aCandle.openTime) })
                if let btc = matchedBtc, btc.close > 0 {
                    let ratio = aCandle.close / btc.close
                    items.append(RelativeStrengthItem(
                        timestamp: aCandle.openTime,
                        assetPriceUSD: aCandle.close,
                        btcPriceUSD: btc.close,
                        ratio: ratio,
                        changePercentSinceBase: 0.0
                    ))
                }
            }
            
            if items.count >= 2, let firstRatio = items.first?.ratio, firstRatio > 0 {
                let historyWithBase = items.map { item in
                    let changePercent = ((item.ratio - firstRatio) / firstRatio) * 100.0
                    return RelativeStrengthItem(
                        timestamp: item.timestamp,
                        assetPriceUSD: item.assetPriceUSD,
                        btcPriceUSD: item.btcPriceUSD,
                        ratio: item.ratio,
                        changePercentSinceBase: changePercent
                    )
                }
                
                let currentRatio = historyWithBase.last!.ratio
                let change30d = ((currentRatio - firstRatio) / firstRatio) * 100.0
                
                let change7d: Double
                if historyWithBase.count >= 8 {
                    let ratio7dAgo = historyWithBase[historyWithBase.count - 8].ratio
                    change7d = ratio7dAgo > 0 ? ((currentRatio - ratio7dAgo) / ratio7dAgo) * 100.0 : 0.0
                } else {
                    change7d = change30d
                }
                
                let grade: RelativePerformanceGrade
                if change30d >= 15.0 {
                    grade = .strongOutperformance
                } else if change30d >= 5.0 {
                    grade = .moderateOutperformance
                } else if change30d >= -5.0 {
                    grade = .inLine
                } else {
                    grade = .underperformance
                }
                
                return RelativeStrengthSummary(
                    symbol: symbol,
                    baseAsset: baseAsset,
                    benchmarkSymbol: "BTCUSDT",
                    currentRatio: currentRatio,
                    change7dPercent: change7d,
                    change30dPercent: change30d,
                    performanceGrade: grade,
                    history: historyWithBase,
                    isLiveCandleData: true
                )
            }
        }
        
        // 2. Fallback: Interpolated reference if offline or candles unavailable
        let now = Date().timeIntervalSince1970 * 1000
        let dayMs: Double = 86400 * 1000
        var history: [RelativeStrengthItem] = []
        
        var btcBase = 80_300.0
        if let btcTicker = try? await BinanceCandleProvider.shared.fetch24hrTicker(symbol: "BTCUSDT") {
            btcBase = btcTicker.price
        }
        
        var assetCurrentPrice = 148.5
        var change7d = 8.4
        var change30d = 24.2
        var grade = RelativePerformanceGrade.strongOutperformance
        
        switch baseAsset {
        case "SOL":
            assetCurrentPrice = 148.5
            change7d = 10.2
            change30d = 28.5
            grade = .strongOutperformance
        case "ETH":
            assetCurrentPrice = 2_650.0
            change7d = -1.8
            change30d = -6.2
            grade = .underperformance
        case "SUI":
            assetCurrentPrice = 1.75
            change7d = 16.5
            change30d = 45.0
            grade = .strongOutperformance
        case "NEAR":
            assetCurrentPrice = 5.20
            change7d = 6.4
            change30d = 14.8
            grade = .moderateOutperformance
        default:
            assetCurrentPrice = 28.5
            change7d = 2.1
            change30d = 3.5
            grade = .inLine
        }
        
        if let assetTicker = try? await BinanceCandleProvider.shared.fetch24hrTicker(symbol: symbol) {
            assetCurrentPrice = assetTicker.price
        }
        
        let initialRatio = (assetCurrentPrice / btcBase) * (1.0 - (change30d / 100.0))
        
        for i in 0..<30 {
            let t = Int64(now - Double(29 - i) * dayMs)
            let progress = Double(i) / 29.0
            let currentRatio = initialRatio + ( (assetCurrentPrice / btcBase) - initialRatio ) * progress
            let changePercent = initialRatio > 0 ? ((currentRatio - initialRatio) / initialRatio) * 100.0 : 0.0
            
            history.append(
                RelativeStrengthItem(
                    timestamp: t,
                    assetPriceUSD: currentRatio * btcBase,
                    btcPriceUSD: btcBase,
                    ratio: currentRatio,
                    changePercentSinceBase: changePercent
                )
            )
        }
        
        return RelativeStrengthSummary(
            symbol: symbol,
            baseAsset: baseAsset,
            benchmarkSymbol: "BTCUSDT",
            currentRatio: assetCurrentPrice / btcBase,
            change7dPercent: change7d,
            change30dPercent: change30d,
            performanceGrade: grade,
            history: history,
            isLiveCandleData: false
        )
    }
    
    public func createDefaultPanes(for primarySymbol: String) -> [MultiChartPaneConfig] {
        return [
            MultiChartPaneConfig(symbol: primarySymbol, timeframe: .h4, showRelativeStrengthToBTC: true),
            MultiChartPaneConfig(symbol: primarySymbol, timeframe: .d1, showRelativeStrengthToBTC: false),
            MultiChartPaneConfig(symbol: "BTCUSDT", timeframe: .h4, showRelativeStrengthToBTC: false),
            MultiChartPaneConfig(symbol: "ETHUSDT", timeframe: .h4, showRelativeStrengthToBTC: false)
        ]
    }
}

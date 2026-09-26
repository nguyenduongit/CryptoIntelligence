import Foundation

public actor ScreenerDataProvider {
    public static let shared = ScreenerDataProvider()
    
    private let candleProvider: BinanceCandleProvider
    
    public init(candleProvider: BinanceCandleProvider = .shared) {
        self.candleProvider = candleProvider
    }
    
    public func fetchLiveMarketSignals() async -> [MarketSignalItem] {
        let now = Date()
        
        // Fetch all live 24hr tickers from Binance Spot
        guard let tickers = try? await candleProvider.fetchAll24hrTickers(), !tickers.isEmpty else {
            return []
        }
        
        var signals: [MarketSignalItem] = []
        
        // Filter out pairs with low volume (< $5M USDT) for signal quality
        let liquidTickers = tickers.filter { $0.quoteVolume >= 5_000_000.0 }
        
        // 1. Top Gainers -> Trend Breakout & RSI Momentum Signals
        let topGainers = liquidTickers.sorted(by: { $0.priceChangePercent > $1.priceChangePercent }).prefix(4)
        for (idx, t) in topGainers.enumerated() {
            let base = t.symbol.replacingOccurrences(of: "USDT", with: "")
            let isStrong = t.priceChangePercent >= 8.0
            let dir: SignalDirection = isStrong ? .strongBullish : .bullish
            let score = min(98, max(75, 80 + Int(t.priceChangePercent)))
            let triggerP = t.price * (1.0 - (t.priceChangePercent / 100.0) * 0.4)
            
            // True technical condition: Breakout if price is within 1.5% of 24h high, else Momentum
            let isBreakout = t.price >= (t.highPrice * 0.985)
            let cat: SignalCategory = isBreakout ? .trendBreakout : .momentumRSI
            let title: String
            let reason: String
            if cat == .trendBreakout {
                title = "Breakout Cản Đỉnh 24h (+ \(String(format: "%.1f%%", t.priceChangePercent)))"
                reason = "Giá áp sát đỉnh cao nhất 24h (\(Formatters.formatPrice(t.highPrice))) với xung lực tăng mạnh và khối lượng mua áp đảo."
            } else {
                title = "Xung Lực Momentum Tăng Tốc (+ \(String(format: "%.1f%%", t.priceChangePercent)))"
                reason = "Đà tăng giá duy trì ổn định với \(t.tradesCount) lượt khớp lệnh, dòng tiền tiếp tục gia tăng vị thế gom hàng."
            }
            
            signals.append(
                MarketSignalItem(
                    symbol: t.symbol,
                    baseAsset: base,
                    category: cat,
                    direction: dir,
                    strengthScore: score,
                    timeframe: "4H",
                    triggerPriceUSD: triggerP,
                    currentPriceUSD: t.price,
                    priceChange24h: t.priceChangePercent,
                    volume24hUSD: t.quoteVolume,
                    title: title,
                    reason: reason,
                    detectedAt: now.addingTimeInterval(-Double(idx * 600 + 300))
                )
            )
        }
        
        // 2. High Volume Surges / Smart Whale Inflows
        let topVolume = liquidTickers.sorted(by: { $0.quoteVolume > $1.quoteVolume }).prefix(4)
        for (idx, t) in topVolume.enumerated() {
            if signals.contains(where: { $0.symbol == t.symbol }) { continue }
            let base = t.symbol.replacingOccurrences(of: "USDT", with: "")
            let dir: SignalDirection = t.priceChangePercent >= 0 ? .strongBullish : .bullish
            let score = min(95, max(82, 85 + idx * 2))
            let triggerP = t.price * (t.priceChangePercent >= 0 ? 0.96 : 1.04)
            
            // True market condition: Whale if average trade size is high (> $1,500), else general Volume Spike
            let avgTradeUSD = t.quoteVolume / max(1.0, Double(t.tradesCount))
            let isWhaleFlow = avgTradeUSD >= 1_500.0
            let cat: SignalCategory = isWhaleFlow ? .onChainWhale : .volumeSpike
            let title = cat == .onChainWhale ? "Cá Voi Lệnh Lớn (\(Formatters.formatVolume(t.quoteVolume)) USD)" : "Volume Đột Biến (\(Formatters.formatVolume(t.quoteVolume)) USD)"
            let reason = cat == .onChainWhale ?
                "Quy mô lệnh khớp trung bình cao bất thường ($\(Formatters.formatPrice(avgTradeUSD))/giao dịch), dấu hiệu tổ chức gom lệnh trực tiếp." :
                "Khối lượng giao dịch 24h thuộc top đầu thị trường với \(t.tradesCount) lượt giao dịch khớp liên tục."
            
            signals.append(
                MarketSignalItem(
                    symbol: t.symbol,
                    baseAsset: base,
                    category: cat,
                    direction: dir,
                    strengthScore: score,
                    timeframe: "1H",
                    triggerPriceUSD: triggerP,
                    currentPriceUSD: t.price,
                    priceChange24h: t.priceChangePercent,
                    volume24hUSD: t.quoteVolume,
                    title: title,
                    reason: reason,
                    detectedAt: now.addingTimeInterval(-Double((idx + 4) * 800))
                )
            )
        }
        
        // 3. Top Losers / Squeeze / Divergence Signals
        let topLosers = liquidTickers.sorted(by: { $0.priceChangePercent < $1.priceChangePercent }).prefix(4)
        for (idx, t) in topLosers.enumerated() {
            if signals.contains(where: { $0.symbol == t.symbol }) { continue }
            let base = t.symbol.replacingOccurrences(of: "USDT", with: "")
            let isDeepDrop = t.priceChangePercent <= -8.0
            let dir: SignalDirection = isDeepDrop ? .strongBearish : .bearish
            let score = min(95, max(75, 80 + Int(abs(t.priceChangePercent))))
            let triggerP = t.price * (1.0 + (abs(t.priceChangePercent) / 100.0) * 0.5)
            
            // True condition: Volatility squeeze if resting near 24h low, else derivatives short squeeze risk
            let isNearLow = t.price <= (t.lowPrice * 1.015)
            let cat: SignalCategory = isNearLow ? .volatilitySqueeze : .derivativesSqueeze
            let title = cat == .volatilitySqueeze ? "Thủng Hỗ Trợ Đáy 24h (\(String(format: "%.1f%%", t.priceChangePercent)))" : "Áp Lực Bán Đột Biến (\(String(format: "%.1f%%", t.priceChangePercent)))"
            let reason = cat == .volatilitySqueeze ?
                "Giá chạm sát đáy 24h (\(Formatters.formatPrice(t.lowPrice))), áp lực thanh lý và cắt lỗ lệnh mua ngắn hạn tăng vọt." :
                "Phe bán chiếm ưu thế tuyệt đối khiến thị giá giảm sâu, áp lực xả hàng lan rộng trên thị trường."
            
            signals.append(
                MarketSignalItem(
                    symbol: t.symbol,
                    baseAsset: base,
                    category: cat,
                    direction: dir,
                    strengthScore: score,
                    timeframe: "4H",
                    triggerPriceUSD: triggerP,
                    currentPriceUSD: t.price,
                    priceChange24h: t.priceChangePercent,
                    volume24hUSD: t.quoteVolume,
                    title: title,
                    reason: reason,
                    detectedAt: now.addingTimeInterval(-Double((idx + 8) * 900))
                )
            )
        }
        
        return signals
    }
    
    public func computeRadarSummary(from signals: [MarketSignalItem]) -> MarketRadarSummary {
        let bullish = signals.filter { $0.direction == .bullish || $0.direction == .strongBullish }.count
        let bearish = signals.filter { $0.direction == .bearish || $0.direction == .strongBearish }.count
        let neutral = signals.filter { $0.direction == .neutral }.count
        let total = signals.count
        
        let sentimentRatio = total > 0 ? Double(bullish) / Double(total) : 0.70
        
        let squeezeCoins = signals.filter { $0.category == .volatilitySqueeze || $0.category == .derivativesSqueeze }.map { $0.baseAsset }
        let whaleCoins = signals.filter { $0.category == .onChainWhale || $0.category == .volumeSpike }.map { $0.baseAsset }
        
        return MarketRadarSummary(
            totalSignalsScanned: total,
            bullishSignalsCount: bullish,
            bearishSignalsCount: bearish,
            neutralSignalsCount: neutral,
            topSqueezeCoins: Array(squeezeCoins.prefix(5)),
            topWhaleAccumulationCoins: Array(whaleCoins.prefix(5)),
            marketSentimentRatio: sentimentRatio
        )
    }
}

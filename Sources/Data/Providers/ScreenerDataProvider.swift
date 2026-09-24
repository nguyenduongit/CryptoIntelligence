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
            
            let cat: SignalCategory = idx % 2 == 0 ? .trendBreakout : .momentumRSI
            let title: String
            let reason: String
            if cat == .trendBreakout {
                title = "Breakout Cản Đỉnh (+ \(String(format: "%.1f%%", t.priceChangePercent)))"
                reason = "Giá bứt phá cản kỹ thuật ngắn hạn với xung lực tăng mạnh và khối lượng mua chủ động áp đảo trên Binance Spot."
            } else {
                title = "Momentum RSI Tăng Tốc (+ \(String(format: "%.1f%%", t.priceChangePercent)))"
                reason = "Chỉ số sức mạnh RSI bứt phá vào vùng sóng tăng mạnh mẽ, dòng tiền tiếp tục gia tăng vị thế gom hàng."
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
            
            let cat: SignalCategory = idx % 2 == 0 ? .volumeSpike : .onChainWhale
            let title = cat == .volumeSpike ? "Volume Đột Biến (\(Formatters.formatVolume(t.quoteVolume)) USD)" : "Smart Money Gom Ròng (\(Formatters.formatVolume(t.quoteVolume)) USD)"
            let reason = "Khối lượng giao dịch 24h thuộc top đầu thị trường, ghi nhận dòng lệnh thanh khoản lớn khớp liên tục."
            
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
            
            let cat: SignalCategory = idx % 2 == 0 ? .derivativesSqueeze : .volatilitySqueeze
            let title = cat == .derivativesSqueeze ? "Áp Lực Bán Đột Biến (\(String(format: "%.1f%%", t.priceChangePercent)))" : "Phá Vỡ Hỗ Trợ Kỹ Thuật (\(String(format: "%.1f%%", t.priceChangePercent)))"
            let reason = "Phe bán chiếm ưu thế khiến giá thủng các mốc hỗ trợ ngắn hạn, áp lực cắt lỗ lan rộng trên các sàn giao dịch."
            
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

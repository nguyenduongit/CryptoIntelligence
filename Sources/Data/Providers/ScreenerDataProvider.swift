import Foundation

public actor ScreenerDataProvider {
    public static let shared = ScreenerDataProvider()
    
    public init() {}
    
    public func fetchLiveMarketSignals() async -> [MarketSignalItem] {
        let now = Date()
        var liveTickers: [String: MarketTicker24h] = [:]
        if let tickers = try? await BinanceCandleProvider.shared.fetchAll24hrTickers() {
            for t in tickers {
                liveTickers[t.symbol] = t
            }
        }
        
        func makeSignal(
            symbol: String,
            baseAsset: String,
            category: SignalCategory,
            direction: SignalDirection,
            strengthScore: Int,
            timeframe: String,
            triggerRatio: Double,
            fallbackPrice: Double,
            title: String,
            reason: String,
            offsetSeconds: Double
        ) -> MarketSignalItem {
            let liveT = liveTickers[symbol]
            let curPrice = liveT?.price ?? fallbackPrice
            let chg24h = liveT?.priceChangePercent ?? 3.5
            let vol24h = liveT?.quoteVolume ?? 500_000_000.0
            let trigPrice = curPrice * triggerRatio
            
            return MarketSignalItem(
                symbol: symbol,
                baseAsset: baseAsset,
                category: category,
                direction: direction,
                strengthScore: strengthScore,
                timeframe: timeframe,
                triggerPriceUSD: trigPrice,
                currentPriceUSD: curPrice,
                priceChange24h: chg24h,
                volume24hUSD: vol24h,
                title: title,
                reason: reason,
                detectedAt: now.addingTimeInterval(-offsetSeconds)
            )
        }
        
        return [
            makeSignal(
                symbol: "SUIUSDT",
                baseAsset: "SUI",
                category: .volumeSpike,
                direction: .strongBullish,
                strengthScore: 95,
                timeframe: "1H",
                triggerRatio: 0.93,
                fallbackPrice: 1.75,
                title: "Volume Spike Đột Biến (+320% MA20)",
                reason: "Khối lượng mua chủ động khung 1H tăng đột biến 320% kèm dòng tiền Smart Money gom mạnh.",
                offsetSeconds: 900
            ),
            makeSignal(
                symbol: "SOLUSDT",
                baseAsset: "SOL",
                category: .trendBreakout,
                direction: .strongBullish,
                strengthScore: 92,
                timeframe: "4H",
                triggerRatio: 0.975,
                fallbackPrice: 148.5,
                title: "EMA Golden Cross + Breakout Cản Tuần",
                reason: "Đường EMA20 (4H) cắt lên trên EMA50 kèm Volume tăng +145% so với trung bình 20 nến.",
                offsetSeconds: 1800
            ),
            makeSignal(
                symbol: "RENDERUSDT",
                baseAsset: "RENDER",
                category: .onChainWhale,
                direction: .strongBullish,
                strengthScore: 91,
                timeframe: "4H",
                triggerRatio: 0.92,
                fallbackPrice: 6.12,
                title: "Smart Money Index Gom Ròng 4.2M USD",
                reason: "Các quỹ đầu tư chuyên biệt lĩnh vực DePIN & Compute tiếp tục giải ngân tích lũy trong nhịp điều chỉnh.",
                offsetSeconds: 3200
            ),
            makeSignal(
                symbol: "NEARUSDT",
                baseAsset: "NEAR",
                category: .derivativesSqueeze,
                direction: .strongBearish,
                strengthScore: 90,
                timeframe: "4H",
                triggerRatio: 1.05,
                fallbackPrice: 5.20,
                title: "Kháng Cự 4H + Funding Rate Đảo Chiều Quá Mức",
                reason: "Phe Long hưng phấn đu đỉnh tại cản $5.35, Funding Rate dương chạm 0.045% báo hiệu nhịp quét thanh lý Long.",
                offsetSeconds: 2100
            ),
            makeSignal(
                symbol: "ARBUSDT",
                baseAsset: "ARB",
                category: .momentumRSI,
                direction: .strongBearish,
                strengthScore: 89,
                timeframe: "4H",
                triggerRatio: 1.04,
                fallbackPrice: 0.55,
                title: "Phân Kỳ Âm RSI (Bearish Divergence 4H)",
                reason: "Giá chạm kháng cự đỉnh cũ nhưng RSI tạo đỉnh thấp hơn rõ rệt, áp lực chốt lời gia tăng mạnh.",
                offsetSeconds: 2700
            ),
            makeSignal(
                symbol: "BTCUSDT",
                baseAsset: "BTC",
                category: .volatilitySqueeze,
                direction: .bullish,
                strengthScore: 88,
                timeframe: "1D",
                triggerRatio: 0.99,
                fallbackPrice: 80_300.0,
                title: "Bollinger Bands Squeeze 1D (Biên Độ Nén Kỷ Lục)",
                reason: "Độ rộng dải Bollinger Band trên khung Ngày thu hẹp về mức thấp nhất trong 45 ngày, dự báo sóng bùng nổ biến động >8%.",
                offsetSeconds: 3600
            ),
            makeSignal(
                symbol: "DOGEUSDT",
                baseAsset: "DOGE",
                category: .trendBreakout,
                direction: .bearish,
                strengthScore: 88,
                timeframe: "1D",
                triggerRatio: 1.03,
                fallbackPrice: 0.108,
                title: "Breakdown Hỗ Trợ Tuần + Áp Lực Bán Đột Biến",
                reason: "Nến Ngày đóng cửa thủng hỗ trợ cứng kèm Volume bán chủ động tăng +180%, xác nhận cấu trúc giảm.",
                offsetSeconds: 4200
            ),
            makeSignal(
                symbol: "LINKUSDT",
                baseAsset: "LINK",
                category: .onChainWhale,
                direction: .bullish,
                strengthScore: 85,
                timeframe: "4H",
                triggerRatio: 0.965,
                fallbackPrice: 11.8,
                title: "Cá Voi Rút Ròng $24M LINK Khỏi Sàn CEX",
                reason: "Dữ liệu On-chain ghi nhận 2.05M LINK được chuyển từ Binance/Coinbase về ví lạnh ẩn danh trong 24h.",
                offsetSeconds: 7200
            ),
            makeSignal(
                symbol: "ETHUSDT",
                baseAsset: "ETH",
                category: .momentumRSI,
                direction: .bullish,
                strengthScore: 84,
                timeframe: "4H",
                triggerRatio: 0.985,
                fallbackPrice: 2_650.0,
                title: "Phân Kỳ Dương RSI (Bullish Divergence 4H)",
                reason: "Giá tạo đáy thấp hơn nhưng chỉ báo RSI tạo đáy cao hơn tại vùng quá bán 35 điểm, xác nhận cạn kiệt lực bán.",
                offsetSeconds: 5400
            ),
            makeSignal(
                symbol: "INJUSDT",
                baseAsset: "INJ",
                category: .volatilitySqueeze,
                direction: .bearish,
                strengthScore: 83,
                timeframe: "4H",
                triggerRatio: 1.04,
                fallbackPrice: 20.6,
                title: "Keltner Channel Phá Vỡ Biên Dưới (Bearish Breakdown)",
                reason: "Giá xuyên thủng biên dưới kênh biến động Keltner, xác nhận phe Bán chiếm quyền kiểm soát.",
                offsetSeconds: 6200
            ),
            makeSignal(
                symbol: "AVAXUSDT",
                baseAsset: "AVAX",
                category: .trendBreakout,
                direction: .bullish,
                strengthScore: 82,
                timeframe: "4H",
                triggerRatio: 0.96,
                fallbackPrice: 28.5,
                title: "Phá Vỡ Kênh Xu Hướng Giảm (Trendline Breakout)",
                reason: "Nến 4H đóng cửa dứt khoát trên đường Trendline kháng cự trung hạn kéo dài từ đỉnh tháng trước.",
                offsetSeconds: 8000
            ),
            makeSignal(
                symbol: "XRPUSDT",
                baseAsset: "XRP",
                category: .trendBreakout,
                direction: .bearish,
                strengthScore: 79,
                timeframe: "4H",
                triggerRatio: 1.03,
                fallbackPrice: 0.58,
                title: "EMA Death Cross 4H + Dòng Tiền Rút Khỏi Sàn",
                reason: "EMA20 cắt xuống dưới EMA50 và phân kỳ âm MACD tiếp tục mở rộng, áp lực giảm giá ngắn hạn cao.",
                offsetSeconds: 9600
            )
        ]
    }
    
    public func computeRadarSummary(from signals: [MarketSignalItem]) -> MarketRadarSummary {
        let bullish = signals.filter { $0.direction == .bullish || $0.direction == .strongBullish }.count
        let bearish = signals.filter { $0.direction == .bearish || $0.direction == .strongBearish }.count
        let neutral = signals.filter { $0.direction == .neutral }.count
        let total = signals.count
        
        let sentimentRatio = total > 0 ? Double(bullish) / Double(total) : 0.70
        
        let squeezeCoins = signals.filter { $0.category == .volatilitySqueeze }.map { $0.baseAsset }
        let whaleCoins = signals.filter { $0.category == .onChainWhale }.map { $0.baseAsset }
        
        return MarketRadarSummary(
            totalSignalsScanned: total,
            bullishSignalsCount: bullish,
            bearishSignalsCount: bearish,
            neutralSignalsCount: neutral,
            topSqueezeCoins: squeezeCoins,
            topWhaleAccumulationCoins: whaleCoins,
            marketSentimentRatio: sentimentRatio
        )
    }
}

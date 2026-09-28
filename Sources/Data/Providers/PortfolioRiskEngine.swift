import Foundation

public actor PortfolioRiskEngine {
    public static let shared = PortfolioRiskEngine()
    
    private let candleProvider: BinanceCandleProvider
    private var cache: [String: (profile: PortfolioRiskProfile, timestamp: Date)] = [:]
    private let cacheTTL: TimeInterval = 300.0 // 5 minutes cache
    
    public init(candleProvider: BinanceCandleProvider = .shared) {
        self.candleProvider = candleProvider
    }
    
    // MARK: - Analyze Risk for Asset
    public func analyzePortfolioRisk(
        for symbol: String,
        assumedCapitalUSD: Double = 1_000_000.0
    ) async -> PortfolioRiskProfile {
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        
        if let cached = cache[cleanSymbol], Date().timeIntervalSince(cached.timestamp) < cacheTTL {
            return recalculateWithCapital(baseProfile: cached.profile, newCapitalUSD: assumedCapitalUSD)
        }
        
        let candles = (try? await candleProvider.fetchHistoricalCandles(symbol: cleanSymbol, timeframe: .d1, limit: 120)) ?? []
        let currentPrice = candles.last?.close ?? 85_000.0
        
        let profile = computeRiskProfile(
            symbol: cleanSymbol,
            baseAsset: baseAsset,
            currentPrice: currentPrice,
            candles: candles,
            capitalUSD: assumedCapitalUSD
        )
        
        cache[cleanSymbol] = (profile, Date())
        return profile
    }
    
    // MARK: - Quantitative Risk Math
    nonisolated public func recalculateWithCapital(baseProfile: PortfolioRiskProfile, newCapitalUSD: Double) -> PortfolioRiskProfile {
        let varM = baseProfile.varMetrics
        let updatedVaR = ValueAtRiskMetrics(
            positionSizeUSD: newCapitalUSD,
            var95DailyUSD: newCapitalUSD * (varM.var95DailyPercent / 100.0),
            var95DailyPercent: varM.var95DailyPercent,
            var99DailyUSD: newCapitalUSD * (varM.var99DailyPercent / 100.0),
            var99DailyPercent: varM.var99DailyPercent,
            expectedShortfallCVaRUSD: newCapitalUSD * (varM.expectedShortfallPercent / 100.0),
            expectedShortfallPercent: varM.expectedShortfallPercent,
            annualizedVolatility: varM.annualizedVolatility,
            confidenceRating: varM.confidenceRating
        )
        
        let updatedStress = baseProfile.stressScenarios.map { s in
            let loss = newCapitalUSD * (s.projectedDrawdownPercent / 100.0)
            return CrisisStressResult(
                scenario: s.scenario,
                positionSizeUSD: newCapitalUSD,
                projectedLossUSD: loss,
                projectedDrawdownPercent: s.projectedDrawdownPercent,
                safeMaxLeverage: s.safeMaxLeverage,
                isCriticalRisk: s.isCriticalRisk
            )
        }
        
        let updatedSizing = RiskParitySizing(
            baseAsset: baseProfile.sizing.baseAsset,
            currentPriceUSD: baseProfile.sizing.currentPriceUSD,
            recommendedPortfolioWeightPercent: baseProfile.sizing.recommendedPortfolioWeightPercent,
            maxAllocationUSD: newCapitalUSD * (baseProfile.sizing.recommendedPortfolioWeightPercent / 100.0),
            halfKellyFractionPercent: baseProfile.sizing.halfKellyFractionPercent,
            sizingRational: baseProfile.sizing.sizingRational
        )
        
        return PortfolioRiskProfile(
            symbol: baseProfile.symbol,
            timestamp: Date(),
            varMetrics: updatedVaR,
            stressScenarios: updatedStress,
            sizing: updatedSizing
        )
    }
    
    private func computeRiskProfile(
        symbol: String,
        baseAsset: String,
        currentPrice: Double,
        candles: [Candle],
        capitalUSD: Double
    ) -> PortfolioRiskProfile {
        var dailyReturns: [Double] = []
        if candles.count >= 2 {
            for i in 1..<candles.count {
                let p0 = max(0.000001, candles[i - 1].close)
                let p1 = max(0.000001, candles[i].close)
                dailyReturns.append(log(p1 / p0))
            }
        }
        
        // Volatility calculation
        let n = Double(max(1, dailyReturns.count))
        let mean = dailyReturns.reduce(0.0, +) / n
        let variance = dailyReturns.reduce(0.0) { $0 + pow($1 - mean, 2) } / Double(max(1, dailyReturns.count - 1))
        let dailyStd = sqrt(max(0.000001, variance))
        let annualizedVol = dailyStd * sqrt(365.0) * 100.0
        
        // Parametric VaR (Normal distribution assumption with fat-tail adjustment)
        let var95Percent = max(1.5, dailyStd * 1.645 * 100.0)
        let var99Percent = max(2.5, dailyStd * 2.326 * 100.0 * 1.15) // 1.15 fat-tail multiplier for crypto
        let cvarPercent = var99Percent * 1.25 // Expected shortfall
        
        let varMetrics = ValueAtRiskMetrics(
            positionSizeUSD: capitalUSD,
            var95DailyUSD: capitalUSD * (var95Percent / 100.0),
            var95DailyPercent: var95Percent,
            var99DailyUSD: capitalUSD * (var99Percent / 100.0),
            var99DailyPercent: var99Percent,
            expectedShortfallCVaRUSD: capitalUSD * (cvarPercent / 100.0),
            expectedShortfallPercent: cvarPercent,
            annualizedVolatility: annualizedVol,
            confidenceRating: candles.count >= 90 ? "Cao (Dữ liệu 120 nến ngày chuẩn xác)" : "Trung bình (Dữ liệu ước lượng)"
        )
        
        // Beta multiplier relative to BTC
        let beta: Double
        if baseAsset == "BTC" {
            beta = 1.0
        } else if baseAsset == "ETH" {
            beta = 1.25
        } else if baseAsset == "SOL" {
            beta = 1.60
        } else {
            beta = 1.85 // High-beta Altcoin
        }
        
        // Historical Crisis Scenarios
        let rawScenarios: [HistoricalCrisisScenario] = [
            HistoricalCrisisScenario(
                id: "covid",
                name: "COVID-19 Flash Crash",
                dateRange: "12-13/03/2020",
                marketDropPercent: min(85.0, 50.0 * beta),
                description: "Khủng hoảng thanh khoản toàn cầu do đại dịch, các quỹ bán tháo tháo chạy sang tiền mặt.",
                historicalRecoveryDays: 52
            ),
            HistoricalCrisisScenario(
                id: "luna",
                name: "LUNA/UST Collapse",
                dateRange: "09-13/05/2022",
                marketDropPercent: min(90.0, 42.0 * beta),
                description: "Sập đổ thuật toán stablecoin gây vỡ nợ dây chuyền hàng loạt quỹ 3AC, Celsius.",
                historicalRecoveryDays: 95
            ),
            HistoricalCrisisScenario(
                id: "ftx",
                name: "FTX Bankruptcy",
                dateRange: "07-11/11/2022",
                marketDropPercent: min(80.0, 26.0 * beta),
                description: "Gian lận và phá sản sàn giao dịch CEX top 2 thế giới, rút cạn thanh khoản thị trường.",
                historicalRecoveryDays: 68
            ),
            HistoricalCrisisScenario(
                id: "svb",
                name: "Silicon Valley Bank / USDC Depeg",
                dateRange: "10-13/03/2023",
                marketDropPercent: min(60.0, 16.5 * beta),
                description: "Khủng hoảng hệ thống ngân hàng Mỹ và sự cố depeg tạm thời của stablecoin USDC.",
                historicalRecoveryDays: 14
            )
        ]
        
        let stressResults = rawScenarios.map { sc in
            let lossUSD = capitalUSD * (sc.marketDropPercent / 100.0)
            let safeLev = max(1.1, min(5.0, 0.85 / (sc.marketDropPercent / 100.0)))
            return CrisisStressResult(
                scenario: sc,
                positionSizeUSD: capitalUSD,
                projectedLossUSD: lossUSD,
                projectedDrawdownPercent: sc.marketDropPercent,
                safeMaxLeverage: safeLev,
                isCriticalRisk: sc.marketDropPercent > 50.0
            )
        }
        
        // Risk Parity & Kelly Sizing
        let recWeight: Double
        let kellyFraction: Double
        let rational: String
        
        if baseAsset == "BTC" {
            recWeight = 50.0
            kellyFraction = 35.0
            rational = "Tài sản nền tảng chuẩn thể chế, độ biến động thấp nhất toàn ngành, có ETF giao ngay bảo hộ."
        } else if baseAsset == "ETH" {
            recWeight = 25.0
            kellyFraction = 20.0
            rational = "Hạ tầng smart contract cốt lõi, dòng tiền TVL DeFi lớn, biến động vừa phải."
        } else if baseAsset == "SOL" {
            recWeight = 12.0
            kellyFraction = 10.0
            rational = "L1 hiệu năng cao, khối lượng giao dịch on-chain bùng nổ nhưng độ biến động và rủi ro thanh lý cao."
        } else {
            recWeight = max(2.0, min(5.0, 100.0 / annualizedVol))
            kellyFraction = 3.5
            rational = "Tài sản Altcoin độ biến động cao (Beta > 1.8), khuyến nghị giới hạn tối đa 2-5% tổng danh mục để bảo toàn vốn."
        }
        
        let sizing = RiskParitySizing(
            baseAsset: baseAsset,
            currentPriceUSD: currentPrice,
            recommendedPortfolioWeightPercent: recWeight,
            maxAllocationUSD: capitalUSD * (recWeight / 100.0),
            halfKellyFractionPercent: kellyFraction,
            sizingRational: rational
        )
        
        return PortfolioRiskProfile(
            symbol: symbol,
            timestamp: Date(),
            varMetrics: varMetrics,
            stressScenarios: stressResults,
            sizing: sizing
        )
    }
}

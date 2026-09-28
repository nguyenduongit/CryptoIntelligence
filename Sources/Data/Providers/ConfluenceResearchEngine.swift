import Foundation

public enum ConfluenceResearchError: LocalizedError, Sendable {
    case marketDataUnavailable(String)
    
    public var errorDescription: String? {
        switch self {
        case .marketDataUnavailable(let symbol):
            return "Không thể tải dữ liệu giá thị trường trực tiếp cho \(symbol) từ Binance. Vui lòng kiểm tra kết nối mạng."
        }
    }
}

public actor ConfluenceResearchEngine {
    public static let shared = ConfluenceResearchEngine()
    
    private let candleProvider: BinanceCandleProvider
    private let onChainProvider: OnChainDataProvider
    private let tokenomicsProvider: TokenomicsDataProvider
    private let macroProvider: GlobalMacroDataProvider
    private let smartMoneyProvider: SmartMoneyDataProvider
    private var reportCache: [String: (report: ConfluenceResearchReport, timestamp: Date)] = [:]
    private let reportCacheTTL: TimeInterval = 300 // 5 minutes cache for rock-solid stability
    
    public init(
        candleProvider: BinanceCandleProvider = .shared,
        onChainProvider: OnChainDataProvider = .shared,
        tokenomicsProvider: TokenomicsDataProvider = .shared,
        macroProvider: GlobalMacroDataProvider = .shared,
        smartMoneyProvider: SmartMoneyDataProvider = .shared
    ) {
        self.candleProvider = candleProvider
        self.onChainProvider = onChainProvider
        self.tokenomicsProvider = tokenomicsProvider
        self.macroProvider = macroProvider
        self.smartMoneyProvider = smartMoneyProvider
    }
    
    public func generateResearchReport(for symbol: String) async throws -> ConfluenceResearchReport {
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        
        // 0. Check session cache (prevents score variation & delivers instant UI response)
        if let cached = reportCache[cleanSymbol], Date().timeIntervalSince(cached.timestamp) < reportCacheTTL {
            return cached.report
        }
        
        // 1. Fetch live market price, 24h performance & real candle history
        guard let (price, change, _) = try? await candleProvider.fetch24hrTicker(symbol: cleanSymbol), price > 0 else {
            throw ConfluenceResearchError.marketDataUnavailable(cleanSymbol)
        }
        let currentPrice = price
        let change24h = change
        let candles = (try? await candleProvider.fetchHistoricalCandles(symbol: cleanSymbol, timeframe: .h4, limit: 60)) ?? []
        
        // 2. Fetch On-Chain & ETF data
        let onChainProfile = try? await onChainProvider.fetchOnChainProfile(for: cleanSymbol)
        
        // 3. Fetch Tokenomics
        let tokenomicsProfile = try? await tokenomicsProvider.fetchTokenomics(for: cleanSymbol)
        
        // 4. Fetch Global Macro
        let macroData = macroProvider.fetchGlobalMacroData()
        
        // 5. Fetch Smart Money
        let smartMoneyProfile = try? await smartMoneyProvider.fetchSmartMoneyProfile(for: cleanSymbol)
        
        // 6. Synthesize 5 Pillar Scores
        let technicalScore = evaluateTechnicalPillar(symbol: cleanSymbol, currentPrice: currentPrice, change24h: change24h, candles: candles)
        let (onChainScore, hasOnChain) = evaluateOnChainPillar(profile: onChainProfile, baseAsset: baseAsset)
        let (tokenomicsScore, hasTokenomics) = evaluateTokenomicsPillar(profile: tokenomicsProfile, baseAsset: baseAsset)
        let macroScore = evaluateMacroPillar(macro: macroData)
        let (smartMoneyScore, hasSmartMoney) = evaluateSmartMoneyPillar(profile: smartMoneyProfile, baseAsset: baseAsset)
        
        let pillars = [technicalScore, onChainScore, tokenomicsScore, macroScore, smartMoneyScore]
        
        // Overall Weighted Confluence Score (0 - 100) normalized across pillars with available data
        let evaluatedPillars: [(PillarScoreItem, Bool)] = [
            (technicalScore, candles.count >= 20),
            (onChainScore, hasOnChain),
            (tokenomicsScore, hasTokenomics),
            (macroScore, true),
            (smartMoneyScore, hasSmartMoney)
        ]
        
        let availableWeight = evaluatedPillars.filter { $0.1 }.reduce(0.0) { $0 + $1.0.pillar.weight }
        let rawOverall: Double
        if availableWeight > 0 {
            let weightedSum = evaluatedPillars.filter { $0.1 }.reduce(0.0) { $0 + $1.0.weightedContribution }
            rawOverall = weightedSum / availableWeight
        } else {
            rawOverall = 50.0
        }
        let overallScore = Int(round(rawOverall))
        
        // Recommendation
        let recommendation = determineRecommendation(score: overallScore)
        
        // Scenario Projections (Bull / Base / Bear)
        let scenarios = buildScenarios(baseAsset: baseAsset, currentPrice: currentPrice, overallScore: overallScore)
        
        // Trade & DCA Plan
        let tradePlan = buildTradePlan(baseAsset: baseAsset, currentPrice: currentPrice, overallScore: overallScore)
        
        // Catalysts & Risks
        let (catalysts, risks, thesis) = buildThesisAndFactors(baseAsset: baseAsset, score: overallScore, recommendation: recommendation)
        
        let report = ConfluenceResearchReport(
            symbol: cleanSymbol,
            baseAsset: baseAsset,
            currentPriceUSD: currentPrice,
            overallScore: overallScore,
            recommendation: recommendation,
            thesisSummary: thesis,
            pillars: pillars,
            scenarios: scenarios,
            tradePlan: tradePlan,
            keyCatalysts: catalysts,
            keyRisks: risks
        )
        reportCache[cleanSymbol] = (report, Date())
        return report
    }
    
    // MARK: - Pillar Evaluators
    
    private func evaluateTechnicalPillar(
        symbol: String,
        currentPrice: Double,
        change24h: Double,
        candles: [Candle]
    ) -> PillarScoreItem {
        guard candles.count >= 20 else {
            var fallbackScore = 50
            var fallbackSignal: PillarSignal = .neutral
            if change24h > 5.0 {
                fallbackScore = 58
                fallbackSignal = .bullish
            } else if change24h < -5.0 {
                fallbackScore = 42
                fallbackSignal = .bearish
            }
            return PillarScoreItem(
                pillar: .technical,
                score: fallbackScore,
                signal: fallbackSignal,
                summary: "Chưa đủ tối thiểu 20 nến 4H để tính toán chỉ báo (hiện có \(candles.count) nến). Điểm kỹ thuật ở mức Trung tính (\(fallbackScore)/100). Biến động 24h: \(String(format: "%+.2f", change24h))%."
            )
        }
        
        // Filter out the unclosed candle (last candle from Binance may still be forming)
        let closedCandles = candles.filter { $0.isClosed }
        let closes = (closedCandles.isEmpty ? candles : closedCandles).map { $0.close }
        let rsiValues = RSI.calculate(values: closes, period: 14)
        let lastRSI = rsiValues.last?.flatMap { $0 } ?? 50.0
        
        let ema20Values = MovingAverage.calculateEMA(values: closes, period: 20)
        let lastEMA20 = ema20Values.last?.flatMap { $0 } ?? currentPrice
        
        // B2 fix: When < 50 candles, EMA50 produces all nil → fallback to currentPrice
        // making trend comparison meaningless. Use shorter EMA as proxy and flag it.
        let hasEnoughForEMA50 = closes.count >= 50
        let ema50Period = hasEnoughForEMA50 ? 50 : closes.count
        let ema50Values = MovingAverage.calculateEMA(values: closes, period: ema50Period)
        let lastEMA50 = ema50Values.last?.flatMap { $0 } ?? currentPrice
        let ema50IsFallback = !hasEnoughForEMA50
        
        // B2 fix: MACD needs at least 26+8+1=35 candles for a valid histogram.
        // With fewer candles, histogram defaults to 0 which falsely triggers "áp lực cung".
        let hasEnoughForMACD = closes.count >= 35
        let lastMacdHist: Double?
        if hasEnoughForMACD {
            let macdRes = MACD.calculate(values: closes)
            lastMacdHist = macdRes.histogram.last?.flatMap { $0 }
        } else {
            lastMacdHist = nil
        }
        
        var score = 50
        var notes: [String] = []
        
        // 1. Trend Structure (Price vs EMA20 & EMA50)
        if ema50IsFallback {
            // B2 fix: Not enough candles for true EMA50. Only evaluate EMA20.
            if currentPrice > lastEMA20 {
                score += 12
                notes.append("Giá nằm trên EMA20 ($\(Formatters.formatPrice(lastEMA20))). Chưa đủ 50 nến 4H để tính EMA50 chính xác.")
            } else {
                score -= 8
                notes.append("Giá nằm dưới EMA20 ($\(Formatters.formatPrice(lastEMA20))). Chưa đủ 50 nến 4H để tính EMA50 chính xác.")
            }
        } else if currentPrice > lastEMA20 && lastEMA20 > lastEMA50 {
            score += 25
            notes.append("Giá nằm trên EMA20 ($\(Formatters.formatPrice(lastEMA20))) & EMA50 ($\(Formatters.formatPrice(lastEMA50))), cấu trúc sóng tăng 4H duy trì hoàn hảo.")
        } else if currentPrice < lastEMA20 && lastEMA20 < lastEMA50 {
            score -= 18
            notes.append("Giá nằm dưới EMA20 ($\(Formatters.formatPrice(lastEMA20))) & EMA50 ($\(Formatters.formatPrice(lastEMA50))), cấu trúc chịu áp lực điều chỉnh kỹ thuật.")
        } else {
            score += 5
            notes.append("Giá đang tích lũy nén quanh đường trung bình EMA20 ($\(Formatters.formatPrice(lastEMA20))).")
        }
        
        // 2. Momentum (RSI 14) — B1 fix: cover all RSI ranges without gaps
        if lastRSI >= 50 && lastRSI <= 68 {
            score += 15
            notes.append("RSI-14 đạt \(String(format: "%.1f", lastRSI)) ở vùng đà tăng ổn định (Healthy Bullish).")
        } else if lastRSI > 68 && lastRSI <= 75 {
            score += 8
            notes.append("RSI-14 đạt \(String(format: "%.1f", lastRSI)) ở vùng momentum tích cực, chưa vào quá mua (Strong Momentum).")
        } else if lastRSI > 75 {
            score += 3
            notes.append("RSI-14 đạt \(String(format: "%.1f", lastRSI)) tiến vào vùng quá mua ngắn hạn (Overbought), rủi ro điều chỉnh tăng.")
        } else if lastRSI < 30 {
            score += 8
            notes.append("RSI-14 đạt \(String(format: "%.1f", lastRSI)) ở vùng quá bán sâu (Oversold), tiềm năng phản hồi kỹ thuật.")
        } else {
            // RSI 30–49: weak momentum
            score -= 10
            notes.append("RSI-14 đạt \(String(format: "%.1f", lastRSI)) nằm dưới mốc 50, đà tăng yếu (Weak Momentum).")
        }
        
        // 3. MACD Momentum — B2 fix: skip when insufficient candles
        if let macdHist = lastMacdHist {
            if macdHist > 0 {
                score += 10
                notes.append("MACD Histogram dương (+\(String(format: "%.2f", macdHist))) khẳng định xung lực tăng.")
            } else {
                score -= 8
                notes.append("MACD Histogram âm (\(String(format: "%.2f", macdHist))) thể hiện áp lực cung.")
            }
        } else {
            notes.append("Chưa đủ nến (cần ≥35 nến 4H) để tính MACD Histogram chính xác. Bỏ qua chỉ báo này.")
        }
        
        score = max(20, min(95, score))
        
        let signal: PillarSignal
        if score >= 80 {
            signal = .strongBullish
        } else if score >= 65 {
            signal = .bullish
        } else if score >= 45 {
            signal = .neutral
        } else if score >= 30 {
            signal = .bearish
        } else {
            signal = .strongBearish
        }
        
        return PillarScoreItem(
            pillar: .technical,
            score: score,
            signal: signal,
            summary: notes.joined(separator: " ")
        )
    }
    
    private func evaluateOnChainPillar(profile: OnChainProfile?, baseAsset: String) -> (PillarScoreItem, Bool) {
        guard let p = profile else {
            return (
                PillarScoreItem(
                    pillar: .onchainETF,
                    score: 50,
                    signal: .neutral,
                    summary: "Chưa có hồ sơ On-Chain & Dòng vốn ETF được kiểm chứng cho \(baseAsset)."
                ),
                false
            )
        }
        
        var score = 78
        var signal: PillarSignal = .bullish
        var summary = p.onChainSummary
        
        if let cycle = p.cycleMetrics {
            // C1 FIX: Synchronize with OnChainDataProvider cyclePhase thresholds
            // Thresholds: < 1.0 (undervalued), < 2.0 (fair value), < 4.0 (expansion), >= 4.0 (overbought)
            if cycle.mvrvZScore < 1.0 {
                score = 92
                signal = .strongBullish
                summary = "MVRV Proxy (\(String(format: "%.2f", cycle.mvrvZScore))) ở vùng định giá hấp dẫn (Under-valued)."
            } else if cycle.mvrvZScore < 2.0 {
                score = 78
                signal = .bullish
                summary = "MVRV Proxy (\(String(format: "%.2f", cycle.mvrvZScore))) ở vùng giá trị hợp lý (Fair Value)."
            } else if cycle.mvrvZScore < 4.0 {
                score = 62
                signal = .neutral
                summary = "MVRV Proxy (\(String(format: "%.2f", cycle.mvrvZScore))) ở giai đoạn tăng tốc chu kỳ (Expansion)."
            } else {
                score = 38
                signal = .bearish
                summary = "MVRV Proxy (\(String(format: "%.2f", cycle.mvrvZScore))) tiếp cận vùng quá nhiệt rủi ro cao (Overbought)."
            }
        }
        
        if let etf = p.spotETFFlows, etf.totalNetFlow24hUSD > 50_000_000 {
            score = min(100, score + 6)
            summary += " Dòng tiền ròng US Spot ETF mua ròng mạnh (+\(Formatters.formatVolume(etf.totalNetFlow24hUSD)) USD)."
        }
        
        return (PillarScoreItem(pillar: .onchainETF, score: score, signal: signal, summary: summary), true)
    }
    
    private func evaluateTokenomicsPillar(profile: TokenomicsProfile?, baseAsset: String) -> (PillarScoreItem, Bool) {
        guard let p = profile else {
            return (
                PillarScoreItem(
                    pillar: .tokenomics,
                    score: 50,
                    signal: .neutral,
                    summary: "Chưa có hồ sơ Tokenomics & Lịch mở khóa (Unlocks) chính thức cho \(baseAsset)."
                ),
                false
            )
        }
        
        // B7 FIX: Realistic scoring without assuming default inflation or over-scoring low MC/FDV
        var score = 65
        let ratio = p.supplyMetrics.mcFdvRatio
        var notes: [String] = []
        
        if ratio >= 0.85 {
            score += 18
            notes.append("Tỷ lệ MC/FDV cao (\(String(format: "%.1f%%", ratio * 100))), rủi ro pha loãng thấp.")
        } else if ratio >= 0.65 {
            score += 8
            notes.append("Tỷ lệ MC/FDV khá (\(String(format: "%.1f%%", ratio * 100))).")
        } else if ratio < 0.45 {
            score -= 15
            notes.append("Tỷ lệ MC/FDV thấp (\(String(format: "%.1f%%", ratio * 100))), lượng token khóa lớn tạo áp lực xả dài hạn.")
        }
        
        if let inflation = p.supplyMetrics.annualInflationRate {
            if inflation <= 2.0 {
                score += 10
                notes.append("Lạm phát hàng năm thấp (\(String(format: "%.1f%%", inflation))).")
            } else if inflation > 8.0 {
                score -= 15
                notes.append("Lạm phát hàng năm cao (\(String(format: "%.1f%%", inflation))).")
            }
        } else {
            notes.append("Lạm phát hàng năm chưa có số liệu chính thức.")
        }
        
        // Deduct if large upcoming unlock in next 30 days
        if p.upcomingUnlocks.contains(where: { $0.riskLevel == .high || $0.riskLevel == .extreme }) {
            score = max(30, score - 15)
            notes.append("Có đợt mở khóa lớn trong 30 ngày tới.")
        }
        
        score = max(20, min(95, score))
        
        let signal: PillarSignal
        if score >= 80 { signal = .strongBullish }
        else if score >= 65 { signal = .bullish }
        else if score >= 50 { signal = .neutral }
        else { signal = .bearish }
        
        let summary = notes.joined(separator: " ")
        return (PillarScoreItem(pillar: .tokenomics, score: score, signal: signal, summary: summary), true)
    }
    
    private func evaluateMacroPillar(macro: GlobalMacroOverviewData) -> PillarScoreItem {
        let score = macro.macroRiskScore // e.g. 72
        let signal: PillarSignal
        if score >= 80 { signal = .strongBullish }
        else if score >= 65 { signal = .bullish }
        else if score >= 50 { signal = .neutral }
        else { signal = .bearish }
        
        let summary = "Cung tiền M2 toàn cầu lập đỉnh lịch sử ($108.4T). Fed bước vào chu kỳ nới lỏng lãi suất hỗ trợ mạnh tài sản rủi ro."
        return PillarScoreItem(pillar: .macro, score: score, signal: signal, summary: summary)
    }
    
    private func evaluateSmartMoneyPillar(profile: SmartMoneyProfile?, baseAsset: String) -> (PillarScoreItem, Bool) {
        guard let p = profile else {
            return (
                PillarScoreItem(
                    pillar: .smartMoney,
                    score: 50,
                    signal: .neutral,
                    summary: "Chưa có luồng dữ liệu ví Smart Money & Quỹ kiểm chứng cho \(baseAsset)."
                ),
                false
            )
        }
        
        let score = p.sentimentSignal.score
        let signal: PillarSignal
        if score >= 80 { signal = .strongBullish }
        else if score >= 65 { signal = .bullish }
        else if score >= 50 { signal = .neutral }
        else { signal = .bearish }
        
        return (PillarScoreItem(pillar: .smartMoney, score: score, signal: signal, summary: p.sentimentSignal.analysisSummary), true)
    }
    
    // MARK: - Recommendation & Scenarios
    
    private func determineRecommendation(score: Int) -> ConfluenceRecommendation {
        if score >= 80 { return .strongBuy }
        if score >= 65 { return .accumulate }
        if score >= 50 { return .watch }
        if score >= 35 { return .takeProfit }
        return .highRisk
    }
    
    private func buildScenarios(baseAsset: String, currentPrice: Double, overallScore: Int) -> [ScenarioProjection] {
        let bullMultiplier: Double
        let baseMultiplier: Double
        let bearMultiplier: Double
        
        if baseAsset == "BTC" {
            bullMultiplier = 1.65   // e.g. $110k
            baseMultiplier = 1.25   // e.g. $83k
            bearMultiplier = 0.80   // e.g. $53k
        } else if baseAsset == "ETH" {
            bullMultiplier = 1.95
            baseMultiplier = 1.35
            bearMultiplier = 0.75
        } else if baseAsset == "SOL" {
            bullMultiplier = 2.20
            baseMultiplier = 1.45
            bearMultiplier = 0.68
        } else if baseAsset == "BNB" {
            bullMultiplier = 1.75
            baseMultiplier = 1.28
            bearMultiplier = 0.78
        } else if baseAsset == "SUI" {
            bullMultiplier = 2.50
            baseMultiplier = 1.50
            bearMultiplier = 0.60
        } else {
            bullMultiplier = 2.20
            baseMultiplier = 1.40
            bearMultiplier = 0.60
        }
        
        // B3 FIX: Probabilities MUST reflect overallScore genuinely across all assets
        let bullProb: Int
        let baseProb: Int
        let bearProb: Int
        
        if overallScore >= 75 {
            bullProb = min(65, 45 + (overallScore - 75))
            baseProb = 35
            bearProb = max(10, 100 - bullProb - baseProb)
        } else if overallScore >= 60 {
            bullProb = 45
            baseProb = 35
            bearProb = 20
        } else if overallScore >= 45 {
            bullProb = 30
            baseProb = 40
            bearProb = 30
        } else if overallScore >= 30 {
            bullProb = 20
            baseProb = 30
            bearProb = 50
        } else {
            bullProb = 10
            baseProb = 25
            bearProb = 65
        }
        
        let bullTarget = currentPrice * bullMultiplier
        let baseTarget = currentPrice * baseMultiplier
        let bearTarget = currentPrice * bearMultiplier
        
        let bullReturn = (bullMultiplier - 1.0) * 100.0
        let baseReturn = (baseMultiplier - 1.0) * 100.0
        let bearReturn = (bearMultiplier - 1.0) * 100.0
        
        return [
            ScenarioProjection(
                scenarioType: .bullCase,
                targetPriceUSD: bullTarget,
                expectedReturnPercent: bullReturn,
                probabilityPercent: bullProb,
                keyDrivers: [
                    "Dòng vốn US Spot ETF & dòng tiền lớn tiếp tục mua ròng",
                    "Thanh khoản M2 toàn cầu tăng tốc sau các đợt nới lỏng tiền tệ",
                    "Nguồn cung trên sàn duy trì rút ròng tạo Supply Squeeze"
                ]
            ),
            ScenarioProjection(
                scenarioType: .baseCase,
                targetPriceUSD: baseTarget,
                expectedReturnPercent: baseReturn,
                probabilityPercent: baseProb,
                keyDrivers: [
                    "Thị trường tăng trưởng ổn định theo chu kỳ 4 năm Halving",
                    "Dòng tiền phân hóa tập trung vào nhóm Top Layer 1 & AI",
                    "Biến động giá sideway-up tạo nền tích lũy vững chắc"
                ]
            ),
            ScenarioProjection(
                scenarioType: .bearCase,
                targetPriceUSD: bearTarget,
                expectedReturnPercent: bearReturn,
                probabilityPercent: bearProb,
                keyDrivers: [
                    "Lạm phát Mỹ quay trở lại khiến ngân hàng trung ương trì hoãn nới lỏng",
                    "Áp lực bán tháo bất ngờ từ các vụ kiện tư pháp / ủy thác",
                    "Thủng mốc hỗ trợ chi phí vốn STH Realized Price"
                ]
            )
        ]
    }
    
    private func buildTradePlan(baseAsset: String, currentPrice: Double, overallScore: Int) -> TradeExecutionPlan {
        // B4 FIX: Dynamic SL, TP and Allocation based on overallScore and asset class
        let isLargeCap = baseAsset == "BTC" || baseAsset == "ETH"
        
        let dcaMinDrop = overallScore >= 75 ? (isLargeCap ? 0.04 : 0.08) : (isLargeCap ? 0.08 : 0.14)
        let dcaMaxDrop = overallScore >= 75 ? (isLargeCap ? 0.015 : 0.03) : (isLargeCap ? 0.03 : 0.06)
        let slDrop = overallScore >= 75 ? (isLargeCap ? 0.08 : 0.12) : (isLargeCap ? 0.12 : 0.18)
        let tp1Gain = overallScore >= 75 ? (isLargeCap ? 0.22 : 0.35) : (isLargeCap ? 0.15 : 0.25)
        let tp2Gain = overallScore >= 75 ? (isLargeCap ? 0.45 : 0.75) : (isLargeCap ? 0.30 : 0.50)
        
        let dcaMin = currentPrice * (1.0 - dcaMinDrop)
        let dcaMax = currentPrice * (1.0 - dcaMaxDrop)
        let stopLoss = currentPrice * (1.0 - slDrop)
        let tp1 = currentPrice * (1.0 + tp1Gain)
        let tp2 = currentPrice * (1.0 + tp2Gain)
        
        let potentialGain = tp1 - currentPrice
        let potentialLoss = currentPrice - stopLoss
        let riskReward = potentialLoss > 0 ? (potentialGain / potentialLoss) : 2.5
        
        let baseAllocation: Double
        if baseAsset == "BTC" {
            baseAllocation = 30.0
        } else if baseAsset == "ETH" || baseAsset == "SOL" || baseAsset == "BNB" {
            baseAllocation = 15.0
        } else {
            baseAllocation = 5.0
        }
        
        let scoreMultiplier: Double
        if overallScore >= 80 { scoreMultiplier = 1.0 }
        else if overallScore >= 65 { scoreMultiplier = 0.8 }
        else if overallScore >= 50 { scoreMultiplier = 0.5 }
        else if overallScore >= 35 { scoreMultiplier = 0.2 }
        else { scoreMultiplier = 0.0 }
        
        let allocation = baseAllocation * scoreMultiplier
        
        return TradeExecutionPlan(
            optimalDCAMinUSD: dcaMin,
            optimalDCAMaxUSD: dcaMax,
            recommendedAllocationPercent: Double(round(allocation * 10) / 10),
            stopLossPriceUSD: stopLoss,
            takeProfit1USD: tp1,
            takeProfit2USD: tp2,
            riskRewardRatio: Double(round(riskReward * 10) / 10),
            timeHorizonMonths: isLargeCap ? 12 : 6
        )
    }
    
    private func buildThesisAndFactors(baseAsset: String, score: Int, recommendation: ConfluenceRecommendation) -> ([String], [String], String) {
        let catalysts: [String]
        let risks: [String]
        let thesis: String
        
        switch baseAsset {
        case "BTC":
            catalysts = [
                "Dòng vốn thể chế khổng lồ từ các quỹ Spot ETF BlackRock & Fidelity liên tục hấp thụ cung",
                "Hiệu ứng sau sự kiện Bitcoin Halving bắt đầu phát huy tác động siết nghẽn nguồn cung",
                "Chu kỳ nới lỏng tiền tệ toàn cầu (Fed hạ lãi suất + Global M2 đạt đỉnh lịch sử $108.4T)"
            ]
            risks = [
                "Biến động thanh lý từ tài sản tư pháp chính phủ Mỹ hoặc ủy thác Silk Road",
                "Rủi ro địa chính trị bất ngờ làm đồng USD (DXY) mạnh lên ngắn hạn"
            ]
            thesis = "Bitcoin đang nằm ở điểm hội tụ giữa chu kỳ vĩ mô nới lỏng và dòng vốn tổ chức ETF."
            
        case "ETH":
            catalysts = [
                "Lượng ETH bị khóa trong Staking và Liquid Staking (Lido, EigenLayer) vượt 34 triệu coin",
                "Nâng cấp Pectra sắp tới tiếp tục tối ưu hóa phí gas Layer 2 và nâng cao trải nghiệm người dùng",
                "Dòng vốn từ các quỹ Spot Ethereum ETF (ETHA, FETH) bắt đầu tăng tốc dương ròng"
            ]
            risks = [
                "Cạnh tranh gay gắt về doanh thu phí giao dịch từ các Layer 1 tốc độ cao như Solana, Sui",
                "Tốc độ giải ngân của quỹ Spot ETH ETF ban đầu chậm hơn so với Bitcoin"
            ]
            thesis = "Ethereum giữ vững vị thế trung tâm thanh khoản DeFi và tài sản sinh lợi nhuận staking an toàn nhất."
            
        case "SOL":
            catalysts = [
                "Số lượng địa chỉ hoạt động hàng ngày dẫn đầu thị trường (gần 4 triệu ví/ngày)",
                "Nâng cấp Firedancer client của Jump Crypto nâng thông lượng lên hàng triệu TPS",
                "Hệ sinh thái DePIN, DEX và Memecoin bùng nổ thu hút thanh khoản bán lẻ liên tục"
            ]
            risks = [
                "Áp lực mở khóa phân bổ token định kỳ từ tài sản phá sản của FTX Estate",
                "Rủi ro tắc nghẽn mạng cục bộ trong các giai đoạn khối lượng giao dịch đột biến"
            ]
            thesis = "Solana thể hiện hiệu suất vượt trội nhờ tốc độ tăng trưởng người dùng thực và thông lượng giao dịch."
            
        case "BNB":
            catalysts = [
                "Cơ chế Auto-Burn hàng quý và BNB Launchpool tạo lực cầu giữ coin liên tục",
                "Hoạt động mạng lưới BNB Chain và opBNB L2 duy trì lượng giao dịch DeFi ổn định",
                "Môi trường pháp lý đã được giải tỏa hoàn toàn sau thỏa thuận dàn xếp DOJ"
            ]
            risks = [
                "Độ phụ thuộc lớn vào danh tiếng và khối lượng giao dịch của sàn Binance",
                "Mức độ phi tập trung của nhóm validator thấp hơn so với Ethereum"
            ]
            thesis = "BNB là tài sản blue-chip utility vững chắc với lực đốt cung đều đặn và dòng tiền thưởng từ Launchpool."
            
        case "SUI":
            catalysts = [
                "Kiến trúc hướng đối tượng Sui Move đem lại thông lượng 297k TPS và độ trễ dưới 400ms",
                "Tốc độ tăng trưởng TVL DeFi và khối lượng DEX thuộc top nhanh nhất thị trường",
                "Hệ sinh thái Gaming và Web3 Mobile đón nhận nhiều nhà phát triển lớn"
            ]
            risks = [
                "Lịch mở khóa token định kỳ cho nhà đầu tư sớm trong các năm đầu Mainnet",
                "Cạnh tranh trực tiếp từ các chuỗi monolithic thế hệ mới như Aptos, Monad"
            ]
            thesis = "Sui đại diện cho công nghệ L1 thế hệ mới với trải nghiệm người dùng tối ưu."
            
        case "ARB":
            catalysts = [
                "Arbitrum One chiếm thị phần TVL Layer 2 lớn nhất hệ sinh thái Ethereum",
                "Cơ chế BOLD Dispute Resolution và mở rộng Arbitrum Orbit L3 thu hút dự án mới",
                "Phí giao dịch cực thấp sau nâng cấp Dencun (EIP-4844 Blob transactions)"
            ]
            risks = [
                "Áp lực phân bổ token mở khóa hàng tháng cho team và nhà đầu tư",
                "Sự vươn lên mạnh mẽ của Base (Coinbase L2) chia sẻ thị phần thanh khoản người dùng"
            ]
            thesis = "Arbitrum là đầu tàu hạ tầng Layer 2 của Ethereum với hệ sinh thái DeFi sôi động nhất."
            
        case "OP":
            catalysts = [
                "Khung OP Stack được lựa chọn bởi Base, Zora, Worldcoin tạo mạng lưới Superchain mạnh mẽ",
                "Cơ chế chia sẻ doanh thu từ Superchain đóng góp đều đặn cho Optimism Collective",
                "Triển khai hoàn thiện hệ thống Fault Proofs đa máy ảo an toàn"
            ]
            risks = [
                "Áp lực lạm phát mở khóa token và sự phân mảnh thanh khoản giữa các chain trong Superchain",
                "Cạnh tranh trực tiếp với Arbitrum Orbit và zkSync Hyperchains"
            ]
            thesis = "Optimism sở hữu mạng lưới liên minh Superchain hùng mạnh nhất Web3."
            
        case "LINK":
            catalysts = [
                "Vị thế độc tôn về mạng lưới Oracle phi tập trung kết nối dữ liệu ngoài chuỗi vào Smart Contract",
                "Giao thức Chainlink CCIP trở thành tiêu chuẩn liên chuỗi cho các tổ chức tài chính lớn (Swift, DTCC)",
                "Chương trình Chainlink Staking v0.2 hấp thụ nguồn cung LINK lưu thông"
            ]
            risks = [
                "Tốc độ tăng trưởng doanh thu on-chain chưa bắt kịp định giá vốn hóa thị trường",
                "Cạnh tranh từ các giải pháp oracle chi phí thấp như Pyth Network"
            ]
            thesis = "Chainlink là tài sản cơ sở hạ tầng thiết yếu không thể thay thế trong toàn bộ hệ sinh thái Web3 và RWA."
            
        case "AVAX":
            catalysts = [
                "Kiến trúc Subnet tùy biến mở đường cho việc áp dụng tài sản thực (RWA) và ngân hàng số",
                "Thời gian hoàn tất giao dịch dưới 1 giây (sub-second finality) nhờ thuật toán Snowman",
                "Hệ sinh thái game Web3 chuyển dịch mạnh mẽ sang Avalanche Subnets"
            ]
            risks = [
                "Lượng giao dịch trên chuỗi C-Chain chính có dấu hiệu chững lại so với các chuỗi mới",
                "Chi phí duy trì validator và tính phân mảnh thanh khoản giữa các Subnet"
            ]
            thesis = "Avalanche có nền tảng công nghệ đồng thuận xuất sắc và hướng đi rõ ràng vào khối doanh nghiệp/RWA."
            
        case "DOGE":
            catalysts = [
                "Đồng coin PoW mang tính biểu tượng văn hóa toàn cầu với cộng đồng trung thành",
                "Khả năng tích hợp thanh toán vi mô trên các nền tảng mạng xã hội và thương mại",
                "Được bảo mật an toàn qua cơ chế đào gộp AuxPoW với Litecoin"
            ]
            risks = [
                "Lạm phát cố định 5 tỷ DOGE mỗi năm không có giới hạn cung tối đa",
                "Không có hệ sinh thái smart contract bản địa, phụ thuộc nhiều vào tâm lý thị trường"
            ]
            thesis = "Dogecoin là đại diện meme/thanh toán hàng đầu với tính thanh khoản cao, phù hợp cho các chiến lược giao dịch theo sóng tâm lý thị trường."
            
        default:
            catalysts = [
                "Động lực dòng tiền luân chuyển từ nhóm Top L1 sang hệ sinh thái ngách",
                "Khối lượng giao dịch gia tăng phản ánh sự quan tâm trở lại của cộng đồng",
                "Các mốc cập nhật công nghệ và mở rộng quan hệ đối tác theo đúng lộ trình"
            ]
            risks = [
                "Áp lực mở khóa token (Cliff Unlocks) từ các vòng gọi vốn ban đầu",
                "Độ biến động giá cao hơn đáng kể so với BTC và rủi ro thanh khoản thấp"
            ]
            thesis = "\(baseAsset) sở hữu tiềm năng tăng trưởng tốt nhưng cần quản trị rủi ro chặt chẽ với tỷ trọng phân bổ vốn hợp lý và tuân thủ kỷ luật cắt lỗ."
        }
        
        // B5 FIX: Thesis MUST directly reference recommendation and score honestly
        let recAction: String
        switch recommendation {
        case .strongBuy:
            recAction = "Điểm hợp lưu \(score)/100 khẳng định sức mạnh đa trụ cột. Khuyến nghị: MUA MẠNH / Tích lũy chủ động với tỷ trọng cao."
        case .accumulate:
            recAction = "Điểm hợp lưu \(score)/100 thể hiện cấu trúc tích cực. Khuyến nghị: TÍCH LŨY TỪNG PHẦN theo các nhịp điều chỉnh giá hợp lý."
        case .watch:
            recAction = "Điểm hợp lưu \(score)/100 ở ngưỡng trung tính. Khuyến nghị: QUAN SÁT, chưa vội mở vị thế mới và chờ tín hiệu xác nhận thêm."
        case .takeProfit:
            recAction = "Điểm hợp lưu \(score)/100 suy yếu so với chu kỳ. Khuyến nghị: CHỐT LỜI TỪNG PHẦN, hạ bớt tỷ trọng để bảo toàn lợi nhuận."
        case .highRisk:
            recAction = "Điểm hợp lưu \(score)/100 cảnh báo rủi ro cao. Khuyến nghị: ĐỨNG NGOÀI / PHÒNG HỘ, tuyệt đối tuân thủ kỷ luật dừng lỗ."
        }
        
        let finalThesis = "\(thesis) \(recAction)"
        return (catalysts, risks, finalThesis)
    }
}

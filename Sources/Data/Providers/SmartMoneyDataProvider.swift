import Foundation

public actor SmartMoneyDataProvider {
    public static let shared = SmartMoneyDataProvider()
    
    private let candleProvider: BinanceCandleProvider
    
    public init(candleProvider: BinanceCandleProvider = .shared) {
        self.candleProvider = candleProvider
    }
    
    public func fetchSmartMoneyProfile(for symbol: String) async throws -> SmartMoneyProfile {
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        
        // Fetch current price for accurate USD calculations
        var currentPrice: Double = 1.0
        if let (price, _, _) = try? await candleProvider.fetch24hrTicker(symbol: cleanSymbol) {
            currentPrice = price
        }
        
        return buildSmartMoneyProfile(baseAsset: baseAsset, symbol: cleanSymbol, currentPrice: currentPrice)
    }
    
    private func buildSmartMoneyProfile(baseAsset: String, symbol: String, currentPrice: Double) -> SmartMoneyProfile {
        let now = Date()
        let topWallets = buildTopWallets(baseAsset: baseAsset, currentPrice: currentPrice)
        let freshWallets = buildFreshWallets(baseAsset: baseAsset, currentPrice: currentPrice)
        
        switch baseAsset {
        case "BTC":
            return SmartMoneyProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                sentimentSignal: SmartMoneySentimentSignal(
                    score: 86,
                    signalLabel: "Dòng Vốn Tổ Chức Tích Lũy Mạnh (Institutional Accumulation)",
                    netDEXVolume24hUSD: 185_000_000,
                    smartMoneyHoldersCount: 1_420,
                    smartHoldersChange7d: 48,
                    analysisSummary: "Các quỹ ETF giao ngay (BlackRock IBIT, Fidelity FBTC) và doanh nghiệp đại chúng (MicroStrategy) tiếp tục duy trì dòng tiền mua ròng định kỳ. Tỷ lệ nắm giữ của các ví cá voi tổ chức đạt mức cao kỷ lục."
                ),
                vcBackers: [
                    VCBackerHolding(fundName: "BlackRock (iShares IBIT)", fundTier: "Tổ Chức Tài Chính Toàn Cầu", isLeadInvestor: true, investmentRound: "Spot ETF Custody", estimatedHoldingUSD: 24_500_000_000, roiMultiplier: 1.45, status: .accumulating),
                    VCBackerHolding(fundName: "MicroStrategy (Strategy Treasury)", fundTier: "Corporate Treasury", isLeadInvestor: true, investmentRound: "Trung bình $39,500/BTC", estimatedHoldingUSD: 16_800_000_000, roiMultiplier: 1.62, status: .accumulating),
                    VCBackerHolding(fundName: "Fidelity Investments (FBTC)", fundTier: "Tổ Chức Quản Lý Tài Sản", isLeadInvestor: false, investmentRound: "Spot ETF Custody", estimatedHoldingUSD: 11_200_000_000, roiMultiplier: 1.42, status: .accumulating),
                    VCBackerHolding(fundName: "Grayscale Bitcoin Trust (GBTC)", fundTier: "Quỹ Đầu Tư Crypto", isLeadInvestor: false, investmentRound: "Closed-end Trust Conversion", estimatedHoldingUSD: 14_100_000_000, roiMultiplier: 8.5, status: .partiallyRealized)
                ],
                dexLiquidity: DEXLiquidityMetrics(
                    totalLiquidityUSD: 1_250_000_000,
                    liquidity24hChangePercent: 2.1,
                    volume24hDEXUSD: 450_000_000,
                    topPoolPair: "WBTC / USDC 0.05% (Uniswap v3)",
                    volumeToLiquidityRatio: 0.36
                ),
                recentDEXSwaps: [
                    SmartMoneyDEXSwap(
                        id: "0x88f1...33a2",
                        timestamp: now.addingTimeInterval(-900),
                        traderLabel: "Smart Trader #12 (PnL +$4.2M)",
                        type: .buy,
                        dexName: "Uniswap v3",
                        amountToken: 45.0,
                        amountUSD: 45.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    ),
                    SmartMoneyDEXSwap(
                        id: "0x44c2...99b1",
                        timestamp: now.addingTimeInterval(-3600),
                        traderLabel: "Wintermute Trading Algorithmic",
                        type: .buy,
                        dexName: "Curve WBTC/tBTC",
                        amountToken: 120.0,
                        amountUSD: 120.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    )
                ],
                topWallets: topWallets,
                freshWallets: freshWallets
            )
            
        case "ETH":
            return SmartMoneyProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                sentimentSignal: SmartMoneySentimentSignal(
                    score: 79,
                    signalLabel: "Tích Lũy Ổn Định Từ Smart Money (Healthy Inflows)",
                    netDEXVolume24hUSD: 94_000_000,
                    smartMoneyHoldersCount: 2_890,
                    smartHoldersChange7d: 34,
                    analysisSummary: "Hoạt động staking thông qua Lido, RocketPool và EigenLayer restaking duy trì tăng trưởng. Các ví Smart Money tăng cường gom ETH trên DEX sau các nhịp điều chỉnh."
                ),
                vcBackers: [
                    VCBackerHolding(fundName: "Paradigm", fundTier: "Tier 1 Crypto VC", isLeadInvestor: true, investmentRound: "DeFi Ecosystem Backer", estimatedHoldingUSD: 1_850_000_000, roiMultiplier: 12.4, status: .holding),
                    VCBackerHolding(fundName: "a16z Crypto (Andreessen Horowitz)", fundTier: "Tier 1 Multi-stage VC", isLeadInvestor: true, investmentRound: "Infrastructure & L2 Rounds", estimatedHoldingUSD: 2_100_000_000, roiMultiplier: 9.8, status: .holding),
                    VCBackerHolding(fundName: "Polychain Capital", fundTier: "Tier 1 Liquid Fund", isLeadInvestor: false, investmentRound: "Early Liquid Staking", estimatedHoldingUSD: 650_000_000, roiMultiplier: 15.2, status: .accumulating)
                ],
                dexLiquidity: DEXLiquidityMetrics(
                    totalLiquidityUSD: 3_800_000_000,
                    liquidity24hChangePercent: -0.8,
                    volume24hDEXUSD: 1_420_000_000,
                    topPoolPair: "ETH / USDC 0.05% (Uniswap v3)",
                    volumeToLiquidityRatio: 0.37
                ),
                recentDEXSwaps: [
                    SmartMoneyDEXSwap(
                        id: "0x11a2...88f4",
                        timestamp: now.addingTimeInterval(-600),
                        traderLabel: "Whale 0x93...21 (PnL +$2.8M)",
                        type: .buy,
                        dexName: "Uniswap v3",
                        amountToken: 450.0,
                        amountUSD: 450.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    ),
                    SmartMoneyDEXSwap(
                        id: "0x66c3...11e9",
                        timestamp: now.addingTimeInterval(-4200),
                        traderLabel: "Jump Trading Market Maker",
                        type: .buy,
                        dexName: "Uniswap v3",
                        amountToken: 800.0,
                        amountUSD: 800.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    )
                ],
                topWallets: topWallets,
                freshWallets: freshWallets
            )
            
        case "SOL":
            return SmartMoneyProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                sentimentSignal: SmartMoneySentimentSignal(
                    score: 91,
                    signalLabel: "Dòng Tiền Quỹ Đổ Bộ & DEX Khối Lượng Cao",
                    netDEXVolume24hUSD: 145_000_000,
                    smartMoneyHoldersCount: 1_850,
                    smartHoldersChange7d: 88,
                    analysisSummary: "Khối lượng giao dịch của các ví Smart Money trên Raydium và Orca tăng 35% trong tuần. Các quỹ đầu tư Mỹ và châu Á tiếp tục gom SOL để chuẩn bị cho Firedancer Mainnet."
                ),
                vcBackers: [
                    VCBackerHolding(fundName: "Multicoin Capital", fundTier: "Tier 1 High Conviction VC", isLeadInvestor: true, investmentRound: "Seed Round ($0.04/SOL)", estimatedHoldingUSD: 1_250_000_000, roiMultiplier: 320.0, status: .holding),
                    VCBackerHolding(fundName: "a16z Crypto", fundTier: "Tier 1 VC", isLeadInvestor: true, investmentRound: "2021 Strategic Private Sale", estimatedHoldingUSD: 850_000_000, roiMultiplier: 6.5, status: .holding),
                    VCBackerHolding(fundName: "Jump Crypto", fundTier: "Tier 1 Quant Market Maker", isLeadInvestor: false, investmentRound: "Infrastructure & Firedancer Lead", estimatedHoldingUSD: 620_000_000, roiMultiplier: 12.0, status: .accumulating)
                ],
                dexLiquidity: DEXLiquidityMetrics(
                    totalLiquidityUSD: 890_000_000,
                    liquidity24hChangePercent: 4.5,
                    volume24hDEXUSD: 980_000_000,
                    topPoolPair: "SOL / USDC (Raydium CLMM)",
                    volumeToLiquidityRatio: 1.10
                ),
                recentDEXSwaps: [
                    SmartMoneyDEXSwap(
                        id: "5xKP...99qL",
                        timestamp: now.addingTimeInterval(-450),
                        traderLabel: "Smart Trader #04 (Raydium Sniper)",
                        type: .buy,
                        dexName: "Raydium CLMM",
                        amountToken: 3_500.0,
                        amountUSD: 3_500.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    ),
                    SmartMoneyDEXSwap(
                        id: "3mZT...11wP",
                        timestamp: now.addingTimeInterval(-2400),
                        traderLabel: "Whale 7X...91",
                        type: .buy,
                        dexName: "Orca Whirlpools",
                        amountToken: 5_200.0,
                        amountUSD: 5_200.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    )
                ],
                topWallets: topWallets,
                freshWallets: freshWallets
            )
            
        case "SUI":
            return SmartMoneyProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                sentimentSignal: SmartMoneySentimentSignal(
                    score: 88,
                    signalLabel: "Làn Sóng Tích Lũy Từ Nhà Đầu Tư Mới (High Growth)",
                    netDEXVolume24hUSD: 42_000_000,
                    smartMoneyHoldersCount: 940,
                    smartHoldersChange7d: 65,
                    analysisSummary: "Dòng tiền dịch chuyển từ các hệ sinh thái EVM sang Sui gia tăng mạnh mẽ. Các quỹ mạo hiểm tăng cường thanh khoản trên Cetus và DeepBook."
                ),
                vcBackers: [
                    VCBackerHolding(fundName: "a16z Crypto", fundTier: "Tier 1 Lead Investor", isLeadInvestor: true, investmentRound: "Series A & B ($300M)", estimatedHoldingUSD: 380_000_000, roiMultiplier: 4.8, status: .holding),
                    VCBackerHolding(fundName: "Binance Labs", fundTier: "Tier 1 Exchange VC", isLeadInvestor: false, investmentRound: "Strategic Ecosystem Round", estimatedHoldingUSD: 140_000_000, roiMultiplier: 3.5, status: .accumulating),
                    VCBackerHolding(fundName: "Coinbase Ventures", fundTier: "Corporate VC", isLeadInvestor: false, investmentRound: "Series B Growth", estimatedHoldingUSD: 95_000_000, roiMultiplier: 3.2, status: .holding),
                    VCBackerHolding(fundName: "Electric Capital", fundTier: "Tier 1 Crypto VC", isLeadInvestor: false, investmentRound: "Early Contributor Fund", estimatedHoldingUSD: 85_000_000, roiMultiplier: 5.1, status: .holding)
                ],
                dexLiquidity: DEXLiquidityMetrics(
                    totalLiquidityUSD: 320_000_000,
                    liquidity24hChangePercent: 8.2,
                    volume24hDEXUSD: 210_000_000,
                    topPoolPair: "SUI / USDC (Cetus CLMM)",
                    volumeToLiquidityRatio: 0.65
                ),
                recentDEXSwaps: [
                    SmartMoneyDEXSwap(
                        id: "0x77b1...44af",
                        timestamp: now.addingTimeInterval(-1500),
                        traderLabel: "Smart Trader #31 (PnL +$820k)",
                        type: .buy,
                        dexName: "Cetus Protocol",
                        amountToken: 150_000.0,
                        amountUSD: 150_000.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    ),
                    SmartMoneyDEXSwap(
                        id: "0x33e8...99cc",
                        timestamp: now.addingTimeInterval(-5400),
                        traderLabel: "Whale 0x1a...88",
                        type: .buy,
                        dexName: "DeepBook Orderbook",
                        amountToken: 220_000.0,
                        amountUSD: 220_000.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    )
                ],
                topWallets: topWallets,
                freshWallets: freshWallets
            )
            
        default:
            return SmartMoneyProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                sentimentSignal: SmartMoneySentimentSignal(
                    score: 72,
                    signalLabel: "Theo Dõi Dòng Tiền Tích Lũy (Neutral to Bullish)",
                    netDEXVolume24hUSD: 8_500_000,
                    smartMoneyHoldersCount: 240,
                    smartHoldersChange7d: 12,
                    analysisSummary: "Dự án duy trì sự quan tâm ổn định từ các quỹ đầu tư hệ sinh thái và nhà tạo lập thị trường. Tỷ lệ mua/bán trên DEX ở mức cân bằng tích cực."
                ),
                vcBackers: [
                    VCBackerHolding(fundName: "Ecosystem Venture Fund", fundTier: "Tier 2 VC", isLeadInvestor: true, investmentRound: "Seed Round ($0.08)", estimatedHoldingUSD: 25_000_000, roiMultiplier: 2.8, status: .holding),
                    VCBackerHolding(fundName: "Strategic Partners VC", fundTier: "Strategic VC", isLeadInvestor: false, investmentRound: "Private Strategic Round", estimatedHoldingUSD: 14_000_000, roiMultiplier: 1.9, status: .holding)
                ],
                dexLiquidity: DEXLiquidityMetrics(
                    totalLiquidityUSD: 45_000_000,
                    liquidity24hChangePercent: 1.2,
                    volume24hDEXUSD: 18_000_000,
                    topPoolPair: "\(baseAsset) / USDT (Uniswap / DEX)",
                    volumeToLiquidityRatio: 0.40
                ),
                recentDEXSwaps: [
                    SmartMoneyDEXSwap(
                        id: "0x55d1...22ea",
                        timestamp: now.addingTimeInterval(-2100),
                        traderLabel: "Smart Trader #19",
                        type: .buy,
                        dexName: "DEX AMM",
                        amountToken: 45_000.0,
                        amountUSD: 45_000.0 * currentPrice,
                        executionPriceUSD: currentPrice
                    )
                ],
                topWallets: topWallets,
                freshWallets: freshWallets
            )
        }
    }
    
    private func buildTopWallets(baseAsset: String, currentPrice: Double) -> [SmartMoneyWalletLeader] {
        return [
            SmartMoneyWalletLeader(
                address: "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
                label: "Legendary Swing Trader (Arkham Verified)",
                winRatePercent: 82.4,
                pnl30dUSD: 3_450_000,
                totalBalanceUSD: 18_200_000,
                topHoldingAsset: baseAsset,
                lastActiveAgo: "15 phút trước"
            ),
            SmartMoneyWalletLeader(
                address: "0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045",
                label: "Whale Alpha Vault #3",
                winRatePercent: 76.8,
                pnl30dUSD: 2_180_000,
                totalBalanceUSD: 12_400_000,
                topHoldingAsset: baseAsset,
                lastActiveAgo: "1 giờ trước"
            ),
            SmartMoneyWalletLeader(
                address: "0x47ac0Fb4F2D84898e4D9E7b4DaB3C24507a6D503",
                label: "Institutional Macro Fund MM",
                winRatePercent: 71.2,
                pnl30dUSD: 1_650_000,
                totalBalanceUSD: 24_500_000,
                topHoldingAsset: baseAsset,
                lastActiveAgo: "3 giờ trước"
            )
        ]
    }
    
    private func buildFreshWallets(baseAsset: String, currentPrice: Double) -> [FreshWalletAlert] {
        let now = Date()
        return [
            FreshWalletAlert(
                address: "0x3f5CE5FBFe3E9af3971dD833D26bA9b5C936f0bE",
                ageHours: 18,
                sourceExchange: "Binance CEX Hot Wallet 20",
                accumulatedAmountUSD: 1_450_000,
                averageEntryPrice: currentPrice * 0.99,
                timestamp: now.addingTimeInterval(-3600 * 3)
            ),
            FreshWalletAlert(
                address: "0x89e51fA8CA5D3089752665B64BAEb9511593F5F0",
                ageHours: 42,
                sourceExchange: "Coinbase Prime Institutional Custody",
                accumulatedAmountUSD: 2_800_000,
                averageEntryPrice: currentPrice * 0.985,
                timestamp: now.addingTimeInterval(-3600 * 12)
            )
        ]
    }
}

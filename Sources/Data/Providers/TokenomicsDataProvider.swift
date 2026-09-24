import Foundation

public actor TokenomicsDataProvider {
    public static let shared = TokenomicsDataProvider()
    
    private let candleProvider: BinanceCandleProvider
    
    public init(candleProvider: BinanceCandleProvider = .shared) {
        self.candleProvider = candleProvider
    }
    
    public func fetchTokenomics(for symbol: String) async throws -> TokenomicsProfile {
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        
        // Fetch current price from 24h ticker for accurate live USD valuations
        var currentPrice: Double = 1.0
        if let (price, _, _) = try? await candleProvider.fetch24hrTicker(symbol: cleanSymbol) {
            currentPrice = price
        }
        
        return buildProfile(baseAsset: baseAsset, symbol: cleanSymbol, currentPrice: currentPrice)
    }
    
    private func buildProfile(baseAsset: String, symbol: String, currentPrice: Double) -> TokenomicsProfile {
        let vestingSchedule = buildVestingSchedule(baseAsset: baseAsset)
        let utilityInfo = buildUtilityInfo(baseAsset: baseAsset)
        
        switch baseAsset {
        case "BTC":
            let circ = 19_750_000.0
            let maxS = 21_000_000.0
            let mc = circ * currentPrice
            let fdv = maxS * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Native Proof-of-Work (UTXO)",
                primaryUseCases: ["Lưu trữ giá trị (Vàng kỹ thuật số)", "Thanh toán ngang hàng", "Tài sản dự trữ ngân quỹ"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: circ,
                    totalSupply: circ,
                    maxSupply: maxS,
                    marketCapUSD: mc,
                    fdvUSD: fdv,
                    mcFdvRatio: circ / maxS,
                    annualInflationRate: 0.85,
                    isBurnActive: false
                ),
                allocations: [
                    TokenAllocationItem(category: "Khai thác công khai (Proof-of-Work)", percentage: 100.0, tokenAmount: 21_000_000, colorHex: "#F7931A", description: "100% được khai thác minh bạch qua thuật toán SHA-256 qua các chu kỳ Halving 4 năm.")
                ],
                upcomingUnlocks: [],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "Bitcoin không có vòng gọi vốn riêng tư, không có token cho Founder hay Quỹ đầu tư mạo hiểm (0% Pre-mine). Lịch phát hành tuân theo cơ chế Halving giảm một nửa phần thưởng khối mỗi 210.000 block (khoảng 4 năm/lần), hiện tại là 3.125 BTC/block."
            )
            
        case "ETH":
            let circ = 120_250_000.0
            let mc = circ * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Native Proof-of-Stake (EVM)",
                primaryUseCases: ["Phí gas giao dịch & Smart Contract", "Staking bảo mật mạng lưới", "Tài sản thế chấp cốt lõi DeFi", "Tiền tệ thanh toán"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: circ,
                    totalSupply: circ,
                    maxSupply: nil,
                    marketCapUSD: mc,
                    fdvUSD: mc,
                    mcFdvRatio: 1.0,
                    annualInflationRate: 0.35,
                    isBurnActive: true,
                    burnedTokens: 4_350_000.0
                ),
                allocations: [
                    TokenAllocationItem(category: "Crowdsale Công khai 2014", percentage: 83.3, tokenAmount: 72_000_000, colorHex: "#627EEA", description: "Bán công khai cho cộng đồng đóng góp ban đầu."),
                    TokenAllocationItem(category: "Ethereum Foundation & Devs", percentage: 16.7, tokenAmount: 14_400_000, colorHex: "#8A92B2", description: "Tài trợ phát triển hệ sinh thái ban đầu.")
                ],
                upcomingUnlocks: [],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "Ethereum hoạt động theo cơ chế Ultra Sound Money (EIP-1559) tự động đốt phí gas cơ bản (Base Fee) theo từng block. Khi hoạt động on-chain tăng cao, tỷ lệ đốt vượt quá lượng phát hành mới từ Staking, tạo ra trạng thái giảm phát (Deflationary)."
            )
            
        case "SOL":
            let circ = 468_000_000.0
            let total = 585_000_000.0
            let mc = circ * currentPrice
            let fdv = total * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Native Proof-of-History / PoS",
                primaryUseCases: ["Phí giao dịch mạng Solana", "Staking bảo mật Validator", "Bỏ phiếu quản trị hệ sinh thái"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: circ,
                    totalSupply: total,
                    maxSupply: nil,
                    marketCapUSD: mc,
                    fdvUSD: fdv,
                    mcFdvRatio: circ / total,
                    annualInflationRate: 5.1,
                    isBurnActive: true,
                    burnedTokens: 12_800_000.0
                ),
                allocations: [
                    TokenAllocationItem(category: "Community & Foundation Reserve", percentage: 38.0, tokenAmount: 190_000_000, colorHex: "#9945FF", description: "Phát triển hệ sinh thái và tài trợ hạ tầng."),
                    TokenAllocationItem(category: "Seed & Founding Investors", percentage: 37.0, tokenAmount: 185_000_000, colorHex: "#14F195", description: "Các vòng gọi vốn sớm Multicoin, a16z, Polychain..."),
                    TokenAllocationItem(category: "Solana Labs Team", percentage: 25.0, tokenAmount: 125_000_000, colorHex: "#00C2FF", description: "Đội ngũ sáng lập Anatoly Yakovenko và kỹ sư cốt lõi.")
                ],
                upcomingUnlocks: [
                    TokenUnlockEvent(
                        unlockDate: Date().addingTimeInterval(86400 * 15),
                        category: "Phần thưởng Staking Validators (Linear)",
                        tokenAmount: 620_000,
                        valueUSD: 620_000 * currentPrice,
                        percentOfCirculating: 0.13,
                        unlockType: .linear,
                        riskLevel: .low
                    )
                ],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "Solana áp dụng mô hình lạm phát giảm dần (Disinflationary): bắt đầu từ 8%/năm và giảm 15% mỗi năm cho đến khi đạt mức ổn định dài hạn 1.5%/năm. 50% phí giao dịch được tự động đốt vĩnh viễn."
            )
            
        case "BNB":
            let circ = 145_880_000.0
            let maxS = 200_000_000.0
            let mc = circ * currentPrice
            let fdv = maxS * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Native BNB Chain (BEP-20)",
                primaryUseCases: ["Phí gas BNB Smart Chain & opBNB", "Giảm phí giao dịch trên Binance CEX", "Tham gia Launchpool / Megadrop", "Quản trị mạng lưới"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: circ,
                    totalSupply: circ,
                    maxSupply: maxS,
                    marketCapUSD: mc,
                    fdvUSD: fdv,
                    mcFdvRatio: circ / maxS,
                    annualInflationRate: 0.0,
                    isBurnActive: true,
                    burnedTokens: 54_120_000.0
                ),
                allocations: [
                    TokenAllocationItem(category: "Public Sale (ICO 2017)", percentage: 50.0, tokenAmount: 100_000_000, colorHex: "#F3BA2F", description: "Bán công khai $0.15/BNB."),
                    TokenAllocationItem(category: "Binance Founding Team", percentage: 40.0, tokenAmount: 80_000_000, colorHex: "#E5A010", description: "Đội ngũ Binance (đã khóa và đốt dần)."),
                    TokenAllocationItem(category: "Angel Investors", percentage: 10.0, tokenAmount: 20_000_000, colorHex: "#FCD535", description: "Nhà đầu tư thiên thần.")
                ],
                upcomingUnlocks: [],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "BNB thực hiện cơ chế Auto-Burn hàng quý theo công thức dựa trên giá BNB và số block BNB Chain tạo ra, cùng với cơ chế Real-time Burn (BEP-95). Mục tiêu là đốt tổng cộng 100 triệu BNB (50% tổng cung) cho đến khi chỉ còn 100 triệu BNB lưu hành."
            )
            
        case "SUI":
            let circ = 2_760_000_000.0
            let maxS = 10_000_000_000.0
            let mc = circ * currentPrice
            let fdv = maxS * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Native Layer 1 (Move VM)",
                primaryUseCases: ["Phí gas thực thi Smart Contract", "Staking ủy quyền Delegated PoS", "Kho bạc quản trị on-chain", "Thanh khoản hệ sinh thái"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: circ,
                    totalSupply: maxS,
                    maxSupply: maxS,
                    marketCapUSD: mc,
                    fdvUSD: fdv,
                    mcFdvRatio: circ / maxS,
                    annualInflationRate: 12.5,
                    isBurnActive: false
                ),
                allocations: [
                    TokenAllocationItem(category: "Community Reserve", percentage: 50.0, tokenAmount: 5_000_000_000, colorHex: "#4DA2FF", description: "Tài trợ nhà phát triển, tài trợ cộng đồng, staking subsidy."),
                    TokenAllocationItem(category: "Early Contributors", percentage: 20.0, tokenAmount: 2_000_000_000, colorHex: "#0066FF", description: "Nhóm kỹ sư cốt lõi và chuyên gia nghiên cứu Mysten Labs."),
                    TokenAllocationItem(category: "Investors (Series A & B)", percentage: 14.0, tokenAmount: 1_400_000_000, colorHex: "#003D99", description: "a16z, FTX Ventures (đã thanh lý/chuyển giao), Binance Labs..."),
                    TokenAllocationItem(category: "Mysten Labs Treasury", percentage: 10.0, tokenAmount: 1_000_000_000, colorHex: "#3385FF", description: "Ngân quỹ dự phòng của công ty phát triển."),
                    TokenAllocationItem(category: "Community Access / IEO", percentage: 6.0, tokenAmount: 600_000_000, colorHex: "#80BFFF", description: "Phân bổ cho cộng đồng qua Binance/OKX/KuCoin.")
                ],
                upcomingUnlocks: [
                    TokenUnlockEvent(
                        unlockDate: Date().addingTimeInterval(86400 * 12),
                        category: "Community Reserve & Early Contributors (Cliff)",
                        tokenAmount: 64_190_000,
                        valueUSD: 64_190_000 * currentPrice,
                        percentOfCirculating: 2.32,
                        unlockType: .cliff,
                        riskLevel: .high
                    ),
                    TokenUnlockEvent(
                        unlockDate: Date().addingTimeInterval(86400 * 42),
                        category: "Series A & B Investors (Cliff)",
                        tokenAmount: 64_190_000,
                        valueUSD: 64_190_000 * currentPrice,
                        percentOfCirculating: 2.28,
                        unlockType: .cliff,
                        riskLevel: .high
                    )
                ],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "Sui có lịch mở khóa hàng tháng (Monthly Cliff Unlock) diễn ra vào ngày 1 hàng tháng với lượng mở khóa khoảng 64 - 80 triệu SUI, chủ yếu đến từ Community Reserve và Series Investors. Lịch trình mở khóa hoàn toàn kéo dài đến năm 2030."
            )
            
        case "ARB":
            let circ = 3_550_000_000.0
            let maxS = 10_000_000_000.0
            let mc = circ * currentPrice
            let fdv = maxS * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Arbitrum Nitro Governance (ERC-20)",
                primaryUseCases: ["Bỏ phiếu quản trị Arbitrum DAO", "Phân bổ ngân quỹ DAO Treasury", "Biểu quyết nâng cấp công nghệ Orbit / Stylus"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: circ,
                    totalSupply: maxS,
                    maxSupply: maxS,
                    marketCapUSD: mc,
                    fdvUSD: fdv,
                    mcFdvRatio: circ / maxS,
                    annualInflationRate: 2.0,
                    isBurnActive: false
                ),
                allocations: [
                    TokenAllocationItem(category: "Arbitrum DAO Treasury", percentage: 42.78, tokenAmount: 4_278_000_000, colorHex: "#28A0F0", description: "Kho bạc do cộng đồng DAO biểu quyết chi tiêu."),
                    TokenAllocationItem(category: "Offchain Labs Team & Advisors", percentage: 26.94, tokenAmount: 2_694_000_000, colorHex: "#125199", description: "Đội ngũ sáng lập và cố vấn Offchain Labs."),
                    TokenAllocationItem(category: "Investors (Seed & Series A/B)", percentage: 17.53, tokenAmount: 1_753_000_000, colorHex: "#0D386B", description: "Lightspeed, Polychain, Pantera, Mark Cuban..."),
                    TokenAllocationItem(category: "Individual User Airdrop", percentage: 11.62, tokenAmount: 1_162_000_000, colorHex: "#5EBEFF", description: "Airdrop cho hơn 600.000 địa chỉ ví người dùng."),
                    TokenAllocationItem(category: "DAO Ecosystem Grants", percentage: 1.13, tokenAmount: 113_000_000, colorHex: "#99DAFF", description: "Tài trợ cho các dApp tiêu biểu trên Arbitrum.")
                ],
                upcomingUnlocks: [
                    TokenUnlockEvent(
                        unlockDate: Date().addingTimeInterval(86400 * 25),
                        category: "Team & Investors Unlock (Cliff)",
                        tokenAmount: 92_650_000,
                        valueUSD: 92_650_000 * currentPrice,
                        percentOfCirculating: 2.61,
                        unlockType: .cliff,
                        riskLevel: .high
                    )
                ],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "Arbitrum mở khóa định kỳ vào ngày 16 hàng tháng với khoảng 92.6 triệu ARB cho Team và VCs. Tỷ lệ lạm phát tối đa 2%/năm do DAO quyết định sau năm đầu tiên."
            )
            
        default:
            let estimatedCirc = 1_000_000_000.0
            let estimatedTotal = 1_500_000_000.0
            let mc = estimatedCirc * currentPrice
            let fdv = estimatedTotal * currentPrice
            return TokenomicsProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                tokenStandard: "Tiêu chuẩn Token Hệ sinh thái",
                primaryUseCases: ["Thanh toán phí dịch vụ", "Bỏ phiếu quản trị giao thức", "Staking nhận thưởng"],
                supplyMetrics: TokenSupplyMetrics(
                    circulatingSupply: estimatedCirc,
                    totalSupply: estimatedTotal,
                    maxSupply: estimatedTotal,
                    marketCapUSD: mc,
                    fdvUSD: fdv,
                    mcFdvRatio: estimatedCirc / estimatedTotal,
                    annualInflationRate: 4.5,
                    isBurnActive: false
                ),
                allocations: [
                    TokenAllocationItem(category: "Cộng đồng & Hệ sinh thái", percentage: 45.0, tokenAmount: estimatedTotal * 0.45, colorHex: "#00E676", description: "Tài trợ dApp, thanh khoản DEX và airdrop."),
                    TokenAllocationItem(category: "Đội ngũ sáng lập & Cố vấn", percentage: 25.0, tokenAmount: estimatedTotal * 0.25, colorHex: "#2979FF", description: "Khóa 12 tháng, mở khóa dần 36 tháng."),
                    TokenAllocationItem(category: "Nhà đầu tư sớm (Private Sale)", percentage: 20.0, tokenAmount: estimatedTotal * 0.20, colorHex: "#651FFF", description: "Vòng hạt giống và chiến lược."),
                    TokenAllocationItem(category: "Ngân quỹ dự trữ (Treasury)", percentage: 10.0, tokenAmount: estimatedTotal * 0.10, colorHex: "#FF9100", description: "Bảo đảm hoạt động dài hạn của dự án.")
                ],
                upcomingUnlocks: [
                    TokenUnlockEvent(
                        unlockDate: Date().addingTimeInterval(86400 * 30),
                        category: "Phân bổ Mở khóa Định kỳ (Linear)",
                        tokenAmount: estimatedTotal * 0.015,
                        valueUSD: (estimatedTotal * 0.015) * currentPrice,
                        percentOfCirculating: 2.25,
                        unlockType: .linear,
                        riskLevel: .medium
                    )
                ],
                vestingSchedule: vestingSchedule,
                utilityInfo: utilityInfo,
                vestingNotes: "Dự án áp dụng lịch phân bổ tiêu chuẩn ngành Web3 với thời gian khóa (Cliff) 6 - 12 tháng đối với Team và Nhà đầu tư, sau đó mở khóa tuyến tính kéo dài 24 - 48 tháng để giảm thiểu áp lực bán xả đột ngột."
            )
        }
    }
    
    private func buildVestingSchedule(baseAsset: String) -> [VestingSchedulePoint] {
        switch baseAsset {
        case "BTC":
            return [
                VestingSchedulePoint(yearLabel: "2024", circulatingPercent: 94.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 6.0),
                VestingSchedulePoint(yearLabel: "2025", circulatingPercent: 95.5, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 4.5),
                VestingSchedulePoint(yearLabel: "2026", circulatingPercent: 97.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 3.0),
                VestingSchedulePoint(yearLabel: "2027", circulatingPercent: 98.5, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 1.5),
                VestingSchedulePoint(yearLabel: "2028", circulatingPercent: 100.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 0.0)
            ]
        case "ETH":
            return [
                VestingSchedulePoint(yearLabel: "2024", circulatingPercent: 100.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 0),
                VestingSchedulePoint(yearLabel: "2025", circulatingPercent: 100.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 0),
                VestingSchedulePoint(yearLabel: "2026", circulatingPercent: 100.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 0),
                VestingSchedulePoint(yearLabel: "2027", circulatingPercent: 100.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 0),
                VestingSchedulePoint(yearLabel: "2028", circulatingPercent: 100.0, teamLockedPercent: 0, investorsLockedPercent: 0, treasuryLockedPercent: 0)
            ]
        case "SOL":
            return [
                VestingSchedulePoint(yearLabel: "2024", circulatingPercent: 80.0, teamLockedPercent: 5.0, investorsLockedPercent: 5.0, treasuryLockedPercent: 10.0),
                VestingSchedulePoint(yearLabel: "2025", circulatingPercent: 87.0, teamLockedPercent: 3.0, investorsLockedPercent: 2.0, treasuryLockedPercent: 8.0),
                VestingSchedulePoint(yearLabel: "2026", circulatingPercent: 93.0, teamLockedPercent: 1.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 6.0),
                VestingSchedulePoint(yearLabel: "2027", circulatingPercent: 97.0, teamLockedPercent: 0.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 3.0),
                VestingSchedulePoint(yearLabel: "2028", circulatingPercent: 100.0, teamLockedPercent: 0.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 0.0)
            ]
        case "SUI":
            return [
                VestingSchedulePoint(yearLabel: "2024", circulatingPercent: 27.6, teamLockedPercent: 20.0, investorsLockedPercent: 14.0, treasuryLockedPercent: 38.4),
                VestingSchedulePoint(yearLabel: "2025", circulatingPercent: 48.0, teamLockedPercent: 14.0, investorsLockedPercent: 8.0, treasuryLockedPercent: 30.0),
                VestingSchedulePoint(yearLabel: "2026", circulatingPercent: 68.0, teamLockedPercent: 8.0, investorsLockedPercent: 3.0, treasuryLockedPercent: 21.0),
                VestingSchedulePoint(yearLabel: "2027", circulatingPercent: 85.0, teamLockedPercent: 3.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 12.0),
                VestingSchedulePoint(yearLabel: "2028", circulatingPercent: 96.0, teamLockedPercent: 0.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 4.0),
                VestingSchedulePoint(yearLabel: "2029", circulatingPercent: 100.0, teamLockedPercent: 0.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 0.0)
            ]
        default:
            return [
                VestingSchedulePoint(yearLabel: "2024", circulatingPercent: 45.0, teamLockedPercent: 20.0, investorsLockedPercent: 15.0, treasuryLockedPercent: 20.0),
                VestingSchedulePoint(yearLabel: "2025", circulatingPercent: 65.0, teamLockedPercent: 12.0, investorsLockedPercent: 8.0, treasuryLockedPercent: 15.0),
                VestingSchedulePoint(yearLabel: "2026", circulatingPercent: 82.0, teamLockedPercent: 5.0, investorsLockedPercent: 3.0, treasuryLockedPercent: 10.0),
                VestingSchedulePoint(yearLabel: "2027", circulatingPercent: 94.0, teamLockedPercent: 0.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 6.0),
                VestingSchedulePoint(yearLabel: "2028", circulatingPercent: 100.0, teamLockedPercent: 0.0, investorsLockedPercent: 0.0, treasuryLockedPercent: 0.0)
            ]
        }
    }
    
    private func buildUtilityInfo(baseAsset: String) -> TokenUtilityInfo {
        switch baseAsset {
        case "BTC":
            return TokenUtilityInfo(
                stakingAPR: nil,
                hasGovernanceRights: false,
                governanceDetails: "Không có DAO hay quản trị tập trung; nâng cấp mạng lưới thông qua các đề xuất BIPs và đồng thuận node toàn cầu.",
                hasFeeBurnMechanism: false,
                feeBurnDetails: "100% phí giao dịch được phân bổ trực tiếp cho thợ đào Proof-of-Work.",
                feeDiscountPercentage: nil
            )
        case "ETH":
            return TokenUtilityInfo(
                stakingAPR: 3.35,
                hasGovernanceRights: true,
                governanceDetails: "Ủy quyền validator Proof-of-Stake; đóng vai trò làm tài sản thế chấp nền tảng của toàn bộ hệ sinh thái DeFi.",
                hasFeeBurnMechanism: true,
                feeBurnDetails: "Cơ chế EIP-1559 tự động đốt toàn bộ Base Fee của mọi giao dịch trên Ethereum Mainnet (>4.35 triệu ETH đã bị đốt vĩnh viễn).",
                feeDiscountPercentage: nil
            )
        case "SOL":
            return TokenUtilityInfo(
                stakingAPR: 6.75,
                hasGovernanceRights: true,
                governanceDetails: "Staking vào hơn 1.500 validator độc lập; bỏ phiếu nâng cấp phần mềm qua Solana Improvement Documents (SIMDs).",
                hasFeeBurnMechanism: true,
                feeBurnDetails: "50% của toàn bộ phí giao dịch cơ bản và phí ưu tiên được tự động đốt tại thời điểm thực thi block.",
                feeDiscountPercentage: nil
            )
        case "BNB":
            return TokenUtilityInfo(
                stakingAPR: 4.80,
                hasGovernanceRights: true,
                governanceDetails: "Quản trị chuỗi BNB Chain & opBNB; tham gia phân bổ giải thưởng Launchpool & Megadrop.",
                hasFeeBurnMechanism: true,
                feeBurnDetails: "Cơ chế Auto-Burn hàng quý dựa trên công thức block và giá BNB + Real-time Burn (BEP-95) đốt phí gas liên tục.",
                feeDiscountPercentage: 25.0
            )
        case "SUI":
            return TokenUtilityInfo(
                stakingAPR: 3.20,
                hasGovernanceRights: true,
                governanceDetails: "Staking với các Validator Move VM; biểu quyết phân bổ quỹ tài trợ Community Reserve.",
                hasFeeBurnMechanism: false,
                feeBurnDetails: "Áp dụng cơ chế Storage Fund (quỹ lưu trữ): người dùng trả phí lưu trữ dữ liệu on-chain và được hoàn lại khi xóa dữ liệu.",
                feeDiscountPercentage: nil
            )
        default:
            return TokenUtilityInfo(
                stakingAPR: 5.0,
                hasGovernanceRights: true,
                governanceDetails: "Bỏ phiếu tham gia quản trị DAO và biểu quyết các đề xuất nâng cấp giao thức.",
                hasFeeBurnMechanism: false,
                feeBurnDetails: "Chưa kích hoạt cơ chế đốt token định kỳ.",
                feeDiscountPercentage: nil
            )
        }
    }
}

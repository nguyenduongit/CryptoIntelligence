import Foundation

public actor ProjectDataProvider {
    public static let shared = ProjectDataProvider()
    
    public init() {}
    
    public func fetchProjectProfile(for symbol: String) async throws -> ProjectProfile {
        let cleanSymbol = symbol.uppercased()
        let baseAsset = cleanSymbol.replacingOccurrences(of: "USDT", with: "")
        return buildProjectProfile(baseAsset: baseAsset, symbol: cleanSymbol)
    }
    
    private func buildProjectProfile(baseAsset: String, symbol: String) -> ProjectProfile {
        let competitors = buildCompetitors(baseAsset: baseAsset)
        let developerActivity = buildDeveloperActivity(baseAsset: baseAsset)
        
        switch baseAsset {
        case "BTC":
            return ProjectProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                projectName: "Bitcoin (BTC)",
                tagline: "Hệ thống tiền tệ điện tử ngang hàng phi tập trung đầu tiên trên thế giới",
                launchYear: 2009,
                consensusMechanism: "Proof-of-Work (SHA-256)",
                programmingLanguage: "C++, Script",
                problemSolved: "Loại bỏ nhu cầu về bên trung gian tài chính tập trung (ngân hàng, chính phủ), giải quyết triệt để bài toán chi tiêu hai lần (Double-Spending) bằng sổ cái phân tán không thể đảo ngược.",
                technicalArchitecture: "Mạng lưới phân tán ngang hàng (P2P), mô hình đầu ra giao dịch chưa chi tiêu (UTXO), độ khó khai thác tự điều chỉnh sau mỗi 2016 block (~2 tuần) nhằm duy trì chu kỳ tạo block trung bình 10 phút.",
                founders: [
                    TeamMember(
                        name: "Satoshi Nakamoto",
                        role: "Nhà Sáng Lập Ẩn Danh",
                        bio: "Tác giả của Whitepaper Bitcoin (2008) và người triển khai khối nguyên thủy (Genesis Block) vào ngày 03/01/2009 trước khi hoàn toàn rút lui khỏi dự án vào năm 2010.",
                        previousExperience: ["Cypherpunks Movement", "Cryptography Pioneer"]
                    )
                ],
                roadmap: [
                    ProjectMilestone(quarterYear: "2008", title: "Phát hành Whitepaper", description: "Công bố tài liệu 'Bitcoin: A Peer-to-Peer Electronic Cash System'.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2009", title: "Genesis Block", description: "Khai thác khối đầu tiên chứa thông điệp thời sự The Times.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2017", title: "Nâng cấp SegWit", description: "Tối ưu hóa dung lượng block và dọn đường cho Lightning Network.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2021", title: "Nâng cấp Taproot", description: "Gia tăng tính bảo mật, hiệu quả giao dịch và hỗ trợ Schnorr Signatures.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2024", title: "Bitcoin Halving Lần 4", description: "Phần thưởng khối giảm xuống còn 3.125 BTC/block.", isCompleted: true)
                ],
                partners: [
                    EcosystemPartner(name: "Lightning Network", category: "Layer 2 Thanh Toán", description: "Kênh thanh toán vi mô tốc độ cao tức thì và chi phí gần như bằng 0."),
                    EcosystemPartner(name: "Blockstream", category: "R&D Hạ Tầng", description: "Nghiên cứu Liquid Network và giải pháp phần cứng khai thác.")
                ],
                officialLinks: [
                    OfficialResourceLink(title: "Website", url: "https://bitcoin.org", iconName: "globe"),
                    OfficialResourceLink(title: "Whitepaper", url: "https://bitcoin.org/bitcoin.pdf", iconName: "doc.text.fill"),
                    OfficialResourceLink(title: "Mã nguồn GitHub", url: "https://github.com/bitcoin/bitcoin", iconName: "chevron.left.forwardslash.chevron.right"),
                    OfficialResourceLink(title: "Trình duyệt Khối", url: "https://mempool.space", iconName: "magnifyingglass")
                ],
                competitors: competitors,
                developerActivity: developerActivity
            )
            
        case "ETH":
            return ProjectProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                projectName: "Ethereum (ETH)",
                tagline: "Máy tính ảo toàn cầu phi tập trung cho Smart Contracts & dApps",
                launchYear: 2015,
                consensusMechanism: "Proof-of-Stake (Casper FFG & LMD-GHOST)",
                programmingLanguage: "Solidity, Vyper, Go (Geth), Rust (Reth)",
                problemSolved: "Mở rộng tiềm năng của công nghệ Blockchain vượt ra ngoài tiền tệ thanh toán đơn thuần bằng cách cung cấp môi trường tính toán Turing-complete (EVM) để tự động hóa mọi thỏa thuận tài chính.",
                technicalArchitecture: "Máy ảo Ethereum Virtual Machine (EVM), kiến trúc Rollup-Centric Roadmap mở rộng qua Layer 2 (Optimistic & ZK-Rollups), chuẩn dữ liệu Blob Space (EIP-4844) và chuẩn bị cho Verkle Trees.",
                founders: [
                    TeamMember(
                        name: "Vitalik Buterin",
                        role: "Đồng Sáng Lập & Trưởng Nhóm Nghiên Cứu",
                        bio: "Lập trình viên và nhà nghiên cứu người Canada gốc Nga, đồng sáng lập Bitcoin Magazine năm 2011 trước khi công bố Whitepaper Ethereum vào cuối năm 2013.",
                        previousExperience: ["Bitcoin Magazine Co-founder", "Thiel Fellowship"]
                    ),
                    TeamMember(
                        name: "Gavin Wood",
                        role: "Đồng Sáng Lập & Tác Giả Yellow Paper",
                        bio: "Kiến trúc sư trưởng của EVM và ngôn ngữ lập trình Solidity; sau đó sáng lập Parity Technologies và Polkadot.",
                        previousExperience: ["Microsoft Research", "Polkadot Founder"]
                    )
                ],
                roadmap: [
                    ProjectMilestone(quarterYear: "2015", title: "Ra mắt Frontier Mainnet", description: "Khởi chạy mạng lưới Ethereum đầu tiên.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2022", title: "Sự Kiện The Merge", description: "Chuyển đổi thành công từ PoW sang PoS, giảm 99.95% tiêu thụ năng lượng.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2024", title: "Nâng cấp Dencun (EIP-4844)", description: "Giảm 90%+ phí giao dịch trên các mạng Layer 2 nhờ Blob Space.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2025", title: "Nâng cấp Pectra", description: "Tối ưu hóa tài khoản trừu tượng Account Abstraction và tăng giới hạn Max Effective Balance lên 2048 ETH.", isCompleted: false)
                ],
                partners: [
                    EcosystemPartner(name: "Uniswap", category: "DeFi AMM", description: "Sàn giao dịch phi tập trung lớn nhất Web3."),
                    EcosystemPartner(name: "Aave", category: "DeFi Lending", description: "Thị trường thanh khoản vay và cho vay phi tập trung."),
                    EcosystemPartner(name: "Optimism & Arbitrum", category: "Layer 2 Rollups", description: "Hạ tầng mở rộng quy mô giao dịch tốc độ cao.")
                ],
                officialLinks: [
                    OfficialResourceLink(title: "Website", url: "https://ethereum.org", iconName: "globe"),
                    OfficialResourceLink(title: "Whitepaper", url: "https://ethereum.org/en/whitepaper/", iconName: "doc.text.fill"),
                    OfficialResourceLink(title: "Mã nguồn GitHub", url: "https://github.com/ethereum", iconName: "chevron.left.forwardslash.chevron.right"),
                    OfficialResourceLink(title: "Etherscan", url: "https://etherscan.io", iconName: "magnifyingglass")
                ],
                competitors: competitors,
                developerActivity: developerActivity
            )
            
        case "SOL":
            return ProjectProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                projectName: "Solana (SOL)",
                tagline: "Blockchain Layer 1 nguyên khối hiệu năng cao hàng đầu thế giới",
                launchYear: 2020,
                consensusMechanism: "Proof-of-History (PoH) kết hợp Tower BFT",
                programmingLanguage: "Rust, C, C++",
                problemSolved: "Giải quyết bài toán nghẽn mạng và phí giao dịch đắt đỏ trên các chuỗi L1 cũ mà không cần chia cắt thanh khoản qua Layer 2, mang lại trải nghiệm mượt mà tương tự ứng dụng Web2.",
                technicalArchitecture: "Đồng hồ thời gian mật mã học Proof-of-History, máy ảo đa luồng Sealevel thực thi song song hàng nghìn giao dịch cùng lúc, giao thức truyền khối Turbine và công cụ đồng thuận độc lập mới Firedancer.",
                founders: [
                    TeamMember(
                        name: "Anatoly Yakovenko",
                        role: "Đồng Sáng Lập & CEO Solana Labs",
                        bio: "Cựu kỹ sư phần mềm cấp cao tại Qualcomm (nắm giữ 2 bằng sáng chế về hệ điều hành), từng làm việc tại Mesosphere và Dropbox.",
                        previousExperience: ["Qualcomm Senior Staff Engineer", "Dropbox Software Engineer"]
                    ),
                    TeamMember(
                        name: "Raj Gokal",
                        role: "Đồng Sáng Lập & COO Solana Labs",
                        bio: "Doanh nhân công nghệ, cựu Giám đốc Sản phẩm tại Omada Health và nhà đầu tư mạo hiểm tại General Catalyst.",
                        previousExperience: ["Omada Health Director", "General Catalyst VC"]
                    )
                ],
                roadmap: [
                    ProjectMilestone(quarterYear: "2020", title: "Ra mắt Beta Mainnet", description: "Khởi tạo mạng lưới Solana với khả năng xử lý hàng nghìn TPS.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2022", title: "Ra mắt Solana Mobile Saga", description: "Hệ sinh thái smartphone Web3 chuyên dụng.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2024", title: "Firedancer Testnet", description: "Khởi chạy client độc lập thứ hai viết bằng C++ bởi Jump Crypto.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2025", title: "Firedancer Mainnet & SIMD-0096", description: "Tối ưu hóa MEV và nâng cao thông lượng mục tiêu lên 1 triệu TPS.", isCompleted: false)
                ],
                partners: [
                    EcosystemPartner(name: "Visa", category: "Thanh Toán Toàn Cầu", description: "Thử nghiệm thanh toán USDC quy mô doanh nghiệp trên Solana."),
                    EcosystemPartner(name: "Shopify", category: "Thương Mại Điện Tử", description: "Tích hợp cổng Solana Pay cho hàng triệu nhà bán lẻ.")
                ],
                officialLinks: [
                    OfficialResourceLink(title: "Website", url: "https://solana.com", iconName: "globe"),
                    OfficialResourceLink(title: "Whitepaper", url: "https://solana.com/solana-whitepaper.pdf", iconName: "doc.text.fill"),
                    OfficialResourceLink(title: "Mã nguồn GitHub", url: "https://github.com/solana-labs/solana", iconName: "chevron.left.forwardslash.chevron.right"),
                    OfficialResourceLink(title: "SolanaFM Explorer", url: "https://solana.fm", iconName: "magnifyingglass")
                ],
                competitors: competitors,
                developerActivity: developerActivity
            )
            
        case "SUI":
            return ProjectProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                projectName: "Sui Network (SUI)",
                tagline: "Blockchain Layer 1 định hướng đối tượng tối ưu cho Game & Trải nghiệm số",
                launchYear: 2023,
                consensusMechanism: "Mysticeti BFT & Narwhal-Bullshark DAG",
                programmingLanguage: "Sui Move",
                problemSolved: "Khắc phục triệt để điểm nghẽn hiệu năng của mô hình tài khoản truyền thống bằng mô hình Object-Centric, giúp thực thi song song các giao dịch không phụ thuộc nhau (Bypass Consensus).",
                technicalArchitecture: "Mô hình định hướng đối tượng (Object-Centric Model), ngôn ngữ Sui Move với khả năng quản lý tài sản an toàn cấp độ byte-code, công cụ đồng thuận siêu nhanh Mysticeti (độ trễ <390ms).",
                founders: [
                    TeamMember(
                        name: "Evan Cheng",
                        role: "Đồng Sáng Lập & CEO Mysten Labs",
                        bio: "Từng giữ vị trí Giám đốc R&D tại Meta (Facebook Novi Financial), lãnh đạo đội ngũ kỹ thuật phát triển ngôn ngữ Move và dự án Diem/Libra. Từng đoạt giải thưởng ACM Software System Award.",
                        previousExperience: ["Meta Director of R&D", "Apple Senior Manager (LLVM)"]
                    ),
                    TeamMember(
                        name: "Adeniyi Abiodun",
                        role: "Đồng Sáng Lập & CPO Mysten Labs",
                        bio: "Cựu Trưởng bộ phận Sản phẩm tại Meta Novi, từng làm việc tại VMware, Oracle và HSBC.",
                        previousExperience: ["Meta Head of Product", "VMware", "Oracle"]
                    ),
                    TeamMember(
                        name: "Sam Blackshear",
                        role: "Đồng Sáng Lập & CTO Mysten Labs",
                        bio: "Nhà khoa học máy tính, tác giả chính phát minh ra ngôn ngữ lập trình Move tại Meta Research.",
                        previousExperience: ["Meta Principal Engineer", "Inventor of Move Language"]
                    )
                ],
                roadmap: [
                    ProjectMilestone(quarterYear: "2023", title: "Ra mắt Mainnet Genesis", description: "Khởi chạy chính thức mạng lưới Sui Network vào tháng 5/2023.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2024", title: "Nâng cấp Mysticeti Consensus", description: "Giảm độ trễ hoàn tất giao dịch xuống dưới 390ms, nhanh nhất trong toàn ngành Blockchain.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2024", title: "Ra mắt SuiPlay0X1", description: "Máy chơi game cầm tay Web3 tích hợp sâu cấp độ phần cứng hệ điều hành.", isCompleted: true),
                    ProjectMilestone(quarterYear: "2025", title: "Giao thức Walrus & DeepBook v3", description: "Hạ tầng lưu trữ phi tập trung và sổ lệnh CLOB phi tập trung tối ưu.", isCompleted: false)
                ],
                partners: [
                    EcosystemPartner(name: "Cetus Protocol", category: "DeFi DEX", description: "Sàn giao dịch thanh khoản tập trung CLMM số 1 trên Sui."),
                    EcosystemPartner(name: "Navi Protocol", category: "DeFi Lending", description: "Giao thức thanh khoản và thế chấp tài sản lớn nhất hệ sinh thái.")
                ],
                officialLinks: [
                    OfficialResourceLink(title: "Website", url: "https://sui.io", iconName: "globe"),
                    OfficialResourceLink(title: "Whitepaper", url: "https://docs.sui.io/paper/sui.pdf", iconName: "doc.text.fill"),
                    OfficialResourceLink(title: "Mã nguồn GitHub", url: "https://github.com/MystenLabs/sui", iconName: "chevron.left.forwardslash.chevron.right"),
                    OfficialResourceLink(title: "Suiscan Explorer", url: "https://suiscan.xyz", iconName: "magnifyingglass")
                ],
                competitors: competitors,
                developerActivity: developerActivity
            )
            
        default:
            return ProjectProfile(
                symbol: symbol,
                baseAsset: baseAsset,
                projectName: "\(baseAsset) Protocol",
                tagline: "Giao thức hạ tầng phi tập trung tiên tiến phục vụ nền kinh tế Web3",
                launchYear: 2022,
                consensusMechanism: "Proof-of-Stake / Smart Contract Protocol",
                programmingLanguage: "Rust, Solidity, TypeScript",
                problemSolved: "Tăng cường khả năng mở rộng, giảm thiểu chi phí giao dịch và nâng cao tính kết nối giữa các ứng dụng phi tập trung.",
                technicalArchitecture: "Kiến trúc mô-đun hóa linh hoạt, tích hợp các chuẩn giao tiếp liên chuỗi an toàn và môi trường thực thi hiệu năng cao.",
                founders: [
                    TeamMember(
                        name: "Core Contributors Team",
                        role: "Đội Ngũ Kỹ Sư & Nhà Nghiên Cứu",
                        bio: "Tập hợp các kỹ sư phần mềm giàu kinh nghiệm từ các dự án mã nguồn mở Web3 và viện nghiên cứu công nghệ uy tín.",
                        previousExperience: ["Web3 Foundation", "Open Source Software Community"]
                    )
                ],
                roadmap: [
                    ProjectMilestone(quarterYear: "Giai đoạn 1", title: "Ra mắt Genesis & Core Network", description: "Khởi tạo mạng lưới và triển khai các chức năng cốt lõi.", isCompleted: true),
                    ProjectMilestone(quarterYear: "Giai đoạn 2", title: "Mở rộng Hệ sinh thái & SDK", description: "Hỗ trợ nhà phát triển xây dựng dApps và tích hợp đối tác thanh khoản.", isCompleted: true),
                    ProjectMilestone(quarterYear: "Giai đoạn 3", title: "Phân cấp Hoàn toàn & DAO", description: "Chuyển giao quyền quản trị hoàn toàn cho cộng đồng.", isCompleted: false)
                ],
                partners: [
                    EcosystemPartner(name: "Hệ Sinh Thái dApps", category: "DeFi & Web3", description: "Mạng lưới đối tác tích hợp giao thức trên các sàn DEX và hạ tầng Oracle.")
                ],
                officialLinks: [
                    OfficialResourceLink(title: "Website", url: "https://coinmarketcap.com", iconName: "globe"),
                    OfficialResourceLink(title: "Mã nguồn GitHub", url: "https://github.com", iconName: "chevron.left.forwardslash.chevron.right"),
                    OfficialResourceLink(title: "Trình duyệt Khối", url: "https://etherscan.io", iconName: "magnifyingglass")
                ],
                competitors: competitors,
                developerActivity: developerActivity
            )
        }
    }
    
    private func buildCompetitors(baseAsset: String) -> [CompetitorBenchmarkItem] {
        switch baseAsset {
        case "SOL":
            return [
                CompetitorBenchmarkItem(name: "Solana (SOL)", tpsRealWorld: 3200, timeToFinality: "400 ms", nakamotoCoefficient: 19, avgTransactionFeeUSD: 0.0003, isTargetCoin: true),
                CompetitorBenchmarkItem(name: "Sui (SUI)", tpsRealWorld: 4500, timeToFinality: "390 ms", nakamotoCoefficient: 11, avgTransactionFeeUSD: 0.001),
                CompetitorBenchmarkItem(name: "Aptos (APT)", tpsRealWorld: 2200, timeToFinality: "900 ms", nakamotoCoefficient: 14, avgTransactionFeeUSD: 0.002),
                CompetitorBenchmarkItem(name: "Ethereum L1 (ETH)", tpsRealWorld: 15, timeToFinality: "12 phút", nakamotoCoefficient: 2, avgTransactionFeeUSD: 2.10)
            ]
        case "SUI":
            return [
                CompetitorBenchmarkItem(name: "Sui (SUI)", tpsRealWorld: 4500, timeToFinality: "390 ms", nakamotoCoefficient: 11, avgTransactionFeeUSD: 0.001, isTargetCoin: true),
                CompetitorBenchmarkItem(name: "Aptos (APT)", tpsRealWorld: 2200, timeToFinality: "900 ms", nakamotoCoefficient: 14, avgTransactionFeeUSD: 0.002),
                CompetitorBenchmarkItem(name: "Solana (SOL)", tpsRealWorld: 3200, timeToFinality: "400 ms", nakamotoCoefficient: 19, avgTransactionFeeUSD: 0.0003),
                CompetitorBenchmarkItem(name: "Near Protocol", tpsRealWorld: 1800, timeToFinality: "1.2 s", nakamotoCoefficient: 8, avgTransactionFeeUSD: 0.0008)
            ]
        case "ETH":
            return [
                CompetitorBenchmarkItem(name: "Ethereum L1", tpsRealWorld: 15, timeToFinality: "12 phút", nakamotoCoefficient: 2, avgTransactionFeeUSD: 2.10, isTargetCoin: true),
                CompetitorBenchmarkItem(name: "Arbitrum One (L2)", tpsRealWorld: 140, timeToFinality: "Instant (Soft)", nakamotoCoefficient: 1, avgTransactionFeeUSD: 0.02),
                CompetitorBenchmarkItem(name: "Solana (SOL)", tpsRealWorld: 3200, timeToFinality: "400 ms", nakamotoCoefficient: 19, avgTransactionFeeUSD: 0.0003),
                CompetitorBenchmarkItem(name: "Avalanche (C-Chain)", tpsRealWorld: 45, timeToFinality: "1.0 s", nakamotoCoefficient: 28, avgTransactionFeeUSD: 0.08)
            ]
        default:
            return [
                CompetitorBenchmarkItem(name: "\(baseAsset) Network", tpsRealWorld: 1500, timeToFinality: "1.5 s", nakamotoCoefficient: 15, avgTransactionFeeUSD: 0.005, isTargetCoin: true),
                CompetitorBenchmarkItem(name: "Solana (SOL)", tpsRealWorld: 3200, timeToFinality: "400 ms", nakamotoCoefficient: 19, avgTransactionFeeUSD: 0.0003),
                CompetitorBenchmarkItem(name: "Sui (SUI)", tpsRealWorld: 4500, timeToFinality: "390 ms", nakamotoCoefficient: 11, avgTransactionFeeUSD: 0.001),
                CompetitorBenchmarkItem(name: "Ethereum L1", tpsRealWorld: 15, timeToFinality: "12 phút", nakamotoCoefficient: 2, avgTransactionFeeUSD: 2.10)
            ]
        }
    }
    
    private func buildDeveloperActivity(baseAsset: String) -> DeveloperActivityMetrics {
        switch baseAsset {
        case "BTC":
            return DeveloperActivityMetrics(monthlyCommits: 620, activeMonthlyDevelopers: 110, totalGitHubStars: 78500, openPullRequests: 180, lastCommitAgo: "25 phút trước")
        case "ETH":
            return DeveloperActivityMetrics(monthlyCommits: 1450, activeMonthlyDevelopers: 420, totalGitHubStars: 46200, openPullRequests: 95, lastCommitAgo: "8 phút trước")
        case "SOL":
            return DeveloperActivityMetrics(monthlyCommits: 1120, activeMonthlyDevelopers: 260, totalGitHubStars: 13800, openPullRequests: 64, lastCommitAgo: "14 phút trước")
        case "SUI":
            return DeveloperActivityMetrics(monthlyCommits: 880, activeMonthlyDevelopers: 140, totalGitHubStars: 6400, openPullRequests: 42, lastCommitAgo: "19 phút trước")
        default:
            return DeveloperActivityMetrics(monthlyCommits: 350, activeMonthlyDevelopers: 65, totalGitHubStars: 4200, openPullRequests: 28, lastCommitAgo: "45 phút trước")
        }
    }
}

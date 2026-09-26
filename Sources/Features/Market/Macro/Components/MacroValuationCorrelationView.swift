import SwiftUI

public struct MacroValuationCorrelationView: View {
    public let snapshots: [MacroIndexSnapshot]
    public let seasonReport: MarketSeasonReport
    
    public init(snapshots: [MacroIndexSnapshot], seasonReport: MarketSeasonReport) {
        self.snapshots = snapshots
        self.seasonReport = seasonReport
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1. Full-Width TOTAL Market Cap & Dominance Segmented Breakdown Block
            totalMarketCapDominanceCard
            
            // 2. Capital Rotation & Season Matrix Radar Card
            seasonMatrixRadarCard
            
            // 3. Stablecoin Liquidity & Cash Sidelined Meter
            stablecoinLiquidityMeterCard
        }
    }
    
    // MARK: - 1. Full-Width TOTAL Market Cap & Dominance Card
    private var totalMarketCapDominanceCard: some View {
        let totalSnap = snapshots.first { $0.indexType == .total }
        let total2Snap = snapshots.first { $0.indexType == .total2 }
        let total3Snap = snapshots.first { $0.indexType == .total3 }
        
        let totalVal = totalSnap?.currentValue ?? seasonReport.totalMarketCapUSD
        let change24h = totalSnap?.change24h ?? 1.85
        let change7d = totalSnap?.change7d ?? 4.20
        
        let btcD = snapshots.first { $0.indexType == .btcD }?.currentValue ?? seasonReport.btcDPercentage
        let ethD = snapshots.first { $0.indexType == .ethD }?.currentValue ?? seasonReport.ethDPercentage
        let stableD = snapshots.first { $0.indexType == .stableD }?.currentValue ?? seasonReport.stablecoinDominancePercentage
        let othersD = max(2.0, 100.0 - btcD - ethD - stableD)
        
        let btcCap = totalVal * (btcD / 100.0)
        let ethCap = totalVal * (ethD / 100.0)
        let stableCap = seasonReport.totalStablecoinLiquidityUSD > 0 ? seasonReport.totalStablecoinLiquidityUSD : totalVal * (stableD / 100.0)
        let othersCap = totalVal * (othersD / 100.0)
        
        return VStack(alignment: .leading, spacing: 14) {
            // Top Header Row
            HStack {
                HStack(spacing: 7) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("TỔNG VỐN HÓA THỊ TRƯỜNG & TỶ TRỌNG THỊ PHẦN (TOTAL & DOMINANCE)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 24h & 7D Change Badges
                HStack(spacing: 6) {
                    HStack(spacing: 3) {
                        Image(systemName: change24h >= 0 ? "arrow.up.right" : "arrow.down.right")
                        Text(String(format: "24h: %+.2f%%", change24h))
                    }
                    .font(.system(size: 10.5, weight: .bold, design: .monospaced))
                    .foregroundColor(change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(change24h >= 0 ? AppTheme.upGreen.opacity(0.12) : AppTheme.downRed.opacity(0.12))
                    .clipShape(Capsule())
                    
                    HStack(spacing: 3) {
                        Text(String(format: "7D: %+.2f%%", change7d))
                    }
                    .font(.system(size: 10.5, weight: .semibold, design: .monospaced))
                    .foregroundColor(change7d >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
                }
            }
            
            // Big Value & Sub-Indices Hierarchy
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("TOTAL (Tổng Quy Mô Toàn Thị Trường)")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Text(formatTrillions(totalVal))
                        .font(.system(size: 26, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Mini Sparkline
                if let spark = totalSnap?.sparkline, !spark.isEmpty {
                    miniSparkline(points: spark, isUp: change24h >= 0)
                        .frame(width: 80, height: 28)
                }
                
                Divider()
                    .frame(height: 36)
                    .background(AppTheme.darkBorder)
                
                // TOTAL2 Badge
                if let t2 = total2Snap {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("TOTAL2 (Altcoins)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppTheme.cyan)
                            Text(String(format: "%+.1f%%", t2.change24h))
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(t2.change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                        Text(t2.formattedValue)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.darkCard.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                // TOTAL3 Badge
                if let t3 = total3Snap {
                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 4) {
                            Text("TOTAL3 (Mid/Low)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundColor(AppTheme.accentBlue)
                            Text(String(format: "%+.1f%%", t3.change24h))
                                .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                .foregroundColor(t3.change24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                        Text(t3.formattedValue)
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.darkCard.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                
                Spacer()
            }
            
            // Full-Width Segmented Dominance Bar
            VStack(alignment: .leading, spacing: 6) {
                GeometryReader { geo in
                    let w = geo.size.width
                    let btcW = max(10, w * CGFloat(btcD / 100.0))
                    let ethW = max(10, w * CGFloat(ethD / 100.0))
                    let stableW = max(10, w * CGFloat(stableD / 100.0))
                    let othersW = max(10, w - btcW - ethW - stableW)
                    
                    HStack(spacing: 2) {
                        // BTC.D Segment
                        Rectangle()
                            .fill(AppTheme.orange)
                            .frame(width: btcW)
                            .overlay(
                                Text(String(format: "BTC %.1f%%", btcD))
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                                    .lineLimit(1),
                                alignment: .center
                            )
                        
                        // ETH.D Segment
                        Rectangle()
                            .fill(Color(red: 98/255, green: 126/255, blue: 234/255))
                            .frame(width: ethW)
                            .overlay(
                                Text(String(format: "ETH %.1f%%", ethD))
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                    .lineLimit(1),
                                alignment: .center
                            )
                        
                        // STABLE.D Segment
                        Rectangle()
                            .fill(AppTheme.upGreen)
                            .frame(width: stableW)
                            .overlay(
                                Text(String(format: "STABLES %.1f%%", stableD))
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                                    .lineLimit(1),
                                alignment: .center
                            )
                        
                        // OTHERS.D Segment
                        Rectangle()
                            .fill(AppTheme.cyan)
                            .frame(width: othersW)
                            .overlay(
                                Text(String(format: "OTHERS %.1f%%", othersD))
                                    .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                                    .foregroundColor(.black)
                                    .lineLimit(1),
                                alignment: .center
                            )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(height: 22)
            }
            
            // Dominance 4-Column Metric Breakdown Cards
            HStack(spacing: 10) {
                dominanceDetailPill(
                    title: "BTC.D (Bitcoin)",
                    percentage: btcD,
                    marketCapUSD: btcCap,
                    color: AppTheme.orange,
                    icon: "bitcoinsign.circle.fill",
                    subtitle: "Thống trị dòng vốn"
                )
                
                dominanceDetailPill(
                    title: "ETH.D (Ethereum)",
                    percentage: ethD,
                    marketCapUSD: ethCap,
                    color: Color(red: 98/255, green: 126/255, blue: 234/255),
                    icon: "diamond.fill",
                    subtitle: "Hệ sinh thái EVM"
                )
                
                dominanceDetailPill(
                    title: "STABLE.D (Toàn Bộ Stablecoins)",
                    percentage: stableD,
                    marketCapUSD: stableCap,
                    color: AppTheme.upGreen,
                    icon: "banknote.fill",
                    subtitle: "USDT, USDC, USDS, USDe..."
                )
                
                dominanceDetailPill(
                    title: "OTHERS.D (Altcoins)",
                    percentage: othersD,
                    marketCapUSD: othersCap,
                    color: AppTheme.cyan,
                    icon: "square.stack.3d.up.fill",
                    subtitle: "Mid & Low-Cap tokens"
                )
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func dominanceDetailPill(
        title: String,
        percentage: Double,
        marketCapUSD: Double,
        color: Color,
        icon: String,
        subtitle: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white.opacity(0.85))
                    .lineLimit(1)
            }
            
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text(String(format: "%.2f%%", percentage))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(color)
                
                Text(formatTrillions(marketCapUSD))
                    .font(.system(size: 10.5, design: .monospaced))
                    .foregroundColor(.white.opacity(0.55))
            }
            
            Text(subtitle)
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.4))
                .lineLimit(1)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.5), lineWidth: 1))
    }
    
    // MARK: - Mini Sparkline
    private func miniSparkline(points: [Double], isUp: Bool) -> some View {
        GeometryReader { geo in
            let minVal = points.min() ?? 0
            let maxVal = points.max() ?? 1
            let range = max(0.0001, maxVal - minVal)
            
            Path { path in
                for (idx, pt) in points.enumerated() {
                    let x = geo.size.width * CGFloat(idx) / CGFloat(points.count - 1)
                    let y = geo.size.height * CGFloat(1.0 - (pt - minVal) / range)
                    if idx == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(
                isUp ? AppTheme.upGreen : AppTheme.downRed,
                style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round)
            )
        }
    }
    
    // MARK: - 2. Season Matrix Radar Card
    private var seasonMatrixRadarCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: seasonReport.currentState.iconName)
                        .foregroundColor(seasonReport.currentState.color)
                        .font(.system(size: 14))
                    Text("MA TRẬN NHẬN DIỆN MÙA & LUÂN CHUYỂN DÒNG TIỀN (CAPITAL ROTATION)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 5) {
                    Circle()
                        .fill(seasonReport.currentState.color)
                        .frame(width: 8, height: 8)
                    Text(seasonReport.currentState.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(seasonReport.currentState.color)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(seasonReport.currentState.color.opacity(0.15))
                .clipShape(Capsule())
            }
            
            // Altcoin Season Index Progress Bar
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Chỉ Số Mùa Altcoin (Altcoin Season Index):")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(seasonReport.altcoinSeasonIndex) / 100")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(seasonReport.altcoinSeasonIndex >= 75 ? AppTheme.upGreen : (seasonReport.altcoinSeasonIndex <= 25 ? AppTheme.orange : AppTheme.accentBlue))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Gradient track
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(AppTheme.orange.opacity(0.4))
                                .frame(width: geo.size.width * 0.25)
                                .overlay(Text("Mùa BTC (<25)").font(.system(size: 9)).foregroundColor(AppTheme.orange), alignment: .center)
                            
                            Rectangle()
                                .fill(AppTheme.accentBlue.opacity(0.3))
                                .frame(width: geo.size.width * 0.50)
                                .overlay(Text("Luân chuyển / Tích lũy (25 - 75)").font(.system(size: 9)).foregroundColor(.white.opacity(0.7)), alignment: .center)
                            
                            Rectangle()
                                .fill(AppTheme.upGreen.opacity(0.4))
                                .frame(width: geo.size.width * 0.25)
                                .overlay(Text("Altseason (>75)").font(.system(size: 9)).foregroundColor(AppTheme.upGreen), alignment: .center)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                        // Marker indicator
                        let xPos = max(6, min(geo.size.width - 6, geo.size.width * CGFloat(seasonReport.altcoinSeasonIndex) / 100.0))
                        Circle()
                            .fill(Color.white)
                            .frame(width: 14, height: 14)
                            .shadow(color: .black.opacity(0.5), radius: 3)
                            .position(x: xPos, y: 10)
                    }
                }
                .frame(height: 20)
            }
            
            // 4 Rotation Regime Cards
            HStack(spacing: 8) {
                rotationMatrixPill(
                    state: .bitcoinSeason,
                    description: "Dòng tiền tập trung vào BTC. BTC.D tăng mạnh, Altcoins đi ngang hoặc giảm.",
                    isActive: seasonReport.currentState == .bitcoinSeason
                )
                
                rotationMatrixPill(
                    state: .capitalRotation,
                    description: "BTC chững lại vùng đỉnh. Lợi nhuận dịch chuyển sang ETH và Top Layer 1.",
                    isActive: seasonReport.currentState == .capitalRotation
                )
                
                rotationMatrixPill(
                    state: .altcoinSeason,
                    description: "Toàn bộ Altcoins bùng nổ. BTC.D giảm mạnh, Mid-cap & Meme tăng trưởng vượt bậc.",
                    isActive: seasonReport.currentState == .altcoinSeason
                )
                
                rotationMatrixPill(
                    state: .riskOffPanic,
                    description: "Thị trường phòng thủ. Dòng vốn rút về USDT/Stablecoin, thanh lý diện rộng.",
                    isActive: seasonReport.currentState == .riskOffPanic
                )
            }
            
            // Actionable summary
            HStack(spacing: 6) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(AppTheme.cyan)
                    .font(.system(size: 11))
                Text(seasonReport.actionableSummary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white.opacity(0.85))
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.cyan.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func rotationMatrixPill(state: MarketSeasonState, description: String, isActive: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: state.iconName)
                    .font(.system(size: 10))
                    .foregroundColor(state.color)
                Text(state.rawValue)
                    .font(.system(size: 10.5, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Text(description)
                .font(.system(size: 9.5))
                .foregroundColor(.white.opacity(0.55))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(8)
        .frame(maxWidth: .infinity, minHeight: 74, alignment: .topLeading)
        .background(isActive ? state.color.opacity(0.15) : Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isActive ? state.color : AppTheme.darkBorder.opacity(0.5), lineWidth: isActive ? 1.5 : 1)
        )
    }
    
    // MARK: - 3. Stablecoin Liquidity & Cash Sidelined Meter
    private var stablecoinLiquidityMeterCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header Row
            HStack(spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "banknote.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.upGreen)
                    Text("QUY MÔ & THANH KHOẢN TIỀN MẶT TOÀN BỘ STABLECOINS (SIDELINED CASH)")
                        .font(.system(size: 11.5, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Total Cap & Dominance Badges
                HStack(spacing: 6) {
                    HStack(spacing: 4) {
                        Text("Tổng Nguồn Cung:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                        Text(formatTrillions(seasonReport.totalStablecoinLiquidityUSD))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(Color.white.opacity(0.06))
                    .clipShape(Capsule())
                    
                    HStack(spacing: 4) {
                        Text("STABLE.D:")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(AppTheme.upGreen.opacity(0.8))
                        Text(String(format: "%.2f%%", seasonReport.stablecoinDominancePercentage))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3.5)
                    .background(AppTheme.upGreen.opacity(0.12))
                    .clipShape(Capsule())
                }
            }
            
            // Multi-Stablecoin Breakdown Grid / Row
            let stables = seasonReport.topStablecoins.isEmpty ? defaultFallbackStables : seasonReport.topStablecoins
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: min(6, max(2, stables.count))), spacing: 8) {
                ForEach(stables) { item in
                    stablecoinItemPill(item)
                }
            }
            
            // Strategic Footer Note
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppTheme.orange)
                    .font(.system(size: 11))
                Text("Ý nghĩa chiến lược: Theo dõi toàn bộ vũ trụ Stablecoins (USDT + USDC + USDS + USDe + DAI...) phản ánh chính xác 100% tổng lượng 'tiền tươi' đang nằm trực chờ trên các sàn CEX và DeFi sẵn sàng giải ngân đón sóng.")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.orange.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func stablecoinItemPill(_ item: StablecoinBreakdownItem) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: item.iconName)
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.upGreen)
                    Text(item.symbol)
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // 7d change
                if item.change7dPercent != 0 {
                    Text(String(format: "%+.1f%%", item.change7dPercent))
                        .font(.system(size: 8.5, weight: .bold, design: .monospaced))
                        .foregroundColor(item.change7dPercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                }
            }
            
            Text(formatTrillions(item.circulatingUSD))
                .font(.system(size: 12.5, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            
            HStack(spacing: 3) {
                Text(String(format: "Tỷ trọng: %.1f%%", item.shareOfStablesPercentage))
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.02))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.6), lineWidth: 1))
    }
    
    private var defaultFallbackStables: [StablecoinBreakdownItem] {
        [
            StablecoinBreakdownItem(symbol: "USDT", name: "Tether USD", circulatingUSD: 183_750_000_000, dominancePercentage: 6.37, shareOfStablesPercentage: 58.5, change7dPercent: 0.24, iconName: "dollarsign.circle.fill"),
            StablecoinBreakdownItem(symbol: "USDC", name: "USD Coin", circulatingUSD: 76_600_000_000, dominancePercentage: 2.66, shareOfStablesPercentage: 24.4, change7dPercent: 2.92, iconName: "centsign.circle.fill"),
            StablecoinBreakdownItem(symbol: "USDS", name: "Sky Dollar", circulatingUSD: 6_640_000_000, dominancePercentage: 0.23, shareOfStablesPercentage: 2.1, change7dPercent: 1.95, iconName: "banknote.fill"),
            StablecoinBreakdownItem(symbol: "USDe", name: "Ethena USD", circulatingUSD: 4_930_000_000, dominancePercentage: 0.17, shareOfStablesPercentage: 1.6, change7dPercent: 2.71, iconName: "flame.fill"),
            StablecoinBreakdownItem(symbol: "DAI", name: "Maker DAI", circulatingUSD: 4_790_000_000, dominancePercentage: 0.16, shareOfStablesPercentage: 1.5, change7dPercent: -0.05, iconName: "diamond.fill"),
            StablecoinBreakdownItem(symbol: "Khác", name: "Khác", circulatingUSD: 37_190_000_000, dominancePercentage: 1.29, shareOfStablesPercentage: 11.9, change7dPercent: 1.10, iconName: "square.stack.3d.up.fill")
        ]
    }
    
    private func formatTrillions(_ val: Double) -> String {
        if val >= 1_000_000_000_000 {
            return String(format: "$%.2fT", val / 1_000_000_000_000)
        } else if val >= 1_000_000_000 {
            return String(format: "$%.1fB", val / 1_000_000_000)
        } else {
            return String(format: "$%.2f", val)
        }
    }
}

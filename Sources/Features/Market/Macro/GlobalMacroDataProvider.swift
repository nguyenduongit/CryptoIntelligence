import Foundation

public struct GlobalMacroDataProvider: Sendable {
    public static let shared = GlobalMacroDataProvider()
    
    public init() {}
    
    public func fetchGlobalMacroData(marketTrend30d: Double? = nil) -> GlobalMacroOverviewData {
        let centralBanks: [CentralBankPolicyItem] = [
            CentralBankPolicyItem(
                id: "fed",
                name: "Federal Reserve (Fed)",
                countryCode: "US",
                currentRate: 4.875, // Target range 4.75% - 5.00%
                previousRate: 5.375,
                rateChangeBps: -50,
                stance: .dovish,
                nextMeetingDate: "18/12/2026",
                fedWatchCutProbability: 84.5,
                keyNotes: "Chu kỳ nới lỏng tiền tệ đã bắt đầu với mức hạ 50bps đầu tiên. Định hướng giảm tiếp 50-100bps trong năm tới."
            ),
            CentralBankPolicyItem(
                id: "ecb",
                name: "European Central Bank (ECB)",
                countryCode: "EU",
                currentRate: 3.50,
                previousRate: 3.75,
                rateChangeBps: -25,
                stance: .dovish,
                nextMeetingDate: "12/12/2026",
                fedWatchCutProbability: 78.0,
                keyNotes: "Lạm phát khu vực Eurozone hạ nhiệt về 2.2%, ECB đã có 2 đợt hạ lãi suất liên tiếp để hỗ trợ tăng trưởng kinh tế."
            ),
            CentralBankPolicyItem(
                id: "boj",
                name: "Bank of Japan (BOJ)",
                countryCode: "JP",
                currentRate: 0.25,
                previousRate: 0.10,
                rateChangeBps: +15,
                stance: .neutral,
                nextMeetingDate: "19/12/2026",
                fedWatchCutProbability: 12.0,
                keyNotes: "Duy trì lãi suất 0.25%. Thị trường theo dõi sát tín hiệu nâng lãi suất để tránh lặp lại biến động đóng vị thế Yên Carry Trade."
            ),
            CentralBankPolicyItem(
                id: "pboc",
                name: "People's Bank of China (PBOC)",
                countryCode: "CN",
                currentRate: 3.10,
                previousRate: 3.35,
                rateChangeBps: -25,
                stance: .dovish,
                nextMeetingDate: "20/12/2026",
                fedWatchCutProbability: 95.0,
                keyNotes: "Triển khai gói kích thích tiền tệ và hạ tỷ lệ dự trữ bắt buộc (RRR) bơm hơn $140 tỷ USD vào hệ thống thanh khoản."
            ),
            CentralBankPolicyItem(
                id: "boe",
                name: "Bank of England (BOE)",
                countryCode: "UK",
                currentRate: 5.00,
                previousRate: 5.25,
                rateChangeBps: -25,
                stance: .dovish,
                nextMeetingDate: "14/12/2026",
                fedWatchCutProbability: 68.0,
                keyNotes: "Bắt đầu chu kỳ nới lỏng lãi suất sau khi lạm phát dịch vụ hạ nhiệt."
            )
        ]
        
        let inflationMetrics: [InflationReportItem] = [
            InflationReportItem(
                id: "cpi_yoy",
                metricName: "US Headline CPI (YoY)",
                latestValue: 2.5,
                previousValue: 2.9,
                forecastValue: 2.6,
                targetValue: 2.0,
                releaseDate: "11/10/2026",
                trend: "Hạ nhiệt nhanh"
            ),
            InflationReportItem(
                id: "core_cpi_yoy",
                metricName: "US Core CPI (YoY)",
                latestValue: 3.2,
                previousValue: 3.2,
                forecastValue: 3.2,
                targetValue: 2.0,
                releaseDate: "11/10/2026",
                trend: "Đi ngang"
            ),
            InflationReportItem(
                id: "pce_yoy",
                metricName: "US Headline PCE (YoY)",
                latestValue: 2.2,
                previousValue: 2.5,
                forecastValue: 2.3,
                targetValue: 2.0,
                releaseDate: "27/10/2026",
                trend: "Sát mục tiêu 2%"
            ),
            InflationReportItem(
                id: "core_pce_yoy",
                metricName: "US Core PCE (Thước đo Fed)",
                latestValue: 2.6,
                previousValue: 2.6,
                forecastValue: 2.7,
                targetValue: 2.0,
                releaseDate: "27/10/2026",
                trend: "Tốt hơn kỳ vọng"
            ),
            InflationReportItem(
                id: "ppi_yoy",
                metricName: "US PPI (Chỉ số giá sản xuất)",
                latestValue: 1.7,
                previousValue: 2.1,
                forecastValue: 1.8,
                targetValue: 2.0,
                releaseDate: "12/10/2026",
                trend: "Dưới mục tiêu 2%"
            )
        ]
        
        // Historical Global M2 vs Bitcoin Price Trajectory
        let m2Points: [GlobalLiquidityM2Point] = [
            GlobalLiquidityM2Point(timestamp: 1577836800000, dateString: "Q1 2020", globalM2Trillions: 82.5, btcPriceUSD: 7200, fedBalanceSheetTrillions: 4.2),
            GlobalLiquidityM2Point(timestamp: 1593561600000, dateString: "Q3 2020", globalM2Trillions: 91.2, btcPriceUSD: 10800, fedBalanceSheetTrillions: 7.0),
            GlobalLiquidityM2Point(timestamp: 1609459200000, dateString: "Q1 2021", globalM2Trillions: 98.4, btcPriceUSD: 29000, fedBalanceSheetTrillions: 7.4),
            GlobalLiquidityM2Point(timestamp: 1625097600000, dateString: "Q3 2021", globalM2Trillions: 103.1, btcPriceUSD: 35000, fedBalanceSheetTrillions: 8.3),
            GlobalLiquidityM2Point(timestamp: 1640995200000, dateString: "Q1 2022", globalM2Trillions: 104.5, btcPriceUSD: 46000, fedBalanceSheetTrillions: 8.9),
            GlobalLiquidityM2Point(timestamp: 1656633600000, dateString: "Q3 2022", globalM2Trillions: 101.8, btcPriceUSD: 19500, fedBalanceSheetTrillions: 8.8),
            GlobalLiquidityM2Point(timestamp: 1672531200000, dateString: "Q1 2023", globalM2Trillions: 99.6, btcPriceUSD: 16600, fedBalanceSheetTrillions: 8.4),
            GlobalLiquidityM2Point(timestamp: 1688169600000, dateString: "Q3 2023", globalM2Trillions: 102.3, btcPriceUSD: 26000, fedBalanceSheetTrillions: 8.0),
            GlobalLiquidityM2Point(timestamp: 1704067200000, dateString: "Q1 2024", globalM2Trillions: 104.8, btcPriceUSD: 42000, fedBalanceSheetTrillions: 7.5),
            GlobalLiquidityM2Point(timestamp: 1719792000000, dateString: "Q3 2024", globalM2Trillions: 106.9, btcPriceUSD: 62000, fedBalanceSheetTrillions: 7.1),
            GlobalLiquidityM2Point(timestamp: 1735689600000, dateString: "Q1 2025", globalM2Trillions: 107.8, btcPriceUSD: 85000, fedBalanceSheetTrillions: 6.9),
            GlobalLiquidityM2Point(timestamp: 1751328000000, dateString: "Q3 2025", globalM2Trillions: 108.4, btcPriceUSD: 96000, fedBalanceSheetTrillions: 6.8)
        ]
        
        let crossAssets: [CrossAssetTickerItem] = [
            CrossAssetTickerItem(
                id: "dxy",
                symbol: "DXY",
                name: "Chỉ số Sức mạnh Đô la (US Dollar Index)",
                category: .currencies,
                currentPrice: 100.85,
                priceUnit: "pts",
                change24h: -0.42,
                change30d: -2.35,
                correlationWithBTC_30d: -0.72,
                correlationWithBTC_90d: -0.68,
                iconName: "dollarsign.circle.fill",
                note: "DXY suy yếu sâu khi Fed hạ lãi suất, tạo lực đẩy mạnh cho giá Bitcoin và tài sản rủi ro."
            ),
            CrossAssetTickerItem(
                id: "gold",
                symbol: "XAU/USD",
                name: "Giá Vàng Giao Ngay (Spot Gold)",
                category: .commodities,
                currentPrice: 2658.40,
                priceUnit: "USD/oz",
                change24h: +0.85,
                change30d: +6.12,
                correlationWithBTC_30d: +0.68,
                correlationWithBTC_90d: +0.62,
                iconName: "sparkles",
                note: "Vàng liên tục phá đỉnh lịch sử (ATH) theo dòng tiền phòng hộ lạm phát & thanh khoản M2 tăng."
            ),
            CrossAssetTickerItem(
                id: "us10y",
                symbol: "US10Y",
                name: "Lợi suất Trái phiếu Mỹ 10 Năm",
                category: .bonds,
                currentPrice: 3.74,
                priceUnit: "%",
                change24h: -0.05,
                change30d: -0.42,
                correlationWithBTC_30d: -0.54,
                correlationWithBTC_90d: -0.48,
                iconName: "chart.line.downtrend.xyaxis",
                note: "Lợi suất 10Y giảm giảm chi phí vốn cho các quỹ đầu tư tài sản số."
            ),
            CrossAssetTickerItem(
                id: "spx",
                symbol: "S&P 500",
                name: "Chỉ số Chứng khoán Mỹ S&P 500",
                category: .equities,
                currentPrice: 5735.20,
                priceUnit: "pts",
                change24h: +0.62,
                change30d: +4.80,
                correlationWithBTC_30d: +0.52,
                correlationWithBTC_90d: +0.58,
                iconName: "chart.line.uptrend.xyaxis",
                note: "S&P 500 chạm đỉnh lịch sử, phản ánh khẩu vị chấp nhận rủi ro (Risk-On) rất mạnh của phố Wall."
            ),
            CrossAssetTickerItem(
                id: "ndx",
                symbol: "Nasdaq 100",
                name: "Chỉ số Cổ phiếu Công nghệ Nasdaq 100",
                category: .equities,
                currentPrice: 20045.80,
                priceUnit: "pts",
                change24h: +0.94,
                change30d: +5.65,
                correlationWithBTC_30d: +0.64,
                correlationWithBTC_90d: +0.66,
                iconName: "cpu",
                note: "Dòng tiền công nghệ AI & Web3 tăng trưởng song hành với hệ sinh thái Crypto."
            ),
            CrossAssetTickerItem(
                id: "wti",
                symbol: "Crude Oil",
                name: "Dầu thô WTI (Crude Oil)",
                category: .commodities,
                currentPrice: 71.40,
                priceUnit: "USD/bbl",
                change24h: -1.15,
                change30d: -4.20,
                correlationWithBTC_30d: -0.22,
                correlationWithBTC_90d: -0.15,
                iconName: "fuelpump.fill",
                note: "Giá dầu thô ổn định giúp giảm áp lực lạm phát năng lượng lên nền kinh tế toàn cầu."
            )
        ]
        
        let upcomingEvents: [EconomicEventItem] = [
            EconomicEventItem(
                id: "fomc_next",
                title: "Quyết định Lãi suất FOMC & Họp báo Powell",
                country: "Mỹ (Fed)",
                dateString: "18/12/2026",
                timeString: "02:00 (VN)",
                impactLevel: .high,
                actual: nil,
                forecast: "4.50% (-25 bps)",
                previous: "4.75%",
                cryptoImpact: .bullish,
                analysis: "Kỳ vọng tiếp tục hạ lãi suất 25 bps. Tuyên bố của Chủ tịch Powell sẽ định hình đường cong thanh khoản Q1."
            ),
            EconomicEventItem(
                id: "cpi_next",
                title: "Công bố Chỉ số Lạm phát CPI Mỹ",
                country: "Mỹ (BLS)",
                dateString: "12/12/2026",
                timeString: "19:30 (VN)",
                impactLevel: .high,
                actual: nil,
                forecast: "2.4% YoY",
                previous: "2.5% YoY",
                cryptoImpact: .bullish,
                analysis: "Nếu CPI giảm về 2.4% hoặc thấp hơn, xác suất Fed hạ mạnh lãi suất tăng cao, kích hoạt sóng tăng giá Crypto."
            ),
            EconomicEventItem(
                id: "pce_next",
                title: "Chỉ số Lạm phát Lõi Core PCE",
                country: "Mỹ (BEA)",
                dateString: "22/12/2026",
                timeString: "19:30 (VN)",
                impactLevel: .high,
                actual: nil,
                forecast: "2.6% YoY",
                previous: "2.6% YoY",
                cryptoImpact: .neutral,
                analysis: "Thước đo ưa thích của Fed. Kết quả dưới 2.6% sẽ củng cố kịch bản kinh tế hạ cánh mềm (Soft Landing)."
            ),
            EconomicEventItem(
                id: "boj_next",
                title: "Quyết định Lãi suất Ngân hàng Trung ương Nhật",
                country: "Nhật Bản (BOJ)",
                dateString: "19/12/2026",
                timeString: "10:30 (VN)",
                impactLevel: .high,
                actual: nil,
                forecast: "0.25% (Giữ nguyên)",
                previous: "0.25%",
                cryptoImpact: .volatilityAlert,
                analysis: "Nếu BOJ bất ngờ tăng lãi suất lên 0.50%, có thể gây rung lắc ngắn hạn do hiện tượng thanh lý vị thế Yên Carry Trade."
            ),
            EconomicEventItem(
                id: "nfp_next",
                title: "Báo cáo Bảng lương Phi Nông nghiệp (NFP)",
                country: "Mỹ (BLS)",
                dateString: "05/12/2026",
                timeString: "19:30 (VN)",
                impactLevel: .medium,
                actual: nil,
                forecast: "+150K",
                previous: "+142K",
                cryptoImpact: .neutral,
                analysis: "Thị trường lao động duy trì ổn định mà không sụt giảm mạnh là điều kiện hoàn hảo cho tài sản rủi ro."
            )
        ]
        
        // B6 FIX: Compute macroRiskScore dynamically from actual policy & macro indicators
        var macroScore = 50 // baseline neutral
        
        // 1. Central bank stances: dovish policies add points (liquidity easing)
        let dovishCount = centralBanks.filter { $0.stance == .dovish }.count
        let hawkishCount = centralBanks.filter { $0.stance == .hawkish }.count
        macroScore += (dovishCount * 5) - (hawkishCount * 8)
        
        // 2. Inflation trend: CPI dropping towards target adds points
        if let cpi = inflationMetrics.first(where: { $0.id == "cpi_yoy" }) {
            if cpi.latestValue < cpi.previousValue {
                macroScore += 6 // Disinflation
            } else if cpi.latestValue > cpi.previousValue {
                macroScore -= 6
            }
        }
        
        // 3. Global M2 liquidity: growth adds points
        if m2Points.count >= 2 {
            let latestM2 = m2Points.last?.globalM2Trillions ?? 0
            let prevM2 = m2Points[m2Points.count - 2].globalM2Trillions
            if latestM2 > prevM2 {
                macroScore += 8 // Expanding global liquidity
            } else {
                macroScore -= 6
            }
        }
        
        // 4. Cross Assets: DXY weakening
        if let dxy = crossAssets.first(where: { $0.id == "dxy" }), dxy.change30d < 0 {
            macroScore += 5 // Weaker USD = Bullish for crypto
        }
        
        // 5. Dynamic Market Liquidity & Risk Appetite Momentum
        if let trend = marketTrend30d {
            if trend > 20.0 {
                macroScore += 12 // Risk-on surge
            } else if trend > 5.0 {
                macroScore += 6
            } else if trend < -20.0 {
                macroScore -= 18 // Severe risk-off liquidity flight
            } else if trend < -5.0 {
                macroScore -= 8
            }
        }
        
        let calculatedMacroScore = max(25, min(90, macroScore))
        let sentimentSummary: String
        if calculatedMacroScore >= 75 {
            sentimentSummary = "Môi trường Vĩ mô thuận lợi (Strong Risk-On): Chu kỳ nới lỏng tiền tệ mở rộng kết hợp cung tiền M2 gia tăng tạo bệ phóng thanh khoản cho tài sản số."
        } else if calculatedMacroScore >= 60 {
            sentimentSummary = "Môi trường Vĩ mô tích cực (Moderate Risk-On): Lãi suất hạ nhiệt dần, áp lực lạm phát được kiểm soát ở mức chấp nhận được."
        } else if calculatedMacroScore >= 45 {
            sentimentSummary = "Môi trường Vĩ mô trung tính (Neutral): Các tín hiệu nới lỏng đan xen với lo ngại tăng trưởng kinh tế."
        } else {
            sentimentSummary = "Môi trường Vĩ mô thách thức (Risk-Off): Thanh khoản thắt chặt hoặc bất ổn vĩ mô gây áp lực lên tài sản rủi ro."
        }
        
        return GlobalMacroOverviewData(
            centralBanks: centralBanks,
            inflationMetrics: inflationMetrics,
            unemploymentRate: 4.2,
            nonFarmPayrollsK: 142.0,
            m2History: m2Points,
            crossAssets: crossAssets,
            upcomingEvents: upcomingEvents,
            macroRiskScore: calculatedMacroScore,
            macroSentimentSummary: sentimentSummary,
            lastUpdated: Date()
        )
    }
}

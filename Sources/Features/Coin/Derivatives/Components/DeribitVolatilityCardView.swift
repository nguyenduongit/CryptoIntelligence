import SwiftUI

public struct DeribitVolatilityCardView: View {
    public let profile: DeribitOptionsSurfaceProfile
    
    public init(profile: DeribitOptionsSurfaceProfile) {
        self.profile = profile
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .foregroundColor(AppTheme.accentBlue)
                    .font(.system(size: 13))
                Text("MẶT CONG BIẾN ĐỘNG & QUYỀN CHỌN DERIBIT (OPTIONS INTELLIGENCE)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
                Spacer()
                HStack(spacing: 4) {
                    Circle()
                        .fill(profile.isFallback ? AppTheme.warningYellow : AppTheme.upGreen)
                        .frame(width: 6, height: 6)
                    Text(profile.isFallback ? "Proxy Benchmark Feed" : "Live Deribit v2")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(profile.isFallback ? AppTheme.warningYellow : AppTheme.upGreen)
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color.white.opacity(0.06))
                .clipShape(Capsule())
            }
            
            // Top 3 Core Institutional Metrics: DVOL Index, Max Pain Strike, Put/Call Ratio
            HStack(spacing: 12) {
                // Card 1: DVOL Index (Crypto VIX)
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("CRYPTO VIX (DVOL)")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("30D Forward IV")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(String(format: "%.1f%%", profile.dvol.currentDVOL))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(profile.dvol.sentimentColor)
                        
                        Text(String(format: "%+.2f%%", profile.dvol.dvolChange24h))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(profile.dvol.dvolChange24h >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    
                    Divider().background(AppTheme.darkBorder)
                    
                    HStack {
                        Text("Realized Vol (HV):")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(String(format: "%.1f%%", profile.dvol.realizedVol30d))
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack {
                        Text("Vol Risk Premium:")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(String(format: "%+.1f%%", profile.dvol.volRiskPremium))
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(profile.dvol.volRiskPremium > 0 ? AppTheme.downRed : AppTheme.upGreen)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Card 2: Max Pain Strike
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("MAX PAIN STRIKE")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(profile.maxPain.expiryDateString)
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text("$\(Int(profile.maxPain.maxPainStrike).formatted())")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                        
                        Text(String(format: "%+.1f%%", profile.maxPain.distancePercent))
                            .font(.system(size: 11, weight: .semibold, design: .monospaced))
                            .foregroundColor(profile.maxPain.distancePercent >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    
                    Divider().background(AppTheme.darkBorder)
                    
                    HStack {
                        Text("Spot Hiện Tại:")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text("$\(Int(profile.maxPain.currentUnderlyingPrice).formatted())")
                            .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    
                    HStack {
                        Text("Hiệu ứng dìm giá:")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(abs(profile.maxPain.distancePercent) > 3 ? "Lực hút mạnh" : "Bám sát")
                            .font(.system(size: 9.5, weight: .semibold))
                            .foregroundColor(abs(profile.maxPain.distancePercent) > 3 ? AppTheme.orange : AppTheme.upGreen)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                
                // Card 3: Put/Call Ratio & Open Interest Distribution
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Text("TỶ LỆ PUT / CALL (PCR)")
                            .font(.system(size: 9.5, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                        Spacer()
                        Text(profile.maxPain.putCallRatio > 1.0 ? "Bearish Hedge" : "Bullish Biased")
                            .font(.system(size: 9))
                            .foregroundColor(profile.maxPain.pcrColor)
                    }
                    
                    Text(String(format: "%.3f", profile.maxPain.putCallRatio))
                        .font(.system(size: 18, weight: .bold, design: .monospaced))
                        .foregroundColor(profile.maxPain.pcrColor)
                    
                    Divider().background(AppTheme.darkBorder)
                    
                    // Visual Call vs Put OI Bar
                    let total = max(1.0, profile.maxPain.totalCallOIUSD + profile.maxPain.totalPutOIUSD)
                    let callShare = (profile.maxPain.totalCallOIUSD / total)
                    
                    GeometryReader { geo in
                        HStack(spacing: 2) {
                            Rectangle()
                                .fill(AppTheme.upGreen)
                                .frame(width: max(4.0, geo.size.width * CGFloat(callShare)))
                            Rectangle()
                                .fill(AppTheme.downRed)
                        }
                        .clipShape(Capsule())
                    }
                    .frame(height: 6)
                    
                    HStack {
                        Text("Calls: $\(formatUSD(profile.maxPain.totalCallOIUSD))")
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(AppTheme.upGreen)
                        Spacer()
                        Text("Puts: $\(formatUSD(profile.maxPain.totalPutOIUSD))")
                            .font(.system(size: 8.5, design: .monospaced))
                            .foregroundColor(AppTheme.downRed)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.03))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // 25-Delta Put/Call Skew Surface (7D, 30D, 90D)
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("ĐỘ LỆCH BIẾN ĐỘNG 25-DELTA (SKEW SURFACE)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("Skew = IV(25Δ Put) - IV(25Δ Call)")
                        .font(.system(size: 9.5))
                        .foregroundColor(.white.opacity(0.4))
                }
                
                HStack(spacing: 12) {
                    ForEach(profile.skews) { skew in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(skew.tenor)
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                                Spacer()
                                Text(String(format: "%+.2f%%", skew.skewPercent))
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(skew.skewColor)
                            }
                            
                            HStack(spacing: 8) {
                                Text("Put IV: \(String(format: "%.1f%%", skew.putIV))")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(AppTheme.downRed.opacity(0.9))
                                Text("Call IV: \(String(format: "%.1f%%", skew.callIV))")
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(AppTheme.upGreen.opacity(0.9))
                            }
                            
                            Text(skew.interpretation)
                                .font(.system(size: 9))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.02))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            // Institutional Insight Banner
            HStack(spacing: 10) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppTheme.warningYellow)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("ĐÁNH GIÁ ĐỊNH LƯỢNG QUYỀN CHỌN (QUANTITATIVE OPTIONS SUMMARY)")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                    Text("\(profile.dvol.sentiment). \(profile.maxPain.gravitationalNote).")
                        .font(.system(size: 10))
                        .foregroundColor(.white.opacity(0.9))
                }
                Spacer()
            }
            .padding(10)
            .background(AppTheme.warningYellow.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.warningYellow.opacity(0.25), lineWidth: 1))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func formatUSD(_ val: Double) -> String {
        if val >= 1_000_000_000 {
            return String(format: "%.2fB", val / 1_000_000_000.0)
        } else if val >= 1_000_000 {
            return String(format: "%.1fM", val / 1_000_000.0)
        } else if val >= 1_000 {
            return String(format: "%.0fK", val / 1_000.0)
        } else {
            return String(format: "%.0f", val)
        }
    }
}

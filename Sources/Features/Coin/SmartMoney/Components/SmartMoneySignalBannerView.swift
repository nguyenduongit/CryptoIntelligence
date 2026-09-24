import SwiftUI

public struct SmartMoneySignalBannerView: View {
    public let signal: SmartMoneySentimentSignal
    
    public init(signal: SmartMoneySentimentSignal) {
        self.signal = signal
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 16) {
                // Circular Gauge Score
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.12), lineWidth: 5)
                        .frame(width: 48, height: 48)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(signal.score) / 100.0)
                        .stroke(scoreColor(signal.score), style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 48, height: 48)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(signal.score)")
                        .font(.system(size: 15, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }
                
                // Title, Health Label & Subtitle
                VStack(alignment: .leading, spacing: 3) {
                    Text("Chỉ Số Dòng Tiền Thông Minh (Smart Money Index)")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    
                    HStack(spacing: 6) {
                        Circle()
                            .fill(scoreColor(signal.score))
                            .frame(width: 7, height: 7)
                        Text(signal.signalLabel)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(scoreColor(signal.score))
                    }
                }
                
                Spacer()
                
                // Metrics Highlights
                HStack(spacing: 12) {
                    // Net DEX Volume
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Dòng Mua Ròng DEX 24h")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(netDEXVolumeText)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(signal.netDEXVolume24hUSD >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkHeaderBg.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    // Smart Holders Count
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Số Ví Smart Trader")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        HStack(spacing: 4) {
                            Text("\(signal.smartMoneyHoldersCount) ví")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text("(+\(signal.smartHoldersChange7d) 7d)")
                                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                                .foregroundColor(AppTheme.upGreen)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkHeaderBg.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Executive Summary Text
            Text(signal.analysisSummary)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.8))
                .lineSpacing(3)
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func scoreColor(_ s: Int) -> Color {
        if s >= 80 { return AppTheme.upGreen }
        if s >= 65 { return AppTheme.cyan }
        if s >= 50 { return AppTheme.warningYellow }
        return AppTheme.downRed
    }
    
    private var netDEXVolumeText: String {
        let prefix = signal.netDEXVolume24hUSD >= 0 ? "+" : "-"
        return prefix + Formatters.formatVolume(abs(signal.netDEXVolume24hUSD)) + " USD"
    }
}

import SwiftUI

public struct CentralBanksPolicyCardView: View {
    public let centralBanks: [CentralBankPolicyItem]
    
    public init(centralBanks: [CentralBankPolicyItem]) {
        self.centralBanks = centralBanks
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.accentBlue)
                    Text("Chính Sách Tiền Tệ & Lãi Suất Toàn Cầu")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(AppTheme.upGreen)
                        .frame(width: 6, height: 6)
                    Text("Chu kỳ Nới Lỏng (Global Easing)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(AppTheme.upGreen)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(AppTheme.upGreen.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            // CME FedWatch Rate Cut Probability Bar
            if let fed = centralBanks.first(where: { $0.id == "fed" }), let prob = fed.fedWatchCutProbability {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Xác suất Fed tiếp tục hạ lãi suất (CME FedWatch Tool)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text(String(format: "%.1f%% Kỳ vọng Hạ Lãi Suất", prob))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.accentBlue)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppTheme.darkBackground)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.accentBlue, AppTheme.cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * CGFloat(prob / 100.0), height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(10)
                .background(AppTheme.darkBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Central Banks List
            VStack(spacing: 8) {
                ForEach(centralBanks) { bank in
                    HStack(spacing: 12) {
                        // Flag / Country Badge
                        Text(bank.countryCode)
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 24)
                            .background(AppTheme.darkBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        
                        // Bank Name & Meeting Date
                        VStack(alignment: .leading, spacing: 2) {
                            Text(bank.name)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                            Text("Họp kế tiếp: \(bank.nextMeetingDate)")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.45))
                        }
                        
                        Spacer()
                        
                        // Current Rate & Change
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: "%.2f%%", bank.currentRate))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            
                            HStack(spacing: 2) {
                                Image(systemName: bank.rateChangeBps < 0 ? "arrow.down" : (bank.rateChangeBps > 0 ? "arrow.up" : "minus"))
                                    .font(.system(size: 8, weight: .bold))
                                Text(String(format: "%@%d bps", bank.rateChangeBps > 0 ? "+" : "", bank.rateChangeBps))
                                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            }
                            .foregroundColor(bank.rateChangeBps <= 0 ? AppTheme.upGreen : AppTheme.downRed)
                        }
                        
                        // Stance Badge
                        Text(bank.stance.rawValue)
                            .font(.system(size: 10, weight: .semibold))
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(bank.stance.badgeColor.opacity(0.18))
                            .foregroundColor(bank.stance.badgeColor)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .frame(width: 130, alignment: .trailing)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

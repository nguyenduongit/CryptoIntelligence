import SwiftUI

public struct GlobalMacroSidebarView: View {
    @Bindable var viewModel: MarketViewModel
    
    public init(viewModel: MarketViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Header Bar
            headerView
            
            ScrollView {
                VStack(alignment: .leading, spacing: 6) {
                    Text("DANH MỤC PHÂN TÍCH VĨ MÔ")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .padding(.bottom, 2)
                    
                    ForEach(GlobalMacroSection.allCases) { sec in
                        let isSelected = (viewModel.selectedGlobalMacroSection == sec)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedGlobalMacroSection = sec
                            }
                        }) {
                            HStack(spacing: 10) {
                                // Icon Box
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isSelected ? AppTheme.accentBlue.opacity(0.2) : Color.white.opacity(0.04))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: sec.iconName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.6))
                                }
                                
                                // Text Content
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(sec.rawValue)
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                                        .lineLimit(1)
                                    
                                    Text(sectionSubtitle(sec))
                                        .font(.system(size: 9.5))
                                        .foregroundColor(.white.opacity(0.45))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Circle()
                                        .fill(AppTheme.accentBlue)
                                        .frame(width: 6, height: 6)
                                        .shadow(color: AppTheme.accentBlue.opacity(0.8), radius: 3)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? AppTheme.accentBlue.opacity(0.12) : Color.white.opacity(0.001)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                            .contentShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            
            Spacer(minLength: 0)
            
            // Bottom Macro Risk Health
            bottomMacroHealth
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "globe.americas.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.accentBlue)
                Text("KINH TẾ VĨ MÔ")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("ĐIỀU HƯỚNG")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.accentBlue)
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(AppTheme.accentBlue.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .frame(height: AppTheme.subHeaderHeight)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Bottom Macro Health
    private var bottomMacroHealth: some View {
        VStack(spacing: 6) {
            Divider().background(AppTheme.darkBorder)
            
            HStack(spacing: 8) {
                Image(systemName: "gauge.with.dots.needle.50percent")
                    .foregroundColor(AppTheme.upGreen)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("TÂM LÝ VĨ MÔ")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Risk-On Toàn Cầu (74/100)")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.upGreen)
                }
                
                Spacer()
            }
            .padding(10)
            .background(AppTheme.darkCard.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .padding(.horizontal, 10)
            .padding(.bottom, 8)
        }
    }
    
    private func sectionSubtitle(_ sec: GlobalMacroSection) -> String {
        switch sec {
        case .all: return "Bao quát toàn cảnh các chỉ báo"
        case .valuation: return "TOTAL, TOTAL2, BTC.D & Mùa Altcoin"
        case .centralBanks: return "Lãi suất Fed, ECB, BOJ, PBOC"
        case .inflation: return "Chỉ số CPI, Core PCE, Việc làm"
        case .intermarket: return "DXY, Vàng, S&P 500, US10Y"
        case .liquidityM2: return "Cung tiền toàn cầu & bảng cân đối"
        case .calendar: return "Sự kiện & họp FOMC sắp tới"
        }
    }
}

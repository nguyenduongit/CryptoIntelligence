import SwiftUI

public struct ScreenerSidebarView: View {
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
                    Text("BỘ LỌC RADAR TÍN HIỆU")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                        .padding(.bottom, 2)
                    
                    ForEach(ScreenerPresetSelection.allCases) { preset in
                        let isSelected = (viewModel.selectedScreenerPreset == preset)
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.selectedScreenerPreset = preset
                            }
                        }) {
                            HStack(spacing: 10) {
                                // Icon Box
                                ZStack {
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isSelected ? Color.yellow.opacity(0.2) : Color.white.opacity(0.04))
                                        .frame(width: 28, height: 28)
                                    
                                    Image(systemName: preset.iconName)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(isSelected ? Color.yellow : .white.opacity(0.6))
                                }
                                
                                // Text Content
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(preset.rawValue)
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                                        .lineLimit(1)
                                    
                                    Text(presetSubtitle(preset))
                                        .font(.system(size: 9.5))
                                        .foregroundColor(.white.opacity(0.45))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Circle()
                                        .fill(Color.yellow)
                                        .frame(width: 6, height: 6)
                                        .shadow(color: Color.yellow.opacity(0.8), radius: 3)
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(
                                isSelected ? Color.yellow.opacity(0.12) : Color.clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(isSelected ? Color.yellow.opacity(0.4) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
            }
            
            Spacer(minLength: 0)
            
            // Bottom Radar Engine Health
            bottomRadarEngineHealth
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.darkSidebarBg)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            HStack(spacing: 7) {
                Image(systemName: "dot.radiowaves.left.and.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color.yellow)
                Text("RADAR TÍN HIỆU")
                    .font(.system(size: 12.5, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text("ĐIỀU HƯỚNG")
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(Color.yellow)
                .padding(.horizontal, 6)
                .padding(.vertical, 2.5)
                .background(Color.yellow.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Bottom Radar Engine Health
    private var bottomRadarEngineHealth: some View {
        VStack(spacing: 6) {
            Divider().background(AppTheme.darkBorder)
            
            HStack(spacing: 8) {
                Image(systemName: "bolt.badge.automatic.fill")
                    .foregroundColor(Color.yellow)
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text("ENGINE QUÉT TÍN HIỆU")
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                    Text("Live Scanner 24/7 (Sẵn sàng)")
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
    
    private func presetSubtitle(_ preset: ScreenerPresetSelection) -> String {
        switch preset {
        case .all: return "Quét tổng hợp mọi tín hiệu kích hoạt"
        case .breakout: return "Phá vỡ kháng cự / đường xu hướng"
        case .oversold: return "Chỉ báo RSI vào vùng quá bán sâu"
        case .whale: return "Dòng tiền lớn gom hàng & đột biến Vol"
        case .goldenCross: return "Đường MA50 cắt lên trên MA200"
        case .largeCap: return "Tập trung nhóm 50 coin đầu ngành"
        }
    }
}

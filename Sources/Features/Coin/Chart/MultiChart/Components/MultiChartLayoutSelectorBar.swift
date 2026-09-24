import SwiftUI

public struct MultiChartLayoutSelectorBar: View {
    @Binding public var layout: MultiChartLayout
    @Binding public var showRelativeStrength: Bool
    
    public init(layout: Binding<MultiChartLayout>, showRelativeStrength: Binding<Bool>) {
        self._layout = layout
        self._showRelativeStrength = showRelativeStrength
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            // Layout modes
            HStack(spacing: 4) {
                ForEach(MultiChartLayout.allCases) { mode in
                    let isSelected = layout == mode
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            layout = mode
                        }
                    }) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 12))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.5))
                            .padding(6)
                            .background(isSelected ? AppTheme.accentBlue : AppTheme.darkSurface)
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.5) : AppTheme.darkBorder, lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .help(mode.rawValue)
                }
            }
            
            Divider()
                .frame(height: 16)
                .background(AppTheme.darkBorder)
            
            // Relative Strength Toggle Button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showRelativeStrength.toggle()
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 11))
                    Text("Sức Mạnh vs BTC")
                        .font(.system(size: 11, weight: showRelativeStrength ? .bold : .medium))
                }
                .foregroundColor(showRelativeStrength ? .white : .white.opacity(0.6))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(showRelativeStrength ? AppTheme.cyan.opacity(0.25) : AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(showRelativeStrength ? AppTheme.cyan.opacity(0.6) : AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .help("Bật/Tắt đo lường sức mạnh tương quan Altcoin so với Bitcoin (ALT/BTC)")
            
            Spacer()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
}

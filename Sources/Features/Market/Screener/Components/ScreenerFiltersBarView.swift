import SwiftUI

public struct ScreenerFiltersBarView: View {
    @Binding public var config: ScreenerFilterConfig
    
    public init(config: Binding<ScreenerFilterConfig>) {
        self._config = config
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            // Row 1: Search & Direction Filter
            HStack(spacing: 12) {
                // Search field
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.5))
                        .font(.system(size: 12))
                    TextField("Tìm theo Coin (BTC, ETH, SOL...)", text: $config.searchText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .foregroundColor(.white)
                    if !config.searchText.isEmpty {
                        Button(action: { config.searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.white.opacity(0.4))
                                .font(.system(size: 11))
                                .padding(2)
                                .background(Color.white.opacity(0.001))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
                .frame(width: 220)
                
                // Direction filter buttons
                HStack(spacing: 4) {
                    filterDirectionButton(title: "Tất cả", direction: nil)
                    filterDirectionButton(title: "Tăng (Bullish)", direction: .bullish)
                    filterDirectionButton(title: "Giảm (Bearish)", direction: .bearish)
                }
                
                Spacer()
                
                // Strength score slider
                HStack(spacing: 6) {
                    Text("Độ mạnh tối thiểu: \(config.minStrengthScore)")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                    Slider(
                        value: Binding(
                            get: { Double(config.minStrengthScore) },
                            set: { config.minStrengthScore = Int($0) }
                        ),
                        in: 40...95,
                        step: 5
                    )
                    .frame(width: 100)
                    .accentColor(AppTheme.accentBlue)
                }
            }
            
            // Row 2: Category Chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    categoryChip(title: "Tất Cả Tín Hiệu", category: nil, icon: "square.grid.2x2.fill")
                    
                    ForEach(SignalCategory.allCases) { cat in
                        categoryChip(title: cat.rawValue, category: cat, icon: cat.iconName)
                    }
                }
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    @ViewBuilder
    private func filterDirectionButton(title: String, direction: SignalDirection?) -> some View {
        let isSelected = config.selectedDirection == direction
        Button(action: { config.selectedDirection = direction }) {
            Text(title)
                .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? AppTheme.accentBlue : AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .contentShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private func categoryChip(title: String, category: SignalCategory?, icon: String) -> some View {
        let isSelected = config.selectedCategory == category
        Button(action: { config.selectedCategory = category }) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
            }
            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(isSelected ? (category?.color ?? AppTheme.accentBlue) : AppTheme.darkSurface)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isSelected ? Color.white.opacity(0.3) : AppTheme.darkBorder, lineWidth: 1)
            )
            .contentShape(RoundedRectangle(cornerRadius: 5))
        }
        .buttonStyle(.plain)
    }
}

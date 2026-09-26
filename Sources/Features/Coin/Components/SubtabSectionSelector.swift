import SwiftUI

public struct SubtabSectionItem: Identifiable, Hashable {
    public let id: String
    public let title: String
    public let iconName: String
    public var badge: String?
    
    public init(id: String, title: String, iconName: String, badge: String? = nil) {
        self.id = id
        self.title = title
        self.iconName = iconName
        self.badge = badge
    }
}

public struct SubtabSectionSelector: View {
    public let items: [SubtabSectionItem]
    @Binding public var selectedId: String
    
    public init(items: [SubtabSectionItem], selectedId: Binding<String>) {
        self.items = items
        self._selectedId = selectedId
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            ForEach(items) { item in
                let isSelected = selectedId == item.id
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        selectedId = item.id
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: item.iconName)
                            .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                            .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.5))
                        
                        Text(item.title)
                            .font(.system(size: 11.5, weight: isSelected ? .semibold : .medium))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.65))
                        
                        if let badge = item.badge {
                            Text(badge)
                                .font(.system(size: 9.5, weight: .bold))
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1.5)
                                .background(isSelected ? AppTheme.accentBlue.opacity(0.25) : Color.white.opacity(0.08))
                                .foregroundColor(isSelected ? AppTheme.accentBlue : .white.opacity(0.6))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        isSelected
                        ? AppTheme.darkCard
                        : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                isSelected ? AppTheme.accentBlue.opacity(0.5) : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding(.horizontal, 2)
        .padding(.vertical, 2)
    }
}

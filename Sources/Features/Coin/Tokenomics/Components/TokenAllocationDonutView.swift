import SwiftUI

public struct TokenAllocationDonutView: View {
    public let allocations: [TokenAllocationItem]
    @Binding var selectedAllocation: TokenAllocationItem?
    
    public init(allocations: [TokenAllocationItem], selectedAllocation: Binding<TokenAllocationItem?>) {
        self.allocations = allocations
        self._selectedAllocation = selectedAllocation
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Cơ Cấu Phân Bổ Token (Token Allocation)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                Text("Tổng 100%")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            HStack(spacing: 20) {
                // 1. Donut Chart
                ZStack {
                    Canvas { context, size in
                        let center = CGPoint(x: size.width / 2, y: size.height / 2)
                        let radius = min(size.width, size.height) / 2 - 8
                        let innerRadius = radius * 0.65
                        
                        var startAngle: Angle = .degrees(-90)
                        
                        for item in allocations {
                            let sweep = Angle.degrees(item.percentage * 3.6)
                            let endAngle = startAngle + sweep
                            
                            var path = Path()
                            path.addArc(
                                center: center,
                                radius: radius,
                                startAngle: startAngle,
                                endAngle: endAngle,
                                clockwise: false
                            )
                            path.addArc(
                                center: center,
                                radius: innerRadius,
                                startAngle: endAngle,
                                endAngle: startAngle,
                                clockwise: true
                            )
                            path.closeSubpath()
                            
                            let isSelected = (selectedAllocation?.id == item.id)
                            let color = Color(hex: item.colorHex) ?? AppTheme.accentBlue
                            
                            context.fill(path, with: .color(isSelected ? color : color.opacity(0.85)))
                            if isSelected {
                                context.stroke(path, with: .color(.white), lineWidth: 2)
                            }
                            
                            startAngle = endAngle
                        }
                    }
                    .frame(width: 170, height: 170)
                    
                    // Center Content in Donut
                    VStack(spacing: 2) {
                        if let sel = selectedAllocation {
                            Text(String(format: "%.1f%%", sel.percentage))
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(.white)
                            Text(sel.category)
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                                .frame(maxWidth: 80)
                        } else {
                            Text("Phân bổ")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .frame(width: 170, height: 170)
                
                // 2. Allocation List
                VStack(spacing: 6) {
                    ForEach(allocations) { item in
                        let isSelected = (selectedAllocation?.id == item.id)
                        
                        Button(action: { selectedAllocation = item }) {
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color(hex: item.colorHex) ?? AppTheme.accentBlue)
                                    .frame(width: 10, height: 10)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.category)
                                        .font(.system(size: 12, weight: isSelected ? .bold : .medium))
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.85))
                                    Text(item.description)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.5))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(String(format: "%.1f%%", item.percentage))
                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white)
                                    Text(Formatters.formatVolume(item.tokenAmount))
                                        .font(.system(size: 10, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isSelected ? AppTheme.darkCard.opacity(0.9) : AppTheme.darkCard.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.6) : Color.clear, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

private extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

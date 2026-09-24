import SwiftUI

public struct EntityWhaleHoldingsCardView: View {
    public let entities: [EntityWhaleHolding]
    @State private var selectedCategory: EntityCategory? = nil
    
    public init(entities: [EntityWhaleHolding]) {
        self.entities = entities
    }
    
    private var filteredEntities: [EntityWhaleHolding] {
        guard let cat = selectedCategory else { return entities }
        return entities.filter { $0.category == cat }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header & Filter Pills
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(AppTheme.warningYellow)
                        .font(.system(size: 13))
                    Text("Danh Bạ Nắm Giữ Tổ Chức & Cá Voi (Arkham Entity Intel)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(entities.count) Thực thể theo dõi")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Category Filter Pills
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    Button {
                        selectedCategory = nil
                    } label: {
                        Text("Tất cả")
                            .font(.system(size: 10, weight: selectedCategory == nil ? .bold : .regular))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(selectedCategory == nil ? AppTheme.accentBlue : AppTheme.darkHeaderBg)
                            .foregroundColor(selectedCategory == nil ? .white : .white.opacity(0.7))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    
                    ForEach(EntityCategory.allCases, id: \.rawValue) { cat in
                        Button {
                            selectedCategory = cat
                        } label: {
                            Text(cat.rawValue)
                                .font(.system(size: 10, weight: selectedCategory == cat ? .bold : .regular))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(selectedCategory == cat ? cat.badgeColor.opacity(0.3) : AppTheme.darkHeaderBg)
                                .foregroundColor(selectedCategory == cat ? cat.badgeColor : .white.opacity(0.7))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            // Entities Table
            VStack(spacing: 6) {
                // Table Headers
                HStack {
                    Text("Thực Thể / Danh mục")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("Số Lượng & Giá Trị")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 140, alignment: .trailing)
                    
                    Text("Giá Vốn / Lãi Lỗ")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 130, alignment: .trailing)
                    
                    Text("Biến Động 30D")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.white.opacity(0.5))
                        .frame(width: 90, alignment: .trailing)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                
                Divider()
                    .background(AppTheme.darkBorder)
                
                ForEach(filteredEntities) { entity in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            // Entity Name & Category
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(entity.entityName)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(entity.category.rawValue)
                                        .font(.system(size: 8, weight: .semibold))
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(entity.category.badgeColor.opacity(0.15))
                                        .foregroundColor(entity.category.badgeColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                }
                                
                                Text(entity.addressSnippet)
                                    .font(.system(size: 9, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Holdings Amount & USD
                            VStack(alignment: .trailing, spacing: 1) {
                                Text(Formatters.formatVolume(entity.holdingsToken) + " Coin")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Text(Formatters.formatVolume(entity.holdingsUSD) + " USD")
                                    .font(.system(size: 9))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(width: 140, alignment: .trailing)
                            
                            // Cost Basis & PnL
                            VStack(alignment: .trailing, spacing: 1) {
                                if let cost = entity.avgPurchasePriceUSD {
                                    Text("Giá vốn: " + (cost > 0 ? Formatters.formatPrice(cost) : "$0 (Tịch thu)"))
                                        .font(.system(size: 9))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                                if let pnl = entity.unrealizedPnLUSD {
                                    Text((pnl >= 0 ? "+" : "") + Formatters.formatVolume(pnl) + " USD")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(pnl >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                }
                            }
                            .frame(width: 130, alignment: .trailing)
                            
                            // 30D Change
                            VStack(alignment: .trailing, spacing: 1) {
                                if entity.change30dToken != 0 {
                                    Text((entity.change30dToken > 0 ? "+" : "") + Formatters.formatVolume(entity.change30dToken))
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(entity.change30dToken > 0 ? AppTheme.upGreen : AppTheme.downRed)
                                } else {
                                    Text("Không đổi")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .frame(width: 90, alignment: .trailing)
                        }
                        
                        // Risk note / Signal
                        Text("💡 \(entity.riskSignal)")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.65))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.darkBackground.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    .padding(8)
                    .background(AppTheme.darkHeaderBg.opacity(0.3))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

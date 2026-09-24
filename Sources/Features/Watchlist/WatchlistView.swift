import SwiftUI

public struct WatchlistView: View {
    @Bindable var viewModel: WatchlistViewModel
    @Binding var selectedSymbol: String
    
    @State private var isShowingSearch: Bool = false
    @State private var itemToDelete: WatchlistItem? = nil
    @State private var showDeleteConfirmation: Bool = false
    
    public init(viewModel: WatchlistViewModel, selectedSymbol: Binding<String>) {
        self.viewModel = viewModel
        self._selectedSymbol = selectedSymbol
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Search & Filter Header
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                        TextField("Tìm coin (VD: BTC, ETH)...", text: $viewModel.searchText)
                            .textFieldStyle(.plain)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        if !viewModel.searchText.isEmpty {
                            Button(action: { viewModel.searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    Button(action: {
                        isShowingSearch = true
                        Task { await viewModel.fetchAvailableSymbols() }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .padding(7)
                            .background(AppTheme.accentBlue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    .buttonStyle(.plain)
                    .popover(isPresented: $isShowingSearch, arrowEdge: .bottom) {
                        SymbolSearchPopover(viewModel: viewModel, isPresented: $isShowingSearch)
                    }
                }
                
                // Filter Pills (Tất cả, Tiers, Trạng thái)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        FilterPill(
                            title: "Tất cả",
                            isSelected: viewModel.selectedTierFilter == nil && viewModel.selectedStatusFilter == nil
                        ) {
                            viewModel.selectedTierFilter = nil
                            viewModel.selectedStatusFilter = nil
                        }
                        
                        // Tiers
                        ForEach(CoinTier.allCases.filter { $0 != .unassigned }) { tier in
                            FilterPill(title: tier.rawValue, isSelected: viewModel.selectedTierFilter == tier) {
                                if viewModel.selectedTierFilter == tier {
                                    viewModel.selectedTierFilter = nil
                                } else {
                                    viewModel.selectedTierFilter = tier
                                    viewModel.selectedStatusFilter = nil
                                }
                            }
                        }
                        
                        // Statuses
                        ForEach(CoinStatus.allCases) { status in
                            FilterPill(
                                title: status.rawValue,
                                isSelected: viewModel.selectedStatusFilter == status
                            ) {
                                if viewModel.selectedStatusFilter == status {
                                    viewModel.selectedStatusFilter = nil
                                } else {
                                    viewModel.selectedStatusFilter = status
                                    viewModel.selectedTierFilter = nil
                                }
                            }
                        }
                    }
                }
            }
            .padding(10)
            .background(AppTheme.darkSidebarBg)
            
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1)
            
            // Watchlist Items List
            if viewModel.filteredItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "bookmark.slash")
                        .font(.system(size: 28))
                        .foregroundColor(.white.opacity(0.3))
                    Text(viewModel.items.isEmpty ? "Watchlist đang trống" : "Không tìm thấy coin phù hợp")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(viewModel.filteredItems) { item in
                        WatchlistRowView(
                            item: item,
                            isSelected: selectedSymbol == item.symbol,
                            onSelect: {
                                selectedSymbol = item.symbol
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .contextMenu {
                            Menu("Đổi Tier") {
                                ForEach(CoinTier.allCases) { tier in
                                    Button(tier.rawValue) {
                                        viewModel.updateItemTier(symbol: item.symbol, tier: tier)
                                    }
                                }
                            }
                            Menu("Đổi Trạng thái") {
                                ForEach(CoinStatus.allCases) { status in
                                    Button(status.rawValue) {
                                        viewModel.updateItemStatus(symbol: item.symbol, status: status)
                                    }
                                }
                            }
                            Divider()
                            Button(role: .destructive, action: {
                                itemToDelete = item
                                showDeleteConfirmation = true
                            }) {
                                Label("Xóa khỏi Watchlist", systemImage: "trash")
                            }
                        }
                    }
                    .onMove { indices, newOffset in
                        viewModel.moveItems(from: indices, to: newOffset)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(AppTheme.darkSidebarBg)
        .confirmationDialog(
            "Xác nhận xóa \(itemToDelete?.symbol ?? "") khỏi Watchlist?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Xóa", role: .destructive) {
                if let sym = itemToDelete?.symbol {
                    viewModel.removeItem(symbol: sym)
                }
                itemToDelete = nil
            }
            Button("Hủy", role: .cancel) {
                itemToDelete = nil
            }
        }
    }
}

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(isSelected ? AppTheme.accentBlue.opacity(0.3) : AppTheme.darkCard)
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? AppTheme.accentBlue : AppTheme.darkBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct WatchlistRowView: View {
    let item: WatchlistItem
    let isSelected: Bool
    let onSelect: () -> Void
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 8) {
                // Base symbol, Tier & Status badges
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(item.baseAsset)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("/USDT")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    HStack(spacing: 4) {
                        // Tier badge
                        Text(item.tier.rawValue)
                            .font(AppTheme.badgeFont)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(tierColor(for: item.tier).opacity(0.2))
                            .foregroundColor(tierColor(for: item.tier))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                        
                        // Status badge
                        Text(item.status.rawValue)
                            .font(AppTheme.badgeFont)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(statusColor(for: item.status).opacity(0.18))
                            .foregroundColor(statusColor(for: item.status))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                }
                
                Spacer(minLength: 8)
                
                // Price & 24h %
                VStack(alignment: .trailing, spacing: 3) {
                    if let price = item.lastPrice {
                        Text(Formatters.formatPrice(price))
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                    } else {
                        Text("--")
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    if let change = item.priceChange24h {
                        Text(Formatters.formatPercentage(change))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(change >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    } else {
                        Text("0.00%")
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected
                ? AppTheme.accentBlue.opacity(0.25)
                : (isHovered ? AppTheme.darkCard.opacity(0.7) : Color.white.opacity(0.001))
            )
            .contentShape(Rectangle())
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isSelected ? AppTheme.accentBlue.opacity(0.6) : (isHovered ? AppTheme.darkBorder : Color.clear), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private func tierColor(for tier: CoinTier) -> Color {
        switch tier {
        case .core: return AppTheme.purple
        case .narrative: return AppTheme.cyan
        case .moonshot: return AppTheme.orange
        case .unassigned: return .white.opacity(0.5)
        }
    }
    
    private func statusColor(for status: CoinStatus) -> Color {
        switch status {
        case .watching: return .white.opacity(0.6)
        case .buyZone: return AppTheme.upGreen
        case .holding: return AppTheme.accentBlue
        case .ignored: return AppTheme.downRed
        }
    }
}

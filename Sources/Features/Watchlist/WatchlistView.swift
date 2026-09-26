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
            // 1. Search Header Row (Aligned with global subHeaderHeight)
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
                                .padding(2)
                                .background(Color.white.opacity(0.001))
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
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
                        .padding(6)
                        .background(AppTheme.accentBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .contentShape(RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
                .help("Thêm coin vào Watchlist")
                .popover(isPresented: $isShowingSearch, arrowEdge: .bottom) {
                    SymbolSearchPopover(viewModel: viewModel, isPresented: $isShowingSearch)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: AppTheme.subHeaderHeight)
            .background(AppTheme.darkHeaderBg)
            .overlay(
                Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
                alignment: .bottom
            )
            
            // 2. Sector Filter Pills & Sort Selector Row
            HStack(spacing: 6) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        SectorFilterPill(
                            title: "Tất cả",
                            icon: "square.grid.2x2.fill",
                            color: AppTheme.accentBlue,
                            isSelected: viewModel.selectedSectorFilter == nil || viewModel.selectedSectorFilter == .all
                        ) {
                            viewModel.selectedSectorFilter = nil
                        }
                        
                        ForEach(CryptoSector.allCases.filter { $0 != .all }) { sector in
                            SectorFilterPill(
                                title: sector.rawValue,
                                icon: sector.iconName,
                                color: sector.color,
                                isSelected: viewModel.selectedSectorFilter == sector
                            ) {
                                if viewModel.selectedSectorFilter == sector {
                                    viewModel.selectedSectorFilter = nil
                                } else {
                                    viewModel.selectedSectorFilter = sector
                                }
                            }
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 4)
                }
                
                // Sort Mode Selector Menu (defaults to Manual)
                Menu {
                    Section("Chế độ sắp xếp") {
                        ForEach(WatchlistSortMode.allCases) { mode in
                            Button(action: { viewModel.sortMode = mode }) {
                                HStack {
                                    Text(mode.rawValue)
                                    if viewModel.sortMode == mode {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: viewModel.sortMode.iconName)
                            .font(.system(size: 10, weight: .bold))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 7, weight: .bold))
                    }
                    .foregroundColor(viewModel.sortMode == .manual ? AppTheme.cyan : AppTheme.accentBlue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4.5)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(viewModel.sortMode == .manual ? AppTheme.cyan.opacity(0.5) : AppTheme.darkBorder, lineWidth: 1)
                    )
                }
                .menuStyle(.borderlessButton)
                .help("Sắp xếp: \(viewModel.sortMode.rawValue) (Mặc định: Thủ công)")
                .padding(.trailing, 8)
            }
            .padding(.vertical, 5)
            .background(AppTheme.darkSidebarBg)
            .overlay(
                Rectangle().fill(AppTheme.darkBorder.opacity(0.6)).frame(height: 1),
                alignment: .bottom
            )
            
            // 3. Watchlist Items List
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
                            isManualSort: viewModel.sortMode == .manual,
                            onSelect: {
                                selectedSymbol = item.symbol
                            },
                            onMoveUp: {
                                viewModel.moveItem(symbol: item.symbol, offset: -1)
                            },
                            onMoveDown: {
                                viewModel.moveItem(symbol: item.symbol, offset: 1)
                            }
                        )
                        .listRowInsets(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .contextMenu {
                            Section("Sắp xếp thủ công") {
                                Button(action: { viewModel.moveItem(symbol: item.symbol, toTop: true) }) {
                                    Label("Đưa lên đầu danh sách", systemImage: "arrow.up.to.line")
                                }
                                Button(action: { viewModel.moveItem(symbol: item.symbol, offset: -1) }) {
                                    Label("Di chuyển lên trên", systemImage: "chevron.up")
                                }
                                Button(action: { viewModel.moveItem(symbol: item.symbol, offset: 1) }) {
                                    Label("Di chuyển xuống dưới", systemImage: "chevron.down")
                                }
                                Button(action: { viewModel.moveItem(symbol: item.symbol, toBottom: true) }) {
                                    Label("Đưa xuống cuối danh sách", systemImage: "arrow.down.to.line")
                                }
                            }
                            
                            Divider()
                            
                            Menu("Đổi Phân khúc (Sector)") {
                                ForEach(CryptoSector.allCases.filter { $0 != .all }) { sec in
                                    Button(action: {
                                        viewModel.updateItemSector(symbol: item.symbol, sector: sec)
                                    }) {
                                        HStack {
                                            Text(sec.rawValue)
                                            if item.sector == sec {
                                                Image(systemName: "checkmark")
                                            }
                                        }
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

private struct SectorFilterPill: View {
    let title: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 3.5) {
                Image(systemName: icon)
                    .font(.system(size: 8.5, weight: .bold))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .medium))
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 3.5)
            .background(isSelected ? color.opacity(0.22) : AppTheme.darkCard)
            .foregroundColor(isSelected ? color : .white.opacity(0.65))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? color : AppTheme.darkBorder, lineWidth: 1)
            )
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct WatchlistRowView: View {
    let item: WatchlistItem
    let isSelected: Bool
    let isManualSort: Bool
    let onSelect: () -> Void
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    @State private var isHovered: Bool = false
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 6) {
                // Manual Sort Handle / Nudge Arrows
                if isManualSort {
                    if isHovered {
                        VStack(spacing: 1) {
                            Button(action: onMoveUp) {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 7.5, weight: .bold))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .buttonStyle(.plain)
                            .help("Di chuyển lên trên")
                            
                            Button(action: onMoveDown) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 7.5, weight: .bold))
                                    .foregroundColor(.white.opacity(0.85))
                            }
                            .buttonStyle(.plain)
                            .help("Di chuyển xuống dưới")
                        }
                        .frame(width: 12)
                    } else {
                        Image(systemName: "line.3.horizontal")
                            .font(.system(size: 8.5))
                            .foregroundColor(.white.opacity(0.25))
                            .frame(width: 12)
                    }
                }
                
                // Base symbol & Sector badge
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 3) {
                        Text(item.baseAsset)
                            .font(.system(size: 12.5, weight: .bold))
                            .foregroundColor(.white)
                        Text("/USDT")
                            .font(.system(size: 9.5))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    // Sector badge (Layer 1, Layer 2, DeFi, AI...)
                    HStack(spacing: 3) {
                        Image(systemName: item.sector.iconName)
                            .font(.system(size: 7.5, weight: .bold))
                        Text(item.sector.rawValue)
                            .font(.system(size: 8.5, weight: .semibold))
                    }
                    .padding(.horizontal, 4.5)
                    .padding(.vertical, 1.5)
                    .background(item.sector.color.opacity(0.18))
                    .foregroundColor(item.sector.color)
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                
                Spacer(minLength: 6)
                
                // Price & 24h %
                VStack(alignment: .trailing, spacing: 2.5) {
                    if let price = item.lastPrice {
                        Text(Formatters.formatPrice(price))
                            .font(.system(size: 11.5, weight: .semibold, design: .monospaced))
                            .foregroundColor(.white)
                    } else {
                        Text("--")
                            .font(.system(size: 11.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    if let change = item.priceChange24h {
                        Text(Formatters.formatPercentage(change))
                            .font(.system(size: 9.5, weight: .bold, design: .monospaced))
                            .foregroundColor(change >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                    } else {
                        Text("0.00%")
                            .font(.system(size: 9.5, design: .monospaced))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
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
}

import SwiftUI

public struct SymbolSearchPopover: View {
    @Bindable var viewModel: WatchlistViewModel
    @Binding var isPresented: Bool
    
    @State private var query: String = ""
    @State private var selectedTier: CoinTier = .unassigned
    @State private var selectedStatus: CoinStatus = .watching
    
    public init(viewModel: WatchlistViewModel, isPresented: Binding<Bool>) {
        self.viewModel = viewModel
        self._isPresented = isPresented
    }
    
    public var body: some View {
        VStack(spacing: 10) {
            // Search Input
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white.opacity(0.5))
                TextField("Nhập mã coin (VD: SOL, ETH, PEPE)...", text: $query)
                    .textFieldStyle(.plain)
                    .font(.system(size: 13))
                    .foregroundColor(.white)
                    .onChange(of: query) { _, newQuery in
                        viewModel.updateSearchQuery(newQuery)
                    }
                if !query.isEmpty {
                    Button(action: {
                        query = ""
                        viewModel.updateSearchQuery("")
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(8)
            .background(AppTheme.darkCard)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            
            // Tier & Status Selectors for newly added item
            HStack(spacing: 8) {
                Picker("Tier:", selection: $selectedTier) {
                    ForEach(CoinTier.allCases) { tier in
                        Text(tier.rawValue).tag(tier)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 11))
                
                Picker("Trạng thái:", selection: $selectedStatus) {
                    ForEach(CoinStatus.allCases) { status in
                        Text(status.rawValue).tag(status)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(size: 11))
            }
            
            Divider()
                .background(AppTheme.darkBorder)
            
            // Search Results List
            if viewModel.searchResults.isEmpty {
                VStack(spacing: 8) {
                    Spacer()
                    Image(systemName: "sparkle.magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                    Text(query.isEmpty ? "Gõ ký tự để tìm kiếm cặp USDT" : "Không tìm thấy kết quả phù hợp")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                }
                .frame(height: 180)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(viewModel.searchResults) { info in
                            let isAlreadyAdded = viewModel.items.contains(where: { $0.symbol == info.symbol })
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(info.baseAsset)
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(info.symbol)
                                        .font(.system(size: 10))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                
                                Spacer()
                                
                                if isAlreadyAdded {
                                    Text("Đã thêm")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundColor(AppTheme.upGreen)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 3)
                                        .background(AppTheme.upGreen.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                } else {
                                    Button(action: {
                                        viewModel.addItem(
                                            symbol: info.symbol,
                                            baseAsset: info.baseAsset,
                                            tier: selectedTier,
                                            status: selectedStatus
                                        )
                                        isPresented = false
                                    }) {
                                        Text("+ Thêm")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(AppTheme.accentBlue)
                                            .clipShape(RoundedRectangle(cornerRadius: 4))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(AppTheme.darkCard.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .frame(height: 220)
            }
        }
        .padding(12)
        .frame(width: 320)
        .background(AppTheme.darkSidebarBg)
        .onDisappear {
            query = ""
            viewModel.updateSearchQuery("")
        }
    }
}

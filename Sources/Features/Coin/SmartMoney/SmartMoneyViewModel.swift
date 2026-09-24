import SwiftUI
import Observation

public enum DEXSwapFilter: String, CaseIterable, Identifiable {
    case all = "Tất cả lệnh Swap"
    case buys = "Lệnh Mua (Buys)"
    case sells = "Lệnh Bán (Sells)"
    
    public var id: String { rawValue }
}

@Observable
public final class SmartMoneyViewModel: @unchecked Sendable {
    public var symbol: String
    public var profile: SmartMoneyProfile? = nil
    public var selectedSwapFilter: DEXSwapFilter = .all
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let provider: SmartMoneyDataProvider
    private var loadTask: Task<Void, Never>?
    
    public init(symbol: String, provider: SmartMoneyDataProvider = .shared) {
        self.symbol = symbol
        self.provider = provider
    }
    
    public var filteredDEXSwaps: [SmartMoneyDEXSwap] {
        guard let p = profile else { return [] }
        switch selectedSwapFilter {
        case .all:
            return p.recentDEXSwaps
        case .buys:
            return p.recentDEXSwaps.filter { $0.type == .buy }
        case .sells:
            return p.recentDEXSwaps.filter { $0.type == .sell }
        }
    }
    
    public func setSymbol(_ newSymbol: String) {
        guard newSymbol != self.symbol else { return }
        self.symbol = newSymbol
        loadData()
    }
    
    public func loadData() {
        loadTask?.cancel()
        loadTask = Task { @MainActor in
            self.isLoading = true
            self.errorMessage = nil
            
            do {
                let fetched = try await provider.fetchSmartMoneyProfile(for: self.symbol)
                guard !Task.isCancelled else { return }
                self.profile = fetched
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải dữ liệu Smart Money: \(error.localizedDescription)"
            }
        }
    }
}

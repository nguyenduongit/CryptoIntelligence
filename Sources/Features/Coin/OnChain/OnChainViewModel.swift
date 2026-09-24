import SwiftUI
import Observation

public enum WhaleTxFilter: String, CaseIterable, Identifiable {
    case all = "Tất cả giao dịch"
    case inflows = "Nạp lên sàn (Bán)"
    case outflows = "Rút về ví (Gom)"
    case whales = "Chuyển giữa các ví"
    
    public var id: String { rawValue }
}

public enum OnChainSectionFilter: String, CaseIterable, Identifiable {
    case all = "Tất cả"
    case cycle = "Chu kỳ & MVRV"
    case etf = "Dòng tiền ETF"
    case supply = "Nguồn cung LTH/STH"
    case entities = "Danh bạ cá voi & Tổ chức"
    case exchangeFlows = "Dòng tiền sàn"
    
    public var id: String { rawValue }
}

@Observable
public final class OnChainViewModel: @unchecked Sendable {
    public var symbol: String
    public var profile: OnChainProfile? = nil
    public var selectedSection: OnChainSectionFilter = .all
    public var selectedTxFilter: WhaleTxFilter = .all
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let provider: OnChainDataProvider
    private var loadTask: Task<Void, Never>?
    
    public init(symbol: String, provider: OnChainDataProvider = .shared) {
        self.symbol = symbol
        self.provider = provider
    }
    
    public var filteredWhaleTransactions: [WhaleTransaction] {
        guard let p = profile else { return [] }
        switch selectedTxFilter {
        case .all:
            return p.recentWhaleTransactions
        case .inflows:
            return p.recentWhaleTransactions.filter { $0.type == .exchangeInflow }
        case .outflows:
            return p.recentWhaleTransactions.filter { $0.type == .exchangeOutflow }
        case .whales:
            return p.recentWhaleTransactions.filter { $0.type == .whaleToWhale || $0.type == .internalTransfer }
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
                let fetched = try await provider.fetchOnChainProfile(for: self.symbol)
                guard !Task.isCancelled else { return }
                self.profile = fetched
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải dữ liệu On-chain: \(error.localizedDescription)"
            }
        }
    }
}

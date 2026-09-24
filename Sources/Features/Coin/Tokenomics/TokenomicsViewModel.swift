import SwiftUI
import Observation

@Observable
public final class TokenomicsViewModel: @unchecked Sendable {
    public var symbol: String
    public var profile: TokenomicsProfile? = nil
    public var selectedAllocation: TokenAllocationItem? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let provider: TokenomicsDataProvider
    private var loadTask: Task<Void, Never>?
    
    public init(symbol: String, provider: TokenomicsDataProvider = .shared) {
        self.symbol = symbol
        self.provider = provider
    }
    
    public func setSymbol(_ newSymbol: String) {
        guard newSymbol != self.symbol else { return }
        self.symbol = newSymbol
        self.selectedAllocation = nil
        loadData()
    }
    
    public func loadData() {
        loadTask?.cancel()
        loadTask = Task { @MainActor in
            self.isLoading = true
            self.errorMessage = nil
            
            do {
                let fetched = try await provider.fetchTokenomics(for: self.symbol)
                guard !Task.isCancelled else { return }
                self.profile = fetched
                self.selectedAllocation = fetched.allocations.first
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải dữ liệu Tokenomics: \(error.localizedDescription)"
            }
        }
    }
}

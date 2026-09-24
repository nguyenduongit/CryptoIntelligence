import SwiftUI
import Observation

@Observable
public final class SecurityLegalViewModel: @unchecked Sendable {
    public var symbol: String
    public var profile: SecurityLegalProfile? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let provider: SecurityLegalDataProvider
    private var loadTask: Task<Void, Never>?
    
    public init(symbol: String, provider: SecurityLegalDataProvider = .shared) {
        self.symbol = symbol
        self.provider = provider
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
                let fetched = try await provider.fetchSecurityLegalProfile(for: self.symbol)
                guard !Task.isCancelled else { return }
                self.profile = fetched
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải hồ sơ bảo mật & pháp lý: \(error.localizedDescription)"
            }
        }
    }
}

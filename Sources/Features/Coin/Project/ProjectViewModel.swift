import SwiftUI
import Observation

@Observable
public final class ProjectViewModel: @unchecked Sendable {
    public var symbol: String
    public var profile: ProjectProfile? = nil
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let provider: ProjectDataProvider
    private var loadTask: Task<Void, Never>?
    
    public init(symbol: String, provider: ProjectDataProvider = .shared) {
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
                let fetched = try await provider.fetchProjectProfile(for: self.symbol)
                guard !Task.isCancelled else { return }
                self.profile = fetched
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải hồ sơ dự án: \(error.localizedDescription)"
            }
        }
    }
}

import SwiftUI
import Observation

@Observable
public final class ProfileViewModel: @unchecked Sendable {
    public var symbol: String
    public var projectProfile: ProjectProfile? = nil
    public var securityProfile: SecurityLegalProfile? = nil
    public var selectedSectionId: String = "teamVcs"
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let projectProvider: ProjectDataProvider
    private let securityProvider: SecurityLegalDataProvider
    private var loadTask: Task<Void, Never>?
    
    public init(
        symbol: String,
        projectProvider: ProjectDataProvider = .shared,
        securityProvider: SecurityLegalDataProvider = .shared
    ) {
        self.symbol = symbol
        self.projectProvider = projectProvider
        self.securityProvider = securityProvider
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
                let cleanSymbol = self.symbol.uppercased()
                async let pFetch = self.projectProvider.fetchProjectProfile(for: cleanSymbol)
                async let sFetch = self.securityProvider.fetchSecurityLegalProfile(for: cleanSymbol)
                
                let (pData, sData) = try await (pFetch, sFetch)
                
                guard !Task.isCancelled else { return }
                self.projectProfile = pData
                self.securityProfile = sData
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải hồ sơ dự án & bảo mật: \(error.localizedDescription)"
            }
        }
    }
}

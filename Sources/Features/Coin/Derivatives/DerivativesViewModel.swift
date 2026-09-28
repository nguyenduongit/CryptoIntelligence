import SwiftUI
import Observation

public enum DerivativesSectionFilter: String, CaseIterable, Identifiable {
    case all = "Tất cả"
    case heatmap = "Bản đồ thanh lý"
    case funding = "Funding Rate & Chênh lệch"
    case openInterest = "Open Interest & Tỷ lệ L/S"
    case orderbook = "Tường sổ lệnh"
    
    public var id: String { rawValue }
}

@Observable
public final class DerivativesViewModel: @unchecked Sendable {
    public var symbol: String
    public var profile: DerivativesProfile? = nil
    public var deribitOptionsProfile: DeribitOptionsSurfaceProfile? = nil
    public var selectedSection: DerivativesSectionFilter = .all
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let provider: DerivativesDataProvider
    private let deribitProvider: DeribitOptionsProvider
    private var loadTask: Task<Void, Never>?
    
    public init(
        symbol: String,
        provider: DerivativesDataProvider = .shared,
        deribitProvider: DeribitOptionsProvider = .shared
    ) {
        self.symbol = symbol
        self.provider = provider
        self.deribitProvider = deribitProvider
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
                async let derivFetch = self.provider.fetchDerivativesProfile(for: self.symbol)
                async let deribitFetch = self.deribitProvider.fetchOptionsProfile(for: self.symbol)
                
                let (fetched, deribitData) = try await (derivFetch, deribitFetch)
                guard !Task.isCancelled else { return }
                self.profile = fetched
                self.deribitOptionsProfile = deribitData
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải dữ liệu phái sinh: \(error.localizedDescription)"
            }
        }
    }
}

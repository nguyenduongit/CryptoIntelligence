import SwiftUI
import Observation

@Observable
public final class LiquidityViewModel: @unchecked Sendable {
    public var symbol: String
    public var onchainProfile: OnChainProfile? = nil
    public var liquidityProfile: LiquidityOverviewProfile? = nil
    public var selectedSectionId: String = "cexDex"
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    private let onchainProvider: OnChainDataProvider
    private let dexProvider: DexScreenerProvider
    private let candleProvider: BinanceCandleProvider
    private var loadTask: Task<Void, Never>?
    
    public init(
        symbol: String,
        onchainProvider: OnChainDataProvider = .shared,
        dexProvider: DexScreenerProvider = .shared,
        candleProvider: BinanceCandleProvider = .shared
    ) {
        self.symbol = symbol
        self.onchainProvider = onchainProvider
        self.dexProvider = dexProvider
        self.candleProvider = candleProvider
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
                let ticker = try? await self.candleProvider.fetch24hrTicker(symbol: cleanSymbol)
                let price = ticker?.price ?? 1.0
                let vol24h = ticker?.volume ?? 10_000_000.0
                
                async let onchainFetch = self.onchainProvider.fetchOnChainProfile(for: cleanSymbol)
                async let liqFetch = self.dexProvider.fetchLiquidityOverview(for: cleanSymbol, currentPrice: price, cexVolume24hUSD: vol24h)
                
                let (onchainData, liqData) = try await (onchainFetch, liqFetch)
                
                guard !Task.isCancelled else { return }
                self.onchainProfile = onchainData
                self.liquidityProfile = liqData
                self.isLoading = false
            } catch {
                guard !Task.isCancelled else { return }
                self.isLoading = false
                self.errorMessage = "Không thể tải dữ liệu Thanh khoản: \(error.localizedDescription)"
            }
        }
    }
}

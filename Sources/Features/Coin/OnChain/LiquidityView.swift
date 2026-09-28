import SwiftUI

public struct LiquidityView: View {
    public let symbol: String
    @State private var viewModel: LiquidityViewModel
    
    private let sections: [SubtabSectionItem] = [
        SubtabSectionItem(id: "cexDex", title: "Tỷ Trọng CEX vs DEX", iconName: "arrow.left.arrow.right.circle.fill"),
        SubtabSectionItem(id: "orderbookTWAP", title: "Sổ Lệnh L2 & TWAP (Cá Voi)", iconName: "square.stack.3d.down.right.fill"),
        SubtabSectionItem(id: "dexPools", title: "Pool AMM DEX", iconName: "drop.fill"),
        SubtabSectionItem(id: "slippage", title: "Độ Sâu & Trượt Giá", iconName: "gauge.with.dots.needle.bottom.50percent"),
        SubtabSectionItem(id: "exchangeFlows", title: "Dòng Tiền Nạp/Rút Sàn", iconName: "tray.and.arrow.down.fill")
    ]
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: LiquidityViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.liquidityProfile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang quét dữ liệu Thanh khoản & Pool AMM cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let liq = viewModel.liquidityProfile {
                    // Sub-navigation Section Selector
                    SubtabSectionSelector(items: sections, selectedId: $viewModel.selectedSectionId)
                    
                    // Dynamic Module Rendering
                    switch viewModel.selectedSectionId {
                    case "cexDex":
                        // 1. CEX vs DEX Volume Split Card
                        CexVsDexVolumeCardView(
                            cexVolumeUSD: liq.cexVolume24hUSD,
                            dexVolumeUSD: liq.dexVolume24hUSD,
                            dexToCexRatio: liq.dexToCexVolumeRatio
                        )
                        
                        // 2. Multi-Exchange Depth if available
                        if let book = viewModel.aggregatedOrderbook {
                            MultiExchangeDepthCardView(orderbook: book)
                        }
                        
                        // 3. DEX Pools Summary
                        DEXLiquidityPoolsCardView(
                            pools: liq.topPools,
                            totalDEXLiquidityUSD: liq.totalLiquidityDEXUSD
                        )
                        
                    case "orderbookTWAP":
                        if let book = viewModel.aggregatedOrderbook {
                            MultiExchangeDepthCardView(orderbook: book)
                            MarketImpactTWAPSimulatorView(orderbook: book)
                        } else {
                            VStack(spacing: 8) {
                                ProgressView()
                                Text("Đang tổng hợp sổ lệnh L2 từ Binance, OKX, Bybit...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                            .background(AppTheme.darkCard)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                    case "dexPools":
                        // 1. Dedicated DEX Liquidity Pools Table
                        DEXLiquidityPoolsCardView(
                            pools: liq.topPools,
                            totalDEXLiquidityUSD: liq.totalLiquidityDEXUSD
                        )
                        
                        // 2. Slippage overview for context
                        SlippageCalculatorView(
                            slippage10k: liq.estimatedSlippage10k,
                            slippage50k: liq.estimatedSlippage50k,
                            slippage100k: liq.estimatedSlippage100k,
                            totalLiquidityUSD: liq.totalLiquidityDEXUSD
                        )
                        
                    case "slippage":
                        // 1. Whale Market Impact & TWAP Simulator if available
                        if let book = viewModel.aggregatedOrderbook {
                            MarketImpactTWAPSimulatorView(orderbook: book)
                        }
                        
                        // 2. AMM Constant Product Slippage & Price Impact Simulator
                        SlippageCalculatorView(
                            slippage10k: liq.estimatedSlippage10k,
                            slippage50k: liq.estimatedSlippage50k,
                            slippage100k: liq.estimatedSlippage100k,
                            totalLiquidityUSD: liq.totalLiquidityDEXUSD
                        )
                        
                        // 2. CEX vs DEX Volume Reference
                        CexVsDexVolumeCardView(
                            cexVolumeUSD: liq.cexVolume24hUSD,
                            dexVolumeUSD: liq.dexVolume24hUSD,
                            dexToCexRatio: liq.dexToCexVolumeRatio
                        )
                        
                    case "exchangeFlows":
                        if let onchain = viewModel.onchainProfile {
                            // Exchange Inflow/Outflow Cards
                            HStack(alignment: .top, spacing: 14) {
                                ExchangeFlowCardView(metrics: onchain.exchangeFlow)
                                    .frame(maxWidth: .infinity)
                                
                                NetworkActivityCardView(metrics: onchain.networkActivity)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            // Whale Transactions
                            WhaleTransactionsTableView(
                                transactions: onchain.recentWhaleTransactions,
                                selectedFilter: .constant(.all)
                            )
                        } else {
                            Text("Đang kết nối dữ liệu dòng tiền sàn...")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                    default:
                        EmptyView()
                    }
                } else if let err = viewModel.errorMessage {
                    DataUnavailableView(
                        title: "Thanh Khoản & AMM Pools",
                        symbol: symbol,
                        iconName: "drop.fill",
                        message: err,
                        onRetry: { viewModel.loadData() }
                    )
                } else {
                    DataUnavailableView(
                        title: "Thanh Khoản & AMM Pools",
                        symbol: symbol,
                        iconName: "drop.fill",
                        onRetry: { viewModel.loadData() }
                    )
                }
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: symbol) { _, newSym in
            viewModel.setSymbol(newSym)
        }
    }
}

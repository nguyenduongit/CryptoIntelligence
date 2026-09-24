import SwiftUI

public struct TokenomicsView: View {
    public let symbol: String
    @State private var viewModel: TokenomicsViewModel
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: TokenomicsViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tải dữ liệu Tokenomics cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Header Status Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Tokenomics, Phân Bổ & Lịch Mở Khóa Vesting (\(symbol))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Mô hình cung tiền, lịch vesting và phân tích lạm phát / đốt token.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .liveBinance, text: "FDV Theo Giá Live")
                        DataSourceBadge(type: .simulatedCatalog, text: "Hồ Sơ Tokenomics & Vesting")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // 1. Supply & Valuation Summary Cards
                    SupplyValuationCardsView(
                        metrics: profile.supplyMetrics,
                        tokenStandard: profile.tokenStandard,
                        useCases: profile.primaryUseCases
                    )
                    
                    // 2. Token Allocation Breakdown (Donut + Legend)
                    TokenAllocationDonutView(
                        allocations: profile.allocations,
                        selectedAllocation: $viewModel.selectedAllocation
                    )
                    
                    // 3. 5-Year Vesting Emission Curve
                    if !profile.vestingSchedule.isEmpty {
                        VestingEmissionCurveView(schedule: profile.vestingSchedule)
                    }
                    
                    // 4. Token Utility & Deflationary Matrix
                    TokenUtilityMatrixCardView(utility: profile.utilityInfo)
                    
                    // 5. Upcoming Unlocks Timeline & Cliff Details
                    UpcomingUnlocksTimelineView(
                        unlocks: profile.upcomingUnlocks,
                        vestingNotes: profile.vestingNotes
                    )
                } else if let err = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.warningYellow)
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        Button("Thử lại") {
                            viewModel.loadData()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .frame(maxWidth: .infinity, minHeight: 250)
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

import SwiftUI

public struct TimeframePickerView: View {
    @Bindable var viewModel: ChartViewModel
    var watchlistVM: WatchlistViewModel? = nil
    @State private var isShowingIndicatorModal: Bool = false
    
    public init(viewModel: ChartViewModel, watchlistVM: WatchlistViewModel? = nil) {
        self.viewModel = viewModel
        self.watchlistVM = watchlistVM
    }
    
    public var body: some View {
        HStack(spacing: 6) {
            // Timeframe Selector Buttons
            ForEach(Timeframe.allCases) { tf in
                Button(action: { viewModel.setTimeframe(tf) }) {
                    Text(tf.displayName)
                        .font(.system(size: 11, weight: viewModel.timeframe == tf ? .bold : .medium))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            viewModel.timeframe == tf
                            ? AppTheme.accentBlue
                            : AppTheme.darkCard
                        )
                        .foregroundColor(
                            viewModel.timeframe == tf
                            ? .white
                            : .white.opacity(0.7)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
                .help("Khung thời gian \(tf.displayName) (Phím tắt: \(tf.shortcutNumber))")
            }
            
            Divider()
                .frame(height: 16)
                .background(AppTheme.darkBorder)
            
            // Log Scale Toggle Button
            Button(action: {
                viewModel.indicatorConfig.isLogScale.toggle()
                viewModel.updatePriceRange()
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "function")
                        .font(.system(size: 10))
                    Text(viewModel.indicatorConfig.isLogScale ? "Log: Bật" : "Log: Tắt")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    viewModel.indicatorConfig.isLogScale
                    ? AppTheme.purple.opacity(0.3)
                    : AppTheme.darkCard
                )
                .foregroundColor(
                    viewModel.indicatorConfig.isLogScale
                    ? AppTheme.purple
                    : .white.opacity(0.7)
                )
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(
                            viewModel.indicatorConfig.isLogScale ? AppTheme.purple.opacity(0.6) : Color.clear,
                            lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .help("Bật/Tắt thang Logarithmic (Phím tắt: L)")
            
            // Indicator Settings Button
            Button(action: { isShowingIndicatorModal = true }) {
                HStack(spacing: 4) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 10))
                    Text("Chỉ báo")
                        .font(.system(size: 11, weight: .medium))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppTheme.darkCard)
                .foregroundColor(.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
            .popover(isPresented: $isShowingIndicatorModal, arrowEdge: .bottom) {
                IndicatorSettingsModal(viewModel: viewModel, isPresented: $isShowingIndicatorModal)
            }
            
            Spacer()
            
            // Auto Fit reset button
            if viewModel.manualPriceRange != nil {
                Button(action: { viewModel.resetPriceAutoFit() }) {
                    Text("Reset Auto-Fit")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppTheme.warningYellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(AppTheme.warningYellow.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                .buttonStyle(.plain)
            }
            
            // Watchlist Star Toggle Button (Gold/Filled if in Watchlist, Grey/Outline if not)
            if let watchlistVM {
                let isInWatchlist = watchlistVM.isInWatchlist(symbol: viewModel.symbol)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        watchlistVM.toggleWatchlist(symbol: viewModel.symbol)
                    }
                }) {
                    HStack(spacing: 5) {
                        Image(systemName: isInWatchlist ? "star.fill" : "star")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(
                                isInWatchlist
                                ? Color(red: 1.0, green: 0.8, blue: 0.15)
                                : Color.white.opacity(0.4)
                            )
                        
                        Text(isInWatchlist ? "Đã theo dõi" : "Theo dõi")
                            .font(.system(size: 11, weight: isInWatchlist ? .semibold : .medium))
                            .foregroundColor(
                                isInWatchlist
                                ? Color(red: 1.0, green: 0.85, blue: 0.3)
                                : Color.white.opacity(0.6)
                            )
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        isInWatchlist
                        ? Color(red: 1.0, green: 0.8, blue: 0.15).opacity(0.15)
                        : AppTheme.darkCard
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                isInWatchlist
                                ? Color(red: 1.0, green: 0.8, blue: 0.15).opacity(0.4)
                                : Color.white.opacity(0.08),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
                .help(isInWatchlist ? "Xóa \(viewModel.symbol) khỏi Watchlist" : "Thêm \(viewModel.symbol) vào Watchlist")
            }
            
            // Loading Spinner
            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
                    .padding(.trailing, 4)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle()
                .fill(AppTheme.darkBorder)
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

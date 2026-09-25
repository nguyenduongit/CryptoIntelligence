import SwiftUI

/// Observed Spot executions only. Rows are never presented as whole-market demand.
public struct OrderFlowFootprintView: View {
    public let symbol: String
    @State private var snapshot: FootprintSnapshot?
    @State private var selectedVenues: Set<FlowVenue> = Set(FlowVenue.allCases)
    @State private var candleMinutes = 60
    @State private var candleOffset = 0
    @State private var errorMessage: String?

    public init(symbol: String) { self.symbol = symbol }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Footprint · giao dịch đã khớp")
                        .font(.system(size: 15, weight: .bold))
                    Text("Chỉ Spot USDT trên các sàn được chọn · Mua/bán theo phía taker · Ô giá cố định ≈0,05%")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Picker("Nến", selection: $candleMinutes) {
                    Text("15 phút").tag(15)
                    Text("1 giờ").tag(60)
                    Text("4 giờ").tag(240)
                    Text("1 ngày").tag(1_440)
                }
                .frame(width: 145)
            }

            HStack(spacing: 10) {
                Button("← Nến trước") { candleOffset += 1 }
                Button("Nến sau →") { candleOffset = max(0, candleOffset - 1) }
                    .disabled(candleOffset == 0)
                Button("Hiện tại") { candleOffset = 0 }
                    .disabled(candleOffset == 0)
                Text(candleOffset == 0 ? "Nến đang hình thành" : "Nến đã đóng")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            HStack(spacing: 12) {
                ForEach(FlowVenue.allCases) { venue in
                    Toggle(venue.rawValue, isOn: Binding(
                        get: { selectedVenues.contains(venue) },
                        set: { enabled in
                            if enabled { selectedVenues.insert(venue) }
                            else { selectedVenues.remove(venue) }
                        }
                    ))
                    .toggleStyle(.checkbox)
                }
                Spacer()
            }

            if let errorMessage {
                Text(errorMessage).foregroundStyle(AppTheme.warningYellow)
            }
            if selectedVenues.isEmpty {
                Text("Chọn ít nhất một sàn để xem giao dịch.")
                    .foregroundStyle(AppTheme.warningYellow)
            }

            if let snapshot {
                Text("Từ \(Date(timeIntervalSince1970: Double(snapshot.startMs) / 1000).formatted(date: .abbreviated, time: .shortened)) đến \(Date(timeIntervalSince1970: Double(snapshot.endMs) / 1000).formatted(date: .omitted, time: .shortened))")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    ForEach(snapshot.coverage, id: \.venue) { item in
                        let percent = Int(item.fraction * 100)
                        Text("\(item.venue.rawValue): \(percent)% thời gian kết nối · \(item.hasOpenSession ? "đang kết nối" : "đã ngắt")")
                            .foregroundStyle(item.fraction >= 0.98 ? AppTheme.upGreen : AppTheme.warningYellow)
                    }
                }
                .font(.system(size: 11, weight: .medium))

                if snapshot.coverage.contains(where: { $0.fraction < 0.98 }) {
                    Text("Dữ liệu trong khoảng chọn chưa đầy đủ. Các khoảng không thu được không được tính là 0; tổng bên dưới chỉ là giao dịch đã quan sát.")
                        .font(.system(size: 11))
                        .foregroundStyle(AppTheme.warningYellow)
                }

                HStack {
                    Text("Giá xấp xỉ").frame(width: 130, alignment: .leading)
                    Text("Mua chủ động").frame(maxWidth: .infinity, alignment: .trailing)
                    Text("Bán chủ động").frame(maxWidth: .infinity, alignment: .trailing)
                    Text("Delta (coin)").frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.secondary)
                Divider()
                if snapshot.levels.isEmpty {
                    ContentUnavailableView("Chưa có giao dịch đã lưu", systemImage: "chart.bar.xaxis",
                                           description: Text("Bộ thu bắt đầu khi ứng dụng chạy. Chọn cặp có giao dịch Spot USDT và chờ dữ liệu mới."))
                } else {
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(snapshot.levels) { level in
                                HStack {
                                    Text(Formatters.formatPrice(level.price))
                                        .frame(width: 130, alignment: .leading)
                                    Text(String(format: "%.4f", level.buyQuantity))
                                        .foregroundStyle(AppTheme.upGreen)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(String(format: "%.4f", level.sellQuantity))
                                        .foregroundStyle(AppTheme.downRed)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Text(String(format: "%+.4f", level.delta))
                                        .foregroundStyle(level.delta >= 0 ? AppTheme.upGreen : AppTheme.downRed)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                }
                                .font(.system(size: 11, design: .monospaced))
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(level.delta >= 0 ? AppTheme.upGreen.opacity(0.05) : AppTheme.downRed.opacity(0.05))
                            }
                        }
                    }
                }
            } else {
                ProgressView("Đang đọc dữ liệu giao dịch...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .padding(14)
        .background(AppTheme.darkBackground)
        .task(id: "\(symbol)|\(candleMinutes)|\(candleOffset)|\(selectedVenues.map(\.rawValue).sorted().joined())") {
            while !Task.isCancelled {
                let now = Int64(Date().timeIntervalSince1970 * 1000)
                let step = Int64(candleMinutes) * 60_000
                let start = now / step * step - Int64(candleOffset) * step
                let end = min(now, start + step)
                let venues = FlowVenue.allCases.filter { selectedVenues.contains($0) }
                let requestedSymbol = symbol
                do {
                    let result = try await Task.detached(priority: .utility) {
                        try OrderFlowStore.shared.snapshot(symbol: requestedSymbol, since: start,
                                                           until: end, venues: venues)
                    }.value
                    guard !Task.isCancelled else { return }
                    snapshot = result
                    errorMessage = nil
                } catch {
                    errorMessage = "Không thể đọc footprint: \(error.localizedDescription)"
                }
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }
}

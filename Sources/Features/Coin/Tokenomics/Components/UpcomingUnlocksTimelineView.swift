import SwiftUI

public struct UpcomingUnlocksTimelineView: View {
    public let unlocks: [TokenUnlockEvent]
    public let vestingNotes: String
    
    public init(unlocks: [TokenUnlockEvent], vestingNotes: String) {
        self.unlocks = unlocks
        self.vestingNotes = vestingNotes
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Lịch Mở Khóa Token Sắp Tới (Upcoming Unlocks)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
                if !unlocks.isEmpty {
                    Text("\(unlocks.count) đợt sắp diễn ra")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(AppTheme.warningYellow)
                }
            }
            
            if unlocks.isEmpty {
                // 100% unlocked banner
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.upGreen)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Toàn Bộ Token Đã Được Phát Hành / Không Có Áp Lực Mở Khóa")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("Dự án không có các đợt mở khóa lớn (Cliff) từ đội ngũ sáng lập hoặc quỹ đầu tư trong thời gian tới.")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.upGreen.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.upGreen.opacity(0.3), lineWidth: 1)
                )
            } else {
                // List of Unlock Events
                VStack(spacing: 8) {
                    ForEach(unlocks) { event in
                        UnlockEventCardView(event: event)
                    }
                }
            }
            
            // Vesting Analysis Notes
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(AppTheme.cyan)
                        .font(.system(size: 12))
                    Text("Đánh Giá Lộ Trình Vesting & Rủi Ro Pha Loãng:")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.cyan)
                }
                
                Text(vestingNotes)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.75))
                    .lineSpacing(3)
            }
            .padding(12)
            .background(AppTheme.darkHeaderBg.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
}

private struct UnlockEventCardView: View {
    let event: TokenUnlockEvent
    
    var body: some View {
        HStack(spacing: 12) {
            // Calendar Date Badge
            VStack(spacing: 2) {
                Text(formatDateDay(event.unlockDate))
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                Text(formatDateMonth(event.unlockDate))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(width: 44, height: 44)
            .background(AppTheme.darkHeaderBg)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
            
            // Unlock Details
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(event.category)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(event.unlockType.rawValue)
                        .font(.system(size: 9))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
                
                Text(relativeTimeDescription(event.unlockDate))
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.warningYellow)
            }
            
            Spacer()
            
            // Amount & USD Value
            VStack(alignment: .trailing, spacing: 2) {
                Text("+" + Formatters.formatVolume(event.tokenAmount) + " tokens")
                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
                
                Text("≈ " + Formatters.formatVolume(event.valueUSD) + " USD (" + String(format: "%.2f%% cung", event.percentOfCirculating) + ")")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Risk Badge
            HStack(spacing: 4) {
                Circle()
                    .fill(event.riskLevel.color)
                    .frame(width: 6, height: 6)
                Text(event.riskLevel.rawValue)
                    .font(.system(size: 10, weight: .semibold))
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(event.riskLevel.color.opacity(0.15))
            .foregroundColor(event.riskLevel.color)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .padding(10)
        .background(AppTheme.darkHeaderBg.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.5), lineWidth: 1))
    }
    
    private func formatDateDay(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd"
        return df.string(from: d)
    }
    
    private func formatDateMonth(_ d: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "MMM yyyy"
        return df.string(from: d)
    }
    
    private func relativeTimeDescription(_ d: Date) -> String {
        let diffSecs = d.timeIntervalSince(Date())
        let days = Int(round(diffSecs / 86400.0))
        if days <= 0 {
            return "Đang mở khóa"
        } else if days == 1 {
            return "Diễn ra vào ngày mai"
        } else {
            return "Diễn ra sau \(days) ngày"
        }
    }
}

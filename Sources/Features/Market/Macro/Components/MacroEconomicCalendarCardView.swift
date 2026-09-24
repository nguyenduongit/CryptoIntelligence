import SwiftUI

public struct MacroEconomicCalendarCardView: View {
    public let events: [EconomicEventItem]
    
    public init(events: [EconomicEventItem]) {
        self.events = events
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.warningYellow)
                    Text("Lịch Sự Kiện Kinh Tế Vĩ Mô (30 Ngày Tới)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Text("\(events.count) Sự kiện quan trọng")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            // Events List
            VStack(spacing: 8) {
                ForEach(events) { ev in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(alignment: .top) {
                            // Date & Time Column
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ev.dateString)
                                    .font(.system(size: 12, weight: .bold, design: .monospaced))
                                    .foregroundColor(.white)
                                Text(ev.timeString)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(width: 95, alignment: .leading)
                            
                            // Event Title & Country
                            VStack(alignment: .leading, spacing: 2) {
                                HStack(spacing: 6) {
                                    Text(ev.title)
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text(ev.country)
                                        .font(.system(size: 10))
                                        .foregroundColor(AppTheme.accentBlue)
                                        .padding(.horizontal, 5)
                                        .padding(.vertical, 1)
                                        .background(AppTheme.accentBlue.opacity(0.15))
                                        .clipShape(RoundedRectangle(cornerRadius: 3))
                                }
                                
                                HStack(spacing: 12) {
                                    if let fc = ev.forecast {
                                        Text("Dự báo: \(fc)")
                                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    if let prev = ev.previous {
                                        Text("Kỳ trước: \(prev)")
                                            .font(.system(size: 10, design: .monospaced))
                                            .foregroundColor(.white.opacity(0.45))
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            // Impact Badge
                            VStack(alignment: .trailing, spacing: 3) {
                                Text(ev.impactLevel.rawValue)
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(ev.impactLevel.badgeColor)
                                
                                Text(ev.cryptoImpact.rawValue)
                                    .font(.system(size: 10, weight: .semibold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(ev.cryptoImpact.badgeColor.opacity(0.18))
                                    .foregroundColor(ev.cryptoImpact.badgeColor)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        
                        // Analysis Note
                        Text(ev.analysis)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.65))
                            .padding(8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(AppTheme.darkBackground.opacity(0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .padding(10)
                    .background(AppTheme.darkBackground.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder.opacity(0.6), lineWidth: 1)
                    )
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

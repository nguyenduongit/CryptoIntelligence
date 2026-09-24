import Foundation

public enum Timeframe: String, CaseIterable, Identifiable, Sendable, Codable {
    case m1 = "1m"
    case m5 = "5m"
    case m15 = "15m"
    case h1 = "1h"
    case h4 = "4h"
    case d1 = "1d"
    case w1 = "1w"
    case mo1 = "1M"

    public var id: String { rawValue }
    
    public var intervalString: String { rawValue }

    public var displayName: String {
        switch self {
        case .m1: return "1m"
        case .m5: return "5m"
        case .m15: return "15m"
        case .h1: return "1h"
        case .h4: return "4h"
        case .d1: return "1D"
        case .w1: return "1W"
        case .mo1: return "1M"
        }
    }

    public var stepMs: Int64 {
        switch self {
        case .m1: return 60 * 1000
        case .m5: return 5 * 60 * 1000
        case .m15: return 15 * 60 * 1000
        case .h1: return 60 * 60 * 1000
        case .h4: return 4 * 60 * 60 * 1000
        case .d1: return 24 * 60 * 60 * 1000
        case .w1: return 7 * 24 * 60 * 60 * 1000
        case .mo1: return 30 * 24 * 60 * 60 * 1000
        }
    }
    
    public var shortcutNumber: Int {
        switch self {
        case .m1: return 1
        case .m5: return 2
        case .m15: return 3
        case .h1: return 4
        case .h4: return 5
        case .d1: return 6
        case .w1: return 7
        case .mo1: return 8
        }
    }
}

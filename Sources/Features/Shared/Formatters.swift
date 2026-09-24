import Foundation

public enum Formatters {
    private static let localDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd HH:mm"
        return df
    }()
    
    private static let localDateOnlyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
    
    private static let localMonthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "yyyy-MM"
        return df
    }()
    
    private static let timeOnlyFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "HH:mm:ss"
        return df
    }()

    public static func formatPrice(_ price: Double) -> String {
        if price.isNaN || price.isInfinite { return "-" }
        let absVal = abs(price)
        let formatted: String
        if absVal >= 1000 {
            formatted = String(format: "%.2f", absVal)
        } else if absVal >= 1 {
            formatted = String(format: "%.4f", absVal)
        } else if absVal >= 0.0001 {
            formatted = String(format: "%.6f", absVal)
        } else {
            // For sub-cent meme tokens
            formatted = String(format: "%.8f", absVal)
        }
        return price < 0 ? "-\(formatted)" : formatted
    }
    
    public static func formatSignedPnL(_ pnl: Double) -> String {
        if pnl.isNaN || pnl.isInfinite { return "$0.00" }
        let absFormatted = formatPrice(abs(pnl))
        if pnl > 0 {
            return "+$\(absFormatted)"
        } else if pnl < 0 {
            return "-$\(absFormatted)"
        } else {
            return "$0.00"
        }
    }
    
    public static func formatPriceDecimal(_ price: Decimal) -> String {
        let doubleVal = NSDecimalNumber(decimal: price).doubleValue
        return formatPrice(doubleVal)
    }

    public static func formatPercentage(_ change: Double) -> String {
        if change.isNaN || change.isInfinite { return "0.00%" }
        let prefix = change > 0 ? "+" : ""
        return String(format: "%@%.2f%%", prefix, change)
    }

    public static func formatVolume(_ volume: Double) -> String {
        if volume.isNaN || volume.isInfinite { return "0" }
        if volume >= 1_000_000_000 {
            return String(format: "%.2fB", volume / 1_000_000_000)
        } else if volume >= 1_000_000 {
            return String(format: "%.2fM", volume / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.2fK", volume / 1_000)
        } else {
            return String(format: "%.2f", volume)
        }
    }
    
    public static func formatNumber(_ num: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        return formatter.string(from: NSNumber(value: num)) ?? "\(num)"
    }
    
    public static func formatDateTime(ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        return localDateTimeFormatter.string(from: date)
    }
    
    public static func formatDateTime(date: Date) -> String {
        return localDateTimeFormatter.string(from: date)
    }
    
    public static func formatCandleTime(ms: Int64, timeframe: Timeframe) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        switch timeframe {
        case .m1, .m5, .m15, .h1, .h4:
            return localDateTimeFormatter.string(from: date)
        case .d1, .w1:
            return localDateOnlyFormatter.string(from: date)
        case .mo1:
            return localMonthFormatter.string(from: date)
        }
    }
    
    public static func formatTime(ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: Double(ms) / 1000.0)
        return timeOnlyFormatter.string(from: date)
    }
    
    public static func formatTime(date: Date) -> String {
        return timeOnlyFormatter.string(from: date)
    }
}

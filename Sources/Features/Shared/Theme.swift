import SwiftUI

public enum AppTheme {
    // MARK: - Dark Palette (Default)
    public static let darkBackground = Color(red: 15/255, green: 17/255, blue: 23/255) // #0F1117
    public static let darkSidebarBg = Color(red: 20/255, green: 23/255, blue: 31/255) // #14171F
    public static let darkHeaderBg = Color(red: 17/255, green: 20/255, blue: 28/255)  // #11141C
    public static let darkSurface = Color(red: 26/255, green: 29/255, blue: 38/255)   // #1A1D26
    public static let darkCard = Color(red: 34/255, green: 38/255, blue: 52/255)      // #222634
    public static let darkBorder = Color(red: 46/255, green: 51/255, blue: 70/255)    // #2E3346
    
    // MARK: - Trading Accent Colors
    public static let upGreen = Color(red: 0/255, green: 192/255, blue: 135/255)     // #00C087
    public static let downRed = Color(red: 255/255, green: 59/255, blue: 48/255)     // #FF3B30
    public static let accentBlue = Color(red: 59/255, green: 130/255, blue: 246/255)  // #3B82F6
    public static let warningYellow = Color(red: 245/255, green: 158/255, blue: 11/255) // #F59E0B
    public static let purple = Color(red: 139/255, green: 92/255, blue: 246/255)     // #8B5CF6
    public static let cyan = Color(red: 6/255, green: 182/255, blue: 212/255)         // #06B6D4
    public static let accentCyan = Color(red: 6/255, green: 182/255, blue: 212/255)   // #06B6D4
    public static let orange = Color(red: 249/255, green: 115/255, blue: 22/255)     // #F97316
    
    // MARK: - Chart Indicator Colors
    public static let ma20 = Color(red: 245/255, green: 158/255, blue: 11/255)      // Yellow
    public static let ma50 = Color(red: 59/255, green: 130/255, blue: 246/255)      // Blue
    public static let ma200 = Color(red: 168/255, green: 85/255, blue: 247/255)    // Purple
    public static let ema12 = Color(red: 6/255, green: 182/255, blue: 212/255)      // Cyan
    public static let ema26 = Color(red: 236/255, green: 72/255, blue: 153/255)     // Pink
    public static let bollingerBand = Color(red: 99/255, green: 102/255, blue: 241/255) // Indigo
    public static let rsiColor = Color(red: 168/255, green: 85/255, blue: 247/255)  // Purple
    public static let macdLine = Color(red: 59/255, green: 130/255, blue: 246/255)  // Blue
    public static let macdSignal = Color(red: 245/255, green: 158/255, blue: 11/255) // Orange/Yellow
    
    // MARK: - Typography & UI Styles
    public static let chartFont = Font.system(size: 11, weight: .regular, design: .monospaced)
    public static let badgeFont = Font.system(size: 10, weight: .semibold, design: .rounded)
    public static let headerTitleFont = Font.system(size: 14, weight: .bold, design: .default)
    public static let bodyMonospaced = Font.system(size: 12, weight: .medium, design: .monospaced)
}

public extension Color {
    static var appBackground: Color { AppTheme.darkBackground }
    static var appSidebarBg: Color { AppTheme.darkSidebarBg }
    static var appHeaderBg: Color { AppTheme.darkHeaderBg }
    static var appSurface: Color { AppTheme.darkSurface }
    static var appCard: Color { AppTheme.darkCard }
    static var appBorder: Color { AppTheme.darkBorder }
    static var appUpGreen: Color { AppTheme.upGreen }
    static var appDownRed: Color { AppTheme.downRed }
    static var appAccent: Color { AppTheme.accentBlue }
}

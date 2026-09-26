import Foundation
import SwiftUI

// MARK: - Timeframe Enum
public enum LiquidationTimeframe: String, CaseIterable, Identifiable, Sendable, Codable {
    case hours24 = "24 hour"
    case days3 = "3 day"
    case days7 = "7 day"
    
    public var id: String { rawValue }
    
    public var sliceCount: Int {
        switch self {
        case .hours24: return 24 // 24 hourly intervals
        case .days3: return 36   // 36 2-hour intervals
        case .days7: return 42   // 42 4-hour intervals
        }
    }
    
    public var intervalHours: Double {
        switch self {
        case .hours24: return 1.0
        case .days3: return 2.0
        case .days7: return 4.0
        }
    }
}

// MARK: - Color Palette for 2D Heatmap
public enum LiquidationHeatmapPalette: String, CaseIterable, Identifiable, Sendable {
    case coinglass = "Coinglass Classic"
    case thermal = "Thermal Plasma"
    case cyber = "Cyber Blue"
    case matrix = "Matrix Green"
    
    public var id: String { rawValue }
    
    /// 4 colors representing the gradient progression for UI preview swatches
    public var previewColors: [Color] {
        switch self {
        case .coinglass:
            return [
                Color(red: 0.12, green: 0.05, blue: 0.22),
                Color(red: 0.10, green: 0.35, blue: 0.65),
                Color(red: 0.05, green: 0.75, blue: 0.60),
                Color(red: 0.98, green: 0.95, blue: 0.20)
            ]
        case .thermal:
            return [
                Color(red: 0.15, green: 0.02, blue: 0.25),
                Color(red: 0.70, green: 0.10, blue: 0.40),
                Color(red: 0.98, green: 0.45, blue: 0.05),
                Color(red: 1.00, green: 0.92, blue: 0.25)
            ]
        case .cyber:
            return [
                Color(red: 0.03, green: 0.06, blue: 0.15),
                Color(red: 0.05, green: 0.35, blue: 0.75),
                Color(red: 0.05, green: 0.85, blue: 0.95),
                Color(red: 0.90, green: 0.98, blue: 1.00)
            ]
        case .matrix:
            return [
                Color(red: 0.02, green: 0.10, blue: 0.05),
                Color(red: 0.08, green: 0.42, blue: 0.18),
                Color(red: 0.15, green: 0.85, blue: 0.35),
                Color(red: 0.85, green: 1.00, blue: 0.20)
            ]
        }
    }
    
    /// Smooth interpolation function mapping normalized intensity (0.0 ... 1.0) to Color
    public func color(for intensity: Double, threshold: Double = 0.0) -> Color {
        // Suppress colors below threshold (dim to dark background)
        if intensity < threshold {
            return previewColors[0].opacity(0.15)
        }
        
        let t = max(0.0, min(1.0, (intensity - threshold) / max(0.01, (1.0 - threshold))))
        let stops = previewColors
        
        if t <= 0.33 {
            let localT = t / 0.33
            return Color.interpolate(from: stops[0], to: stops[1], progress: localT)
        } else if t <= 0.66 {
            let localT = (t - 0.33) / 0.33
            return Color.interpolate(from: stops[1], to: stops[2], progress: localT)
        } else {
            let localT = (t - 0.66) / 0.34
            return Color.interpolate(from: stops[2], to: stops[3], progress: localT)
        }
    }
}

// MARK: - Color Interpolation Helper
private extension Color {
    static func interpolate(from c1: Color, to c2: Color, progress: Double) -> Color {
        #if canImport(AppKit)
        let ns1 = NSColor(c1).usingColorSpace(.sRGB) ?? .black
        let ns2 = NSColor(c2).usingColorSpace(.sRGB) ?? .white
        
        let r = Double(ns1.redComponent) + (Double(ns2.redComponent) - Double(ns1.redComponent)) * progress
        let g = Double(ns1.greenComponent) + (Double(ns2.greenComponent) - Double(ns1.greenComponent)) * progress
        let b = Double(ns1.blueComponent) + (Double(ns2.blueComponent) - Double(ns1.blueComponent)) * progress
        let a = Double(ns1.alphaComponent) + (Double(ns2.alphaComponent) - Double(ns1.alphaComponent)) * progress
        
        return Color(red: r, green: g, blue: b, opacity: a)
        #else
        return c2
        #endif
    }
}

// MARK: - Liquidation Price Band (Horizontal slice at a specific price)
public struct LiquidationPriceBand: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(price)_\(side.rawValue)" }
    public let price: Double
    public let volumeUSD: Double
    public let intensity: Double // 0.0 to 1.0
    public let side: LiquidationSide
    public let leverageTier: String // "100x", "50x", "25x", "10x", "5x"
    public let isSwept: Bool // True if historical price pierced this level
    
    public init(
        price: Double,
        volumeUSD: Double,
        intensity: Double,
        side: LiquidationSide,
        leverageTier: String,
        isSwept: Bool = false
    ) {
        self.price = price
        self.volumeUSD = volumeUSD
        self.intensity = max(0.0, min(1.0, intensity))
        self.side = side
        self.leverageTier = leverageTier
        self.isSwept = isSwept
    }
}

// MARK: - Candle Trajectory Point
public struct LiquidationCandlePoint: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(timestamp.timeIntervalSince1970)" }
    public let timestamp: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    
    public var isBullish: Bool { close >= open }
    
    public init(timestamp: Date, open: Double, high: Double, low: Double, close: Double) {
        self.timestamp = timestamp
        self.open = open
        self.high = high
        self.low = low
        self.close = close
    }
}

// MARK: - Liquidation Time Slice
public struct LiquidationTimeSlice: Identifiable, Sendable, Codable, Equatable {
    public var id: String { "\(timestamp.timeIntervalSince1970)" }
    public let timestamp: Date
    public let timeLabel: String // e.g. "25, 20:00"
    public let candle: LiquidationCandlePoint
    public let bands: [LiquidationPriceBand]
    
    public init(timestamp: Date, timeLabel: String, candle: LiquidationCandlePoint, bands: [LiquidationPriceBand]) {
        self.timestamp = timestamp
        self.timeLabel = timeLabel
        self.candle = candle
        self.bands = bands
    }
}

// MARK: - Full 2D Heatmap Data Model
public struct LiquidationHeatmap2DData: Sendable, Codable, Equatable {
    public let symbol: String
    public let exchange: String
    public let timeframe: LiquidationTimeframe
    public let currentPrice: Double
    public let minPrice: Double
    public let maxPrice: Double
    public let peakVolumeUSD: Double
    public let slices: [LiquidationTimeSlice]
    public let candles: [LiquidationCandlePoint]
    
    public init(
        symbol: String,
        exchange: String = "Binance Futures Perpetual",
        timeframe: LiquidationTimeframe,
        currentPrice: Double,
        minPrice: Double,
        maxPrice: Double,
        peakVolumeUSD: Double,
        slices: [LiquidationTimeSlice],
        candles: [LiquidationCandlePoint]
    ) {
        self.symbol = symbol
        self.exchange = exchange
        self.timeframe = timeframe
        self.currentPrice = currentPrice
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.peakVolumeUSD = peakVolumeUSD
        self.slices = slices
        self.candles = candles
    }
}

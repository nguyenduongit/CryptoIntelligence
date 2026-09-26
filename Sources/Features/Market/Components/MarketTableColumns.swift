import SwiftUI

/// Responsive column width calculator for the Market table.
/// Ensures table rows and header always fill 100% of the available width,
/// distributing space cleanly without any blank area.
public struct MarketTableColumns: Equatable, Sendable {
    public let rank: CGFloat = 48
    public let action: CGFloat = 46
    public let symbol: CGFloat
    public let price: CGFloat
    public let change24h: CGFloat
    public let highLow: CGFloat
    public let volume: CGFloat
    public let cap: CGFloat
    public let sparkline: CGFloat
    public let totalWidth: CGFloat

    public init(totalWidth: CGFloat) {
        // Enforce sensible minimum width (800pt) so columns never compress too tightly
        let w = max(totalWidth, 800)
        self.totalWidth = w

        // Fixed columns: rank (48) + action (46) = 94
        let flex = w - 48 - 46

        // Distribute proportionally across all flexible columns:
        // symbol: 20%
        // price: 13%
        // change24h: 11%
        // highLow: 14%
        // volume: 14%
        // cap: 13%
        // sparkline: remainder (~15%)
        let sym = floor(flex * 0.20)
        let pr = floor(flex * 0.13)
        let ch = floor(flex * 0.11)
        let hl = floor(flex * 0.14)
        let vol = floor(flex * 0.14)
        let cp = floor(flex * 0.13)
        let spark = flex - (sym + pr + ch + hl + vol + cp)

        self.symbol = sym
        self.price = pr
        self.change24h = ch
        self.highLow = hl
        self.volume = vol
        self.cap = cp
        self.sparkline = spark
    }
}

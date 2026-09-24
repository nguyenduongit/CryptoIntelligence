import Foundation

public struct IndicatorConfig: Sendable, Codable, Equatable {
    // Overlay Indicators
    public var showSMA20: Bool = true
    public var sma20Period: Int = 20
    
    public var showSMA50: Bool = false
    public var sma50Period: Int = 50
    
    public var showSMA200: Bool = false
    public var sma200Period: Int = 200
    
    public var showEMA12: Bool = false
    public var ema12Period: Int = 12
    
    public var showEMA26: Bool = false
    public var ema26Period: Int = 26
    
    public var showEMARibbon: Bool = false
    
    public var showBollinger: Bool = false
    public var bollingerPeriod: Int = 20
    public var bollingerStdDev: Double = 2.0
    
    public var showVWAP: Bool = false
    
    // Sub-pane Indicators
    public var showVolume: Bool = true
    public var showVolumeMA: Bool = true
    public var volumeMAPeriod: Int = 20
    
    public var showRSI: Bool = true
    public var rsiPeriod: Int = 14
    
    public var showStochRSI: Bool = false
    public var stochRsiPeriod: Int = 14
    public var stochRsiKPeriod: Int = 3
    public var stochRsiDPeriod: Int = 3
    
    public var showMACD: Bool = false
    public var macdFastPeriod: Int = 12
    public var macdSlowPeriod: Int = 26
    public var macdSignalPeriod: Int = 9
    
    public var showATR: Bool = false
    public var atrPeriod: Int = 14
    
    // Scale mode
    public var isLogScale: Bool = false
    
    public init() {}
}

import Foundation

public struct ComputedIndicators: Sendable, Equatable {
    public var sma20: [Double?] = []
    public var sma50: [Double?] = []
    public var sma200: [Double?] = []
    public var ema12: [Double?] = []
    public var ema26: [Double?] = []
    public var emaRibbon20: [Double?] = []
    public var emaRibbon50: [Double?] = []
    public var emaRibbon100: [Double?] = []
    public var emaRibbon200: [Double?] = []
    public var bollinger: BollingerResult?
    public var vwap: [Double?] = []
    public var rsi: [Double?] = []
    public var stochRSI: StochRSIResult?
    public var macd: MACDResult?
    public var atr: [Double?] = []
    public var volumeMA: [Double?] = []
    
    public init() {}
}

public struct IndicatorEngine {
    public static func compute(candles: [Candle], config: IndicatorConfig) -> ComputedIndicators {
        var computed = ComputedIndicators()
        guard !candles.isEmpty else { return computed }
        
        let closePrices = candles.map { $0.close }
        
        if config.showSMA20 {
            computed.sma20 = MovingAverage.calculateSMA(values: closePrices, period: config.sma20Period)
        }
        if config.showSMA50 {
            computed.sma50 = MovingAverage.calculateSMA(values: closePrices, period: config.sma50Period)
        }
        if config.showSMA200 {
            computed.sma200 = MovingAverage.calculateSMA(values: closePrices, period: config.sma200Period)
        }
        if config.showEMA12 {
            computed.ema12 = MovingAverage.calculateEMA(values: closePrices, period: config.ema12Period)
        }
        if config.showEMA26 {
            computed.ema26 = MovingAverage.calculateEMA(values: closePrices, period: config.ema26Period)
        }
        if config.showEMARibbon {
            computed.emaRibbon20 = MovingAverage.calculateEMA(values: closePrices, period: 20)
            computed.emaRibbon50 = MovingAverage.calculateEMA(values: closePrices, period: 50)
            computed.emaRibbon100 = MovingAverage.calculateEMA(values: closePrices, period: 100)
            computed.emaRibbon200 = MovingAverage.calculateEMA(values: closePrices, period: 200)
        }
        if config.showBollinger {
            computed.bollinger = BollingerBands.calculate(
                values: closePrices,
                period: config.bollingerPeriod,
                multiplier: config.bollingerStdDev
            )
        }
        if config.showVWAP {
            computed.vwap = VWAP.calculate(candles: candles)
        }
        if config.showRSI {
            computed.rsi = RSI.calculate(values: closePrices, period: config.rsiPeriod)
        }
        if config.showStochRSI {
            computed.stochRSI = StochasticRSI.calculate(
                values: closePrices,
                rsiPeriod: config.stochRsiPeriod,
                stochPeriod: config.stochRsiPeriod,
                kPeriod: config.stochRsiKPeriod,
                dPeriod: config.stochRsiDPeriod
            )
        }
        if config.showMACD {
            computed.macd = MACD.calculate(
                values: closePrices,
                fastPeriod: config.macdFastPeriod,
                slowPeriod: config.macdSlowPeriod,
                signalPeriod: config.macdSignalPeriod
            )
        }
        if config.showATR {
            computed.atr = ATR.calculate(candles: candles, period: config.atrPeriod)
        }
        if config.showVolumeMA {
            computed.volumeMA = VolumeMA.calculate(candles: candles, period: config.volumeMAPeriod)
        }
        
        return computed
    }
}

import Testing
import Foundation
@testable import CryptoResearch

struct IndicatorMathTests {
    
    struct FixtureData: Codable {
        let candles: [Candle]
        let sma20: [Double?]
        let ema12: [Double?]
        let bollinger_mid: [Double?]
        let bollinger_upper: [Double?]
        let bollinger_lower: [Double?]
        let rsi14: [Double?]
        let macd_line: [Double?]
        let macd_signal: [Double?]
        let macd_histogram: [Double?]
        let atr14: [Double?]
        let volume_ma20: [Double?]
    }
    
    private func loadFixture() -> FixtureData {
        var possibleURLs = [URL]()
        
        if let bundleURL = Bundle.module.url(forResource: "btc_1h_computed", withExtension: "json") {
            possibleURLs.append(bundleURL)
        }
        if let fixtureDirURL = Bundle.module.url(forResource: "TestFixtures/btc_1h_computed", withExtension: "json") {
            possibleURLs.append(fixtureDirURL)
        }
        
        let cwdURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("Tests/TestFixtures/btc_1h_computed.json")
        possibleURLs.append(cwdURL)
        
        let sourceURL = URL(fileURLWithPath: #file).deletingLastPathComponent().deletingLastPathComponent().appendingPathComponent("TestFixtures/btc_1h_computed.json")
        possibleURLs.append(sourceURL)
        
        for url in possibleURLs {
            if let data = try? Data(contentsOf: url),
               let decoded = try? JSONDecoder().decode(FixtureData.self, from: data) {
                return decoded
            }
        }
        
        fatalError("Failed to locate or decode btc_1h_computed.json in any candidate location: \(possibleURLs)")
    }
    
    @Test func testSMA20MatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let closes = fixture.candles.map { $0.close }
        let calculated = MovingAverage.calculateSMA(values: closes, period: 20)
        
        #expect(calculated.count == fixture.sma20.count)
        for i in 0..<calculated.count {
            if let expected = fixture.sma20[i] {
                guard let actual = calculated[i] else {
                    Issue.record("Expected value at \(i) but got nil")
                    return
                }
                #expect(abs(actual - expected) <= 1e-9, "SMA20 mismatch at index \(i)")
            } else {
                #expect(calculated[i] == nil, "Expected nil at index \(i)")
            }
        }
    }
    
    @Test func testEMA12MatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let closes = fixture.candles.map { $0.close }
        let calculated = MovingAverage.calculateEMA(values: closes, period: 12)
        
        #expect(calculated.count == fixture.ema12.count)
        for i in 0..<calculated.count {
            if let expected = fixture.ema12[i] {
                guard let actual = calculated[i] else {
                    Issue.record("Expected value at \(i) but got nil")
                    return
                }
                #expect(abs(actual - expected) <= 1e-9, "EMA12 mismatch at index \(i)")
            } else {
                #expect(calculated[i] == nil, "Expected nil at index \(i)")
            }
        }
    }
    
    @Test func testBollingerBandsMatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let closes = fixture.candles.map { $0.close }
        let result = BollingerBands.calculate(values: closes, period: 20, multiplier: 2.0)
        
        for i in 0..<closes.count {
            if let expectedMid = fixture.bollinger_mid[i],
               let expectedUp = fixture.bollinger_upper[i],
               let expectedLow = fixture.bollinger_lower[i] {
                guard let actualMid = result.middle[i],
                      let actualUp = result.upper[i],
                      let actualLow = result.lower[i] else {
                    Issue.record("Expected Bollinger values at \(i) but got nil")
                    return
                }
                #expect(abs(actualMid - expectedMid) <= 1e-9, "Bollinger Mid mismatch at \(i)")
                #expect(abs(actualUp - expectedUp) <= 1e-9, "Bollinger Upper mismatch at \(i)")
                #expect(abs(actualLow - expectedLow) <= 1e-9, "Bollinger Lower mismatch at \(i)")
            } else {
                #expect(result.middle[i] == nil)
                #expect(result.upper[i] == nil)
                #expect(result.lower[i] == nil)
            }
        }
    }
    
    @Test func testRSI14MatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let closes = fixture.candles.map { $0.close }
        let calculated = RSI.calculate(values: closes, period: 14)
        
        for i in 0..<closes.count {
            if let expected = fixture.rsi14[i] {
                guard let actual = calculated[i] else {
                    Issue.record("Expected RSI value at \(i) but got nil")
                    return
                }
                #expect(abs(actual - expected) <= 1e-9, "RSI14 mismatch at index \(i)")
            } else {
                #expect(calculated[i] == nil)
            }
        }
    }
    
    @Test func testMACDMatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let closes = fixture.candles.map { $0.close }
        let result = MACD.calculate(values: closes, fastPeriod: 12, slowPeriod: 26, signalPeriod: 9)
        
        for i in 0..<closes.count {
            if let expLine = fixture.macd_line[i] {
                #expect(abs(result.macdLine[i]! - expLine) <= 1e-9, "MACD line mismatch at \(i)")
            } else {
                #expect(result.macdLine[i] == nil)
            }
            
            if let expSig = fixture.macd_signal[i] {
                #expect(abs(result.signalLine[i]! - expSig) <= 1e-9, "MACD signal mismatch at \(i)")
            } else {
                #expect(result.signalLine[i] == nil)
            }
            
            if let expHist = fixture.macd_histogram[i] {
                #expect(abs(result.histogram[i]! - expHist) <= 1e-9, "MACD hist mismatch at \(i)")
            } else {
                #expect(result.histogram[i] == nil)
            }
        }
    }
    
    @Test func testATR14MatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let calculated = ATR.calculate(candles: fixture.candles, period: 14)
        
        for i in 0..<fixture.candles.count {
            if let expected = fixture.atr14[i] {
                guard let actual = calculated[i] else {
                    Issue.record("Expected ATR value at \(i) but got nil")
                    return
                }
                #expect(abs(actual - expected) <= 1e-9, "ATR14 mismatch at index \(i)")
            } else {
                #expect(calculated[i] == nil)
            }
        }
    }
    
    @Test func testVolumeMA20MatchesReferenceWithinTolerance() {
        let fixture = loadFixture()
        let calculated = VolumeMA.calculate(candles: fixture.candles, period: 20)
        
        for i in 0..<fixture.candles.count {
            if let expected = fixture.volume_ma20[i] {
                guard let actual = calculated[i] else {
                    Issue.record("Expected Volume MA value at \(i) but got nil")
                    return
                }
                #expect(abs(actual - expected) <= 1e-9, "Volume MA mismatch at index \(i)")
            } else {
                #expect(calculated[i] == nil)
            }
        }
    }
}

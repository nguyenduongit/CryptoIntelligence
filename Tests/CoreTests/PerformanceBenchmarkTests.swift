import Testing
import Foundation
@testable import CryptoResearch

struct PerformanceBenchmarkTests {
    
    private func generate50kCandles() -> [Candle] {
        var candles = [Candle]()
        candles.reserveCapacity(50_000)
        
        var price = 50000.0
        let baseTime: Int64 = 1600000000000
        
        for i in 0..<50_000 {
            let open = price
            let delta = Double((i % 17) - 8) * 5.0
            let close = max(100.0, open + delta)
            let high = max(open, close) + 10.0
            let low = min(open, close) - 10.0
            let volume = Double(100 + (i % 500))
            
            candles.append(Candle(
                openTime: baseTime + Int64(i * 60 * 1000),
                open: open,
                high: high,
                low: low,
                close: close,
                volume: volume,
                isClosed: true
            ))
            
            price = close
        }
        return candles
    }
    
    @Test func benchmark50kCandlesIndicatorComputation() {
        let candles = generate50kCandles()
        #expect(candles.count == 50_000)
        
        var config = IndicatorConfig()
        config.showSMA20 = true
        config.showEMA12 = true
        config.showBollinger = true
        config.showRSI = true
        config.showMACD = true
        
        let start = CFAbsoluteTimeGetCurrent()
        let computed = IndicatorEngine.compute(candles: candles, config: config)
        let elapsed = CFAbsoluteTimeGetCurrent() - start
        
        #expect(computed.sma20.count == 50_000)
        #expect(computed.rsi.count == 50_000)
        #expect(computed.bollinger != nil)
        
        print(String(format: "🔥 50,000 candles full indicator computation time: %.4f seconds (%.2f ms)", elapsed, elapsed * 1000.0))
        #expect(elapsed < 2.5, "50k indicator calculation should take less than 2.5s in debug mode")
    }
    
    @Test func benchmark50kCandlesPanZoomRenderingLoop() {
        let candles = generate50kCandles()
        let width: CGFloat = 1200.0
        let height: CGFloat = 700.0
        
        var config = IndicatorConfig()
        config.showBollinger = true
        config.showRSI = true
        let computed = IndicatorEngine.compute(candles: candles, config: config)
        
        // Simulate 120 pan/zoom frames across 50,000 candles
        let frameCount = 120
        let start = CFAbsoluteTimeGetCurrent()
        
        for frame in 0..<frameCount {
            let lower = Double(frame * 10)
            let upper = lower + 1000.0 // 1,000 visible candles
            let transform = CoordinateTransform(
                visibleRange: lower...upper,
                priceRange: 45000.0...55000.0,
                isLogScale: false
            )
            
            // Execute Level-of-Detail aggregation across visible slice
            let startIdx = max(0, Int(floor(lower)))
            let endIdx = min(candles.count - 1, Int(ceil(upper)))
            
            var pixelColumns = [Int: (open: Double, high: Double, low: Double, close: Double, volume: Double)]()
            for i in startIdx...endIdx {
                let c = candles[i]
                let x = transform.x(forIndex: Double(i), width: width)
                let px = Int(x)
                if var existing = pixelColumns[px] {
                    existing.high = max(existing.high, c.high)
                    existing.low = min(existing.low, c.low)
                    existing.close = c.close
                    existing.volume += c.volume
                    pixelColumns[px] = existing
                } else {
                    pixelColumns[px] = (c.open, c.high, c.low, c.close, c.volume)
                }
            }
            
            // Execute indicator slice mapping
            for i in startIdx...endIdx {
                if let mid = computed.bollinger?.middle[i] {
                    _ = transform.y(forPrice: mid, height: height)
                }
                if let rsi = computed.rsi[i] {
                    _ = CoordinateTransform(visibleRange: lower...upper, priceRange: 0...100).y(forPrice: rsi, height: 100)
                }
            }
        }
        
        let totalTime = CFAbsoluteTimeGetCurrent() - start
        let fps = Double(frameCount) / totalTime
        let avgFrameMs = (totalTime / Double(frameCount)) * 1000.0
        
        print(String(format: "🔥 50,000 candles simulated pan/zoom rendering: %.2f FPS (avg %.3f ms per frame)", fps, avgFrameMs))
        #expect(fps >= 30.0, "Frame rate must be >= 30 FPS")
    }
}

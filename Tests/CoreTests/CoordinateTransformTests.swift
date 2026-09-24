import Testing
import Foundation
@testable import CryptoResearch

struct CoordinateTransformTests {
    
    @Test func testLinearCoordinateTransformRoundtrip() {
        let transform = CoordinateTransform(
            visibleRange: 0.0...100.0,
            priceRange: 1000.0...2000.0,
            isLogScale: false
        )
        let width: CGFloat = 1000.0
        let height: CGFloat = 500.0
        
        // Test X mapping
        let x50 = transform.x(forIndex: 50.0, width: width)
        #expect(abs(x50 - 500.0) <= 0.001)
        let index50 = transform.index(forX: 500.0, width: width)
        #expect(abs(index50 - 50.0) <= 0.001)
        
        // Test Y mapping (Linear)
        let yMid = transform.y(forPrice: 1500.0, height: height)
        #expect(abs(yMid - 250.0) <= 0.001)
        let priceMid = transform.price(forY: 250.0, height: height)
        #expect(abs(priceMid - 1500.0) <= 0.001)
    }
    
    @Test func testLogCoordinateTransformRoundtrip() {
        let transform = CoordinateTransform(
            visibleRange: 0.0...100.0,
            priceRange: 10.0...1000.0,
            isLogScale: true
        )
        let height: CGFloat = 600.0
        
        let y100 = transform.y(forPrice: 100.0, height: height)
        #expect(abs(y100 - 300.0) <= 0.001)
        let price100 = transform.price(forY: 300.0, height: height)
        #expect(abs(price100 - 100.0) <= 0.001)
    }
    
    @Test func testNicePriceSteps() {
        let steps = CoordinateTransform.calculateNicePriceSteps(minPrice: 95.0, maxPrice: 205.0, targetStepCount: 5)
        #expect(!steps.isEmpty)
        #expect(steps.first! <= 100.0)
        #expect(steps.last! >= 200.0)
    }
}

import Testing
import Foundation
@testable import CryptoResearch

struct RateLimiterTests {
    
    @Test func testWeightRecordingFromHeaders() async {
        let limiter = BinanceRateLimiter()
        
        let headers: [AnyHashable: Any] = [
            "x-mbx-used-weight-1m": "45"
        ]
        
        await limiter.recordUsedWeight(fromHeaders: headers)
        let (used, _) = await limiter.getCurrentUsedWeight()
        
        #expect(used == 45)
    }
    
    @Test func testPermitAcquisitionUnderThreshold() async throws {
        let limiter = BinanceRateLimiter()
        await limiter.setMaxWeight(6000)
        
        try await limiter.acquirePermit(weight: 2)
        let (used, maxWeight) = await limiter.getCurrentUsedWeight()
        #expect(used == 2)
        #expect(maxWeight == 6000)
    }
    
    @Test func testWeightPreReservationAccumulation() async throws {
        let limiter = BinanceRateLimiter()
        await limiter.setMaxWeight(100)
        await limiter.setSafetyThreshold(0.5) // 50 max safe weight
        
        try await limiter.acquirePermit(weight: 15)
        try await limiter.acquirePermit(weight: 20)
        
        let (used, _) = await limiter.getCurrentUsedWeight()
        #expect(used == 35)
    }
    
    @Test func testBanHandlingThrowsError() async {
        let limiter = BinanceRateLimiter()
        await limiter.recordBan(retryAfterSeconds: 30)
        
        do {
            try await limiter.acquirePermit(weight: 2)
            #expect(Bool(false), "Should have thrown rate limit ban error")
        } catch {
            let nsErr = error as NSError
            #expect(nsErr.code == 418)
        }
    }
}

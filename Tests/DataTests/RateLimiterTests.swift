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
    }
}

import Foundation

public actor BinanceRateLimiter {
    public static let shared = BinanceRateLimiter()
    
    private var maxWeightPerMinute: Int = 6000
    private var targetSafetyThreshold: Double = 0.5 // Keep under 50% = 3000 weight
    private var currentUsedWeight1m: Int = 0
    private var banUntil: Date? = nil
    private var lastRecordedTime: Date = Date()
    
    public init() {}
    
    public func setMaxWeight(_ maxWeight: Int) {
        self.maxWeightPerMinute = maxWeight
    }
    
    public func getCurrentUsedWeight() -> (used: Int, max: Int) {
        (currentUsedWeight1m, maxWeightPerMinute)
    }
    
    public func recordUsedWeight(fromHeaders headers: [AnyHashable: Any]?) {
        guard let headers = headers else { return }
        
        // Binance returns X-MBX-USED-WEIGHT-1M or x-mbx-used-weight-1m
        for (key, value) in headers {
            if let strKey = (key as? String)?.lowercased(), strKey == "x-mbx-used-weight-1m" {
                if let strVal = value as? String, let intVal = Int(strVal) {
                    self.currentUsedWeight1m = intVal
                }
            }
        }
    }
    
    public func recordBan(retryAfterSeconds: Double?) {
        let duration = retryAfterSeconds ?? 120.0 // Default 2 minutes if not provided
        self.banUntil = Date().addingTimeInterval(duration)
    }
    
    /// Wait if needed before executing a request with specified weight
    public func acquirePermit(weight: Int = 2) async throws {
        if let ban = banUntil {
            if Date() < ban {
                let remaining = ban.timeIntervalSince(Date())
                throw NSError(
                    domain: "BinanceRateLimiter",
                    code: 418,
                    userInfo: [NSLocalizedDescriptionKey: "IP tạm thời bị hạn chế bởi sàn. Đang chờ \(Int(remaining)) giây (Retry-After)."]
                )
            } else {
                self.banUntil = nil
            }
        }
        
        let maxSafeWeight = Int(Double(maxWeightPerMinute) * targetSafetyThreshold)
        if currentUsedWeight1m + weight >= maxSafeWeight {
            // Throttling: wait a bit to allow 1m window to slide
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second sleep
        }
    }
}

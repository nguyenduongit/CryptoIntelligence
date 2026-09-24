import Foundation

public actor BinanceRateLimiter {
    public static let shared = BinanceRateLimiter()
    
    private var maxWeightPerMinute: Int = 6000
    private var targetSafetyThreshold: Double = 0.5 // Keep under 50% = 3000 weight
    private var serverReportedWeight1m: Int = 0
    private var lastServerReportedTime: Date = Date()
    private var banUntil: Date? = nil
    
    // Timestamped local reservations for sliding 60-second window
    private var activeReservations: [(timestamp: Date, weight: Int)] = []
    
    public init() {}
    
    public func setMaxWeight(_ maxWeight: Int) {
        self.maxWeightPerMinute = max(1, maxWeight)
    }
    
    public func setSafetyThreshold(_ threshold: Double) {
        self.targetSafetyThreshold = min(max(threshold, 0.1), 1.0)
    }
    
    public func getCurrentUsedWeight() -> (used: Int, max: Int) {
        pruneExpiredReservations()
        let localSum = activeReservations.reduce(0) { $0 + $1.weight }
        
        // Server weight also decays if more than 60s have passed since last header update
        let secondsSinceServerReport = Date().timeIntervalSince(lastServerReportedTime)
        let effectiveServerWeight: Int
        if secondsSinceServerReport >= 60.0 {
            effectiveServerWeight = 0
        } else if secondsSinceServerReport <= 1.0 {
            effectiveServerWeight = serverReportedWeight1m
        } else {
            // Linear decay approximation for server metric between header updates
            let decayFraction = max(0.0, 1.0 - (secondsSinceServerReport / 60.0))
            effectiveServerWeight = Int(round(Double(serverReportedWeight1m) * decayFraction))
        }
        
        let effectiveUsed = max(localSum, effectiveServerWeight)
        return (effectiveUsed, maxWeightPerMinute)
    }
    
    public func recordUsedWeight(fromHeaders headers: [AnyHashable: Any]?) {
        guard let headers = headers else { return }
        
        // Binance returns X-MBX-USED-WEIGHT-1M or x-mbx-used-weight-1m
        for (key, value) in headers {
            if let strKey = (key as? String)?.lowercased(), strKey == "x-mbx-used-weight-1m" {
                if let strVal = value as? String, let intVal = Int(strVal) {
                    self.serverReportedWeight1m = intVal
                    self.lastServerReportedTime = Date()
                }
            }
        }
    }
    
    public func recordBan(retryAfterSeconds: Double?) {
        let duration = retryAfterSeconds ?? 120.0 // Default 2 minutes if not provided
        self.banUntil = Date().addingTimeInterval(duration)
    }
    
    /// Pre-reserves weight and blocks until the sliding 1-minute window has enough capacity.
    public func acquirePermit(weight: Int = 2) async throws {
        let requestedWeight = max(1, weight)
        let maxSafeWeight = Int(Double(maxWeightPerMinute) * targetSafetyThreshold)
        
        while true {
            try Task.checkCancellation()
            
            // 1. Check if currently banned / restricted by Binance (HTTP 418 / 429)
            if let ban = banUntil {
                let now = Date()
                if now < ban {
                    let remaining = ban.timeIntervalSince(now)
                    throw NSError(
                        domain: "BinanceRateLimiter",
                        code: 418,
                        userInfo: [NSLocalizedDescriptionKey: "IP tạm thời bị hạn chế bởi sàn. Đang chờ \(Int(ceil(remaining))) giây (Retry-After)."]
                    )
                } else {
                    self.banUntil = nil
                }
            }
            
            // 2. Prune reservations older than 60 seconds
            pruneExpiredReservations()
            
            let (currentUsed, _) = getCurrentUsedWeight()
            
            // 3. If within safety threshold, pre-reserve weight immediately and allow request through
            if currentUsed + requestedWeight <= maxSafeWeight {
                activeReservations.append((timestamp: Date(), weight: requestedWeight))
                return
            }
            
            // 4. Calculate optimal wait time until oldest reservation expires
            let now = Date()
            let oldestTimestamp = activeReservations.first?.timestamp ?? now
            let timeUntilOldestExpires = max(0.05, 60.0 - now.timeIntervalSince(oldestTimestamp) + 0.05)
            let waitSeconds = min(timeUntilOldestExpires, 1.0)
            
            let waitNanoseconds = UInt64(waitSeconds * 1_000_000_000)
            try await Task.sleep(nanoseconds: waitNanoseconds)
        }
    }
    
    private func pruneExpiredReservations() {
        let cutoff = Date().addingTimeInterval(-60.0)
        activeReservations.removeAll { $0.timestamp < cutoff }
    }
}

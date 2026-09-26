import SwiftUI
import Observation

@Observable
public final class BubblePhysicsEngine: @unchecked Sendable {
    public var bubbles: [BubbleNode] = []
    public var bounds: CGSize = .zero
    public var isSimulating: Bool = true
    
    private var simulationTime: Double = 0
    private var sleepCounter: Int = 0
    private let padding: CGFloat = 3.5
    
    public init() {}
    
    public func wake() {
        isSimulating = true
        sleepCounter = 0
    }
    
    // MARK: - Update Data & Recompute Dynamic Radii with True Graduated Distribution
    public func update(
        with tickers: [MarketTicker24h],
        metric: BubbleSizingMetric,
        in canvasSize: CGSize
    ) {
        guard canvasSize.width > 50 && canvasSize.height > 50 && !tickers.isEmpty else { return }
        self.bounds = canvasSize
        self.wake()
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let existingMap = Dictionary(uniqueKeysWithValues: bubbles.map { ($0.id, $0) })
        
        // 1. Calculate dynamic min and max radius so bubbles FILL the viewport nicely
        let canvasArea = Double(canvasSize.width * canvasSize.height)
        let bubbleCount = max(1, tickers.count)
        // Target ~54% of total canvas area covered by bubbles
        let targetTotalArea = canvasArea * 0.54
        let meanTargetArea = targetTotalArea / Double(bubbleCount)
        let meanR = sqrt(meanTargetArea / Double.pi)
        
        let dynamicMinRadius = max(24.0, min(42.0, meanR * 0.58))
        let dynamicMaxRadius = max(70.0, min(140.0, meanR * 2.35))
        
        // 2. Hybrid Rank-Decay + Logarithmic Value Normalization
        // Eliminates the issue where only BTC/ETH are big and all others look identical
        let n = Double(max(1, tickers.count))
        let logValues: [Double] = tickers.map { t in
            switch metric {
            case .marketCap:
                return log10(max(10_000_000, t.estimatedMarketCap))
            case .volume24h:
                return log10(max(100_000, t.quoteVolume))
            case .priceChange:
                return pow(max(0.2, abs(t.priceChangePercent)), 0.65)
            }
        }
        
        let minLog = logValues.min() ?? 1.0
        let maxLog = logValues.max() ?? 10.0
        let logRange = max(1e-5, maxLog - minLog)
        
        // 3. Build or update nodes
        var updatedNodes: [BubbleNode] = []
        updatedNodes.reserveCapacity(tickers.count)
        
        let aspectRatio = max(1.0, min(2.2, canvasSize.width / canvasSize.height))
        
        for (index, ticker) in tickers.enumerated() {
            let logNorm = (logValues[index] - minLog) / logRange
            // Power curve rank percentile produces smooth visually distinct steps
            let rankPercentile = 1.0 - pow(Double(index) / n, 0.62)
            
            // 55% Rank Percentile + 45% Log Value Weighting
            let combinedNorm = 0.55 * rankPercentile + 0.45 * logNorm
            let targetR = CGFloat(dynamicMinRadius) + CGFloat(combinedNorm) * CGFloat(dynamicMaxRadius - dynamicMinRadius)
            
            if var existing = existingMap[ticker.symbol] {
                existing.price = ticker.price
                existing.priceChangePercent = ticker.priceChangePercent
                existing.quoteVolume = ticker.quoteVolume
                existing.estimatedMarketCap = ticker.estimatedMarketCap
                existing.sector = ticker.sector
                existing.targetRadius = targetR
                existing.radius += (targetR - existing.radius) * 0.35
                updatedNodes.append(existing)
            } else {
                // Elliptical phyllotaxis spawn across the wide viewport
                let angle = Double(index) * 2.39996 // Golden ratio angle
                let dist = sqrt(Double(index) + 1.0) * (Double(meanR) * 1.35)
                let spawnX = center.x + CGFloat(cos(angle) * dist * Double(aspectRatio))
                let spawnY = center.y + CGFloat(sin(angle) * dist)
                
                let newNode = BubbleNode(
                    ticker: ticker,
                    position: CGPoint(x: spawnX, y: spawnY),
                    radius: targetR
                )
                updatedNodes.append(newNode)
            }
        }
        
        self.bubbles = updatedNodes
        
        // Run initial relaxation steps if fresh initialization
        if existingMap.isEmpty {
            for _ in 0..<35 {
                step(dt: 0.02)
            }
        }
    }
    
    // MARK: - Re-pack / Shake Layout
    public func repack() {
        guard bounds.width > 50 && bounds.height > 50 else { return }
        self.wake()
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let aspectRatio = bounds.width / bounds.height
        
        for (index, _) in bubbles.enumerated() {
            let angle = Double(index) * 2.39996
            let dist = sqrt(Double(index) + 1.0) * 45.0
            bubbles[index].position = CGPoint(
                x: center.x + CGFloat(cos(angle) * dist * Double(aspectRatio)),
                y: center.y + CGFloat(sin(angle) * dist)
            )
            bubbles[index].velocity = .zero
        }
        
        for _ in 0..<30 {
            step(dt: 0.02)
        }
    }
    
    // MARK: - Physics Simulation Step (Ultra-Optimized 60 FPS)
    public func step(dt: CGFloat = 0.016) {
        guard isSimulating else { return }
        guard bounds.width > 50 && bounds.height > 50 && !bubbles.isEmpty else { return }
        simulationTime += Double(dt)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let count = bubbles.count
        let halfW = max(1.0, bounds.width * 0.5)
        let halfH = max(1.0, bounds.height * 0.5)
        let aspectRatio = bounds.width / max(1.0, bounds.height)
        
        // 1. Center Attraction Force (Gentle Elliptical Radial Gravity)
        for i in 0..<count {
            guard !bubbles[i].isPinned else { continue }
            
            let dx = center.x - bubbles[i].position.x
            let dy = center.y - bubbles[i].position.y
            let normX = dx / halfW
            let normY = dy / halfH
            let normDist = sqrt(normX * normX + normY * normY)
            
            // Soft quadratic gravity: near center it's almost zero; rises gently towards edges
            if normDist > 0.05 {
                let gravForce = pow(normDist, 1.25) * 0.30
                bubbles[i].velocity.x += (normX / normDist) * gravForce * (1.0 / aspectRatio)
                bubbles[i].velocity.y += (normY / normDist) * gravForce
            }
            
            // Organic Floating Drift
            let phase = bubbles[i].phase
            bubbles[i].velocity.x += CGFloat(sin(simulationTime * 1.2 + phase)) * 0.05
            bubbles[i].velocity.y += CGFloat(cos(simulationTime * 1.0 + phase)) * 0.05
        }
        
        // 2. Anti-Overlap Collision Resolution (2 Iterations for high performance & stability)
        for _ in 0..<2 {
            for i in 0..<count {
                for j in (i + 1)..<count {
                    var dx = bubbles[j].position.x - bubbles[i].position.x
                    var dy = bubbles[j].position.y - bubbles[i].position.y
                    var dist = sqrt(dx * dx + dy * dy)
                    let minDist = bubbles[i].radius + bubbles[j].radius + padding
                    
                    if dist < minDist {
                        if dist < 0.001 {
                            dx = CGFloat.random(in: -0.5...0.5)
                            dy = CGFloat.random(in: -0.5...0.5)
                            dist = sqrt(dx * dx + dy * dy)
                        }
                        
                        let overlap = minDist - dist
                        let nx = dx / max(0.0001, dist)
                        let ny = dy / max(0.0001, dist)
                        
                        // Mass-weighted displacement: larger circles displace less
                        let totalR = bubbles[i].radius + bubbles[j].radius
                        let wi = bubbles[j].radius / totalR
                        let wj = bubbles[i].radius / totalR
                        
                        if !bubbles[i].isPinned {
                            bubbles[i].position.x -= nx * overlap * wi
                            bubbles[i].position.y -= ny * overlap * wi
                        }
                        if !bubbles[j].isPinned {
                            bubbles[j].position.x += nx * overlap * wj
                            bubbles[j].position.y += ny * overlap * wj
                        }
                    }
                }
            }
        }
        
        // 3. Boundary Clamping & Elastic Bounce
        for i in 0..<count {
            guard !bubbles[i].isPinned else { continue }
            
            let r = bubbles[i].radius
            let minX = r + 8
            let maxX = bounds.width - r - 8
            let minY = r + 8
            let maxY = bounds.height - r - 8
            
            if bubbles[i].position.x < minX {
                bubbles[i].position.x = minX
                bubbles[i].velocity.x = abs(bubbles[i].velocity.x) * 0.4
            } else if bubbles[i].position.x > maxX {
                bubbles[i].position.x = maxX
                bubbles[i].velocity.x = -abs(bubbles[i].velocity.x) * 0.4
            }
            
            if bubbles[i].position.y < minY {
                bubbles[i].position.y = minY
                bubbles[i].velocity.y = abs(bubbles[i].velocity.y) * 0.4
            } else if bubbles[i].position.y > maxY {
                bubbles[i].position.y = maxY
                bubbles[i].velocity.y = -abs(bubbles[i].velocity.y) * 0.4
            }
        }
        
        // 4. Position Integration & Velocity Damping
        var maxVel: CGFloat = 0
        for i in 0..<count {
            guard !bubbles[i].isPinned else { continue }
            
            bubbles[i].position.x += bubbles[i].velocity.x
            bubbles[i].position.y += bubbles[i].velocity.y
            
            bubbles[i].velocity.x *= 0.88
            bubbles[i].velocity.y *= 0.88
            
            let currentV = abs(bubbles[i].velocity.x) + abs(bubbles[i].velocity.y)
            if currentV > maxVel { maxVel = currentV }
            
            // Interpolate towards target radius
            let diffR = bubbles[i].targetRadius - bubbles[i].radius
            if abs(diffR) > 0.1 {
                bubbles[i].radius += diffR * 0.15
            }
        }
        
        // 5. Alpha Decay / Simulation Sleep (Saves CPU, zero lag when settled)
        if maxVel < 0.10 {
            sleepCounter += 1
            if sleepCounter > 80 { // ~1.3 seconds of calm
                isSimulating = false
            }
        } else {
            sleepCounter = 0
        }
    }
    
    // MARK: - Interactive Drag & Throw Gestures
    public func startDrag(symbol: String, at point: CGPoint) {
        self.wake()
        if let idx = bubbles.firstIndex(where: { $0.id == symbol }) {
            bubbles[idx].isPinned = true
            bubbles[idx].position = point
            bubbles[idx].velocity = .zero
        }
    }
    
    public func updateDrag(symbol: String, to point: CGPoint) {
        self.wake()
        if let idx = bubbles.firstIndex(where: { $0.id == symbol }) {
            let prev = bubbles[idx].position
            bubbles[idx].position = point
            bubbles[idx].velocity = CGPoint(
                x: (point.x - prev.x) * 0.85,
                y: (point.y - prev.y) * 0.85
            )
        }
    }
    
    public func endDrag(symbol: String, releaseVelocity: CGPoint) {
        self.wake()
        if let idx = bubbles.firstIndex(where: { $0.id == symbol }) {
            bubbles[idx].isPinned = false
            bubbles[idx].velocity = CGPoint(
                x: min(25, max(-25, releaseVelocity.x * 0.05)),
                y: min(25, max(-25, releaseVelocity.y * 0.05))
            )
        }
    }
}

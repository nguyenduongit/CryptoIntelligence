import SwiftUI
import Observation

@Observable
public final class BubblePhysicsEngine: @unchecked Sendable {
    public var bubbles: [BubbleNode] = []
    public var bounds: CGSize = .zero
    
    private var simulationTime: Double = 0
    private let minRadius: CGFloat = 22.0
    private let maxRadius: CGFloat = 78.0
    private let padding: CGFloat = 3.5
    
    public init() {}
    
    // MARK: - Update Data & Recompute Radii
    public func update(
        with tickers: [MarketTicker24h],
        metric: BubbleSizingMetric,
        in canvasSize: CGSize
    ) {
        guard canvasSize.width > 50 && canvasSize.height > 50 else { return }
        self.bounds = canvasSize
        
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let existingMap = Dictionary(uniqueKeysWithValues: bubbles.map { ($0.id, $0) })
        
        // 1. Calculate min and max metric values for scaling
        let values: [Double] = tickers.map { t in
            switch metric {
            case .marketCap:
                return max(1_000, t.estimatedMarketCap)
            case .volume24h:
                return max(1_000, t.quoteVolume)
            case .priceChange:
                return max(0.2, abs(t.priceChangePercent))
            }
        }
        
        let minVal = values.min() ?? 1.0
        let maxVal = values.max() ?? 100.0
        let sqrtMin = sqrt(minVal)
        let sqrtMax = sqrt(maxVal)
        let range = max(1e-5, sqrtMax - sqrtMin)
        
        // 2. Build or update nodes
        var updatedNodes: [BubbleNode] = []
        updatedNodes.reserveCapacity(tickers.count)
        
        for (index, ticker) in tickers.enumerated() {
            let val: Double
            switch metric {
            case .marketCap: val = max(1_000, ticker.estimatedMarketCap)
            case .volume24h: val = max(1_000, ticker.quoteVolume)
            case .priceChange: val = max(0.2, abs(ticker.priceChangePercent))
            }
            
            // Square Root Scaling: Area is proportional to Value
            let norm = (sqrt(val) - sqrtMin) / range
            let targetR = minRadius + CGFloat(norm) * (maxRadius - minRadius)
            
            if var existing = existingMap[ticker.symbol] {
                existing.price = ticker.price
                existing.priceChangePercent = ticker.priceChangePercent
                existing.quoteVolume = ticker.quoteVolume
                existing.estimatedMarketCap = ticker.estimatedMarketCap
                existing.sector = ticker.sector
                existing.targetRadius = targetR
                // Smooth radius adjustment
                existing.radius += (targetR - existing.radius) * 0.25
                updatedNodes.append(existing)
            } else {
                // Spawn new bubble in Archimedean sunflower spiral around center
                let angle = Double(index) * 2.39996 // Golden ratio angle
                let dist = sqrt(Double(index) + 1.0) * 36.0
                let spawnX = center.x + CGFloat(cos(angle) * dist)
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
            for _ in 0..<20 {
                step(dt: 0.02)
            }
        }
    }
    
    // MARK: - Physics Simulation Step (60 FPS)
    public func step(dt: CGFloat = 0.016) {
        guard bounds.width > 50 && bounds.height > 50 && !bubbles.isEmpty else { return }
        simulationTime += Double(dt)
        
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let count = bubbles.count
        
        // 1. Center Attraction Force (Gentle Radial Gravity)
        for i in 0..<count {
            guard !bubbles[i].isPinned else { continue }
            
            let dx = center.x - bubbles[i].position.x
            let dy = center.y - bubbles[i].position.y
            let dist = sqrt(dx * dx + dy * dy)
            
            if dist > 1.0 {
                let grav = min(dist * 0.04, 3.2) * 0.40
                bubbles[i].velocity.x += (dx / dist) * grav
                bubbles[i].velocity.y += (dy / dist) * grav
            }
            
            // Organic Floating Drift
            let phase = bubbles[i].phase
            bubbles[i].velocity.x += CGFloat(sin(simulationTime * 1.3 + phase)) * 0.07
            bubbles[i].velocity.y += CGFloat(cos(simulationTime * 1.1 + phase)) * 0.07
        }
        
        // 2. Anti-Overlap Collision Resolution (2 Iterations for rock-solid stability)
        for _ in 0..<2 {
            for i in 0..<count {
                for j in (i + 1)..<count {
                    var dx = bubbles[j].position.x - bubbles[i].position.x
                    var dy = bubbles[j].position.y - bubbles[i].position.y
                    var dist = sqrt(dx * dx + dy * dy)
                    let minDist = bubbles[i].radius + bubbles[j].radius + padding
                    
                    if dist < minDist {
                        if dist < 0.001 {
                            dx = 0.1
                            dy = 0.1
                            dist = 0.1414
                        }
                        
                        let overlap = minDist - dist
                        let nx = dx / dist
                        let ny = dy / dist
                        
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
        
        // 3. Boundary Clamping & Bounce
        for i in 0..<count {
            guard !bubbles[i].isPinned else { continue }
            
            let r = bubbles[i].radius
            let minX = r + 6
            let maxX = bounds.width - r - 6
            let minY = r + 6
            let maxY = bounds.height - r - 6
            
            if bubbles[i].position.x < minX {
                bubbles[i].position.x = minX
                bubbles[i].velocity.x = abs(bubbles[i].velocity.x) * 0.5
            } else if bubbles[i].position.x > maxX {
                bubbles[i].position.x = maxX
                bubbles[i].velocity.x = -abs(bubbles[i].velocity.x) * 0.5
            }
            
            if bubbles[i].position.y < minY {
                bubbles[i].position.y = minY
                bubbles[i].velocity.y = abs(bubbles[i].velocity.y) * 0.5
            } else if bubbles[i].position.y > maxY {
                bubbles[i].position.y = maxY
                bubbles[i].velocity.y = -abs(bubbles[i].velocity.y) * 0.5
            }
        }
        
        // 4. Position Integration & Velocity Damping
        for i in 0..<count {
            guard !bubbles[i].isPinned else { continue }
            
            bubbles[i].position.x += bubbles[i].velocity.x
            bubbles[i].position.y += bubbles[i].velocity.y
            
            bubbles[i].velocity.x *= 0.88
            bubbles[i].velocity.y *= 0.88
            
            // Interpolate towards target radius
            let diffR = bubbles[i].targetRadius - bubbles[i].radius
            if abs(diffR) > 0.1 {
                bubbles[i].radius += diffR * 0.15
            }
        }
    }
    
    // MARK: - Interactive Drag & Throw Gestures
    public func startDrag(symbol: String, at point: CGPoint) {
        if let idx = bubbles.firstIndex(where: { $0.id == symbol }) {
            bubbles[idx].isPinned = true
            bubbles[idx].position = point
            bubbles[idx].velocity = .zero
        }
    }
    
    public func updateDrag(symbol: String, to point: CGPoint) {
        if let idx = bubbles.firstIndex(where: { $0.id == symbol }) {
            let prev = bubbles[idx].position
            bubbles[idx].position = point
            bubbles[idx].velocity = CGPoint(
                x: (point.x - prev.x) * 0.8,
                y: (point.y - prev.y) * 0.8
            )
        }
    }
    
    public func endDrag(symbol: String, releaseVelocity: CGPoint) {
        if let idx = bubbles.firstIndex(where: { $0.id == symbol }) {
            bubbles[idx].isPinned = false
            bubbles[idx].velocity = CGPoint(
                x: min(25, max(-25, releaseVelocity.x * 0.05)),
                y: min(25, max(-25, releaseVelocity.y * 0.05))
            )
        }
    }
}

import SwiftUI

public struct CoordinateTransform {
    public let visibleRange: ClosedRange<Double>
    public let priceRange: ClosedRange<Double>
    public let isLogScale: Bool
    
    public init(
        visibleRange: ClosedRange<Double>,
        priceRange: ClosedRange<Double>,
        isLogScale: Bool = false
    ) {
        self.visibleRange = visibleRange
        self.priceRange = priceRange
        self.isLogScale = isLogScale
    }
    
    // MARK: - X Coordinate Mapping
    public func x(forIndex index: Double, width: CGFloat) -> CGFloat {
        let span = visibleRange.upperBound - visibleRange.lowerBound
        guard span > 0 else { return 0 }
        let fraction = (index - visibleRange.lowerBound) / span
        return CGFloat(fraction) * width
    }
    
    public func index(forX x: CGFloat, width: CGFloat) -> Double {
        guard width > 0 else { return visibleRange.lowerBound }
        let fraction = Double(x / width)
        let span = visibleRange.upperBound - visibleRange.lowerBound
        return visibleRange.lowerBound + fraction * span
    }
    
    // MARK: - Y Coordinate Mapping
    public func y(forPrice price: Double, height: CGFloat) -> CGFloat {
        guard height > 0 else { return 0 }
        
        if isLogScale {
            let logMin = log10(max(priceRange.lowerBound, 1e-9))
            let logMax = log10(max(priceRange.upperBound, 1e-9))
            let logPrice = log10(max(price, 1e-9))
            let span = logMax - logMin
            guard span > 0 else { return height / 2 }
            let fraction = (logPrice - logMin) / span
            // Y is 0 at top, height at bottom
            return height * CGFloat(1.0 - fraction)
        } else {
            let span = priceRange.upperBound - priceRange.lowerBound
            guard span > 0 else { return height / 2 }
            let fraction = (price - priceRange.lowerBound) / span
            return height * CGFloat(1.0 - fraction)
        }
    }
    
    public func price(forY y: CGFloat, height: CGFloat) -> Double {
        guard height > 0 else { return priceRange.lowerBound }
        let fraction = Double(1.0 - (y / height))
        
        if isLogScale {
            let logMin = log10(max(priceRange.lowerBound, 1e-9))
            let logMax = log10(max(priceRange.upperBound, 1e-9))
            let span = logMax - logMin
            let logPrice = logMin + fraction * span
            return pow(10, logPrice)
        } else {
            let span = priceRange.upperBound - priceRange.lowerBound
            return priceRange.lowerBound + fraction * span
        }
    }
    
    // MARK: - "Nice Numbers" Grid Steps
    public static func calculateNicePriceSteps(minPrice: Double, maxPrice: Double, targetStepCount: Int = 6) -> [Double] {
        let span = maxPrice - minPrice
        guard span > 0, targetStepCount > 0 else { return [minPrice] }
        
        let rawStep = span / Double(targetStepCount)
        let exponent = floor(log10(rawStep))
        let fraction = rawStep / pow(10, exponent)
        
        let niceFraction: Double
        if fraction < 1.5 {
            niceFraction = 1.0
        } else if fraction < 3.0 {
            niceFraction = 2.0
        } else if fraction < 7.0 {
            niceFraction = 5.0
        } else {
            niceFraction = 10.0
        }
        
        let step = niceFraction * pow(10, exponent)
        let firstStep = ceil(minPrice / step) * step
        
        var steps = [Double]()
        var current = firstStep
        while current <= maxPrice + step * 0.01 {
            steps.append(current)
            current += step
        }
        
        return steps
    }
}

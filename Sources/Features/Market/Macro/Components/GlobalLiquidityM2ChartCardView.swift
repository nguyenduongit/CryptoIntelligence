import SwiftUI

public struct GlobalLiquidityM2ChartCardView: View {
    public let m2History: [GlobalLiquidityM2Point]
    
    public init(m2History: [GlobalLiquidityM2Point]) {
        self.m2History = m2History
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Card Header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "water.waves")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.cyan)
                    Text("Cung Tiền Toàn Cầu (Global M2) vs Chu Kỳ Bitcoin")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Circle().fill(AppTheme.cyan).frame(width: 6, height: 6)
                        Text("Global M2: $108.4T (ATH)")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.cyan)
                    }
                    
                    HStack(spacing: 4) {
                        Circle().fill(Color(red: 1.0, green: 0.8, blue: 0.2)).frame(width: 6, height: 6)
                        Text("BTC: ~$96,000")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(Color(red: 1.0, green: 0.8, blue: 0.2))
                    }
                }
            }
            
            // Interactive Chart Canvas
            if !m2History.isEmpty {
                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    
                    let minM2 = m2History.map { $0.globalM2Trillions }.min() ?? 80.0
                    let maxM2 = m2History.map { $0.globalM2Trillions }.max() ?? 110.0
                    let spanM2 = max(1.0, maxM2 - minM2)
                    
                    let minBTC = m2History.map { $0.btcPriceUSD }.min() ?? 5000.0
                    let maxBTC = m2History.map { $0.btcPriceUSD }.max() ?? 100000.0
                    let spanBTC = max(1.0, maxBTC - minBTC)
                    
                    ZStack(alignment: .bottomLeading) {
                        // Background horizontal grid lines
                        VStack(spacing: 0) {
                            ForEach(0..<4) { _ in
                                Spacer()
                                Divider().background(AppTheme.darkBorder.opacity(0.4))
                            }
                        }
                        
                        // 1. Global M2 Area & Line Path (Cyan)
                        Path { path in
                            for (index, pt) in m2History.enumerated() {
                                let x = (CGFloat(index) / CGFloat(m2History.count - 1)) * w
                                let normY = CGFloat((pt.globalM2Trillions - minM2) / spanM2)
                                let y = h - (normY * (h - 24)) - 12
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(AppTheme.cyan, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                        
                        // 2. Bitcoin Price Line Path (Gold/Amber)
                        Path { path in
                            for (index, pt) in m2History.enumerated() {
                                let x = (CGFloat(index) / CGFloat(m2History.count - 1)) * w
                                let normY = CGFloat((pt.btcPriceUSD - minBTC) / spanBTC)
                                let y = h - (normY * (h - 24)) - 12
                                
                                if index == 0 {
                                    path.move(to: CGPoint(x: x, y: y))
                                } else {
                                    path.addLine(to: CGPoint(x: x, y: y))
                                }
                            }
                        }
                        .stroke(
                            Color(red: 1.0, green: 0.8, blue: 0.2),
                            style: StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round, dash: [4, 2])
                        )
                        
                        // Quarter Labels along X axis
                        HStack {
                            ForEach(m2History) { pt in
                                Text(pt.dateString)
                                    .font(.system(size: 8, design: .monospaced))
                                    .foregroundColor(.white.opacity(0.4))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.top, h - 14)
                    }
                }
                .frame(height: 140)
            }
            
            // Insight Footnote
            HStack(spacing: 6) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 10))
                    .foregroundColor(AppTheme.warningYellow)
                Text("Cung tiền Global M2 tăng trưởng lập đỉnh mới $108.4T là động lực vĩ mô chính đẩy giá Bitcoin (độ trễ tương quan ~70-90 ngày).")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.75))
            }
            .padding(8)
            .background(AppTheme.darkBackground.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

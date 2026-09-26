import SwiftUI

public struct MacroIndexKLineChartView: View {
    @Binding var selectedIndex: MacroIndexType
    @Binding var selectedTimeframe: String
    
    @State private var candles: [MacroIndexCandle] = []
    @State private var isLoading: Bool = false
    
    private let timeframes = ["1h", "4h", "1d", "1w"]
    
    public init(
        selectedIndex: Binding<MacroIndexType> = .constant(.total),
        selectedTimeframe: Binding<String> = .constant("1d")
    ) {
        self._selectedIndex = selectedIndex
        self._selectedTimeframe = selectedTimeframe
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. Top Controls Bar: Index Selector & Timeframe Picker
            HStack(spacing: 8) {
                // Index Selector Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(MacroIndexType.allCases) { idx in
                            Button(action: {
                                selectedIndex = idx
                                loadCandles()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: idx.iconName)
                                        .font(.system(size: 10))
                                    Text(idx.shortName)
                                        .font(.system(size: 11, weight: selectedIndex == idx ? .bold : .medium))
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(selectedIndex == idx ? AppTheme.accentBlue : AppTheme.darkCard)
                                .foregroundColor(selectedIndex == idx ? .white : .white.opacity(0.7))
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6)
                                        .stroke(selectedIndex == idx ? AppTheme.accentBlue : AppTheme.darkBorder, lineWidth: 1)
                                )
                                .contentShape(RoundedRectangle(cornerRadius: 6))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
                
                // Timeframe Picker
                HStack(spacing: 4) {
                    ForEach(timeframes, id: \.self) { tf in
                        Button(action: {
                            selectedTimeframe = tf
                            loadCandles()
                        }) {
                            Text(tf.uppercased())
                                .font(.system(size: 11, weight: selectedTimeframe.lowercased() == tf ? .bold : .medium, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(selectedTimeframe.lowercased() == tf ? Color.white.opacity(0.15) : Color.white.opacity(0.001))
                                .foregroundColor(selectedTimeframe.lowercased() == tf ? .white : .white.opacity(0.5))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .contentShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(2)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
            }
            
            // 2. OHLC HUD Info Bar
            if let lastCandle = candles.last {
                HStack(spacing: 14) {
                    HStack(spacing: 4) {
                        Text(selectedIndex.displayName)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        Text("(\(selectedTimeframe.uppercased()))")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    
                    HStack(spacing: 8) {
                        Text("O: \(formatVal(lastCandle.open))")
                        Text("H: \(formatVal(lastCandle.high))")
                        Text("L: \(formatVal(lastCandle.low))")
                        Text("C: \(formatVal(lastCandle.close))")
                            .foregroundColor(lastCandle.isBullish ? AppTheme.upGreen : AppTheme.downRed)
                    }
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.warningYellow).frame(width: 6, height: 6)
                            Text("EMA 20").font(.system(size: 10)).foregroundColor(.white.opacity(0.6))
                        }
                        HStack(spacing: 4) {
                            Circle().fill(AppTheme.cyan).frame(width: 6, height: 6)
                            Text("EMA 50").font(.system(size: 10)).foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.02))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // 3. Candlestick Canvas Area (Flexible Height)
            ZStack {
                if isLoading && candles.isEmpty {
                    ProgressView()
                        .controlSize(.regular)
                } else if !candles.isEmpty {
                    GeometryReader { geo in
                        let w = geo.size.width
                        let h = geo.size.height
                        let minVal = candles.map { $0.low }.min() ?? 1.0
                        let maxVal = candles.map { $0.high }.max() ?? 2.0
                        let range = max(0.0001, maxVal - minVal)
                        let candleWidth = max(3.0, (w / CGFloat(candles.count)) * 0.7)
                        let stepX = w / CGFloat(candles.count)
                        
                        // Background Grid Lines
                        Path { path in
                            for i in 1...4 {
                                let y = h * CGFloat(i) / 5.0
                                path.move(to: CGPoint(x: 0, y: y))
                                path.addLine(to: CGPoint(x: w, y: y))
                            }
                        }
                        .stroke(Color.white.opacity(0.05), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        
                        // EMA 20 line
                        let ema20 = calculateEMA(period: 20)
                        Path { path in
                            for (idx, val) in ema20.enumerated() {
                                let x = CGFloat(idx) * stepX + (stepX / 2.0)
                                let y = h * CGFloat(1.0 - (val - minVal) / range)
                                if idx == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(AppTheme.warningYellow.opacity(0.8), lineWidth: 1.5)
                        
                        // EMA 50 line
                        let ema50 = calculateEMA(period: 50)
                        Path { path in
                            for (idx, val) in ema50.enumerated() {
                                let x = CGFloat(idx) * stepX + (stepX / 2.0)
                                let y = h * CGFloat(1.0 - (val - minVal) / range)
                                if idx == 0 { path.move(to: CGPoint(x: x, y: y)) }
                                else { path.addLine(to: CGPoint(x: x, y: y)) }
                            }
                        }
                        .stroke(AppTheme.cyan.opacity(0.8), lineWidth: 1.5)
                        
                        // Candlestick Bodies & Wicks
                        ForEach(Array(candles.enumerated()), id: \.offset) { idx, c in
                            let xCenter = CGFloat(idx) * stepX + (stepX / 2.0)
                            let yHigh = h * CGFloat(1.0 - (c.high - minVal) / range)
                            let yLow = h * CGFloat(1.0 - (c.low - minVal) / range)
                            let yOpen = h * CGFloat(1.0 - (c.open - minVal) / range)
                            let yClose = h * CGFloat(1.0 - (c.close - minVal) / range)
                            let topY = min(yOpen, yClose)
                            let bodyHeight = max(1.5, abs(yOpen - yClose))
                            let color = c.isBullish ? AppTheme.upGreen : AppTheme.downRed
                            
                            // Wick line
                            Path { path in
                                path.move(to: CGPoint(x: xCenter, y: yHigh))
                                path.addLine(to: CGPoint(x: xCenter, y: yLow))
                            }
                            .stroke(color, lineWidth: 1)
                            
                            // Candle Body
                            Rectangle()
                                .fill(color)
                                .frame(width: candleWidth, height: bodyHeight)
                                .position(x: xCenter, y: topY + (bodyHeight / 2.0))
                        }
                    }
                } else {
                    Text("Đang kết nối luồng nến vĩ mô...")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .frame(minHeight: 480, maxHeight: 560)
            .background(Color.black.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(AppTheme.darkBorder, lineWidth: 1))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
        .onAppear {
            loadCandles()
        }
        .onChange(of: selectedIndex) { _, _ in
            loadCandles()
        }
        .onChange(of: selectedTimeframe) { _, _ in
            loadCandles()
        }
    }
    
    private func loadCandles() {
        isLoading = true
        Task { @MainActor in
            let fetched = await MacroIndicesDataProvider.shared.fetchIndexCandles(
                index: selectedIndex,
                timeframe: selectedTimeframe
            )
            self.candles = fetched
            self.isLoading = false
        }
    }
    
    private func calculateEMA(period: Int) -> [Double] {
        guard !candles.isEmpty else { return [] }
        var result: [Double] = []
        let k = 2.0 / Double(period + 1)
        var ema = candles[0].close
        
        for c in candles {
            ema = (c.close * k) + (ema * (1.0 - k))
            result.append(ema)
        }
        return result
    }
    
    private func formatVal(_ val: Double) -> String {
        if selectedIndex.isPercentage {
            return String(format: "%.2f%%", val)
        } else if val >= 1_000_000_000_000 {
            return String(format: "$%.2fT", val / 1_000_000_000_000)
        } else if val >= 1_000_000_000 {
            return String(format: "$%.1fB", val / 1_000_000_000)
        } else {
            return String(format: "$%.2f", val)
        }
    }
}

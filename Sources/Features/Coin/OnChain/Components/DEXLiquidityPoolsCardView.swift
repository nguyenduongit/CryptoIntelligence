import SwiftUI

public struct DEXLiquidityPoolsCardView: View {
    public let pools: [DEXPoolData]
    public let totalDEXLiquidityUSD: Double
    
    public init(pools: [DEXPoolData], totalDEXLiquidityUSD: Double) {
        self.pools = pools
        self.totalDEXLiquidityUSD = totalDEXLiquidityUSD
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(AppTheme.cyan)
                    .font(.system(size: 13))
                Text("DANH SÁCH POOL THANH KHOẢN AMM TRÊN SÀN DEX")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("Tổng TVL DEX: \(Formatters.formatVolume(totalDEXLiquidityUSD)) USD")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(AppTheme.cyan)
            }
            
            if pools.isEmpty {
                Text("Chưa tìm thấy pool thanh khoản DEX lớn nào cho tài sản này.")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.vertical, 8)
            } else {
                // Table Header
                HStack(spacing: 8) {
                    Text("SÀN DEX / CHAIN")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 140, alignment: .leading)
                    
                    Text("CẶP GHÉP")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 110, alignment: .leading)
                    
                    Text("THANH KHOẢN (TVL)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 120, alignment: .trailing)
                    
                    Text("VOLUME 24H")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 100, alignment: .trailing)
                    
                    Text("GIAO DỊCH 24H (MUA/BÁN)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    
                    Text("XEM")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                        .frame(width: 40, alignment: .center)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Rows
                VStack(spacing: 4) {
                    ForEach(pools) { pool in
                        HStack(spacing: 8) {
                            // DEX & Chain
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(chainColor(pool.chainId))
                                    .frame(width: 7, height: 7)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(pool.dexName)
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundColor(.white)
                                    Text(pool.chainId)
                                        .font(.system(size: 9))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .frame(width: 140, alignment: .leading)
                            
                            // Pair
                            Text("\(pool.baseSymbol) / \(pool.quoteSymbol)")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(AppTheme.accentBlue)
                                .frame(width: 110, alignment: .leading)
                            
                            // TVL
                            Text(Formatters.formatVolume(pool.liquidityUSD) + " USD")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundColor(.white)
                                .frame(width: 120, alignment: .trailing)
                            
                            // 24h Vol
                            Text(Formatters.formatVolume(pool.volume24hUSD) + " USD")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                                .frame(width: 100, alignment: .trailing)
                            
                            // Buys / Sells
                            HStack(spacing: 4) {
                                Text("\(pool.txns24hBuys) 🟢")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(AppTheme.upGreen)
                                Text("/")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("\(pool.txns24hSells) 🔴")
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(AppTheme.downRed)
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            // Link button
                            Button(action: {
                                if let url = URL(string: pool.url) {
                                    NSWorkspace.shared.open(url)
                                }
                            }) {
                                Image(systemName: "arrow.up.right.square")
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.accentBlue)
                            }
                            .buttonStyle(.plain)
                            .frame(width: 40, alignment: .center)
                            .help("Mở Pool trên DexScreener")
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(AppTheme.darkCard.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }
            }
        }
        .padding(12)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppTheme.darkBorder, lineWidth: 1))
    }
    
    private func chainColor(_ chain: String) -> Color {
        switch chain.lowercased() {
        case "ethereum": return Color(red: 0.38, green: 0.49, blue: 0.95)
        case "solana": return Color(red: 0.1, green: 0.85, blue: 0.6)
        case "bsc", "binance": return Color(red: 0.95, green: 0.75, blue: 0.1)
        case "base": return Color(red: 0.0, green: 0.5, blue: 1.0)
        case "arbitrum": return Color(red: 0.18, green: 0.63, blue: 0.95)
        default: return AppTheme.accentBlue
        }
    }
}

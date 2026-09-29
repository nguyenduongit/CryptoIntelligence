import SwiftUI

/// Shown when DexScreener returned no usable pools for an asset (API error, timeout,
/// or the asset simply has no meaningful DEX liquidity). Never substitute made-up numbers here.
public struct DexDataUnavailableCardView: View {
    public let symbol: String
    
    public init(symbol: String) {
        self.symbol = symbol
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 22))
                .foregroundColor(.white.opacity(0.5))
            Text("Không có dữ liệu DEX cho \(symbol)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            Text("DexScreener không trả về pool đủ thanh khoản (lỗi mạng, hết thời gian chờ, hoặc coin không có thanh khoản DEX đáng kể). Ứng dụng không hiển thị số liệu thay thế.")
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.55))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(16)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

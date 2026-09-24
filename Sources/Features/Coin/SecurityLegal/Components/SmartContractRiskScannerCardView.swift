import SwiftUI

public struct SmartContractRiskScannerCardView: View {
    public let scan: SmartContractSafetyScan
    
    public init(scan: SmartContractSafetyScan) {
        self.scan = scan
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 13))
                        .foregroundColor(AppTheme.upGreen)
                    Text("Trình Quét An Toàn Hợp Đồng Thông Minh (Contract Safety Scan)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle().fill(AppTheme.upGreen).frame(width: 5, height: 5)
                    Text("Tự động quét De.Fi/GoPlus Engine")
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.upGreen)
                }
            }
            
            // 6 Security Checks Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                checkItem(
                    title: "Bẫy Honeypot",
                    isSafe: !scan.isHoneypot,
                    safeLabel: "Không phát hiện",
                    dangerLabel: "Nguy hiểm (Không thể bán)"
                )
                
                checkItem(
                    title: "Hàm Mint Vô Hạn",
                    isSafe: !scan.canMint,
                    safeLabel: "Không có quyền Mint",
                    dangerLabel: "Có thể in thêm token"
                )
                
                checkItem(
                    title: "Hàm Blacklist Địa Chỉ",
                    isSafe: !scan.isBlacklistable,
                    safeLabel: "Không thể chặn ví",
                    dangerLabel: "Có quyền đóng băng ví"
                )
                
                checkItem(
                    title: "Thuế Mua (Buy Tax)",
                    isSafe: scan.buyTaxPercent == 0,
                    safeLabel: "0.0% (Miễn phí)",
                    dangerLabel: "\(String(format: "%.1f%%", scan.buyTaxPercent)) Thuế"
                )
                
                checkItem(
                    title: "Thuế Bán (Sell Tax)",
                    isSafe: scan.sellTaxPercent == 0,
                    safeLabel: "0.0% (Miễn phí)",
                    dangerLabel: "\(String(format: "%.1f%%", scan.sellTaxPercent)) Thuế"
                )
                
                checkItem(
                    title: "Mã Nguồn Mở Verified",
                    isSafe: scan.isOpenSourceVerified,
                    safeLabel: "Đã xác minh 100%",
                    dangerLabel: "Chưa xác minh"
                )
            }
            
            // Summary Banner
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 12))
                    .foregroundColor(AppTheme.cyan)
                    .padding(.top, 1)
                Text(scan.scanSummary)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.8))
                    .lineSpacing(2)
            }
            .padding(10)
            .background(AppTheme.darkBackground.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
    
    private func checkItem(title: String, isSafe: Bool, safeLabel: String, dangerLabel: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: isSafe ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                .font(.system(size: 14))
                .foregroundColor(isSafe ? AppTheme.upGreen : AppTheme.downRed)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.white)
                Text(isSafe ? safeLabel : dangerLabel)
                    .font(.system(size: 10))
                    .foregroundColor(isSafe ? AppTheme.upGreen : AppTheme.downRed)
            }
            Spacer()
        }
        .padding(8)
        .background(AppTheme.darkBackground.opacity(0.4))
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke((isSafe ? AppTheme.upGreen : AppTheme.downRed).opacity(0.2), lineWidth: 1)
        )
    }
}

import SwiftUI
import GRDB

public struct SettingsView: View {
    @Bindable var router: NavigationRouter
    
    @State private var primaryURL: String = "https://data-api.binance.vision"
    @State private var fallbackURL: String = "https://api.binance.com"
    @State private var pingStatus: String = "Chưa kiểm tra"
    @State private var isPinging: Bool = false
    @State private var cacheClearedMessage: String? = nil
    
    public init(router: NavigationRouter) {
        self.router = router
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title
                Text("Cài đặt Hệ thống")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                // Section 1: Data Provider Endpoints
                VStack(alignment: .leading, spacing: 14) {
                    Text("Cấu hình API Binance")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.accentBlue)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Primary Base URL (Khuyên dùng)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        TextField("Primary URL", text: $primaryURL)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Fallback Base URL (Dự phòng)")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        TextField("Fallback URL", text: $fallbackURL)
                            .textFieldStyle(.roundedBorder)
                    }
                    
                    HStack(spacing: 12) {
                        Button(action: testEndpoints) {
                            HStack(spacing: 6) {
                                if isPinging {
                                    ProgressView().controlSize(.small)
                                } else {
                                    Image(systemName: "bolt.horizontal.fill")
                                }
                                Text("Kiểm tra kết nối (Ping)")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.accentBlue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        .disabled(isPinging)
                        
                        Text(pingStatus)
                            .font(.system(size: 12, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(20)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // Section 2: Storage & Cache Management
                VStack(alignment: .leading, spacing: 14) {
                    Text("Lưu trữ & Bộ nhớ tạm (SQLite)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.purple)
                    
                    Text("Cơ sở dữ liệu SQLite cục bộ được quản lý bởi GRDB.swift tại thư mục Application Support.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 12) {
                        Button(action: clearCandleCache) {
                            HStack(spacing: 6) {
                                Image(systemName: "trash.fill")
                                Text("Xóa toàn bộ Cache Nến")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(AppTheme.downRed.opacity(0.8))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                        .buttonStyle(.plain)
                        
                        if let msg = cacheClearedMessage {
                            Text(msg)
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.upGreen)
                        }
                    }
                }
                .padding(20)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // Section 3: Rate Limiter Stats
                VStack(alignment: .leading, spacing: 14) {
                    Text("Trạng thái Rate Limiter")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AppTheme.warningYellow)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Request Weight 1m:")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("\(router.usedWeight1m) / \(router.maxWeight1m)")
                                .font(.system(size: 18, weight: .bold, design: .monospaced))
                                .foregroundColor(AppTheme.upGreen)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("An toàn Token Bucket:")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.6))
                            Text("< 50% trần sàn (3.000 max)")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(20)
                .background(AppTheme.darkSurface)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
            }
            .padding(24)
        }
        .background(AppTheme.darkBackground)
    }
    
    private func testEndpoints() {
        isPinging = true
        pingStatus = "Đang kiểm tra..."
        
        Task {
            let start = CFAbsoluteTimeGetCurrent()
            do {
                guard let url = URL(string: "\(primaryURL)/api/v3/ping") else { return }
                var req = URLRequest(url: url)
                req.timeoutInterval = 5.0
                let (_, resp) = try await URLSession.shared.data(for: req)
                let elapsed = Int((CFAbsoluteTimeGetCurrent() - start) * 1000)
                
                if let http = resp as? HTTPURLResponse, http.statusCode == 200 {
                    await MainActor.run {
                        self.pingStatus = "Thành công: \(elapsed)ms (HTTP 200)"
                        self.isPinging = false
                    }
                } else {
                    await MainActor.run {
                        self.pingStatus = "Lỗi phản hồi HTTP"
                        self.isPinging = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.pingStatus = "Lỗi kết nối: \(error.localizedDescription)"
                    self.isPinging = false
                }
            }
        }
    }
    
    private func clearCandleCache() {
        do {
            try DatabaseManager.shared.dbQueue.write { db in
                _ = try CandleRecord.deleteAll(db)
            }
            cacheClearedMessage = "Đã xóa toàn bộ cache nến khỏi SQLite."
        } catch {
            cacheClearedMessage = "Lỗi xóa cache: \(error)"
        }
    }
}

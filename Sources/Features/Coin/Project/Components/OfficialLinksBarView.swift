import SwiftUI
import AppKit

public struct OfficialLinksBarView: View {
    public let links: [OfficialResourceLink]
    public let partners: [EcosystemPartner]
    
    public init(links: [OfficialResourceLink], partners: [EcosystemPartner]) {
        self.links = links
        self.partners = partners
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. Ecosystem Partners
            if !partners.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Image(systemName: "network")
                            .foregroundColor(AppTheme.cyan)
                            .font(.system(size: 12))
                        Text("Đối Tác & Ứng Dụng Tiêu Biểu Hệ Sinh Thái:")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 8) {
                        ForEach(partners) { partner in
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(AppTheme.accentBlue)
                                    .frame(width: 6, height: 6)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(partner.name)
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.white)
                                    Text(partner.category)
                                        .font(.system(size: 9))
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(AppTheme.darkHeaderBg)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AppTheme.darkBorder, lineWidth: 1)
                            )
                        }
                    }
                }
                
                Divider()
                    .background(AppTheme.darkBorder)
            }
            
            // 2. Official Resource Links Buttons
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(AppTheme.accentBlue)
                        .font(.system(size: 12))
                    Text("Tài Nguyên & Liên Kết Chính Thức:")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 8) {
                    ForEach(links) { link in
                        Button(action: {
                            if let url = URL(string: link.url) {
                                NSWorkspace.shared.open(url)
                            }
                        }) {
                            HStack(spacing: 5) {
                                Image(systemName: link.iconName)
                                    .font(.system(size: 11))
                                Text(link.title)
                                    .font(.system(size: 11, weight: .medium))
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 8))
                                    .foregroundColor(.white.opacity(0.4))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(AppTheme.darkHeaderBg)
                            .foregroundColor(.white.opacity(0.9))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(AppTheme.darkBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(14)
        .background(AppTheme.darkCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
    }
}

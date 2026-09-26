import SwiftUI

public struct ProfileView: View {
    public let symbol: String
    @State private var viewModel: ProfileViewModel
    
    private let sections: [SubtabSectionItem] = [
        SubtabSectionItem(id: "teamVcs", title: "Thông Tin & Đội Ngũ", iconName: "person.2.crop.square.stack.fill"),
        SubtabSectionItem(id: "securityAudit", title: "Kiểm Toán & Cờ Đỏ Bảo Mật", iconName: "shield.checkered"),
        SubtabSectionItem(id: "legalRoadmap", title: "Pháp Lý & Lộ Trình", iconName: "building.columns.fill")
    ]
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: ProfileViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.projectProfile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tải hồ sơ dự án & kiểm toán bảo mật cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let project = viewModel.projectProfile, let sec = viewModel.securityProfile {
                    // Header Status Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hồ Sơ Dự Án, Đội Ngũ & Báo Cáo Kiểm Toán (\(symbol))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Thẩm định uy tín nhà sáng lập, các quỹ VC hậu thuẫn, kiểm tra mã độc Smart Contract và tình trạng pháp lý.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .liveCoinGecko, text: "GitHub Dev & DeFiLlama VCs")
                        DataSourceBadge(type: .liveCoinGecko, text: "CertiK / Etherscan Audited")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // Sub-navigation Section Selector
                    SubtabSectionSelector(items: sections, selectedId: $viewModel.selectedSectionId)
                    
                    // Dynamic Module Rendering
                    switch viewModel.selectedSectionId {
                    case "teamVcs":
                        // 1. Project Overview & Architecture
                        ProjectHeaderOverviewCardView(profile: project)
                        
                        // 2. Official Resource Links & Partners Bar
                        OfficialLinksBarView(links: project.officialLinks, partners: project.partners)
                        
                        // 3. Core Founders & Team
                        CoreTeamGridView(founders: project.founders)
                        
                        // 4. GitHub Developer Activity
                        DeveloperActivityCardView(metrics: project.developerActivity)
                        
                    case "securityAudit":
                        // 1. Security Score Banner
                        SecurityScoreBannerView(profile: sec)
                        
                        // 2. Smart Contract Risk Scanner (Red Flags)
                        SmartContractRiskScannerCardView(scan: sec.contractScan)
                        
                        // 3. Audit Reports (CertiK, OpenZeppelin, etc.)
                        AuditReportsCardView(audits: sec.audits)
                        
                        // 4. Bug Bounty & Insurance
                        BugBountyInsuranceCardView(bugBounty: sec.bugBounty)
                        
                    case "legalRoadmap":
                        // 1. Regulatory Compliance (SEC, MiCA)
                        RegulatoryComplianceCardView(compliance: sec.regulatory)
                        
                        // 2. Project Roadmap Timeline
                        ProjectRoadmapTimelineView(roadmap: project.roadmap)
                        
                        // 3. Competitor Benchmark Matrix
                        CompetitorBenchmarkMatrixCardView(competitors: project.competitors)
                        
                    default:
                        EmptyView()
                    }
                } else if let err = viewModel.errorMessage {
                    DataUnavailableView(
                        title: "Hồ Sơ Dự Án & Bảo Mật",
                        symbol: symbol,
                        iconName: "person.2.crop.square.stack.fill",
                        message: err,
                        onRetry: { viewModel.loadData() }
                    )
                } else {
                    DataUnavailableView(
                        title: "Hồ Sơ Dự Án & Bảo Mật",
                        symbol: symbol,
                        iconName: "person.2.crop.square.stack.fill",
                        onRetry: { viewModel.loadData() }
                    )
                }
            }
            .padding(14)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            viewModel.loadData()
        }
        .onChange(of: symbol) { _, newSym in
            viewModel.setSymbol(newSym)
        }
    }
}

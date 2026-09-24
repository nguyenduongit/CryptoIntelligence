import SwiftUI

public struct ProjectProfileView: View {
    public let symbol: String
    @State private var viewModel: ProjectViewModel
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: ProjectViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang tải hồ sơ dự án \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // Header Status Banner
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Hồ Sơ Dự Án & Nền Tảng Kỹ Thuật (\(symbol))")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                            Text("Kiến trúc công nghệ, đội ngũ sáng lập, đối thủ cạnh tranh và lộ trình phát triển.")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        
                        Spacer()
                        
                        DataSourceBadge(type: .simulatedCatalog, text: "Hồ Sơ Dự Án")
                    }
                    .padding(12)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
                    
                    // 1. Project Header & Mission Card
                    ProjectHeaderOverviewCardView(profile: profile)
                    
                    // 2. Technical Architecture Card
                    TechnicalArchitectureCardView(architecture: profile.technicalArchitecture)
                    
                    // 3. Founders & Core Team
                    CoreTeamGridView(founders: profile.founders)
                    
                    // 4. Competitor Benchmark Matrix
                    if !profile.competitors.isEmpty {
                        CompetitorBenchmarkMatrixCardView(competitors: profile.competitors)
                    }
                    
                    // 5. Open Source Developer Activity
                    DeveloperActivityCardView(metrics: profile.developerActivity)
                    
                    // 6. Roadmap & Milestones
                    ProjectRoadmapTimelineView(roadmap: profile.roadmap)
                    
                    // 7. Official Resources & Ecosystem Partners
                    OfficialLinksBarView(
                        links: profile.officialLinks,
                        partners: profile.partners
                    )
                } else if let err = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(AppTheme.warningYellow)
                        Text(err)
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                        Button("Thử lại") {
                            viewModel.loadData()
                        }
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(AppTheme.accentBlue)
                    }
                    .frame(maxWidth: .infinity, minHeight: 250)
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

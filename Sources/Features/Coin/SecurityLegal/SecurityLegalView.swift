import SwiftUI

public struct SecurityLegalView: View {
    public let symbol: String
    @State private var viewModel: SecurityLegalViewModel
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: SecurityLegalViewModel(symbol: symbol))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                if viewModel.isLoading && viewModel.profile == nil {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text("Đang phân tích hồ sơ bảo mật & pháp lý cho \(symbol)...")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                } else if let profile = viewModel.profile {
                    // 1. Security Score & Overall Rating Banner
                    SecurityScoreBannerView(profile: profile)
                    
                    // 2. Automated Smart Contract Safety Scanner
                    SmartContractRiskScannerCardView(scan: profile.contractScan)
                    
                    // 3. Security Audits Grid
                    AuditReportsCardView(audits: profile.audits)
                    
                    // 4. Governance & Admin Key Risks
                    GovernanceDecentralizationCardView(risks: profile.governanceRisks)
                    
                    // 5. Regulatory Compliance (SEC, MiCA, CFTC)
                    RegulatoryComplianceCardView(compliance: profile.regulatory)
                    
                    // 6. Bug Bounty & Exploit History
                    BugBountyInsuranceCardView(bugBounty: profile.bugBounty)
                } else if !viewModel.isLoading {
                    DataUnavailableView(
                        symbol: symbol,
                        moduleName: "Bảo Mật Smart Contract & Tuân Thủ Pháp Lý",
                        retryAction: {
                            viewModel.loadData()
                        }
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

import Foundation
import GRDB

public actor NotesDataProvider {
    public static let shared = NotesDataProvider()
    
    private let dbQueue: DatabaseQueue
    
    public init(databaseManager: DatabaseManager = .shared) {
        self.dbQueue = databaseManager.dbQueue
    }
    
    public func fetchNotes(for symbol: String) async throws -> [ResearchNote] {
        let cleanSymbol = symbol.uppercased()
        
        let records = try await dbQueue.read { db in
            try ResearchNoteRecord
                .filter(Column("symbol") == cleanSymbol)
                .order(Column("isPinned").desc, Column("updatedAt").desc)
                .fetchAll(db)
        }
        
        if records.isEmpty {
            // Seed initial analysis notes for this coin so the user has immediate rich context
            try await seedInitialNotes(for: cleanSymbol)
            return try await dbQueue.read { db in
                try ResearchNoteRecord
                    .filter(Column("symbol") == cleanSymbol)
                    .order(Column("isPinned").desc, Column("updatedAt").desc)
                    .fetchAll(db)
            }.compactMap { $0.toModel() }
        }
        
        return records.compactMap { $0.toModel() }
    }
    
    public func saveNote(_ note: ResearchNote) async throws {
        var mutableNote = note
        mutableNote.updatedAt = Date()
        let record = ResearchNoteRecord(note: mutableNote)
        
        try await dbQueue.write { db in
            try record.save(db)
        }
    }
    
    public func deleteNote(id: UUID) async throws {
        let idStr = id.uuidString
        try await dbQueue.write { db in
            _ = try ResearchNoteRecord.deleteOne(db, key: idStr)
        }
    }
    
    public func togglePin(id: UUID) async throws {
        let idStr = id.uuidString
        try await dbQueue.write { db in
            if var record = try ResearchNoteRecord.fetchOne(db, key: idStr) {
                record.isPinned.toggle()
                record.updatedAt = Date()
                try record.update(db)
            }
        }
    }
    
    private func seedInitialNotes(for symbol: String) async throws {
        let baseAsset = symbol.replacingOccurrences(of: "USDT", with: "")
        let initialNotes: [ResearchNote]
        
        switch baseAsset {
        case "BTC":
            initialNotes = [
                ResearchNote(
                    symbol: symbol,
                    title: "Luận điểm đầu tư Halving Cycle 2024-2026",
                    content: """
                    ### Tóm tắt Luận điểm
                    - **Yếu tố Vĩ mô:** Dòng vốn từ các quỹ ETF Spot (BlackRock, Fidelity) liên tục gom ròng với tốc độ trung bình 2.000 - 5.000 BTC/ngày, vượt xa lượng phát hành mới 450 BTC/ngày sau Halving.
                    - **Chu kỳ Thanh khoản:** M2 toàn cầu đang đảo chiều tăng trưởng, chu kỳ nới lỏng tiền tệ của Fed tạo động lực cho các tài sản rủi ro.
                    - **Chiến lược:** Tích lũy vùng $58.000 - $64.000, chốt lời từng phần tại các mốc kháng cự Fibonacci extension.
                    """,
                    sentiment: .bullish,
                    tags: ["Thesis", "Macro", "ETF", "Halving"],
                    targetPrice: 125000,
                    stopLoss: 52000,
                    timeHorizon: "Dài hạn (6-24 tháng)",
                    isPinned: true
                ),
                ResearchNote(
                    symbol: symbol,
                    title: "Quan sát On-chain: Hành vi của Long-term Holders (LTH)",
                    content: """
                    Chỉ số LTH SOPR duy trì ở ngưỡng an toàn, chưa ghi nhận làn sóng phân phối chốt lời ồ ạt từ các ví cá voi cổ xưa (>3 năm). Dự trữ trên các sàn CEX tiếp tục chạm đáy 5 năm qua.
                    """,
                    sentiment: .bullish,
                    tags: ["On-chain", "Whales"],
                    targetPrice: 98000,
                    stopLoss: 55000,
                    timeHorizon: "Trung hạn (1-6 tháng)",
                    isPinned: false
                )
            ]
            
        case "ETH":
            initialNotes = [
                ResearchNote(
                    symbol: symbol,
                    title: "Đánh giá Nâng cấp Pectra & Lớp Thanh Toán Toàn Cầu",
                    content: """
                    ### Phân tích Cơ bản
                    - **Pectra Upgrade:** Tăng giới hạn stake từ 32 lên 2.048 ETH cho mỗi validator, tối ưu hóa kích thước mạng lưới và giảm áp lực gossip protocol.
                    - **Layer 2 Dominance:** Base, Arbitrum, Optimism tiếp tục dẫn đầu về TVL và giao dịch, phí blob EIP-4844 giúp L2 có chi phí cực thấp nhưng vẫn trả phí bảo mật về Mainnet.
                    - **Rủi ro:** Cạnh tranh gay gắt về người dùng từ hệ sinh thái SVM (Solana) và Move (Sui).
                    """,
                    sentiment: .bullish,
                    tags: ["Thesis", "Layer 2", "Staking", "Pectra"],
                    targetPrice: 48000,
                    stopLoss: 2100,
                    timeHorizon: "Trung hạn (1-6 tháng)",
                    isPinned: true
                )
            ]
            
        case "SOL":
            initialNotes = [
                ResearchNote(
                    symbol: symbol,
                    title: "Firedancer Testnet & Khả năng mở rộng 1 Triệu TPS",
                    content: """
                    ### Điểm nhấn Công nghệ
                    - Client độc lập **Firedancer** do Jump Trading phát triển giúp giải quyết triệt để rủi ro nghẽn mạng và tăng độ đa dạng client.
                    - Khối lượng DEX giao dịch trên Solana liên tục vượt Ethereum L1 trong các giai đoạn sốt sóng meme và thanh khoản on-chain.
                    - **Kế hoạch giao dịch:** Canh nhịp retest EMA200 khung Ngày để mở vị thế Swing.
                    """,
                    sentiment: .bullish,
                    tags: ["Firedancer", "TPS", "DEX Volume", "TA"],
                    targetPrice: 280,
                    stopLoss: 120,
                    timeHorizon: "Trung hạn (1-6 tháng)",
                    isPinned: true
                )
            ]
            
        default:
            initialNotes = [
                ResearchNote(
                    symbol: symbol,
                    title: "Bản phân tích ban đầu & Kế hoạch theo dõi",
                    content: """
                    ### Kế hoạch Nghiên cứu:
                    1. Đánh giá cơ cấu phát hành token và lịch Unlock trong 6 tháng tới.
                    2. Theo dõi biến động On-chain của các ví Top 10 cá voi.
                    3. Kiểm tra tính thanh khoản trên các sàn giao dịch tập trung và phi tập trung.
                    """,
                    sentiment: .neutral,
                    tags: ["Research", "Watchlist"],
                    targetPrice: nil,
                    stopLoss: nil,
                    timeHorizon: "Trung hạn (1-6 tháng)",
                    isPinned: false
                )
            ]
        }
        
        try await dbQueue.write { db in
            for note in initialNotes {
                let record = ResearchNoteRecord(note: note)
                try record.insert(db)
            }
        }
    }
}

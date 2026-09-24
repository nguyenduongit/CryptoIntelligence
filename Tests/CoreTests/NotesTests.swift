import Testing
import Foundation
@testable import CryptoResearch

@Suite("NotesTests")
struct NotesTests {
    
    @Test("Test ResearchNote model properties and sentiments")
    func testResearchNoteModel() {
        let note = ResearchNote(
            symbol: "BTCUSDT",
            title: "Bitcoin Halving Thesis",
            content: "Bullish supply shock",
            sentiment: .bullish,
            tags: ["Thesis", "Macro"],
            targetPrice: 150000,
            stopLoss: 60000,
            timeHorizon: "12M",
            isPinned: true
        )
        
        #expect(note.symbol == "BTCUSDT")
        #expect(note.sentiment == .bullish)
        #expect(note.sentiment.shortLabel == "Bullish")
        #expect(note.tags.count == 2)
        #expect(note.targetPrice == 150000)
        #expect(note.isPinned == true)
        
        let record = ResearchNoteRecord(note: note)
        let restored = record.toModel()
        #expect(restored != nil)
        #expect(restored?.title == "Bitcoin Halving Thesis")
        #expect(restored?.tags == ["Thesis", "Macro"])
        #expect(restored?.sentiment == .bullish)
    }
    
    @Test("Test NotesDataProvider CRUD operations with in-memory database")
    func testNotesDataProviderCRUD() async throws {
        let inMemoryDB = DatabaseManager(inMemory: true)
        let provider = NotesDataProvider(databaseManager: inMemoryDB)
        
        // 1. Initial fetch triggers seeding
        let btcNotes = try await provider.fetchNotes(for: "BTCUSDT")
        #expect(!btcNotes.isEmpty)
        #expect(btcNotes.first?.symbol == "BTCUSDT")
        
        // 2. Save a custom note
        let customNote = ResearchNote(
            symbol: "BTCUSDT",
            title: "Custom Breakout Note",
            content: "Testing breakout above 70k",
            sentiment: .bullish,
            tags: ["Breakout", "TA"],
            targetPrice: 75000,
            isPinned: false
        )
        try await provider.saveNote(customNote)
        
        let updatedNotes = try await provider.fetchNotes(for: "BTCUSDT")
        #expect(updatedNotes.contains { $0.id == customNote.id })
        
        // 3. Toggle Pin
        try await provider.togglePin(id: customNote.id)
        let pinnedNotes = try await provider.fetchNotes(for: "BTCUSDT")
        let pinnedCustom = pinnedNotes.first { $0.id == customNote.id }
        #expect(pinnedCustom?.isPinned == true)
        
        // 4. Delete Note
        try await provider.deleteNote(id: customNote.id)
        let afterDelete = try await provider.fetchNotes(for: "BTCUSDT")
        #expect(!afterDelete.contains { $0.id == customNote.id })
    }
    
    @Test("Test NotesViewModel filtering and tags computation")
    @MainActor
    func testNotesViewModelFiltering() {
        let note1 = ResearchNote(
            symbol: "ETHUSDT",
            title: "Layer 2 Analysis",
            content: "Base and Arbitrum growth",
            sentiment: .bullish,
            tags: ["L2", "Ecosystem"]
        )
        let note2 = ResearchNote(
            symbol: "ETHUSDT",
            title: "Gas Fee Concerns",
            content: "Mainnet revenue decreasing",
            sentiment: .bearish,
            tags: ["Risk", "L1"]
        )
        
        let inMemoryDB = DatabaseManager(inMemory: true)
        let provider = NotesDataProvider(databaseManager: inMemoryDB)
        let vm = NotesViewModel(symbol: "ETHUSDT", dataProvider: provider)
        vm.notes = [note1, note2]
        
        #expect(vm.notes.count == 2)
        #expect(vm.bullishCount == 1)
        #expect(vm.bearishCount == 1)
        #expect(vm.allTags.contains("L2"))
        #expect(vm.allTags.contains("Risk"))
        
        // Filter by Sentiment
        vm.selectedSentimentFilter = .bullish
        #expect(vm.filteredNotes.count == 1)
        #expect(vm.filteredNotes.first?.title == "Layer 2 Analysis")
        
        // Filter by Tag
        vm.selectedSentimentFilter = nil
        vm.selectedTagFilter = "Risk"
        #expect(vm.filteredNotes.count == 1)
        #expect(vm.filteredNotes.first?.title == "Gas Fee Concerns")
        
        // Search Query
        vm.selectedTagFilter = nil
        vm.searchQuery = "Arbitrum"
        #expect(vm.filteredNotes.count == 1)
        #expect(vm.filteredNotes.first?.title == "Layer 2 Analysis")
    }
    
    @Test("Test Risk/Reward ratio calculation and export")
    @MainActor
    func testRiskRewardCalculationAndExport() {
        let inMemoryDB = DatabaseManager(inMemory: true)
        let provider = NotesDataProvider(databaseManager: inMemoryDB)
        let vm = NotesViewModel(symbol: "BTCUSDT", dataProvider: provider)
        
        vm.livePrice = 60000.0
        vm.draftTargetPriceText = "78000" // +30%
        vm.draftStopLossText = "54000" // -10%
        
        #expect(vm.upsidePercent == 30.0)
        #expect(vm.downsidePercent == 10.0)
        #expect(vm.riskRewardRatio == 3.0)
        #expect(vm.riskRewardRating.label.contains("Rất Tốt"))
    }
}

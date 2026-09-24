import Foundation
import SwiftUI
import AppKit

@MainActor
@Observable
public final class NotesViewModel {
    public var symbol: String
    public var notes: [ResearchNote] = []
    public var selectedNoteId: UUID? = nil
    public var searchQuery: String = ""
    public var selectedTagFilter: String? = nil
    public var selectedSentimentFilter: ResearchSentiment? = nil
    
    public var livePrice: Double? = nil
    public var isLoading: Bool = false
    public var isSaving: Bool = false
    public var isCopiedToastVisible: Bool = false
    public var errorMessage: String? = nil
    public var lastSavedText: String? = nil
    
    // Active note draft properties for direct binding
    public var draftTitle: String = ""
    public var draftContent: String = ""
    public var draftSentiment: ResearchSentiment = .bullish
    public var draftTags: [String] = []
    public var draftTargetPriceText: String = ""
    public var draftStopLossText: String = ""
    public var draftTimeHorizon: String = "Trung hạn (1-6 tháng)"
    public var draftIsPinned: Bool = false
    public var newTagInput: String = ""
    public var isPreviewMode: Bool = false
    
    private let dataProvider: NotesDataProvider
    private var saveTask: Task<Void, Never>? = nil
    
    public init(symbol: String, dataProvider: NotesDataProvider = .shared) {
        self.symbol = symbol
        self.dataProvider = dataProvider
    }
    
    public var filteredNotes: [ResearchNote] {
        notes.filter { note in
            let matchesSearch = searchQuery.isEmpty
                || note.title.localizedCaseInsensitiveContains(searchQuery)
                || note.content.localizedCaseInsensitiveContains(searchQuery)
                || note.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
            
            let matchesTag = selectedTagFilter == nil || note.tags.contains(selectedTagFilter!)
            let matchesSentiment = selectedSentimentFilter == nil || note.sentiment == selectedSentimentFilter
            
            return matchesSearch && matchesTag && matchesSentiment
        }
    }
    
    public var allTags: [String] {
        let tagSet = Set(notes.flatMap { $0.tags })
        return Array(tagSet).sorted()
    }
    
    public var bullishCount: Int {
        notes.filter { $0.sentiment == .bullish }.count
    }
    
    public var bearishCount: Int {
        notes.filter { $0.sentiment == .bearish }.count
    }
    
    public var selectedNote: ResearchNote? {
        guard let id = selectedNoteId else { return nil }
        return notes.first { $0.id == id }
    }
    
    // MARK: - Live Risk / Reward (R:R) Calculations
    public var targetPriceValue: Double? {
        Double(draftTargetPriceText.replacingOccurrences(of: ",", with: "."))
    }
    
    public var stopLossValue: Double? {
        Double(draftStopLossText.replacingOccurrences(of: ",", with: "."))
    }
    
    public var upsidePercent: Double? {
        guard let current = livePrice, let target = targetPriceValue, current > 0 else { return nil }
        return ((target - current) / current) * 100.0
    }
    
    public var downsidePercent: Double? {
        guard let current = livePrice, let stop = stopLossValue, current > 0 else { return nil }
        return ((current - stop) / current) * 100.0
    }
    
    public var riskRewardRatio: Double? {
        guard let up = upsidePercent, let down = downsidePercent, down > 0 else { return nil }
        return up / down
    }
    
    public var riskRewardRating: (label: String, color: Color) {
        guard let rr = riskRewardRatio else { return ("Chưa đủ thông số", .white.opacity(0.4)) }
        if rr >= 3.0 {
            return ("Tỷ lệ R:R Rất Tốt (\(String(format: "1:%.1f", rr)))", AppTheme.upGreen)
        } else if rr >= 1.8 {
            return ("Tỷ lệ R:R Hợp Lý (\(String(format: "1:%.1f", rr)))", AppTheme.accentBlue)
        } else if rr >= 1.0 {
            return ("Tỷ lệ R:R Trung Bình (\(String(format: "1:%.1f", rr)))", AppTheme.warningYellow)
        } else {
            return ("Rủi ro cao hơn lợi nhuận (\(String(format: "1:%.1f", rr)))", AppTheme.downRed)
        }
    }
    
    public func setSymbol(_ newSymbol: String) {
        guard newSymbol != symbol else { return }
        self.symbol = newSymbol
        self.selectedNoteId = nil
        loadNotes()
    }
    
    public func loadNotes() {
        isLoading = true
        errorMessage = nil
        
        Task {
            // 1. Fetch live price
            if let (price, _, _) = try? await BinanceCandleProvider.shared.fetch24hrTicker(symbol: symbol) {
                self.livePrice = price
            }
            
            // 2. Fetch notes
            do {
                let fetched = try await dataProvider.fetchNotes(for: symbol)
                self.notes = fetched
                self.isLoading = false
                if let first = fetched.first, self.selectedNoteId == nil {
                    self.selectNote(first)
                } else if let id = self.selectedNoteId, let note = fetched.first(where: { $0.id == id }) {
                    self.populateDraft(from: note)
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    public func selectNote(_ note: ResearchNote) {
        self.selectedNoteId = note.id
        populateDraft(from: note)
    }
    
    private func populateDraft(from note: ResearchNote) {
        self.draftTitle = note.title
        self.draftContent = note.content
        self.draftSentiment = note.sentiment
        self.draftTags = note.tags
        self.draftTargetPriceText = note.targetPrice != nil ? String(format: "%.2f", note.targetPrice!) : ""
        self.draftStopLossText = note.stopLoss != nil ? String(format: "%.2f", note.stopLoss!) : ""
        self.draftTimeHorizon = note.timeHorizon
        self.draftIsPinned = note.isPinned
        self.newTagInput = ""
        
        let df = DateFormatter()
        df.dateFormat = "HH:mm:ss"
        self.lastSavedText = "Đã lưu lúc \(df.string(from: note.updatedAt))"
    }
    
    public func createNewNote() {
        let newNote = ResearchNote(
            symbol: symbol,
            title: "Ghi chú phân tích mới",
            content: "Nhập nội dung luận điểm đầu tư, quan sát kỹ thuật hoặc on-chain tại đây...",
            sentiment: .bullish,
            tags: ["Research"],
            targetPrice: nil,
            stopLoss: nil,
            timeHorizon: "Trung hạn (1-6 tháng)",
            isPinned: false
        )
        
        notes.insert(newNote, at: 0)
        selectNote(newNote)
        triggerSave()
    }
    
    public func deleteCurrentNote() {
        guard let id = selectedNoteId else { return }
        deleteNote(id: id)
    }
    
    public func deleteNote(id: UUID) {
        notes.removeAll { $0.id == id }
        if selectedNoteId == id {
            if let first = notes.first {
                selectNote(first)
            } else {
                selectedNoteId = nil
            }
        }
        
        Task {
            try? await dataProvider.deleteNote(id: id)
        }
    }
    
    public func togglePinCurrentNote() {
        guard let id = selectedNoteId else { return }
        draftIsPinned.toggle()
        if let idx = notes.firstIndex(where: { $0.id == id }) {
            notes[idx].isPinned = draftIsPinned
        }
        triggerSave()
    }
    
    public func addTagToDraft() {
        let clean = newTagInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !clean.isEmpty, !draftTags.contains(clean) else { return }
        draftTags.append(clean)
        newTagInput = ""
        onDraftFieldChanged()
    }
    
    public func removeTagFromDraft(_ tag: String) {
        draftTags.removeAll { $0 == tag }
        onDraftFieldChanged()
    }
    
    public func insertMarkdownSnippet(_ snippet: String) {
        draftContent.append("\n" + snippet)
        onDraftFieldChanged()
    }
    
    public func exportCurrentNoteToClipboard() {
        guard let note = selectedNote else { return }
        
        var md = "# Báo Cáo Nghiên Cứu: \(note.title)\n\n"
        md += "- **Tài sản:** `\(note.symbol)`\n"
        md += "- **Tâm lý:** `\(note.sentiment.rawValue)`\n"
        if let target = note.targetPrice {
            md += "- **Mục tiêu chốt lời (Target):** `$\(String(format: "%.2f", target))`\n"
        }
        if let stop = note.stopLoss {
            md += "- **Cắt lỗ (Stop Loss):** `$\(String(format: "%.2f", stop))`\n"
        }
        if let rr = riskRewardRatio {
            md += "- **Tỷ lệ Lợi nhuận/Rủi ro (R:R):** `1 : \(String(format: "%.2f", rr))`\n"
        }
        md += "- **Thời gian nắm giữ:** `\(note.timeHorizon)`\n"
        md += "- **Tags:** \(note.tags.map { "#\($0)" }.joined(separator: ", "))\n"
        md += "- **Ngày cập nhật:** \(note.updatedAt.formatted())\n\n"
        md += "## Nội Dung Chi Tiết\n\n"
        md += note.content
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(md, forType: .string)
        
        isCopiedToastVisible = true
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            self.isCopiedToastVisible = false
        }
    }
    
    public func onDraftFieldChanged() {
        guard let id = selectedNoteId, let idx = notes.firstIndex(where: { $0.id == id }) else { return }
        
        let targetPrice = Double(draftTargetPriceText.replacingOccurrences(of: ",", with: "."))
        let stopLoss = Double(draftStopLossText.replacingOccurrences(of: ",", with: "."))
        
        notes[idx].title = draftTitle
        notes[idx].content = draftContent
        notes[idx].sentiment = draftSentiment
        notes[idx].tags = draftTags
        notes[idx].targetPrice = targetPrice
        notes[idx].stopLoss = stopLoss
        notes[idx].timeHorizon = draftTimeHorizon
        notes[idx].isPinned = draftIsPinned
        notes[idx].updatedAt = Date()
        
        triggerSave()
    }
    
    private func triggerSave() {
        saveTask?.cancel()
        isSaving = true
        
        saveTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms debounce
            guard !Task.isCancelled, let id = selectedNoteId, let note = notes.first(where: { $0.id == id }) else { return }
            
            do {
                try await dataProvider.saveNote(note)
                self.isSaving = false
                let df = DateFormatter()
                df.dateFormat = "HH:mm:ss"
                self.lastSavedText = "Đã lưu lúc \(df.string(from: Date()))"
            } catch {
                self.isSaving = false
            }
        }
    }
}

import SwiftUI

public struct NotesView: View {
    public let symbol: String
    @State private var viewModel: NotesViewModel
    
    public init(symbol: String) {
        self.symbol = symbol
        self._viewModel = State(initialValue: NotesViewModel(symbol: symbol))
    }
    
    public var body: some View {
        HSplitView {
            // Left Panel: Notes List & Filters
            notesListSidebar
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 400)
                .layoutPriority(0)
            
            // Right Panel: Note Editor / Preview
            noteEditorArea
                .frame(minWidth: 450, maxWidth: .infinity)
                .layoutPriority(1)
        }
        .background(AppTheme.darkBackground)
        .onAppear {
            viewModel.loadNotes()
        }
        .onChange(of: symbol) { _, newSym in
            viewModel.setSymbol(newSym)
        }
    }
    
    // MARK: - Left Notes List Sidebar
    private var notesListSidebar: some View {
        VStack(spacing: 0) {
            // Sidebar Header
            VStack(spacing: 10) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil.and.list.clipboard")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.accentBlue)
                        Text("Ghi chú & Luận điểm")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.createNewNote() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                                .font(.system(size: 10, weight: .bold))
                            Text("Tạo mới")
                                .font(.system(size: 11, weight: .semibold))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppTheme.accentBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    }
                    .buttonStyle(.plain)
                }
                
                // Search Field
                HStack(spacing: 6) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                    TextField("Tìm kiếm ghi chú, tag, nội dung...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11))
                        .foregroundColor(.white)
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
                
                // Sentiment & Tag Quick Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        // All Filter
                        Button(action: {
                            viewModel.selectedSentimentFilter = nil
                            viewModel.selectedTagFilter = nil
                        }) {
                            Text("Tất cả (\(viewModel.notes.count))")
                                .font(.system(size: 10, weight: (viewModel.selectedSentimentFilter == nil && viewModel.selectedTagFilter == nil) ? .bold : .medium))
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(
                                    (viewModel.selectedSentimentFilter == nil && viewModel.selectedTagFilter == nil)
                                    ? AppTheme.accentBlue.opacity(0.3)
                                    : AppTheme.darkCard
                                )
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                        
                        // Bullish Filter
                        Button(action: {
                            viewModel.selectedSentimentFilter = viewModel.selectedSentimentFilter == .bullish ? nil : .bullish
                        }) {
                            HStack(spacing: 3) {
                                Circle().fill(AppTheme.upGreen).frame(width: 4, height: 4)
                                Text("Bull (\(viewModel.bullishCount))")
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(viewModel.selectedSentimentFilter == .bullish ? AppTheme.upGreen.opacity(0.25) : AppTheme.darkCard)
                            .foregroundColor(viewModel.selectedSentimentFilter == .bullish ? AppTheme.upGreen : .white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                        
                        // Bearish Filter
                        Button(action: {
                            viewModel.selectedSentimentFilter = viewModel.selectedSentimentFilter == .bearish ? nil : .bearish
                        }) {
                            HStack(spacing: 3) {
                                Circle().fill(AppTheme.downRed).frame(width: 4, height: 4)
                                Text("Bear (\(viewModel.bearishCount))")
                                    .font(.system(size: 10))
                            }
                            .padding(.horizontal, 7)
                            .padding(.vertical, 3)
                            .background(viewModel.selectedSentimentFilter == .bearish ? AppTheme.downRed.opacity(0.25) : AppTheme.darkCard)
                            .foregroundColor(viewModel.selectedSentimentFilter == .bearish ? AppTheme.downRed : .white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                        .buttonStyle(.plain)
                        
                        // Tag filters
                        ForEach(viewModel.allTags, id: \.self) { tag in
                            Button(action: {
                                viewModel.selectedTagFilter = viewModel.selectedTagFilter == tag ? nil : tag
                            }) {
                                Text("#\(tag)")
                                    .font(.system(size: 10))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(viewModel.selectedTagFilter == tag ? AppTheme.cyan.opacity(0.3) : AppTheme.darkCard)
                                    .foregroundColor(viewModel.selectedTagFilter == tag ? AppTheme.cyan : .white.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(12)
            .background(AppTheme.darkHeaderBg)
            .overlay(
                Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
                alignment: .bottom
            )
            
            // Notes Cards List
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.filteredNotes.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "note.text.badge.plus")
                                .font(.system(size: 24))
                                .foregroundColor(.white.opacity(0.3))
                            Text("Chưa có ghi chú phù hợp")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .frame(maxWidth: .infinity, minHeight: 120)
                    } else {
                        ForEach(viewModel.filteredNotes) { note in
                            NoteCardView(
                                note: note,
                                isSelected: viewModel.selectedNoteId == note.id,
                                onSelect: { viewModel.selectNote(note) },
                                onDelete: { viewModel.deleteNote(id: note.id) }
                            )
                        }
                    }
                }
                .padding(10)
            }
        }
        .background(AppTheme.darkBackground)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(width: 1),
            alignment: .trailing
        )
    }
    
    // MARK: - Right Note Editor Area
    private var noteEditorArea: some View {
        Group {
            if viewModel.selectedNoteId != nil {
                VStack(spacing: 0) {
                    // Editor Top Toolbar (Title, Sentiment, Target/Stop, Pin, Save Status)
                    editorTopToolbar
                    
                    // Tags & Formatting Bar
                    editorFormattingBar
                    
                    // Content Body: Edit Mode or Preview Mode
                    if viewModel.isPreviewMode {
                        ScrollView {
                            markdownPreviewContent
                                .padding(16)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    } else {
                        TextEditor(text: $viewModel.draftContent)
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.white)
                            .scrollContentBackground(.hidden)
                            .padding(14)
                            .background(AppTheme.darkBackground)
                            .onChange(of: viewModel.draftContent) { _, _ in
                                viewModel.onDraftFieldChanged()
                            }
                    }
                }
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))
                    Text("Chọn một ghi chú từ danh sách hoặc tạo ghi chú mới")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.5))
                    Button("Tạo Ghi Chú Phân Tích Mới") {
                        viewModel.createNewNote()
                    }
                    .font(.system(size: 12, weight: .semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 7)
                    .background(AppTheme.accentBlue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .buttonStyle(.plain)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
    
    // MARK: - Editor Top Toolbar
    private var editorTopToolbar: some View {
        VStack(spacing: 8) {
            HStack(spacing: 10) {
                // Title Field
                TextField("Tiêu đề ghi chú phân tích...", text: $viewModel.draftTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .textFieldStyle(.plain)
                    .onChange(of: viewModel.draftTitle) { _, _ in
                        viewModel.onDraftFieldChanged()
                    }
                
                Spacer()
                
                // Save Status
                if viewModel.isSaving {
                    HStack(spacing: 4) {
                        ProgressView().controlSize(.mini)
                        Text("Đang lưu...")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                    }
                } else if let savedText = viewModel.lastSavedText {
                    Text(savedText)
                        .font(.system(size: 10))
                        .foregroundColor(AppTheme.upGreen.opacity(0.8))
                }
                
                // Pin Button
                Button(action: { viewModel.togglePinCurrentNote() }) {
                    Image(systemName: viewModel.draftIsPinned ? "pin.fill" : "pin")
                        .font(.system(size: 13))
                        .foregroundColor(viewModel.draftIsPinned ? AppTheme.warningYellow : .white.opacity(0.6))
                        .padding(6)
                        .background(AppTheme.darkCard)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
                
                // Preview Toggle
                Button(action: { viewModel.isPreviewMode.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isPreviewMode ? "pencil" : "eye.fill")
                            .font(.system(size: 11))
                        Text(viewModel.isPreviewMode ? "Sửa" : "Xem trước")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(viewModel.isPreviewMode ? AppTheme.accentBlue.opacity(0.2) : AppTheme.darkCard)
                    .foregroundColor(viewModel.isPreviewMode ? AppTheme.accentBlue : .white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(viewModel.isPreviewMode ? AppTheme.accentBlue : AppTheme.darkBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Export Button
                Button(action: { viewModel.exportCurrentNoteToClipboard() }) {
                    HStack(spacing: 4) {
                        Image(systemName: viewModel.isCopiedToastVisible ? "checkmark" : "square.and.arrow.up")
                            .font(.system(size: 11))
                        Text(viewModel.isCopiedToastVisible ? "Đã sao chép!" : "Xuất báo cáo")
                            .font(.system(size: 11, weight: .medium))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(viewModel.isCopiedToastVisible ? AppTheme.upGreen.opacity(0.2) : AppTheme.darkCard)
                    .foregroundColor(viewModel.isCopiedToastVisible ? AppTheme.upGreen : .white.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(viewModel.isCopiedToastVisible ? AppTheme.upGreen : AppTheme.darkBorder, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                
                // Delete Note
                Button(action: { viewModel.deleteCurrentNote() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(AppTheme.downRed.opacity(0.8))
                        .padding(6)
                        .background(AppTheme.darkCard)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .buttonStyle(.plain)
            }
            
            // Meta Row: Sentiment, Target Price, Stop Loss, Time Horizon
            HStack(spacing: 12) {
                // Sentiment Picker
                Menu {
                    ForEach(ResearchSentiment.allCases, id: \.self) { s in
                        Button(action: {
                            viewModel.draftSentiment = s
                            viewModel.onDraftFieldChanged()
                        }) {
                            HStack {
                                Text(s.rawValue)
                                Image(systemName: s.iconName)
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 5) {
                        Circle().fill(viewModel.draftSentiment.color).frame(width: 6, height: 6)
                        Text(viewModel.draftSentiment.rawValue)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(viewModel.draftSentiment.color)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(viewModel.draftSentiment.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
                
                // Target Price Input
                HStack(spacing: 4) {
                    Text("🎯 Target:")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text("$")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                    TextField("0.00", text: $viewModel.draftTargetPriceText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.upGreen)
                        .frame(width: 70)
                        .onChange(of: viewModel.draftTargetPriceText) { _, _ in
                            viewModel.onDraftFieldChanged()
                        }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Stop Loss Input
                HStack(spacing: 4) {
                    Text("🛑 Stop:")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.5))
                    Text("$")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.4))
                    TextField("0.00", text: $viewModel.draftStopLossText)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(AppTheme.downRed)
                        .frame(width: 70)
                        .onChange(of: viewModel.draftStopLossText) { _, _ in
                            viewModel.onDraftFieldChanged()
                        }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Horizon
                HStack(spacing: 4) {
                    Text("⏳")
                        .font(.system(size: 10))
                    TextField("Thời gian...", text: $viewModel.draftTimeHorizon)
                        .textFieldStyle(.plain)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.8))
                        .frame(width: 120)
                        .onChange(of: viewModel.draftTimeHorizon) { _, _ in
                            viewModel.onDraftFieldChanged()
                        }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                // Auto R:R Ratio Badge
                if let rr = viewModel.riskRewardRatio {
                    HStack(spacing: 4) {
                        Text("⚖️ R:R:")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.5))
                        Text(String(format: "1 : %.1f", rr))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(viewModel.riskRewardRating.color)
                        Text("(\(viewModel.riskRewardRating.label))")
                            .font(.system(size: 9))
                            .foregroundColor(viewModel.riskRewardRating.color.opacity(0.8))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(viewModel.riskRewardRating.color.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(viewModel.riskRewardRating.color.opacity(0.3), lineWidth: 1)
                    )
                }
                
                Spacer()
            }
        }
        .padding(12)
        .background(AppTheme.darkHeaderBg)
        .overlay(
            Rectangle().fill(AppTheme.darkBorder).frame(height: 1),
            alignment: .bottom
        )
    }
    
    // MARK: - Tags & Quick Formatting Toolbar
    private var editorFormattingBar: some View {
        HStack(spacing: 8) {
            // Tag chips
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(viewModel.draftTags, id: \.self) { tag in
                        HStack(spacing: 3) {
                            Text("#\(tag)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(AppTheme.cyan)
                            Button(action: { viewModel.removeTagFromDraft(tag) }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 8))
                                    .foregroundColor(AppTheme.cyan.opacity(0.6))
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(AppTheme.cyan.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    // Add Tag Field
                    HStack(spacing: 3) {
                        Image(systemName: "tag.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                        TextField("+ Tag mới", text: $viewModel.newTagInput)
                            .textFieldStyle(.plain)
                            .font(.system(size: 10))
                            .foregroundColor(.white)
                            .frame(width: 65)
                            .onSubmit {
                                viewModel.addTagToDraft()
                            }
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppTheme.darkCard)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
            
            Spacer()
            
            // Formatting helpers
            if !viewModel.isPreviewMode {
                HStack(spacing: 4) {
                    formattingButton(label: "H3", snippet: "### Tiêu đề")
                    formattingButton(label: "Bold", snippet: "**chữ đậm**")
                    formattingButton(label: "• List", snippet: "- Ý chính 1\n- Ý chính 2")
                    formattingButton(label: "🎯 Target", snippet: "🎯 **Mục tiêu chốt lời:** $")
                    formattingButton(label: "⚠️ Risk", snippet: "⚠️ **Rủi ro chính:** ")
                    formattingButton(label: "⛓️ On-chain", snippet: "⛓️ **Tín hiệu On-chain:** ")
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(AppTheme.darkCard.opacity(0.4))
        .overlay(
            Rectangle().fill(AppTheme.darkBorder.opacity(0.5)).frame(height: 1),
            alignment: .bottom
        )
    }
    
    private func formattingButton(label: String, snippet: String) -> some View {
        Button(action: { viewModel.insertMarkdownSnippet(snippet) }) {
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(AppTheme.darkCard)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Markdown Live Preview
    private var markdownPreviewContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Note Title in preview
            Text(viewModel.draftTitle.isEmpty ? "Ghi chú không tiêu đề" : viewModel.draftTitle)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
            
            // Meta highlights in preview
            HStack(spacing: 12) {
                HStack(spacing: 4) {
                    Circle().fill(viewModel.draftSentiment.color).frame(width: 6, height: 6)
                    Text(viewModel.draftSentiment.rawValue)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(viewModel.draftSentiment.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(viewModel.draftSentiment.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                
                if !viewModel.draftTargetPriceText.isEmpty {
                    HStack(spacing: 3) {
                        Text("🎯 Target:")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                        Text("$\(viewModel.draftTargetPriceText)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.upGreen)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AppTheme.upGreen.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                if !viewModel.draftStopLossText.isEmpty {
                    HStack(spacing: 3) {
                        Text("🛑 Stop Loss:")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                        Text("$\(viewModel.draftStopLossText)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.downRed)
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(AppTheme.downRed.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
                
                Text("⏳ \(viewModel.draftTimeHorizon)")
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Divider().background(AppTheme.darkBorder)
            
            // Markdown text paragraphs
            ForEach(viewModel.draftContent.components(separatedBy: "\n\n"), id: \.self) { block in
                renderMarkdownBlock(block)
            }
        }
    }
    
    @ViewBuilder
    private func renderMarkdownBlock(_ block: String) -> some View {
        let trimmed = block.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.hasPrefix("### ") {
            Text(trimmed.replacingOccurrences(of: "### ", with: ""))
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(AppTheme.cyan)
                .padding(.top, 4)
        } else if trimmed.hasPrefix("## ") {
            Text(trimmed.replacingOccurrences(of: "## ", with: ""))
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 6)
        } else if trimmed.hasPrefix("# ") {
            Text(trimmed.replacingOccurrences(of: "# ", with: ""))
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 8)
        } else if trimmed.contains("- ") {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(trimmed.components(separatedBy: "\n"), id: \.self) { line in
                    if line.trimmingCharacters(in: .whitespaces).hasPrefix("- ") {
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.accentBlue)
                            Text(line.replacingOccurrences(of: "- ", with: "").replacingOccurrences(of: "**", with: ""))
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.85))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } else {
                        Text(line)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.85))
                    }
                }
            }
        } else {
            Text(trimmed.replacingOccurrences(of: "**", with: ""))
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.85))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

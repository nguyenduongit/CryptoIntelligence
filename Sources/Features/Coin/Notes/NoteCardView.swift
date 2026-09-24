import SwiftUI

public struct NoteCardView: View {
    public let note: ResearchNote
    public let isSelected: Bool
    public let onSelect: () -> Void
    public let onDelete: () -> Void
    
    @State private var isHovered: Bool = false
    
    public init(
        note: ResearchNote,
        isSelected: Bool,
        onSelect: @escaping () -> Void,
        onDelete: @escaping () -> Void
    ) {
        self.note = note
        self.isSelected = isSelected
        self.onSelect = onSelect
        self.onDelete = onDelete
    }
    
    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                // Header: Pin, Title & Delete
                HStack(spacing: 6) {
                    if note.isPinned {
                        Image(systemName: "pin.fill")
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.warningYellow)
                    }
                    
                    Text(note.title.isEmpty ? "Ghi chú không tiêu đề" : note.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    if isHovered {
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .font(.system(size: 11))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Content snippet
                Text(cleanMarkdownPreview(note.content))
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(2)
                    .lineSpacing(2)
                
                // Tags & Sentiment footer
                HStack(spacing: 6) {
                    // Sentiment Pill
                    HStack(spacing: 3) {
                        Circle()
                            .fill(note.sentiment.color)
                            .frame(width: 5, height: 5)
                        Text(note.sentiment.shortLabel)
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(note.sentiment.color)
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(note.sentiment.color.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 3))
                    
                    // First 2 tags
                    ForEach(note.tags.prefix(2), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.system(size: 9))
                            .foregroundColor(AppTheme.cyan.opacity(0.8))
                            .padding(.horizontal, 5)
                            .padding(.vertical, 2)
                            .background(AppTheme.cyan.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                    }
                    
                    if note.tags.count > 2 {
                        Text("+\(note.tags.count - 2)")
                            .font(.system(size: 9))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    
                    Spacer()
                    
                    // Date
                    Text(formattedDate(note.updatedAt))
                        .font(.system(size: 9))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(10)
            .background(
                isSelected
                ? AppTheme.accentBlue.opacity(0.18)
                : (isHovered ? AppTheme.darkCard.opacity(0.8) : AppTheme.darkCard.opacity(0.4))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected ? AppTheme.accentBlue.opacity(0.6) : AppTheme.darkBorder,
                        lineWidth: 1
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
    
    private func cleanMarkdownPreview(_ text: String) -> String {
        let clean = text
            .replacingOccurrences(of: "### ", with: "")
            .replacingOccurrences(of: "## ", with: "")
            .replacingOccurrences(of: "# ", with: "")
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "- ", with: "• ")
            .replacingOccurrences(of: "`", with: "")
        return clean.isEmpty ? "(Chưa có nội dung)" : clean
    }
    
    private func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd/MM HH:mm"
        return df.string(from: date)
    }
}

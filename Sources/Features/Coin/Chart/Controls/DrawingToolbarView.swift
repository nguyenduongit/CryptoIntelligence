import SwiftUI

public struct DrawingToolbarView: View {
    @Bindable var viewModel: ChartViewModel
    @State private var showClearConfirm: Bool = false
    
    public init(viewModel: ChartViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        VStack(spacing: 4) {
            toolsSection
            Divider()
                .frame(width: 20)
                .background(AppTheme.darkBorder)
                .padding(.vertical, 2)
            undoRedoSection
            actionSection
        }
        .padding(4)
        .background(AppTheme.darkHeaderBg.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(AppTheme.darkBorder, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 6, x: 2, y: 2)
    }
    
    @ViewBuilder
    private var toolsSection: some View {
        ForEach(DrawingToolType.allCases) { tool in
            let isSelected = (viewModel.selectedDrawingTool == tool)
            Button(action: {
                viewModel.selectedDrawingTool = tool
                viewModel.activeDrawing = nil
            }) {
                Image(systemName: tool.iconName)
                    .font(.system(size: 13, weight: .semibold))
                    .padding(7)
                    .frame(width: 30, height: 30)
                    .background(isSelected ? AppTheme.accentBlue : AppTheme.darkCard.opacity(0.8))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? AppTheme.accentBlue.opacity(0.8) : AppTheme.darkBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help(tool.rawValue)
        }
    }
    
    @ViewBuilder
    private var undoRedoSection: some View {
        // Undo Button
        Button(action: { viewModel.undo() }) {
            Image(systemName: "arrow.uturn.backward")
                .font(.system(size: 11, weight: .semibold))
                .padding(7)
                .frame(width: 30, height: 30)
                .background(AppTheme.darkCard.opacity(viewModel.canUndo ? 0.8 : 0.3))
                .foregroundColor(viewModel.canUndo ? .white : .white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canUndo)
        .help("Hoàn tác hình vẽ (⌘Z)")
        
        // Redo Button
        Button(action: { viewModel.redo() }) {
            Image(systemName: "arrow.uturn.forward")
                .font(.system(size: 11, weight: .semibold))
                .padding(7)
                .frame(width: 30, height: 30)
                .background(AppTheme.darkCard.opacity(viewModel.canRedo ? 0.8 : 0.3))
                .foregroundColor(viewModel.canRedo ? .white : .white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(AppTheme.darkBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canRedo)
        .help("Làm lại hình vẽ (⇧⌘Z)")
    }
    
    @ViewBuilder
    private var actionSection: some View {
        if viewModel.selectedDrawingId != nil {
            Button(action: { viewModel.deleteSelectedDrawing() }) {
                Image(systemName: "trash")
                    .font(.system(size: 12, weight: .semibold))
                    .padding(7)
                    .frame(width: 30, height: 30)
                    .background(AppTheme.downRed.opacity(0.25))
                    .foregroundColor(AppTheme.downRed)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.downRed.opacity(0.6), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Xóa hình vẽ đang chọn (Phím ⌫)")
        }
        
        if !viewModel.drawings.isEmpty {
            Button(action: { showClearConfirm = true }) {
                Image(systemName: "trash.slash")
                    .font(.system(size: 12))
                    .padding(7)
                    .frame(width: 30, height: 30)
                    .background(AppTheme.darkCard.opacity(0.8))
                    .foregroundColor(.white.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppTheme.darkBorder, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
            .help("Xóa tất cả hình vẽ trên \(viewModel.symbol)")
            .confirmationDialog(
                "Xóa tất cả hình vẽ trên \(viewModel.symbol)?",
                isPresented: $showClearConfirm,
                titleVisibility: .visible
            ) {
                Button("Xóa tất cả", role: .destructive) {
                    viewModel.clearAllDrawings()
                }
                Button("Hủy", role: .cancel) {}
            }
        }
    }
}

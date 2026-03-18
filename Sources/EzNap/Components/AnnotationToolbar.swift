import SwiftUI

/// Floating annotation toolbar — uses GlassEffectContainer so the active
/// tool indicator morphs smoothly between buttons.
struct AnnotationToolbar: View {
    @Binding var selectedTool: AnnotationTool
    @Namespace private var glassNamespace

    var body: some View {
        GlassEffectContainer(spacing: 4) {
            HStack(spacing: 4) {
            ForEach(AnnotationTool.allCases) { tool in
                Button {
                    withAnimation(.spring(duration: 0.3, bounce: 0.2)) {
                        selectedTool = tool
                    }
                } label: {
                    Image(systemName: tool.icon)
                        .font(.system(size: 16, weight: selectedTool == tool ? .semibold : .regular))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(selectedTool == tool ? .primary : .secondary)
                }
                .buttonStyle(.plain)
                .glassEffectID(tool.id, in: glassNamespace)
                .glassEffect(
                    selectedTool == tool ? .regular : .regular.interactive(),
                    in: RoundedRectangle(cornerRadius: 10)
                )
                .accessibilityLabel(tool.rawValue)
            }
            } // HStack
        }
    }
}

#Preview {
    @Previewable @State var tool: AnnotationTool = .select
    AnnotationToolbar(selectedTool: $tool)
        .padding(24)
        .background(Color(white: 0.1))
}

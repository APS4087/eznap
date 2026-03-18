import SwiftUI

enum AnnotationTool: String, CaseIterable, Identifiable {
    case select = "Select"
    case arrow = "Arrow"
    case box = "Box"
    case text = "Text"
    case blur = "Blur"
    case highlight = "Highlight"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .select:    return "arrow.up.left"
        case .arrow:     return "arrow.up.right"
        case .box:       return "square"
        case .text:      return "textformat"
        case .blur:      return "drop.halffull"
        case .highlight: return "highlighter"
        }
    }
}

struct Annotation: Identifiable {
    let id = UUID()
    var tool: AnnotationTool
    var rect: CGRect
    var text: String?
    var color: Color
    var lineWidth: CGFloat

    init(tool: AnnotationTool, rect: CGRect, text: String? = nil, color: Color = .red, lineWidth: CGFloat = 2) {
        self.tool = tool
        self.rect = rect
        self.text = text
        self.color = color
        self.lineWidth = lineWidth
    }
}

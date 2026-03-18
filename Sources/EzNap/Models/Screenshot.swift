import CoreGraphics
import CoreImage
import SwiftUI

/// Represents a captured screenshot along with its styling configuration.
@Observable
final class Screenshot {
    let originalImage: CGImage
    var style: ScreenshotStyle {
        didSet {
            if style != oldValue { _cachedStyled = nil }
        }
    }

    private var _cachedStyled: CGImage?

    init(image: CGImage, style: ScreenshotStyle = .default) {
        self.originalImage = image
        self.style = style
    }

    /// The styled image — recomputed only when `style` changes.
    var styledImage: CGImage? {
        if let cached = _cachedStyled { return cached }
        let result = ImageStyler.apply(style, to: originalImage)
        _cachedStyled = result
        return result
    }
}

/// All visual styling options for a screenshot.
struct ScreenshotStyle: Equatable {
    var background: BackgroundStyle = .gradient(.macDefault)
    var cornerRadius: CGFloat = 12
    var shadowRadius: CGFloat = 20
    var shadowOpacity: CGFloat = 0.4
    var paddingH: CGFloat = 60
    var paddingV: CGFloat = 60

    static let `default` = ScreenshotStyle()
    static let none = ScreenshotStyle(
        background: .transparent,
        cornerRadius: 0,
        shadowRadius: 0,
        shadowOpacity: 0,
        paddingH: 0,
        paddingV: 0
    )
}

enum BackgroundStyle: Equatable {
    case gradient(GradientPreset)
    case solid(Color)
    case transparent
    case custom(startColor: Color, endColor: Color, angle: Double)
}

enum GradientPreset: String, CaseIterable, Identifiable {
    case macDefault = "macOS Default"
    case ocean = "Ocean"
    case sunset = "Sunset"
    case forest = "Forest"
    case midnight = "Midnight"
    case rose = "Rose"

    var id: String { rawValue }

    var colors: (Color, Color) {
        switch self {
        case .macDefault: return (Color(red: 0.45, green: 0.55, blue: 0.95), Color(red: 0.65, green: 0.45, blue: 0.95))
        case .ocean:      return (Color(red: 0.13, green: 0.59, blue: 0.95), Color(red: 0.13, green: 0.85, blue: 0.82))
        case .sunset:     return (Color(red: 0.99, green: 0.56, blue: 0.27), Color(red: 0.97, green: 0.29, blue: 0.46))
        case .forest:     return (Color(red: 0.21, green: 0.78, blue: 0.55), Color(red: 0.08, green: 0.55, blue: 0.40))
        case .midnight:   return (Color(red: 0.07, green: 0.07, blue: 0.15), Color(red: 0.15, green: 0.10, blue: 0.30))
        case .rose:       return (Color(red: 0.98, green: 0.75, blue: 0.82), Color(red: 0.92, green: 0.45, blue: 0.65))
        }
    }
}

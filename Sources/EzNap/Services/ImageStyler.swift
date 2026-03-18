import CoreGraphics
import AppKit

/// Composites a raw CGImage onto a styled canvas (background + rounded corners + shadow).
enum ImageStyler {

    static func apply(_ style: ScreenshotStyle, to image: CGImage) -> CGImage? {
        let imgW = CGFloat(image.width)
        let imgH = CGFloat(image.height)
        let canvasW = imgW + style.paddingH * 2
        let canvasH = imgH + style.paddingV * 2

        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard let ctx = CGContext(
            data: nil,
            width: Int(canvasW),
            height: Int(canvasH),
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        // 1. Background
        drawBackground(style.background, in: ctx, size: CGSize(width: canvasW, height: canvasH))

        // 2. Shadow beneath screenshot
        ctx.saveGState()
        if style.shadowRadius > 0 {
            ctx.setShadow(
                offset: CGSize(width: 0, height: -(style.shadowRadius * 0.3)),
                blur: style.shadowRadius,
                color: CGColor(red: 0, green: 0, blue: 0, alpha: style.shadowOpacity)
            )
        }

        // 3. Clip screenshot to rounded rect
        let imageRect = CGRect(x: style.paddingH, y: style.paddingV, width: imgW, height: imgH)
        if style.cornerRadius > 0 {
            let path = CGPath(roundedRect: imageRect, cornerWidth: style.cornerRadius, cornerHeight: style.cornerRadius, transform: nil)
            ctx.addPath(path)
            ctx.clip()
        }
        ctx.draw(image, in: imageRect)
        ctx.restoreGState()

        return ctx.makeImage()
    }

    // MARK: - Background

    private static func drawBackground(_ bg: BackgroundStyle, in ctx: CGContext, size: CGSize) {
        switch bg {
        case .transparent:
            break
        case .solid(let color):
            if let cgColor = color.cgColor {
                ctx.setFillColor(cgColor)
                ctx.fill(CGRect(origin: .zero, size: size))
            }
        case .gradient(let preset):
            let (start, end) = preset.colors
            drawLinearGradient(start: start, end: end, angle: 135, in: ctx, size: size)
        case .custom(let start, let end, let angle):
            drawLinearGradient(start: start, end: end, angle: angle, in: ctx, size: size)
        }
    }

    private static func drawLinearGradient(start: SwiftUI.Color, end: SwiftUI.Color, angle: Double, in ctx: CGContext, size: CGSize) {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        guard
            let startCG = start.cgColor,
            let endCG = end.cgColor,
            let gradient = CGGradient(colorsSpace: colorSpace, colors: [startCG, endCG] as CFArray, locations: [0, 1])
        else { return }

        let rad = angle * .pi / 180
        let cx = size.width / 2, cy = size.height / 2
        let d = max(size.width, size.height)
        ctx.drawLinearGradient(
            gradient,
            start: CGPoint(x: cx - cos(rad) * d / 2, y: cy - sin(rad) * d / 2),
            end:   CGPoint(x: cx + cos(rad) * d / 2, y: cy + sin(rad) * d / 2),
            options: [.drawsBeforeStartLocation, .drawsAfterEndLocation]
        )
    }
}

// MARK: - Color → CGColor bridge
import SwiftUI
private extension SwiftUI.Color {
    var cgColor: CGColor? { NSColor(self).cgColor }
}

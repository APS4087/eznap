import AppKit

/// Presents a full-screen overlay for drag-to-select region capture.
/// Returns a CGRect in SCKit coordinate space (top-left origin, points), or nil if cancelled.
@MainActor
final class RegionSelectorService {

    private var overlayWindow: RegionOverlayWindow?

    func selectRegion() async -> CGRect? {
        let result = await withCheckedContinuation { (continuation: CheckedContinuation<CGRect?, Never>) in
            var resumed = false
            let window = RegionOverlayWindow { result in
                guard !resumed else { return }
                resumed = true
                continuation.resume(returning: result)
            }
            overlayWindow = window
            window.makeKeyAndOrderFront(nil)
        }
        // Close window after continuation returns — AttributeGraph is no longer involved
        overlayWindow?.close()
        overlayWindow = nil
        NSCursor.arrow.set()
        return result
    }
}

// MARK: - Overlay Window

final class RegionOverlayWindow: NSWindow {
    init(onComplete: @escaping @MainActor (CGRect?) -> Void) {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        let view = RegionSelectorView(frame: screen.frame, onComplete: onComplete)
        self.contentView = view
        self.makeFirstResponder(view)
    }
}

// MARK: - Pure AppKit selector view
// No SwiftUI / NSHostingView / AttributeGraph — eliminates the use-after-free crash
// caused by AttributeGraph background threads outliving NSHostingView teardown.

private final class RegionSelectorView: NSView {
    private let onComplete: @MainActor (CGRect?) -> Void
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var completed = false

    init(frame: CGRect, onComplete: @escaping @MainActor (CGRect?) -> Void) {
        self.onComplete = onComplete
        super.init(frame: frame)
        addTrackingArea(NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseMoved, .cursorUpdate, .inVisibleRect],
            owner: self,
            userInfo: nil
        ))
    }

    required init?(coder: NSCoder) { fatalError() }

    // Top-left origin — matches SCKit's sourceRect coordinate space directly
    override var isFlipped: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    override func cursorUpdate(with event: NSEvent) {
        NSCursor.crosshair.set()
    }

    // MARK: - Drawing

    override func draw(_ dirtyRect: NSRect) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }

        // Dim layer
        ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.35))
        ctx.fill(bounds)

        if let rect = selectionRect, rect.width > 2, rect.height > 2 {
            // Punch a transparent hole for the selection
            ctx.setBlendMode(.clear)
            ctx.fill(rect)
            ctx.setBlendMode(.normal)

            if rect.width > 8, rect.height > 8 {
                drawBorder(rect, ctx: ctx)
                drawSizeLabel(rect, ctx: ctx)
            }
        } else if startPoint == nil {
            drawInstructions(ctx: ctx)
        }
    }

    private func drawBorder(_ rect: CGRect, ctx: CGContext) {
        ctx.setStrokeColor(CGColor(red: 1, green: 1, blue: 1, alpha: 1))
        ctx.setLineWidth(1.5)
        ctx.stroke(rect.insetBy(dx: 0.75, dy: 0.75))
    }

    private func drawSizeLabel(_ rect: CGRect, ctx: CGContext) {
        let text = "\(Int(rect.width)) × \(Int(rect.height))" as NSString
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 11, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let textSize = text.size(withAttributes: attrs)
        let pad: CGFloat = 8
        let labelW = textSize.width + pad * 2
        let labelH = textSize.height + 8
        let labelX = rect.minX
        let labelY = max(0, rect.minY - labelH - 4)
        let labelRect = CGRect(x: labelX, y: labelY, width: labelW, height: labelH)

        ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.6))
        ctx.addPath(CGPath(roundedRect: labelRect, cornerWidth: 6, cornerHeight: 6, transform: nil))
        ctx.fillPath()
        text.draw(at: CGPoint(x: labelRect.minX + pad, y: labelRect.minY + 4), withAttributes: attrs)
    }

    private func drawInstructions(ctx: CGContext) {
        let title    = "Drag to select a region" as NSString
        let subtitle = "ESC to cancel" as NSString
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 15, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11),
            .foregroundColor: NSColor.white.withAlphaComponent(0.5)
        ]
        let tSize = title.size(withAttributes: titleAttrs)
        let sSize = subtitle.size(withAttributes: subAttrs)
        let boxW = max(tSize.width, sSize.width) + 40
        let boxH = tSize.height + sSize.height + 28
        let boxX = (bounds.width - boxW) / 2
        let boxY = (bounds.height - boxH) / 2
        let boxRect = CGRect(x: boxX, y: boxY, width: boxW, height: boxH)

        ctx.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 0.55))
        ctx.addPath(CGPath(roundedRect: boxRect, cornerWidth: 10, cornerHeight: 10, transform: nil))
        ctx.fillPath()

        title.draw(at: CGPoint(x: boxX + (boxW - tSize.width) / 2, y: boxY + 14), withAttributes: titleAttrs)
        subtitle.draw(at: CGPoint(x: boxX + (boxW - sSize.width) / 2, y: boxY + 14 + tSize.height + 6), withAttributes: subAttrs)
    }

    // MARK: - Mouse events

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        if let rect = selectionRect, rect.width > 10, rect.height > 10 {
            finish(with: rect)
        } else {
            startPoint = nil; currentPoint = nil
            needsDisplay = true
        }
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { finish(with: nil) }  // ESC
    }

    // MARK: - Helpers

    private var selectionRect: CGRect? {
        guard let s = startPoint, let c = currentPoint else { return nil }
        return CGRect(x: min(s.x, c.x), y: min(s.y, c.y),
                      width: abs(c.x - s.x), height: abs(c.y - s.y))
    }

    private func finish(with rect: CGRect?) {
        guard !completed else { return }
        completed = true
        Task { @MainActor in onComplete(rect) }
    }
}

import AppKit
import SwiftUI

/// Presents a full-screen overlay for drag-to-select region capture.
/// Returns the selected CGRect in AppKit screen coordinates (origin bottom-left), or nil if cancelled.
@MainActor
final class RegionSelectorService {

    private var overlayWindow: RegionOverlayWindow?

    func selectRegion() async -> CGRect? {
        return await withCheckedContinuation { continuation in
            let window = RegionOverlayWindow { [weak self] result in
                self?.overlayWindow?.close()
                self?.overlayWindow = nil
                continuation.resume(returning: result)
            }
            overlayWindow = window
            window.makeKeyAndOrderFront(nil)
            NSCursor.crosshair.set()
        }
    }
}

// MARK: - Overlay Window

final class RegionOverlayWindow: NSWindow {
    init(onComplete: @escaping @MainActor (CGRect?) -> Void) {
        let screen = NSScreen.main ?? NSScreen.screens[0]
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let view = RegionOverlayView(screenFrame: screen.frame, onComplete: onComplete)
        self.contentView = NSHostingView(rootView: view)
    }
}

// MARK: - SwiftUI Overlay

private struct RegionOverlayView: View {
    let screenFrame: CGRect
    let onComplete: @MainActor (CGRect?) -> Void

    @State private var startPoint: CGPoint? = nil
    @State private var currentPoint: CGPoint? = nil
    @State private var isDragging = false

    private var selectionRect: CGRect? {
        guard let s = startPoint, let c = currentPoint else { return nil }
        return CGRect(
            x: min(s.x, c.x), y: min(s.y, c.y),
            width: abs(c.x - s.x), height: abs(c.y - s.y)
        )
    }

    var body: some View {
        ZStack {
            // Dim overlay — cut out the selection rectangle
            if let rect = selectionRect {
                DimWithCutout(rect: rect)
            } else {
                Color.black.opacity(0.35)
            }

            // Selection rectangle border + size label
            if let rect = selectionRect, rect.width > 4, rect.height > 4 {
                selectionOverlay(rect)
            }

            // Instructions
            if !isDragging {
                VStack(spacing: 8) {
                    Text("Drag to select a region")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                    Text("ESC to cancel")
                        .font(.system(size: 12))
                        .foregroundStyle(.white.opacity(0.55))
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .ignoresSafeArea()
        .gesture(
            DragGesture(minimumDistance: 2, coordinateSpace: .local)
                .onChanged { v in
                    isDragging = true
                    if startPoint == nil { startPoint = v.startLocation }
                    currentPoint = v.location
                }
                .onEnded { _ in
                    if let rect = selectionRect, rect.width > 10, rect.height > 10 {
                        // Convert from SwiftUI top-left coords to AppKit bottom-left coords
                        let flippedY = screenFrame.height - rect.maxY
                        let appKitRect = CGRect(x: rect.minX + screenFrame.minX,
                                               y: flippedY + screenFrame.minY,
                                               width: rect.width, height: rect.height)
                        Task { @MainActor in onComplete(appKitRect) }
                    } else {
                        reset()
                    }
                }
        )
        .onKeyPress(.escape) {
            Task { @MainActor in onComplete(nil) }
            return .handled
        }
        .cursor(.crosshair)
    }

    private func reset() {
        startPoint = nil
        currentPoint = nil
        isDragging = false
    }

    @ViewBuilder
    private func selectionOverlay(_ rect: CGRect) -> some View {
        ZStack(alignment: .topLeading) {
            // Border
            Rectangle()
                .strokeBorder(.white, lineWidth: 1.5)
                .frame(width: rect.width, height: rect.height)
                .offset(x: rect.minX, y: rect.minY)

            // Size label
            Text("\(Int(rect.width)) × \(Int(rect.height))")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                .offset(
                    x: rect.minX,
                    y: max(0, rect.minY - 28)
                )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Dim with selection cutout

private struct DimWithCutout: View {
    let rect: CGRect

    var body: some View {
        Canvas { ctx, size in
            // Full dim
            ctx.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.35)))
            // Cut out selection — use .clear blending
            ctx.blendMode = .clear
            ctx.fill(Path(rect), with: .color(.black))
        }
        .ignoresSafeArea()
    }
}

// MARK: - Cursor modifier

private struct CursorModifier: ViewModifier {
    let cursor: NSCursor
    func body(content: Content) -> some View {
        content.onContinuousHover { _ in cursor.set() }
    }
}

private extension View {
    func cursor(_ cursor: NSCursor) -> some View {
        modifier(CursorModifier(cursor: cursor))
    }
}

import AppKit
import SwiftUI

/// Presents a full-screen overlay for drag-to-select region capture.
/// Returns a CGRect in SCKit/SwiftUI coordinate space (top-left origin, points), or nil if cancelled.
@MainActor
final class RegionSelectorService {

    private var overlayWindow: RegionOverlayWindow?

    func selectRegion() async -> CGRect? {
        let result = await withCheckedContinuation { (continuation: CheckedContinuation<CGRect?, Never>) in
            var resumed = false
            let window = RegionOverlayWindow { result in
                guard !resumed else { return }   // prevent double-resume
                resumed = true
                // Do NOT close the window here — tearing down NSHostingView while
                // SwiftUI's attribute graph is still processing the drag/keypress event
                // causes a use-after-free crash. Window teardown happens below.
                continuation.resume(returning: result)
            }
            overlayWindow = window
            window.makeKeyAndOrderFront(nil)
        }
        // Continuation has fully returned — safe to tear down the overlay now
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
        // Convert AppKit screen frame (bottom-left origin) to a window rect
        super.init(contentRect: screen.frame, styleMask: .borderless, backing: .buffered, defer: false)
        self.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.screenSaverWindow)))
        self.isOpaque = false
        self.backgroundColor = .clear
        self.ignoresMouseEvents = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.contentView = NSHostingView(rootView: RegionOverlayView(onComplete: onComplete))
        self.makeFirstResponder(self.contentView)
    }
}

// MARK: - SwiftUI Overlay

private struct RegionOverlayView: View {
    let onComplete: @MainActor (CGRect?) -> Void

    @State private var startPoint: CGPoint? = nil
    @State private var currentPoint: CGPoint? = nil
    @State private var isDragging = false

    private var selectionRect: CGRect? {
        guard let s = startPoint, let c = currentPoint else { return nil }
        return CGRect(x: min(s.x, c.x), y: min(s.y, c.y),
                      width: abs(c.x - s.x), height: abs(c.y - s.y))
    }

    var body: some View {
        ZStack {
            // Dim layer with cutout
            if let rect = selectionRect, rect.width > 2, rect.height > 2 {
                DimWithCutout(rect: rect)
            } else {
                Color.black.opacity(0.35).ignoresSafeArea()
            }

            // Selection border + size label
            if let rect = selectionRect, rect.width > 8, rect.height > 8 {
                selectionOverlay(rect)
            }

            // Instructions when idle
            if !isDragging {
                VStack(spacing: 6) {
                    Text("Drag to select a region")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white)
                    Text("ESC to cancel")
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.50))
                }
                .padding(.horizontal, 20).padding(.vertical, 12)
                .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
            }
        }
        .ignoresSafeArea()
        .onContinuousHover { _ in NSCursor.crosshair.set() }
        .gesture(
            DragGesture(minimumDistance: 2, coordinateSpace: .local)
                .onChanged { v in
                    if startPoint == nil { startPoint = v.startLocation }
                    currentPoint = v.location
                    isDragging = true
                }
                .onEnded { _ in
                    // SwiftUI local coords == SCKit sourceRect coords (top-left, points) — no conversion needed
                    if let rect = selectionRect, rect.width > 10, rect.height > 10 {
                        Task { @MainActor in onComplete(rect) }
                    } else {
                        startPoint = nil; currentPoint = nil; isDragging = false
                    }
                }
        )
        .onKeyPress(.escape) {
            Task { @MainActor in onComplete(nil) }
            return .handled
        }
    }

    @ViewBuilder
    private func selectionOverlay(_ rect: CGRect) -> some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .strokeBorder(.white, lineWidth: 1.5)
                .frame(width: rect.width, height: rect.height)
                .offset(x: rect.minX, y: rect.minY)

            Text("\(Int(rect.width)) × \(Int(rect.height))")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(.black.opacity(0.6), in: RoundedRectangle(cornerRadius: 6))
                .offset(x: rect.minX, y: max(0, rect.minY - 28))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// MARK: - Dim with cutout using drawLayer for correct .clear blend

private struct DimWithCutout: View {
    let rect: CGRect
    var body: some View {
        Canvas { ctx, size in
            ctx.drawLayer { layer in
                layer.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.black.opacity(0.35)))
                layer.blendMode = .clear
                layer.fill(Path(rect), with: .color(.black))
            }
        }
        .ignoresSafeArea()
    }
}

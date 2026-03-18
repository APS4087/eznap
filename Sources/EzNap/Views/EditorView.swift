import SwiftUI

/// Main editor shown after a screenshot is captured.
/// Layout: canvas (centre) + style panel (trailing) + annotation toolbar (bottom).
struct EditorView: View {
    @Environment(AppState.self) private var appState
    @Bindable var screenshot: Screenshot

    @State private var selectedTool: AnnotationTool = .select
    @State private var annotations: [Annotation] = []
    @State private var showSavePanel = false

    var body: some View {
        HStack(spacing: 0) {
            // ── Canvas ────────────────────────────────────────────
            canvasArea
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // ── Style Panel ───────────────────────────────────────
            StylePanel(style: $screenshot.style)
                .frame(width: 260)
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("New Capture") {
                    withAnimation(.spring(duration: 0.3)) {
                        appState.screenshot = nil
                    }
                }
                .keyboardShortcut("n", modifiers: .command)

                Divider()

                Button {
                    appState.copyToClipboard()
                } label: {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])

                Button {
                    showSavePanel = true
                } label: {
                    Label("Save…", systemImage: "square.and.arrow.down")
                }
                .keyboardShortcut("s", modifiers: .command)
            }
        }
        .fileExporter(
            isPresented: $showSavePanel,
            document: ScreenshotDocument(screenshot: screenshot),
            contentType: .png,
            defaultFilename: "screenshot"
        ) { result in
            if case .failure(let error) = result {
                appState.captureError = error.localizedDescription
            }
        }
    }

    // MARK: - Canvas

    private var canvasArea: some View {
        VStack(spacing: 0) {
            ZStack {
                // Warm light canvas — matches home screen aesthetic
                Color(red: 0.93, green: 0.92, blue: 0.90)
                    .ignoresSafeArea()

                CheckerboardBackground()

                if let styled = screenshot.styledImage {
                    Image(decorative: styled, scale: 2)
                        .resizable()
                        .scaledToFit()
                        .shadow(color: .black.opacity(0.18), radius: 32, x: 0, y: 12)
                        .padding(40)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // canvas takes all remaining height

            // Annotation toolbar — natural height only, never expands
            AnnotationToolbar(selectedTool: $selectedTool)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.93, green: 0.92, blue: 0.90))
        }
    }
}

// MARK: - Checkerboard
// Uses a static 24×24 NSImage tiled via ImagePaint — zero per-frame CPU cost.

private struct CheckerboardBackground: View {
    private static let tile: Image = {
        let size = CGSize(width: 24, height: 24)
        let img = NSImage(size: size, flipped: false) { _ in
            NSColor(white: 0.86, alpha: 0.6).setFill()
            NSBezierPath(rect: NSRect(x: 0,  y: 0,  width: 12, height: 12)).fill()
            NSBezierPath(rect: NSRect(x: 12, y: 12, width: 12, height: 12)).fill()
            NSColor(white: 0.82, alpha: 0.6).setFill()
            NSBezierPath(rect: NSRect(x: 12, y: 0,  width: 12, height: 12)).fill()
            NSBezierPath(rect: NSRect(x: 0,  y: 12, width: 12, height: 12)).fill()
            return true
        }
        return Image(nsImage: img)
    }()

    var body: some View {
        Rectangle()
            .fill(ImagePaint(image: Self.tile))
            .ignoresSafeArea()
    }
}

// MARK: - File document wrapper for fileExporter

import UniformTypeIdentifiers

struct ScreenshotDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png] }
    let screenshot: Screenshot

    init(screenshot: Screenshot) { self.screenshot = screenshot }
    init(configuration: ReadConfiguration) throws { fatalError("read not supported") }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        // fileWrapper is called on the main thread by SwiftUI's fileExporter.
        // Screenshot is @MainActor so we use assumeIsolated to satisfy the compiler.
        let image = MainActor.assumeIsolated {
            screenshot.styledImage ?? screenshot.renderSync()
        }
        guard
            let image,
            let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
        else { throw ExportError.renderFailed }
        return FileWrapper(regularFileWithContents: data)
    }
}

import AppKit

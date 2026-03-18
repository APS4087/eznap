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

            // Annotation toolbar sits below the canvas — never overlaps image
            AnnotationToolbar(selectedTool: $selectedTool)
                .padding(.vertical, 12)
                .background(Color(red: 0.93, green: 0.92, blue: 0.90))
        }
    }
}

// MARK: - Checkerboard

private struct CheckerboardBackground: View {
    var body: some View {
        Canvas { ctx, size in
            let tileSize: CGFloat = 12
            let cols = Int(size.width / tileSize) + 1
            let rows = Int(size.height / tileSize) + 1
            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    ctx.fill(
                        Path(CGRect(x: CGFloat(col) * tileSize, y: CGFloat(row) * tileSize, width: tileSize, height: tileSize)),
                        with: .color(isLight ? Color(white: 0.86) : Color(white: 0.82))
                    )
                }
            }
        }
        .opacity(0.6)
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
        guard
            let image = screenshot.styledImage,
            let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])
        else { throw ExportError.renderFailed }
        return FileWrapper(regularFileWithContents: data)
    }
}

import AppKit

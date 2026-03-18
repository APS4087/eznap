import SwiftUI
import ScreenCaptureKit

/// Central application state, shared via SwiftUI environment.
@Observable
@MainActor
final class AppState {
    var screenshot: Screenshot?
    var isCapturing = false
    var captureError: String?

    private let captureService = ScreenCaptureService()
    private let exportService = ImageExportService()

    // MARK: - Capture

    func captureScreen() async {
        await performCapture { [captureService] in
            try await captureService.captureScreen()
        }
    }

    func captureWindow() async {
        await performCapture { [captureService] in
            try await captureService.captureWindow()
        }
    }

    func captureRegion() async {
        await performCapture { [captureService] in
            try await captureService.captureRegion()
        }
    }

    private func performCapture(_ block: @Sendable () async throws -> CGImage) async {
        isCapturing = true
        captureError = nil
        defer { isCapturing = false }
        do {
            let image = try await block()
            withAnimation(.spring(duration: 0.4)) {
                screenshot = Screenshot(image: image)
            }
        } catch {
            captureError = error.localizedDescription
        }
    }

    // MARK: - Export

    func copyToClipboard() {
        guard let image = screenshot?.styledImage else { return }
        exportService.copyToClipboard(image)
    }

    func saveToDisk(url: URL) async throws {
        guard let image = screenshot?.styledImage else { return }
        try await exportService.save(image, to: url)
    }
}

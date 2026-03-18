import SwiftUI
import ScreenCaptureKit

/// Central application state, shared via SwiftUI environment.
@Observable
@MainActor
final class AppState {
    var screenshot: Screenshot?
    var isCapturing = false
    var captureError: String?
    var hasScreenPermission: Bool = false
    var showWindowPicker = false

    private let captureService = ScreenCaptureService()
    private let exportService = ImageExportService()
    private let regionSelector = RegionSelectorService()

    init() {
        hasScreenPermission = captureService.hasPermission
    }

    func requestScreenPermission() {
        hasScreenPermission = captureService.requestPermission()
        // If still denied after request, the user needs System Settings
    }

    func openPrivacySettings() {
        captureService.openPrivacySettings()
    }

    /// Call when app becomes active — re-checks in case user toggled in System Settings
    func recheckPermission() {
        hasScreenPermission = captureService.hasPermission
    }

    // MARK: - Capture

    func captureScreen() async {
        await performCapture { [captureService] in
            try await captureService.captureScreen()
        }
    }

    /// Shows the window picker sheet — user selects which window to capture.
    func initiateWindowCapture() {
        showWindowPicker = true
    }

    /// Called from WindowPickerView after user selects a window.
    func captureSpecificWindow(id windowID: CGWindowID) async {
        await performCapture { [captureService] in
            try await captureService.captureWindow(id: windowID)
        }
    }

    /// Fetches window list for the picker.
    func fetchWindows() async throws -> [WindowInfo] {
        try await captureService.fetchWindows()
    }

    /// Shows full-screen region selector overlay, then captures the selection.
    func captureRegion() async {
        guard let rect = await regionSelector.selectRegion() else { return }
        await performCapture { [captureService] in
            try await captureService.captureRegion(rect)
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

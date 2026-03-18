import ScreenCaptureKit
import CoreGraphics

/// Handles all screen capture operations using ScreenCaptureKit.
final class ScreenCaptureService: Sendable {

    // MARK: - Permission

    /// Returns true if screen recording permission is currently granted.
    var hasPermission: Bool {
        CGPreflightScreenCaptureAccess()
    }

    /// Requests permission. Shows the system prompt if not yet decided,
    /// returns true if granted. Must be called from any context (not just MainActor).
    @discardableResult
    func requestPermission() -> Bool {
        CGRequestScreenCaptureAccess()
    }

    /// Opens System Settings directly to Screen Recording.
    @MainActor
    func openPrivacySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
    }

    // MARK: - Capture Methods

    func captureScreen() async throws -> CGImage {
        guard hasPermission else { throw CaptureError.permissionDenied }
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let display = content.displays.first else { throw CaptureError.noDisplayFound }
        let filter = SCContentFilter(display: display, excludingWindows: [])
        return try await capture(filter: filter, size: CGSize(width: display.width, height: display.height))
    }

    func captureWindow() async throws -> CGImage {
        guard hasPermission else { throw CaptureError.permissionDenied }
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        guard let window = content.windows.first(where: {
            $0.isOnScreen && $0.owningApplication?.bundleIdentifier != "com.eznap.app"
        }) else { throw CaptureError.noWindowFound }
        let filter = SCContentFilter(desktopIndependentWindow: window)
        let size = CGSize(width: window.frame.width, height: window.frame.height)
        return try await capture(filter: filter, size: size)
    }

    func captureRegion() async throws -> CGImage {
        // TODO: interactive region selection (Phase 2)
        return try await captureScreen()
    }

    // MARK: - Private

    private func capture(filter: SCContentFilter, size: CGSize) async throws -> CGImage {
        let config = SCStreamConfiguration()
        config.width = Int(size.width * 2)
        config.height = Int(size.height * 2)
        config.scalesToFit = false
        config.showsCursor = false
        return try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
    }
}

enum CaptureError: LocalizedError {
    case noDisplayFound
    case noWindowFound
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .noDisplayFound:   return "No display found for capture."
        case .noWindowFound:    return "No eligible window found."
        case .permissionDenied: return "Screen recording permission is required."
        }
    }
}

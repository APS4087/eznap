import CoreGraphics
import ScreenCaptureKit

/// Lightweight, Sendable snapshot of an SCWindow for display in the window picker.
struct WindowInfo: Identifiable, @unchecked Sendable {
    let id: CGWindowID        // SCWindow.windowID — UInt32
    let appName: String
    let windowTitle: String
    let frame: CGRect
    let thumbnail: CGImage?   // CGImage is immutable — safe to share
}

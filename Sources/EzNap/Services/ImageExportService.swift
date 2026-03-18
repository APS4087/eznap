import AppKit
import CoreGraphics

final class ImageExportService: Sendable {

    func copyToClipboard(_ cgImage: CGImage) {
        let image = NSImage()
        image.addRepresentation(NSBitmapImageRep(cgImage: cgImage))
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
    }

    func save(_ cgImage: CGImage, to url: URL) async throws {
        let rep = NSBitmapImageRep(cgImage: cgImage)
        let isPNG = url.pathExtension.lowercased() != "jpg" && url.pathExtension.lowercased() != "jpeg"
        let data: Data?
        if isPNG {
            data = rep.representation(using: .png, properties: [:])
        } else {
            data = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.92])
        }
        guard let data else { throw ExportError.encodingFailed }
        try data.write(to: url)
    }
}

enum ExportError: LocalizedError {
    case renderFailed
    case encodingFailed
    var errorDescription: String? {
        switch self {
        case .renderFailed:   return "Failed to render styled screenshot."
        case .encodingFailed: return "Failed to encode image data."
        }
    }
}

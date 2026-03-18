# EzNap

Beautiful macOS screenshot tool with Liquid Glass design.

![macOS 26+](https://img.shields.io/badge/macOS-26%2B-black?style=flat-square)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange?style=flat-square&logo=swift)
![License](https://img.shields.io/badge/license-MIT-blue?style=flat-square)

---

## Features

- **Capture** — full screen, window, or region via ScreenCaptureKit
- **Backgrounds** — gradient presets, solid colors, or transparent
- **Styling** — rounded corners, drop shadow, configurable padding
- **Annotations** — arrows, boxes, text, blur, highlight *(in progress)*
- **Export** — copy to clipboard or save as PNG / JPEG
- **Liquid Glass UI** — built with macOS 26's native glass design system

## Requirements

- macOS 26 or later
- Xcode 26+

## Getting Started

```bash
# Clone
git clone https://github.com/APS4087/eznap.git
cd eznap

# Generate Xcode project
brew install xcodegen
xcodegen generate

# Open in Xcode
open eznap.xcodeproj
```

Grant **Screen Recording** permission when prompted on first launch.

## Project Structure

```
Sources/EzNap/
├── App/          # Entry point, AppState
├── Models/       # Screenshot, AnnotationTool
├── Services/     # ScreenCaptureService, ImageStyler, ImageExportService
├── Views/        # CaptureHomeView, EditorView, SettingsView
└── Components/   # AnnotationToolbar, StylePanel
```

## License

MIT

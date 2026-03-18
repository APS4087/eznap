# EzNap — macOS Screenshot Styling Tool

## Project Overview
EzNap is a native macOS app (Swift + SwiftUI) that enhances screenshots with automatic backgrounds, rounded corners, drop shadows, and annotations. Open source, distributed as a direct download (not Mac App Store), targeting macOS 14+.

## Tech Stack
- **Language**: Swift 6, SwiftUI
- **Screen Capture**: ScreenCaptureKit (macOS 13+)
- **Image Processing**: Core Image, Core Graphics
- **Project Build**: XcodeGen (`project.yml` → `.xcodeproj`)
- **Minimum OS**: macOS 26 (Liquid Glass requires Xcode 26+)

## Project Structure
```
eznap/
├── project.yml              # XcodeGen config — run `xcodegen generate` to (re)create .xcodeproj
├── Sources/EzNap/
│   ├── App/                 # App entry point, AppDelegate if needed
│   ├── Views/               # SwiftUI views (screens)
│   ├── Components/          # Reusable SwiftUI components
│   ├── Models/              # Data types (Screenshot, AnnotationTool, etc.)
│   ├── Services/            # ScreenCaptureService, ImageExportService
│   └── Resources/           # Assets, Info.plist additions
├── Supporting Files/
│   ├── Info.plist
│   └── EzNap.entitlements
└── .claude/
    └── skills/              # Project-specific Claude skills
```

## Design Principles
- **Apple HIG**: Follow Human Interface Guidelines strictly — spacing, typography, color, controls
- **Liquid Glass first**: Use Liquid Glass as the primary material for floating UI (toolbars, panels, badges, annotation tools). Prefer it over flat backgrounds and `NSVisualEffectView`.
- **No third-party UI libs**: Use pure SwiftUI + AppKit bridging only where necessary
- **Accessibility**: Support VoiceOver, Dynamic Type, and keyboard navigation

## Liquid Glass Design (macOS 26+)

### Core APIs
| API | Use case |
|-----|----------|
| `.glassEffect(_:in:)` | Apply Liquid Glass to any custom view |
| `GlassEffectContainer` | Group multiple glass shapes that can morph together |
| `.glassEffectID(_:in:)` | Assign identity for morph animations between glass shapes |
| `GlassEffectTransition` | Animate glass appearing/disappearing |
| `.buttonStyle(.glass)` / `.buttonStyle(.glassProminent)` | Glass buttons |
| `.backgroundExtensionEffect()` | Blur/extend a hero image under sidebar or inspector |

### When to use Liquid Glass in EzNap
- **Annotation toolbar** — use `GlassEffectContainer` with tool buttons so they morph when selected
- **Style panel** (background/shadow/padding controls) — floating panel with `.glassEffect`
- **Export buttons** (Copy / Save) — `.buttonStyle(.glassProminent)`
- **Capture mode picker** — glass capsule buttons in a `GlassEffectContainer`
- **Preview canvas overlays** — corner radius / shadow handles styled with `.glassEffect`

### Patterns to follow
```swift
// Toolbar with auto-glass (system does it automatically)
.toolbar { ToolbarItem { ... } }

// Custom floating panel
someView
    .padding(16)
    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))

// Morphing tool group
GlassEffectContainer {
    ForEach(tools) { tool in
        Button(...) { ... }
            .glassEffectID(tool.id, in: namespace)
    }
}

// Hero image extending under sidebar
Image(...)
    .resizable()
    .backgroundExtensionEffect()
```

### Rules
- Do NOT layer `.glassEffect` on top of `NSVisualEffectView` — pick one
- Use `GlassEffectContainer` whenever you have 2+ adjacent glass shapes that should animate together
- The default glass shape is a capsule (`DefaultGlassEffectShape`) — pass a custom `Shape` for cards

## Key Features
1. **Capture**: Full screen, window, or region selection via ScreenCaptureKit
2. **Styling**: Gradient/solid/transparent backgrounds, configurable padding, rounded corners, drop shadow
3. **Annotation**: Arrows, boxes, text labels, blur/pixelate regions
4. **Export**: Copy to clipboard (`NSPasteboard`) and save to disk (PNG/JPEG)

## Entitlements Required
- `com.apple.security.screen-capture` — ScreenCaptureKit access (requires user permission prompt)
- App is NOT sandboxed (to allow saving anywhere on disk)

## Regenerating the Xcode Project
```bash
brew install xcodegen  # one-time
xcodegen generate      # run from project root whenever project.yml changes
```

## Code Conventions
- Use `@Observable` macro (Swift 5.9+) for view models, not `ObservableObject`
- Prefer `async/await` over completion handlers
- Keep views thin — business logic in Services or ViewModels
- File naming: one type per file, filename matches type name

---
name: new-view
description: Scaffold a new SwiftUI view for EzNap following Apple HIG and project conventions. Use when creating a new screen, panel, or reusable component.
argument-hint: <ViewName> [brief description of what it does]
---

Create a new SwiftUI view named `$ARGUMENTS[0]` in the appropriate directory.

## Steps

1. Determine if this is a **screen** (goes in `Sources/EzNap/Views/`) or a **reusable component** (goes in `Sources/EzNap/Components/`). Ask if unclear from the description.

2. Scaffold the file following this template:

```swift
import SwiftUI

struct $ARGUMENTS[0]: View {
    // MARK: - Properties

    // MARK: - Body
    var body: some View {
        // implementation
    }
}

// MARK: - Preview
#Preview {
    $ARGUMENTS[0]()
}
```

3. Apply Apple HIG + Liquid Glass standards:
   - Use system spacing: `.padding()` defaults, or explicit multiples of 4pt (4, 8, 12, 16, 20, 24)
   - Use semantic colors: `.primary`, `.secondary`, `Color(.windowBackground)`, `Color(.controlBackground)`
   - Use SF Symbols for icons — never custom icon assets unless brand-required
   - Use `.font(.title)`, `.font(.headline)`, `.font(.body)` — never hardcode point sizes
   - **Floating panels**: use `.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 16))` instead of `.background(.regularMaterial)`
   - **Glass buttons**: use `.buttonStyle(.glass)` for secondary actions, `.buttonStyle(.glassProminent)` for primary/CTA
   - **Morphing tool groups**: wrap related buttons in `GlassEffectContainer` and assign `.glassEffectID` for morph transitions
   - Use `RoundedRectangle(cornerRadius: 12)` as the shape for card-style glass containers

4. If the view has state, add a `@Observable` ViewModel class in the same file or a separate `{ViewName}ViewModel.swift` if substantial.

5. Read the existing views in `Sources/EzNap/Views/` first to ensure consistency in patterns.

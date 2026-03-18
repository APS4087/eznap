---
name: hig-review
description: Review SwiftUI/AppKit code against Apple Human Interface Guidelines and EzNap design standards. Use when finishing a UI feature or before committing UI changes.
argument-hint: [file or view name to review]
---

Review the UI code specified in `$ARGUMENTS` (or recently changed files if no argument) against Apple HIG and EzNap design standards.

## What to check

### Spacing & Layout
- [ ] Spacing follows 4pt grid (4, 8, 12, 16, 20, 24pt)
- [ ] No hardcoded magic numbers — use `.padding()`, `.spacing`, or named constants
- [ ] Content respects safe areas and window chrome

### Typography
- [ ] Uses semantic text styles (`.title`, `.headline`, `.body`, `.caption`) — no hardcoded sizes
- [ ] Font weight used purposefully — avoid overuse of `.bold`
- [ ] Line length is comfortable (not too wide)

### Color & Materials
- [ ] Uses adaptive/semantic colors — no hardcoded hex for UI chrome
- [ ] Vibrancy/materials used for floating panels: `.regularMaterial`, `.thickMaterial`
- [ ] Dark mode tested (use `#Preview` with `preferredColorScheme`)

### Liquid Glass (macOS 26+)
- [ ] Floating panels use `.glassEffect` not `.background(.material)`
- [ ] Tool buttons / icon groups are wrapped in `GlassEffectContainer` where 2+ glass shapes are adjacent
- [ ] Each glass element in a container has a unique `.glassEffectID` for morph animation
- [ ] Primary action buttons use `.buttonStyle(.glassProminent)`, secondary use `.buttonStyle(.glass)`
- [ ] Hero/banner images use `.backgroundExtensionEffect()` to extend under sidebar/inspector
- [ ] Toolbar glass is left to the system — **no manual glass applied to toolbar items**
- [ ] `.glassEffect` is NOT stacked on top of `NSVisualEffectView` — only one material per surface

### Controls & Interaction
- [ ] Native controls used where possible (`Toggle`, `Slider`, `Picker`) — no reimplementations
- [ ] Hover states on interactive elements (`.onHover`)
- [ ] Keyboard shortcuts for primary actions (`keyboardShortcut`)
- [ ] Cursor changes where appropriate (`.onHover { cursor.set() }`)

### Accessibility
- [ ] All interactive elements have `.accessibilityLabel`
- [ ] Decorative images have `.accessibilityHidden(true)`
- [ ] Focus order makes sense for keyboard navigation

### macOS-specific
- [ ] Window controls not obscured
- [ ] Context menus for right-click on relevant elements
- [ ] Toolbar items follow macOS toolbar conventions

## Output format
Report findings as:
- **Must fix**: HIG violations that would make the app feel un-Apple
- **Should fix**: Best practice improvements
- **Consider**: Polish suggestions

Then fix all "Must fix" items directly.

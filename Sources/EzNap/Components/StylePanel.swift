import SwiftUI

/// Trailing style panel — tabbed layout so nothing needs to scroll.
struct StylePanel: View {
    @Binding var style: ScreenshotStyle
    @State private var tab: PanelTab = .background

    enum PanelTab: String, CaseIterable {
        case background = "BG"
        case layout     = "Layout"
        case shadow     = "Shadow"

        var icon: String {
            switch self {
            case .background: return "paintpalette"
            case .layout:     return "square.arrowtriangle.4.outward"
            case .shadow:     return "square.shadow"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {

            // ── Tab bar ──────────────────────────────────────────────
            HStack(spacing: 0) {
                ForEach(PanelTab.allCases, id: \.self) { t in
                    Button {
                        withAnimation(.easeInOut(duration: 0.18)) { tab = t }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: t.icon)
                                .font(.system(size: 14, weight: .medium))
                            Text(t.rawValue)
                                .font(.system(size: 10, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .foregroundStyle(tab == t
                            ? Color(red: 0.10, green: 0.10, blue: 0.12)
                            : Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.35))
                    }
                    .buttonStyle(.plain)
                    .background(alignment: .bottom) {
                        if tab == t {
                            Rectangle()
                                .fill(Color(red: 0.25, green: 0.47, blue: 0.98))
                                .frame(height: 2)
                                .matchedGeometryEffect(id: "tabIndicator", in: tabNS)
                        }
                    }
                }
            }
            .background(Color(red: 0.98, green: 0.97, blue: 0.96))

            Divider()

            // ── Tab content ──────────────────────────────────────────
            Group {
                switch tab {
                case .background: backgroundTab
                case .layout:     layoutTab
                case .shadow:     shadowTab
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(20)
            .transition(.opacity)
        }
        .background(Color(red: 0.98, green: 0.97, blue: 0.96))
        .overlay(alignment: .leading) { Divider() }
    }

    @Namespace private var tabNS

    // MARK: - Background tab

    private var backgroundTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionLabel("Gradient Presets")

            LazyVGrid(
                columns: Array(repeating: .init(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(GradientPreset.allCases) { preset in
                    gradientSwatch(preset)
                }
                transparentSwatch
            }
        }
    }

    private func gradientSwatch(_ preset: GradientPreset) -> some View {
        let (start, end) = preset.colors
        let selected = style.background == .gradient(preset)
        return Button {
            style.background = .gradient(preset)
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing))
                .aspectRatio(1.6, contentMode: .fit)
                .overlay {
                    if selected {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(.white, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var transparentSwatch: some View {
        let selected = style.background == .transparent
        return Button { style.background = .transparent } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(.quaternary)
                .aspectRatio(1.6, contentMode: .fit)
                .overlay {
                    Image(systemName: "circle.slash").foregroundStyle(.secondary)
                    if selected {
                        RoundedRectangle(cornerRadius: 8).strokeBorder(.white, lineWidth: 2.5)
                    }
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Layout tab

    private var layoutTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("Padding")
                sliderRow("Horizontal", value: $style.paddingH, range: 0...160, format: "%dpt")
                sliderRow("Vertical",   value: $style.paddingV, range: 0...160, format: "%dpt")
            }
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                sectionLabel("Corner Radius")
                sliderRow("Radius", value: $style.cornerRadius, range: 0...40, format: "%dpt")
            }
        }
    }

    // MARK: - Shadow tab

    private var shadowTab: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionLabel("Shadow")
            sliderRow("Blur",    value: $style.shadowRadius,  range: 0...80, format: "%dpt")
            sliderRow("Opacity", value: $style.shadowOpacity, range: 0...1,  format: "%d%%", scale: 100)
        }
    }

    // MARK: - Helpers

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.35))
            .tracking(0.8)
    }

    private func sliderRow(
        _ label: String,
        value: Binding<CGFloat>,
        range: ClosedRange<CGFloat>,
        format: String,
        scale: CGFloat = 1
    ) -> some View {
        VStack(spacing: 6) {
            HStack {
                Text(label)
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.65))
                Spacer()
                Text(String(format: format, Int(value.wrappedValue * scale)))
                    .font(.system(size: 12).monospacedDigit())
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.40))
            }
            Slider(value: value, in: range)
                .tint(Color(red: 0.25, green: 0.47, blue: 0.98))
        }
    }
}

#Preview {
    @Previewable @State var style = ScreenshotStyle()
    StylePanel(style: $style)
        .frame(width: 260, height: 500)
}

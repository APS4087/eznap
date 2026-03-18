import SwiftUI

/// Trailing panel for adjusting screenshot style — background, padding, shadow, corner radius.
struct StylePanel: View {
    @Binding var style: ScreenshotStyle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                backgroundSection
                paddingSection
                cornerSection
                shadowSection
            }
            .padding(20)
        }
        .background(.regularMaterial)
        .frame(maxHeight: .infinity)
    }

    // MARK: - Background

    private var backgroundSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Background")

            // Gradient presets
            LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 8), count: 3), spacing: 8) {
                ForEach(GradientPreset.allCases) { preset in
                    gradientSwatch(preset)
                }
                // Transparent option
                transparentSwatch
            }
        }
    }

    private func gradientSwatch(_ preset: GradientPreset) -> some View {
        let (start, end) = preset.colors
        let isSelected = style.background == .gradient(preset)
        return Button {
            withAnimation(.spring(duration: 0.25)) {
                style.background = .gradient(preset)
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(LinearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing))
                .aspectRatio(1.6, contentMode: .fit)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.white, lineWidth: 2)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(preset.rawValue)
    }

    private var transparentSwatch: some View {
        let isSelected = style.background == .transparent
        return Button {
            withAnimation(.spring(duration: 0.25)) {
                style.background = .transparent
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    ImagePaint(image: Image(systemName: "checkmark"), scale: 0.4)
                )
                .aspectRatio(1.6, contentMode: .fit)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.quaternary)
                )
                .overlay {
                    Image(systemName: "circle.slash")
                        .foregroundStyle(.secondary)
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.white, lineWidth: 2)
                    }
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Transparent")
    }

    // MARK: - Padding

    private var paddingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Padding")
            sliderRow("Horizontal", value: $style.paddingH, range: 0...160, unit: "pt")
            sliderRow("Vertical",   value: $style.paddingV, range: 0...160, unit: "pt")
        }
    }

    // MARK: - Corner Radius

    private var cornerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Corner Radius")
            sliderRow("Radius", value: $style.cornerRadius, range: 0...40, unit: "pt")
        }
    }

    // MARK: - Shadow

    private var shadowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Shadow")
            sliderRow("Blur",    value: $style.shadowRadius,  range: 0...80,  unit: "pt")
            sliderRow("Opacity", value: $style.shadowOpacity, range: 0...1,   unit: "%", scale: 100)
        }
    }

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private func sliderRow(_ label: String, value: Binding<CGFloat>, range: ClosedRange<CGFloat>, unit: String, scale: CGFloat = 1) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label).font(.caption).foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value.wrappedValue * scale))\(unit)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range)
                .tint(.white.opacity(0.8))
        }
    }
}

#Preview {
    @Previewable @State var style = ScreenshotStyle()
    StylePanel(style: $style)
        .frame(width: 260, height: 600)
}

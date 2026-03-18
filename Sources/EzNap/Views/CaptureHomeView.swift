import SwiftUI

struct CaptureHomeView: View {
    @Environment(AppState.self) private var appState
    @Namespace private var glassNamespace

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(minWidth: 760, minHeight: 500)
        .overlay(alignment: .center) {
            if appState.isCapturing {
                ProgressView()
                    .controlSize(.large)
                    .padding(28)
                    .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            // Warm off-white base — editorial / fashion magazine feel
            Color(red: 0.97, green: 0.96, blue: 0.94)
                .ignoresSafeArea()

            // Soft warm ambient glow top-right (like window light)
            RadialGradient(
                colors: [
                    Color(red: 1.0, green: 0.82, blue: 0.60).opacity(0.45),
                    Color.clear
                ],
                center: .init(x: 0.85, y: 0.0),
                startRadius: 0,
                endRadius: 520
            )
            .ignoresSafeArea()

            // Cool lavender accent bottom-left for depth
            RadialGradient(
                colors: [
                    Color(red: 0.72, green: 0.68, blue: 0.92).opacity(0.30),
                    Color.clear
                ],
                center: .init(x: 0.05, y: 1.0),
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()

            // Wordmark
            VStack(spacing: 10) {
                Text("EzNap")
                    .font(.system(size: 52, weight: .bold, design: .default))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                    .tracking(-2)

                Text("Take a screenshot. Make it beautiful.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.40))
                    .tracking(0.1)
            }
            .padding(.bottom, 56)

            // Capture mode cards
            captureCards

            if let error = appState.captureError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.75))
                    .padding(.top, 20)
            }

            Spacer()

            // Subtle keyboard hints
            HStack(spacing: 20) {
                shortcutHint(key: "⇧⌘3", label: "Screen")
                shortcutHint(key: "⇧⌘4", label: "Window")
                shortcutHint(key: "⇧⌘5", label: "Region")
            }
            .padding(.bottom, 28)
        }
    }

    // MARK: - Capture Cards

    private var captureCards: some View {
        HStack(spacing: 16) {
            captureCard(
                title: "Screen",
                subtitle: "Full display",
                icon: "display",
                accent: Color(red: 0.25, green: 0.47, blue: 0.98)
            ) { Task { await appState.captureScreen() } }
            .glassEffectID("screen", in: glassNamespace)

            captureCard(
                title: "Window",
                subtitle: "Active window",
                icon: "macwindow",
                accent: Color(red: 0.55, green: 0.35, blue: 0.92)
            ) { Task { await appState.captureWindow() } }
            .glassEffectID("window", in: glassNamespace)

            captureCard(
                title: "Region",
                subtitle: "Select area",
                icon: "crop",
                accent: Color(red: 0.95, green: 0.42, blue: 0.32)
            ) { Task { await appState.captureRegion() } }
            .glassEffectID("region", in: glassNamespace)
        }
    }

    private func captureCard(
        title: String,
        subtitle: String,
        icon: String,
        accent: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                // Icon with accent tint
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(accent.opacity(0.12))
                        .frame(width: 48, height: 48)
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(accent)
                }
                .padding(.bottom, 20)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))

                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.40))
                    .padding(.top, 3)
            }
            .frame(width: 148, alignment: .leading)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.72))
                    .shadow(color: .black.opacity(0.07), radius: 16, x: 0, y: 4)
                    .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(.white.opacity(0.8), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: 18))
    }

    // MARK: - Shortcut Hint

    private func shortcutHint(key: String, label: String) -> some View {
        HStack(spacing: 5) {
            Text(key)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.28))
            Text(label)
                .font(.system(size: 10, weight: .regular))
                .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.28))
        }
    }
}

#Preview {
    CaptureHomeView()
        .environment(AppState())
}

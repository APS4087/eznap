import SwiftUI

/// Landing view shown before any screenshot is taken.
struct CaptureHomeView: View {
    @Environment(AppState.self) private var appState
    @Namespace private var glassNamespace

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(minWidth: 720, minHeight: 480)
        .overlay(alignment: .center) {
            if appState.isCapturing {
                ProgressView()
                    .controlSize(.large)
                    .padding(28)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 20))
            }
        }
    }

    // MARK: - Background

    private var background: some View {
        ZStack {
            // Base: rich dark
            Color(red: 0.04, green: 0.04, blue: 0.08)
                .ignoresSafeArea()

            // Upper-left aurora glow
            RadialGradient(
                colors: [
                    Color(red: 0.30, green: 0.18, blue: 0.70).opacity(0.55),
                    Color.clear
                ],
                center: .init(x: 0.15, y: 0.10),
                startRadius: 0,
                endRadius: 480
            )
            .ignoresSafeArea()

            // Lower-right warm accent
            RadialGradient(
                colors: [
                    Color(red: 0.85, green: 0.30, blue: 0.45).opacity(0.30),
                    Color.clear
                ],
                center: .init(x: 0.88, y: 0.90),
                startRadius: 0,
                endRadius: 360
            )
            .ignoresSafeArea()

            // Subtle blue mid-glow
            RadialGradient(
                colors: [
                    Color(red: 0.10, green: 0.45, blue: 0.95).opacity(0.18),
                    Color.clear
                ],
                center: .init(x: 0.75, y: 0.20),
                startRadius: 0,
                endRadius: 320
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon badge
            ZStack {
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 72, height: 72)
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .glassEffect(.regular, in: Circle())
            .padding(.bottom, 28)

            // Headline
            VStack(spacing: 8) {
                Text("EzNap")
                    .font(.system(size: 48, weight: .semibold, design: .default))
                    .foregroundStyle(.white)
                    .tracking(-1)

                Text("Beautiful screenshots, effortlessly.")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(.white.opacity(0.45))
                    .tracking(0.2)
            }
            .padding(.bottom, 52)

            // Capture buttons — horizontal, morphing glass
            captureButtons
                .padding(.bottom, 20)

            if let error = appState.captureError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red.opacity(0.85))
                    .padding(.top, 16)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Keyboard hint
            Text("⇧⌘3  ·  ⇧⌘4  ·  ⇧⌘5")
                .font(.system(size: 11, weight: .regular, design: .monospaced))
                .foregroundStyle(.white.opacity(0.18))
                .padding(.bottom, 28)
        }
    }

    // MARK: - Capture Buttons

    private var captureButtons: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                captureButton(title: "Screen",  icon: "display",   action: { Task { await appState.captureScreen()  } })
                    .glassEffectID("screen", in: glassNamespace)
                captureButton(title: "Window",  icon: "macwindow", action: { Task { await appState.captureWindow()  } })
                    .glassEffectID("window", in: glassNamespace)
                captureButton(title: "Region",  icon: "crop",      action: { Task { await appState.captureRegion()  } })
                    .glassEffectID("region", in: glassNamespace)
            }
        }
    }

    private func captureButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .medium))
                Text(title)
                    .font(.system(size: 14, weight: .medium))
            }
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    CaptureHomeView()
        .environment(AppState())
}

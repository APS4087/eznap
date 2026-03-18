import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if !appState.hasScreenPermission {
                PermissionView()
            } else if let screenshot = appState.screenshot {
                EditorView(screenshot: screenshot)
            } else {
                CaptureHomeView()
            }
        }
        .frame(minWidth: 760, minHeight: 500)
    }
}

// MARK: - Permission Denied View

struct PermissionView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            // Same warm background as home
            Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea()
            RadialGradient(
                colors: [Color(red: 1.0, green: 0.82, blue: 0.60).opacity(0.45), Color.clear],
                center: .init(x: 0.85, y: 0.0), startRadius: 0, endRadius: 520
            ).ignoresSafeArea()

            VStack(spacing: 0) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(red: 0.95, green: 0.42, blue: 0.32).opacity(0.12))
                        .frame(width: 64, height: 64)
                    Image(systemName: "lock.shield")
                        .font(.system(size: 28, weight: .medium))
                        .foregroundStyle(Color(red: 0.95, green: 0.42, blue: 0.32))
                }
                .padding(.bottom, 24)

                Text("Screen Recording Required")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                    .tracking(-0.5)
                    .padding(.bottom, 10)

                Text("EzNap needs permission to capture your screen.\nGrant access in System Settings, then return to the app.")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.bottom, 36)

                HStack(spacing: 12) {
                    // Primary: open settings
                    Button {
                        appState.openPrivacySettings()
                    } label: {
                        Text("Open System Settings")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(red: 0.10, green: 0.10, blue: 0.12))
                            )
                    }
                    .buttonStyle(.plain)

                    // Secondary: re-check (user may have just toggled it)
                    Button {
                        appState.recheckPermission()
                        if !appState.hasScreenPermission {
                            appState.requestScreenPermission()
                        }
                    } label: {
                        Text("I've Granted Access")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.65))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.7))
                                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(.white.opacity(0.8), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(40)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}

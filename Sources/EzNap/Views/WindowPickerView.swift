import SwiftUI

struct WindowPickerView: View {
    @Environment(AppState.self) private var appState
    @Binding var isPresented: Bool

    @State private var windows: [WindowInfo] = []
    @State private var isLoading = true
    @State private var loadError: String? = nil

    private let columns = [GridItem(.adaptive(minimum: 200, maximum: 260), spacing: 16)]

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Select a Window")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                    Text("Click any window to capture it")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.40))
                }
                Spacer()
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.20))
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            Divider().opacity(0.5)

            // Content
            Group {
                if isLoading {
                    loadingView
                } else if let error = loadError {
                    errorView(error)
                } else if windows.isEmpty {
                    emptyView
                } else {
                    windowGrid
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(red: 0.97, green: 0.96, blue: 0.94))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .frame(width: 640, height: 480)
        .task { await loadWindows() }
    }

    // MARK: - Grid

    private var windowGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(windows) { window in
                    WindowCard(window: window) {
                        isPresented = false
                        Task { await appState.captureSpecificWindow(id: window.id) }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: - States

    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView().controlSize(.regular)
            Text("Loading windows…")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)
            Text(message)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "macwindow.badge.plus")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)
            Text("No open windows found")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Load

    private func loadWindows() async {
        isLoading = true
        loadError = nil
        do {
            windows = try await appState.fetchWindows()
        } catch {
            loadError = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - Window Card

private struct WindowCard: View {
    let window: WindowInfo
    let onSelect: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 0) {
                // Thumbnail
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(red: 0.90, green: 0.89, blue: 0.87))

                    if let thumb = window.thumbnail {
                        Image(decorative: thumb, scale: 2)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .padding(6)
                    } else {
                        Image(systemName: "macwindow")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 130)

                // Labels
                VStack(alignment: .leading, spacing: 2) {
                    Text(window.appName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                        .lineLimit(1)

                    if !window.windowTitle.isEmpty && window.windowTitle != window.appName {
                        Text(window.windowTitle)
                            .font(.system(size: 11))
                            .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12).opacity(0.45))
                            .lineLimit(1)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isHovered ? .white : .white.opacity(0.6))
                    .shadow(color: .black.opacity(isHovered ? 0.10 : 0.05), radius: isHovered ? 12 : 6, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(isHovered ? Color(red: 0.25, green: 0.47, blue: 0.98).opacity(0.5) : .white.opacity(0.7), lineWidth: 1.5)
            )
            .scaleEffect(isHovered ? 1.02 : 1.0)
            .animation(.spring(duration: 0.2), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
    }
}

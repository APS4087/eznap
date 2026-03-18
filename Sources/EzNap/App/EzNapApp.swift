import SwiftUI

@main
struct EzNapApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.automatic)
        .defaultSize(width: 820, height: 540)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandMenu("Capture") {
                Button("Capture Screen") {
                    Task { await appState.captureScreen() }
                }
                .keyboardShortcut("3", modifiers: [.command, .shift])

                Button("Capture Window") {
                    Task { await appState.captureWindow() }
                }
                .keyboardShortcut("4", modifiers: [.command, .shift])

                Button("Capture Region") {
                    Task { await appState.captureRegion() }
                }
                .keyboardShortcut("5", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
                .environment(appState)
        }
    }
}

import SwiftUI

struct ContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        Group {
            if let screenshot = appState.screenshot {
                EditorView(screenshot: screenshot)
            } else {
                CaptureHomeView()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}

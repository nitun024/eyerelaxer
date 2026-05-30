import SwiftUI

@main
struct EyeRelaxerApp: App {
    @StateObject var appState = AppState()

    init() {
        // Initialize notification manager early so its delegate is set.
        _ = NotificationManager.shared
        NotificationManager.shared.requestAuthorizationIfNeeded()
    }

    var body: some Scene {
        MenuBarExtra {
            PopoverView(appState: appState)
        } label: {
            // Menu bar icons work best as template images; SVG is fine for a crisp vector.
            // If for any reason the resource can't be loaded, fall back to an SF Symbol.
            if let url = Bundle.main.url(forResource: "AppLogo", withExtension: "svg"),
               let img = NSImage(contentsOf: url) {
                Image(nsImage: img)
                    .renderingMode(.template)
                    .foregroundStyle(appState.timerState == .breaking ? .green : .primary)
            } else {
                let image = Image(systemName: "eye")
                if appState.timerState == .breaking {
                    image.foregroundColor(.green)
                } else {
                    image
                }
            }
        }
        .menuBarExtraStyle(.window)
    }
}

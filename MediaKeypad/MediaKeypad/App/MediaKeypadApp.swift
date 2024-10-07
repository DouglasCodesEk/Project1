import SwiftUI

@main
struct MediaKeypadApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 300, height: 200)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        Settings {
            SettingsView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("MediaKeypad")
                .font(.title)
            Text("Running in background")
                .font(.subheadline)
            Text("Use the menu bar icon to access settings")
                .font(.caption)
                .padding()
        }
        .padding()
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .padding()
        // We'll expand this view later
    }
}

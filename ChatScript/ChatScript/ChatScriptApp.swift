import SwiftUI
import SwiftData

@main
struct ChatScriptApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var viewModel = AIServiceModelView()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.modelContext, PersistenceController.shared.container.mainContext)
                .environmentObject(viewModel)
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                Button("Settings...") {
                    appDelegate.openSettings()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
}

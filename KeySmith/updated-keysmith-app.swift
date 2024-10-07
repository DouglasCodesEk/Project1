import SwiftUI

@main
struct KeySmithApp: App {
    @StateObject private var macroEngine = MacroEngine()
    @StateObject private var keyboardRemapper = KeyboardRemapper()
    @StateObject private var variableManager = VariableManager()
    @StateObject private var preferencesManager = PreferencesManager()
    @StateObject private var contextManager = ContextManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(macroEngine)
                .environmentObject(keyboardRemapper)
                .environmentObject(variableManager)
                .environmentObject(preferencesManager)
                .environmentObject(contextManager)
        }
        .commands {
            KeySmithCommands(macroEngine: macroEngine, keyboardRemapper: keyboardRemapper)
        }
        
        Settings {
            SettingsView()
                .environmentObject(preferencesManager)
        }
    }
}

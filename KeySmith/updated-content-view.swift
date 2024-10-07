struct ContentView: View {
    @State private var selectedTab: Tab = .macros
    @EnvironmentObject var contextManager: ContextManager
    @EnvironmentObject var macroEngine: MacroEngine
    
    enum Tab {
        case macros, keyboardRemapper, visualBuilder, macroTesting
    }
    
    var body: some View {
        NavigationView {
            Sidebar(selectedTab: $selectedTab)
            
            Group {
                switch selectedTab {
                case .macros:
                    MacroEditorView()
                case .keyboardRemapper:
                    KeyboardRemapperView()
                case .visualBuilder:
                    VisualMacroBuilderView()
                case .macroTesting:
                    MacroTestingView()
                }
            }
        }
        .frame(minWidth: 900, minHeight: 600)
        .overlay(ContextOverlay(), alignment: .topTrailing)
    }
}

struct MacroEditorView: View {
    @EnvironmentObject var macroEngine: MacroEngine
    @State private var selectedMacro: VersionedMacro?
    
    var body: some View {
        VStack {
            if let macro = selectedMacro {
                MacroDetailView(macro: macro)
            } else {
                Text("Select a macro to edit")
            }
        }
        .sheet(item: $selectedMacro) { macro in
            MacroHistoryView(versionedMacro: macro)
        }
    }
}

struct MacroDetailView: View {
    @ObservedObject var macro: VersionedMacro
    @EnvironmentObject var macroEngine: MacroEngine
    
    var body: some View {
        VStack {
            TextField("Macro Name", text: $macro.currentVersion.name)
            
            List {
                ForEach(macro.currentVersion.actions.indices, id: \.self) { index in
                    ActionView(action: macro.currentVersion.actions[index])
                }
            }
            
            HStack {
                Button("Save Version") {
                    macro.createNewVersion()
                    macroEngine.saveMacroVersion(macro)
                }
                
                Button("Show History") {
                    // This will present the MacroHistoryView as a sheet
                    // The presentation is handled in MacroEditorView
                }
            }
        }
    }
}

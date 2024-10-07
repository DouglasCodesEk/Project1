import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .macros
    @EnvironmentObject var contextManager: ContextManager
    @EnvironmentObject var macroEngine: MacroEngine
    
    enum Tab {
        case dashboard, macros, keyboardRemapper, visualBuilder, macroTesting
    }
    
    var body: some View {
        NavigationView {
            sidebar
            
            tabContent
        }
        .frame(minWidth: 900, minHeight: 600)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                contextOverlay
            }
        }
    }
    
    var sidebar: some View {
        List {
            NavigationLink(destination: DashboardView(), tag: Tab.dashboard, selection: $selectedTab) {
                Label("Dashboard", systemImage: "chart.bar")
            }
            
            Section(header: Text("MACROS")) {
                NavigationLink(destination: MacroListView(), tag: Tab.macros, selection: $selectedTab) {
                    Label("All Macros", systemImage: "list.bullet")
                }
                NavigationLink(destination: VisualMacroBuilderView(), tag: Tab.visualBuilder, selection: $selectedTab) {
                    Label("Visual Builder", systemImage: "square.grid.2x2")
                }
                NavigationLink(destination: MacroTestingView(), tag: Tab.macroTesting, selection: $selectedTab) {
                    Label("Macro Testing", systemImage: "hammer")
                }
            }
            
            Section(header: Text("TOOLS")) {
                NavigationLink(destination: KeyboardRemapperView(), tag: Tab.keyboardRemapper, selection: $selectedTab) {
                    Label("Keyboard Remapper", systemImage: "keyboard")
                }
            }
        }
        .listStyle(SidebarListStyle())
        .frame(minWidth: 200)
    }
    
    @ViewBuilder
    var tabContent: some View {
        switch selectedTab {
        case .dashboard:
            DashboardView()
        case .macros:
            MacroListView()
        case .keyboardRemapper:
            KeyboardRemapperView()
        case .visualBuilder:
            VisualMacroBuilderView()
        case .macroTesting:
            MacroTestingView()
        }
    }
    
    var contextOverlay: some View {
        HStack {
            Text("App: \(contextManager.currentApp)")
            Text("Location: \(contextManager.currentLocation)")
            Text("Time: \(contextManager.timeOfDay.rawValue)")
            Text("Network: \(contextManager.networkStatus.rawValue)")
        }
        .font(.caption)
        .padding(6)
        .background(Color.secondary.opacity(0.2))
        .cornerRadius(8)
    }
}

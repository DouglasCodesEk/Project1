import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var macroEngine: MacroEngine
    @EnvironmentObject var contextManager: ContextManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                recentMacrosSection
                
                systemStatusSection
                
                quickActionsSection
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }
    
    var recentMacrosSection: some View {
        VStack(alignment: .leading) {
            Text("Recent Macros")
                .font(.headline)
            
            ForEach(macroEngine.recentlyUsedMacros.prefix(5)) { macro in
                HStack {
                    Text(macro.name)
                    Spacer()
                    Button("Run") {
                        Task {
                            try? await macroEngine.runMacro(macro, in: contextManager)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    var systemStatusSection: some View {
        VStack(alignment: .leading) {
            Text("System Status")
                .font(.headline)
            
            Grid {
                GridRow {
                    Text("Current App:")
                    Text(contextManager.currentApp)
                }
                GridRow {
                    Text("Location:")
                    Text(contextManager.currentLocation)
                }
                GridRow {
                    Text("Time of Day:")
                    Text(contextManager.timeOfDay.rawValue)
                }
                GridRow {
                    Text("Network Status:")
                    Text(contextManager.networkStatus.rawValue)
                }
            }
        }
    }
    
    var quickActionsSection: some View {
        VStack(alignment: .leading) {
            Text("Quick Actions")
                .font(.headline)
            
            HStack {
                Button("New Macro") {
                    // TODO: Implement new macro creation
                }
                Button("Import Macro") {
                    // TODO: Implement macro import
                }
                Button("Export All Macros") {
                    // TODO: Implement macro export
                }
            }
        }
    }
}

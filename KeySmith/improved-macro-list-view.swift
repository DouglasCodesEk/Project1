import SwiftUI

struct MacroListView: View {
    @EnvironmentObject var macroEngine: MacroEngine
    @State private var searchText = ""
    @State private var selectedGroup: MacroGroup?
    @State private var selectedMacro: Macro?
    
    var body: some View {
        HSplitView {
            groupList
            
            macroList
            
            if let macro = selectedMacro {
                MacroDetailView(macro: macro)
            } else {
                Text("Select a macro to view details")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Macros")
        .searchable(text: $searchText, prompt: "Search macros")
    }
    
    var groupList: some View {
        List(selection: $selectedGroup) {
            ForEach(macroEngine.macroGroups) { group in
                Text(group.name)
                    .tag(group)
            }
        }
        .frame(minWidth: 200)
    }
    
    var macroList: some View {
        List(selection: $selectedMacro) {
            ForEach(filteredMacros) { macro in
                MacroRowView(macro: macro)
            }
        }
        .frame(minWidth: 250)
    }
    
    var filteredMacros: [Macro] {
        let groupMacros = selectedGroup?.macros ?? macroEngine.macroGroups.flatMap { $0.macros }
        if searchText.isEmpty {
            return groupMacros
        } else {
            return groupMacros.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct MacroRowView: View {
    let macro: Macro
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(macro.name)
                .font(.headline)
            Text("\(macro.actions.count) actions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

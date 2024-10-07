import SwiftUI
import SwiftData

struct ScriptLibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ScriptHistory.createdAt, order: .reverse) private var scripts: [ScriptHistory]
    @State private var searchText: String = ""
    
    var filteredScripts: [ScriptHistory] {
        if searchText.isEmpty {
            return scripts
        } else {
            return scripts.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        VStack {
            TextField("Search scripts", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .accessibilityIdentifier("searchScriptsTextField")
            
            List {
                ForEach(filteredScripts) { script in
                    VStack(alignment: .leading) {
                        Text(script.name)
                            .font(.headline)
                        Text(script.createdAt, style: .date)
                            .font(.caption)
                    }
                }
                .onDelete(perform: deleteScripts)
            }
            .accessibilityIdentifier("scriptsList")
        }
    }
    
    private func deleteScripts(at offsets: IndexSet) {
        for index in offsets {
            let script = filteredScripts[index]
            if let originalIndex = scripts.firstIndex(where: { $0.id == script.id }) {
                context.delete(scripts[originalIndex])
            }
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete scripts: \(error)")
        }
    }
}

struct ScriptLibraryView_Previews: PreviewProvider {
    static var previews: some View {
        ScriptLibraryView()
    }
}

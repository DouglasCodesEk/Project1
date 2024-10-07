import SwiftUI
import SwiftData

struct ScriptHistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ScriptHistory.createdAt, order: .reverse) private var scripts: [ScriptHistory]
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedScript: ScriptHistory?
    
    var body: some View {
        VStack {
            Text("Saved Scripts")
                .font(.title)
                .padding()
            
            List {
                ForEach(scripts) { script in
                    Button(action: {
                        selectedScript = script
                    }) {
                        VStack(alignment: .leading) {
                            Text(script.name)
                                .font(.headline)
                            Text(script.createdAt, style: .date)
                                .font(.caption)
                        }
                    }
                }
                .onDelete(perform: deleteScripts)
            }
            .accessibilityIdentifier("savedScriptsList")
            
            HStack {
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .accessibilityIdentifier("closeScriptHistoryButton")
            }
        }
        .frame(width: 400, height: 400)
        .sheet(item: $selectedScript) { script in
            ScriptDetailView(script: script)
        }
    }
    
    private func deleteScripts(at offsets: IndexSet) {
        for index in offsets {
            let script = scripts[index]
            context.delete(script)
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete scripts: \(error)")
        }
    }
}

struct ScriptDetailView: View {
    let script: ScriptHistory
    
    var body: some View {
        VStack {
            Text(script.name)
                .font(.title)
                .padding()
            
            ScrollView {
                Text(script.content)
                    .padding()
            }
            
            Button("Copy to Clipboard") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(script.content, forType: .string)
            }
            .padding()
            .accessibilityIdentifier("copyToClipboardButton")
        }
    }
}

struct ScriptHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ScriptHistoryView()
    }
}

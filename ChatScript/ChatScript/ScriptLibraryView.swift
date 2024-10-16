import SwiftUI
import SwiftData

struct ScriptLibraryView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: ScriptHistoryViewModel
    @Environment(\.presentationMode) var presentationMode

    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: ScriptHistoryViewModel(context: context))
    }

    var body: some View {
        VStack {
            Text("Saved Scripts")
                .font(.title)
                .padding()

            List {
                ForEach(viewModel.scripts) { script in
                    Button(action: {
                        viewModel.selectedScript = script
                    }) {
                        VStack(alignment: .leading) {
                            Text(script.name)
                                .font(.headline)
                            Text(script.createdAt, style: .date)
                                .font(.caption)
                        }
                    }
                }
                .onDelete { indexSet in
                    Task {
                        await viewModel.deleteScripts(at: indexSet)
                    }
                }
            }

            HStack {
                Spacer()
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
            }
        }
        .frame(width: 400, height: 400)
        .sheet(item: $viewModel.selectedScript) { script in
            ScriptDetailView(script: script)
        }
        .onAppear {
            Task {
                await viewModel.fetchScripts()
            }
        }
    }
}

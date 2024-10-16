import SwiftUI

struct PresetScriptDetailView: View {
    @ObservedObject var script: PresetScript
    @State private var isEditing = false
    @State private var editedContent: String
    @State private var executionResult: String = ""
    @State private var showExecutionResult: Bool = false

    init(script: PresetScript) {
        self.script = script
        _editedContent = State(initialValue: script.content)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(script.name)
                    .font(.title)

                Text("Category: \(script.category)")
                    .font(.subheadline)

                if isEditing {
                    TextEditor(text: $editedContent)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                } else {
                    Text(script.content)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                HStack {
                    Button(isEditing ? "Save" : "Edit") {
                        if isEditing {
                            saveEditedContent()
                        }
                        isEditing.toggle()
                    }
                    .padding()
                    .background(isEditing ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)

                    Button("Run Script") {
                        runScript(isEditing ? editedContent : script.content)
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                if showExecutionResult {
                    Text("Execution Result:")
                        .font(.headline)
                        .padding([.top, .bottom], 5)

                    Text(executionResult)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .navigationTitle(script.name)
    }

    private func runScript(_ scriptToRun: String) {
        let scriptExecutor = ScriptExecutor()
        do {
            executionResult = try scriptExecutor.execute(script: scriptToRun)
            showExecutionResult = true
        } catch {
            executionResult = "Failed to execute script: \(error.localizedDescription)"
            showExecutionResult = true
        }
    }

    private func saveEditedContent() {
        script.content = editedContent
    }
}

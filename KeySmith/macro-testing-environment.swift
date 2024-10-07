import SwiftUI

struct MacroTestingView: View {
    @EnvironmentObject var macroEngine: MacroEngine
    @EnvironmentObject var contextManager: ContextManager
    @State private var selectedMacro: VersionedMacro?
    @State private var testOutput: String = ""
    @State private var isRunning: Bool = false
    
    var body: some View {
        VStack {
            Text("Macro Testing Environment")
                .font(.title)
            
            Picker("Select Macro", selection: $selectedMacro) {
                ForEach(macroEngine.macroGroups, id: \.self) { group in
                    ForEach(group.macros?.allObjects as? [VersionedMacro] ?? [], id: \.self) { macro in
                        Text(macro.name).tag(macro as VersionedMacro?)
                    }
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Button(action: runSelectedMacro) {
                Text(isRunning ? "Running..." : "Run Macro")
            }
            .disabled(selectedMacro == nil || isRunning)
            
            TextEditor(text: $testOutput)
                .font(.system(.body, design: .monospaced))
                .border(Color.gray, width: 1)
        }
        .padding()
    }
    
    private func runSelectedMacro() {
        guard let macro = selectedMacro else { return }
        
        isRunning = true
        testOutput = "Running macro: \(macro.name)\n"
        
        Task {
            do {
                let testContext = TestMacroExecutionContext(parentContext: contextManager)
                try await macroEngine.runMacro(macro, in: testContext)
                DispatchQueue.main.async {
                    self.testOutput += "Macro completed successfully.\n"
                    self.testOutput += "Actions performed:\n"
                    self.testOutput += testContext.actionLog.joined(separator: "\n")
                    self.isRunning = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.testOutput += "Error: \(error.localizedDescription)\n"
                    self.isRunning = false
                }
            }
        }
    }
}

class TestMacroExecutionContext: MacroExecutionContext {
    var actionLog: [String] = []
    
    override func executeAction(_ action: Action) async throws {
        actionLog.append("Executed: \(String(describing: type(of: action)))")
        // In a real testing environment, you might want to simulate the action
        // rather than actually executing it
    }
}

import SwiftUI
import SwiftData

struct VariablesView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Variable.name, order: .forward) private var variables: [Variable]
    @State private var newVariableName: String = ""
    @State private var newVariableValue: String = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(variables) { variable in
                    HStack {
                        Text(variable.name)
                        Spacer()
                        Text(variable.value)
                    }
                }
                .onDelete(perform: deleteVariables)
            }
            .accessibilityIdentifier("variablesList")
            
            HStack {
                TextField("Name", text: $newVariableName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("newVariableNameTextField")
                TextField("Value", text: $newVariableValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityIdentifier("newVariableValueTextField")
                Button("Add") {
                    addVariable()
                }
                .disabled(newVariableName.isEmpty || newVariableValue.isEmpty)
                .accessibilityIdentifier("addVariableButton")
            }
            .padding()
        }
    }
    
    private func addVariable() {
        guard !newVariableName.isEmpty && !newVariableValue.isEmpty else { return }
        DataManager.shared.saveVariable(newVariableName, value: newVariableValue, context: context)
        newVariableName = ""
        newVariableValue = ""
    }
    
    private func deleteVariables(at offsets: IndexSet) {
        for index in offsets {
            let variable = variables[index]
            context.delete(variable)
        }
        do {
            try context.save()
        } catch {
            print("Failed to delete variables: \(error)")
        }
    }
}

struct VariablesView_Previews: PreviewProvider {
    static var previews: some View {
        VariablesView()
    }
}

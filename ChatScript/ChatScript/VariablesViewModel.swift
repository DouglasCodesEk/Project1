import SwiftUI
import SwiftData

@MainActor
class VariablesViewModel: ObservableObject {
    struct IdentifiableError: Identifiable {
        let id = UUID()
        let message: String
    }

    @Published var variables: [Variable] = []
    @Published var newVariableName: String = ""
    @Published var newVariableValue: String = ""
    @Published var errorMessage: IdentifiableError? = nil

    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchVariables() {
        do {
            variables = try context.fetch(FetchDescriptor<Variable>())
        } catch {
            errorMessage = IdentifiableError(message: "Failed to fetch variables: \(error.localizedDescription)")
        }
    }

    func addVariable() {
        let trimmedName = newVariableName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedValue = newVariableValue.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedValue.isEmpty else { return }

        let newVariable = Variable(name: trimmedName, value: trimmedValue)
        context.insert(newVariable)

        do {
            try context.save()
            variables.append(newVariable)
            newVariableName = ""
            newVariableValue = ""
        } catch {
            errorMessage = IdentifiableError(message: "Failed to add variable: \(error.localizedDescription)")
        }
    }

    func deleteVariables(at offsets: IndexSet) {
        for index in offsets {
            let variable = variables[index]
            context.delete(variable)
        }

        do {
            try context.save()
            variables.remove(atOffsets: offsets)
        } catch {
            errorMessage = IdentifiableError(message: "Failed to delete variables: \(error.localizedDescription)")
        }
    }
}

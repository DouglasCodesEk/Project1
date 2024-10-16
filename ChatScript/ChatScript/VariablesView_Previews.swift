// VariablesView_Previews.swift
import SwiftUI
import SwiftData

struct VariablesView_Previews: PreviewProvider {
    static var previews: some View {
        do {
            let container = try ModelContainer(for: Variable.self)
            let context = container.mainContext
            let viewModel = VariablesViewModel(context: context)
            // Pre-populate with sample data
            viewModel.variables = [
                Variable(name: "Sample Variable 1", value: "Value 1"),
                Variable(name: "Sample Variable 2", value: "Value 2")
            ]
            return VariablesView(context: context)
                .environmentObject(viewModel)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }
}

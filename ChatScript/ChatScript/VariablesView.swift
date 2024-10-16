import SwiftUI
import SwiftData

struct VariablesView: View {
    @StateObject private var viewModel: VariablesViewModel
    @Environment(\.presentationMode) var presentationMode

    init(context: ModelContext) {
        _viewModel = StateObject(wrappedValue: VariablesViewModel(context: context))
    }

    var body: some View {
        VStack {
            List {
                ForEach(viewModel.variables) { variable in
                    HStack {
                        Text(variable.name)
                        Spacer()
                        Text(variable.value)
                    }
                }
                .onDelete { indexSet in
                    viewModel.deleteVariables(at: indexSet)
                }
            }
            .listStyle(InsetListStyle())

            HStack {
                TextField("Name", text: $viewModel.newVariableName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Value", text: $viewModel.newVariableValue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    viewModel.addVariable()
                }
                .disabled(viewModel.newVariableName.isEmpty || viewModel.newVariableValue.isEmpty)
            }
            .padding()

            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .frame(width: 400, height: 300)
        .onAppear {
            viewModel.fetchVariables()
        }
        .alert(item: $viewModel.errorMessage) { errorMessage in
            Alert(
                title: Text("Error"),
                message: Text(errorMessage.message),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
    }
}

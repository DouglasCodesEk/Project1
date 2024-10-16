import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel = AIServiceModelView()
    @State private var showWelcomeScreen = false
    @State private var selectedPermissions: ScriptPermission = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                TextField("Enter your request", text: $viewModel.userInput)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Generate Script") {
                    Task {
                        await viewModel.generateScript()
                    }
                }
                .padding()
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    ProgressView("Generating Script...")
                        .padding()
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }

                if !viewModel.scriptOutput.isEmpty {
                    Text("Generated Script:")
                        .font(.headline)
                        .padding([.top, .bottom], 5)

                    Text(viewModel.scriptOutput)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }

                Text("Using AI Provider: \(viewModel.aiService.provider.rawValue)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding([.bottom])

                Text("Select Script Permissions:")
                    .font(.headline)
                    .padding([.top])

                PermissionsView(selectedPermissions: $selectedPermissions)
                    .frame(height: 200)

                Button("Execute Script") {
                    Task {
                        await viewModel.executeScript(with: selectedPermissions)
                    }
                }
                .padding()
                .disabled(viewModel.isExecuting || viewModel.isLoading || viewModel.scriptOutput.isEmpty)

                if viewModel.isExecuting {
                    ProgressView("Executing Script...")
                        .padding()
                }

                if !viewModel.executionResult.isEmpty {
                    Text("Execution Result:")
                        .font(.headline)
                        .padding([.top, .bottom], 5)

                    Text(viewModel.executionResult)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 800)
        .sheet(isPresented: $showWelcomeScreen) {
            WelcomeView(showWelcomeScreen: $showWelcomeScreen)
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
                showWelcomeScreen = true
                UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            }
        }
    }
}

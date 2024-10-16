import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            APIKeyView()
                .tabItem {
                    Label("API Keys", systemImage: "key")
                }
        }
        .padding()
        .frame(width: 450, height: 400)
    }
}

struct APIKeyView: View {
    @State private var openAIAPIKey: String = ""
    @State private var anthropicAPIKey: String = ""
    @State private var selectedProvider: AIProvider = .anthropicClaudeHaiku
    @State private var showAlert = false

    var body: some View {
        VStack {
            Form {
                Section(header: Text("AI Provider")) {
                    Picker("Select AI Provider", selection: $selectedProvider) {
                        ForEach(AIProvider.allCases) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }
                    .pickerStyle(RadioGroupPickerStyle())
                }

                Section(header: Text("OpenAI API Key")) {
                    SecureField("Enter OpenAI API Key", text: $openAIAPIKey)
                }

                Section(header: Text("Anthropic API Key")) {
                    SecureField("Enter Anthropic API Key", text: $anthropicAPIKey)
                }
            }

            Button("Save") {
                KeychainHelper.saveAPIKey(openAIAPIKey, for: .openAI)
                KeychainHelper.saveAPIKey(anthropicAPIKey, for: .anthropic)
                UserDefaults.standard.set(selectedProvider.rawValue, forKey: "SelectedAIProvider")
                showAlert = true
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Success"), message: Text("Settings saved successfully."), dismissButton: .default(Text("OK")))
            }
        }
        .onAppear {
            openAIAPIKey = KeychainHelper.getAPIKey(for: .openAI) ?? ""
            anthropicAPIKey = KeychainHelper.getAPIKey(for: .anthropic) ?? ""
            if let providerRawValue = UserDefaults.standard.string(forKey: "SelectedAIProvider"),
               let provider = AIProvider(rawValue: providerRawValue) {
                selectedProvider = provider
            }
        }
        .padding()
    }
}

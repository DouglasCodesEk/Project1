import SwiftUI

struct SettingsView: View {
    var body: some View {
        TabView {
            APIKeyView()
                .tabItem {
                    Label("API Keys", systemImage: "key")
                }
            
            VariablesView()
                .tabItem {
                    Label("Variables", systemImage: "variable")
                }
            
            ScriptHistoryView()
                .tabItem {
                    Label("Script History", systemImage: "doc.text")
                }
        }
        .padding()
        .frame(width: 450, height: 300)
    }
}

struct APIKeyView: View {
    @State private var anthropicAPIKey: String = ""
    @State private var openAIAPIKey: String = ""
    @State private var googleAIAPIKey: String = ""
    
    var body: some View {
        Form {
            SecureField("Anthropic API Key", text: $anthropicAPIKey)
                .onChange(of: anthropicAPIKey) { newValue in
                    KeychainHelper.saveAPIKey(newValue, for: .anthropic)
                }
                .onAppear {
                    anthropicAPIKey = KeychainHelper.getAPIKey(for: .anthropic) ?? ""
                }
                .accessibilityIdentifier("anthropicAPIKeySecureField")
            
            SecureField("OpenAI API Key", text: $openAIAPIKey)
                .onChange(of: openAIAPIKey) { newValue in
                    KeychainHelper.saveAPIKey(newValue, for: .openAI)
                }
                .onAppear {
                    openAIAPIKey = KeychainHelper.getAPIKey(for: .openAI) ?? ""
                }
                .accessibilityIdentifier("openAIAPIKeySecureField")
            
            SecureField("Google AI API Key", text: $googleAIAPIKey)
                .onChange(of: googleAIAPIKey) { newValue in
                    KeychainHelper.saveAPIKey(newValue, for: .googleAI)
                }
                .onAppear {
                    googleAIAPIKey = KeychainHelper.getAPIKey(for: .googleAI) ?? ""
                }
                .accessibilityIdentifier("googleAIAPIKeySecureField")
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

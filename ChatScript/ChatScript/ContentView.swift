import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum AIProvider: String, CaseIterable {
    case anthropic = "Anthropic"
    case openAI = "OpenAI"
    case googleAI = "Google AI"
}

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @AppStorage("hasSeenWelcomeScreen") private var hasSeenWelcomeScreen = false
    @State private var showWelcomeScreen = false
    @State private var userInput: String = ""
    @State private var scriptOutput: String = ""
    @State private var executionResult: String = ""
    @State private var selectedAI: AIProvider = .anthropic
    @State private var isVariablesWindowOpen: Bool = false
    @State private var isScriptLibraryOpen: Bool = false
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    var body: some View {
        ZStack {
            mainView
            
            if showWelcomeScreen {
                WelcomeView(showWelcomeScreen: $showWelcomeScreen)
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .onAppear {
            if !hasSeenWelcomeScreen {
                showWelcomeScreen = true
                hasSeenWelcomeScreen = true
            }
        }
    }
    
    var mainView: some View {
        VStack(spacing: 10) {
            HStack {
                Text("ChatScripts").font(.title)
                Spacer()
                Button(action: { showWelcomeScreen = true }) {
                    Image(systemName: "questionmark.circle")
                }
                .accessibilityIdentifier("welcomeButton")
            }
            
            Picker("AI Provider", selection: $selectedAI) {
                ForEach(AIProvider.allCases, id: \.self) { provider in
                    Text(provider.rawValue).tag(provider)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .accessibilityIdentifier("aiProviderPicker")
            
            TextEditor(text: $userInput)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .padding(.horizontal)
                .accessibilityIdentifier("userInputTextEditor")
            
            HStack {
                Button("Generate Script") { sendRequest() }
                    .accessibilityIdentifier("generateScriptButton")
                Button("Execute Script") { executeScript() }
                    .disabled(scriptOutput.isEmpty)
                    .accessibilityIdentifier("executeScriptButton")
                Button("Save Script") { saveScript() }
                    .disabled(scriptOutput.isEmpty)
                    .accessibilityIdentifier("saveScriptButton")
            }
            .padding(.horizontal)
            
            Text("Generated AppleScript:")
                .font(.headline)
                .padding(.top, 10)
            
            TextEditor(text: $scriptOutput)
                .frame(height: 150)
                .border(Color.gray, width: 1)
                .padding(.horizontal)
                .accessibilityIdentifier("scriptOutputTextEditor")
            
            Text("Execution Result:")
                .font(.headline)
                .padding(.top, 10)
            
            TextEditor(text: $executionResult)
                .frame(height: 100)
                .border(Color.gray, width: 1)
                .padding(.horizontal)
                .accessibilityIdentifier("executionResultTextEditor")
            
            if isLoading {
                ProgressView()
                    .padding()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            HStack {
                Button("Variables") { isVariablesWindowOpen.toggle() }
                    .accessibilityIdentifier("variablesButton")
                Button("Script Library") { isScriptLibraryOpen.toggle() }
                    .accessibilityIdentifier("scriptLibraryButton")
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(width: 400, height: 700)
        .sheet(isPresented: $isVariablesWindowOpen) { VariablesView() }
        .sheet(isPresented: $isScriptLibraryOpen) { ScriptHistoryView() }
    }
    
    func sendRequest() {
        isLoading = true
        errorMessage = nil
        executionResult = ""
        let aiService = AIService(provider: selectedAI)
        
        aiService.generateScript(from: userInput) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let script):
                    if script.isEmpty {
                        errorMessage = "No AppleScript could be generated for the given input."
                    } else {
                        scriptOutput = script
                    }
                case .failure(let error):
                    errorMessage = "Error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func executeScript() {
        guard !scriptOutput.isEmpty else {
            errorMessage = "No script to execute"
            return
        }
        
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let result = ScriptExecutor.execute(scriptOutput)
            
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let output):
                    executionResult = output
                case .failure(let error):
                    executionResult = "Execution Error: \(error)"
                }
            }
        }
    }
    
    func saveScript() {
        guard !scriptOutput.isEmpty else {
            errorMessage = "No script to save"
            return
        }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [UTType.appleScript]
        savePanel.canCreateDirectories = true
        savePanel.nameFieldStringValue = "ChatScript.scpt"
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                let compileResult = ScriptExecutor.compileAndSave(scriptOutput, to: url)
                let saveResult = DataManager.shared.saveScript(scriptOutput, name: url.lastPathComponent, context: context)
                
                switch compileResult {
                case .success:
                    switch saveResult {
                    case .success:
                        DispatchQueue.main.async {
                            self.executionResult = "Script saved successfully."
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            self.errorMessage = "Error saving script: \(error.localizedDescription)"
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.errorMessage = "Error compiling script: \(error)"
                    }
                }
            }
        }
    }
}

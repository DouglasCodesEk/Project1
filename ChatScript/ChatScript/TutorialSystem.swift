import SwiftUI

@MainActor
class TutorialSystem: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var isActive: Bool = false

    let steps: [TutorialStep] = [
        TutorialStep(title: "Welcome to ChatScripts",
                     description: "Let's walk through how to create and execute your first script.",
                     action: .showWelcome),
        TutorialStep(title: "Enter Your Request",
                     description: "Type a description of what you want your script to do.",
                     action: .focusOnInput),
        TutorialStep(title: "Generate Script",
                     description: "Click the 'Generate Script' button to create your AppleScript.",
                     action: .highlightGenerateButton),
        TutorialStep(title: "Review Your Script",
                     description: "Look over the generated script. You can make changes if needed.",
                     action: .focusOnOutput),
        TutorialStep(title: "Execute Script",
                     description: "When you're ready, click 'Execute Script' to run it.",
                     action: .highlightExecuteButton),
        TutorialStep(title: "Congratulations!",
                     description: "You've created and run your first script with ChatScripts!",
                     action: .showCompletion)
    ]

    func start() {
        currentStep = 0
        isActive = true
    }

    func nextStep() {
        if currentStep < steps.count - 1 {
            currentStep += 1
        } else {
            isActive = false
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
}

struct TutorialStep {
    let title: String
    let description: String
    let action: TutorialAction
}

enum TutorialAction {
    case showWelcome
    case focusOnInput
    case highlightGenerateButton
    case focusOnOutput
    case highlightExecuteButton
    case showCompletion
}

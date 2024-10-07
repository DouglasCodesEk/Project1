import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcomeScreen: Bool
    @State private var currentPage = 0
    
    let pages = [
        WelcomePage(title: "Welcome to ChatScripts", content: "ChatScripts uses AI to generate and execute AppleScripts based on your natural language input.", imageName: "wand.and.stars"),
        WelcomePage(title: "API Keys", content: "To use ChatScripts, you'll need an API key from either OpenAI, Anthropic, or Google AI. Enter your key in the Settings.", imageName: "key"),
        WelcomePage(title: "Generate Scripts", content: "Simply type what you want your AppleScript to do, and AI will generate it for you.", imageName: "text.bubble"),
        WelcomePage(title: "Execute or Copy", content: "You can execute the generated script directly or copy it for use elsewhere.", imageName: "play.circle"),
    ]

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { showWelcomeScreen = false }) {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.gray)
                        .accessibilityIdentifier("closeWelcomeViewButton")
                }
            }
            .padding(.top)
            
            WelcomePageView(page: pages[currentPage])
                .transition(.slide)
                .animation(.easeInOut, value: currentPage)
                .accessibilityIdentifier("welcomePageView")
            
            HStack {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                    .accessibilityIdentifier("previousPageButton")
                }
                
                Spacer()
                
                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                    .accessibilityIdentifier("nextPageButton")
                } else {
                    Button("Get Started") {
                        showWelcomeScreen = false
                    }
                    .accessibilityIdentifier("getStartedButton")
                }
            }
            .padding()
            
            ProgressView(value: Double(currentPage + 1), total: Double(pages.count))
                .padding(.horizontal)
                .accessibilityIdentifier("welcomeProgressView")
        }
        .frame(width: 400, height: 300)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct WelcomePage {
    let title: String
    let content: String
    let imageName: String
}

struct WelcomePageView: View {
    let page: WelcomePage
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: page.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 60, height: 60)
                .foregroundColor(.blue)
                .accessibilityIdentifier("welcomeImage")
            
            Text(page.title)
                .font(.title)
                .fontWeight(.bold)
                .accessibilityIdentifier("welcomeTitle")
            
            Text(page.content)
                .multilineTextAlignment(.center)
                .padding()
                .accessibilityIdentifier("welcomeContent")
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(showWelcomeScreen: .constant(true))
    }
}

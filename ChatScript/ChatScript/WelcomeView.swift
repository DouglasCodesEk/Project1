import SwiftUI

struct WelcomeView: View {
    @Binding var showWelcomeScreen: Bool
    @State private var currentPage = 0

    let pages = [
        WelcomePage(title: "Welcome to ChatScripts", content: "ChatScripts uses AI to generate and execute AppleScripts based on your natural language input.", imageName: "wand.and.stars"),
        WelcomePage(title: "Set Up Your API Key", content: "Before you begin, you'll need to enter your API key. Go to Settings > API Keys to enter your OpenAI or Anthropic API key.", imageName: "key"),
        WelcomePage(title: "Choose Your AI", content: "Select between OpenAI's GPT-3.5 Turbo or Anthropic's Claude models for script generation.", imageName: "cpu"),
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
                }
            }
            .padding(.top)

            WelcomePageView(page: pages[currentPage])
                .transition(.slide)
                .animation(.easeInOut, value: currentPage)

            HStack {
                if currentPage > 0 {
                    Button("Previous") {
                        withAnimation {
                            currentPage -= 1
                        }
                    }
                }

                Spacer()

                if currentPage < pages.count - 1 {
                    Button("Next") {
                        withAnimation {
                            currentPage += 1
                        }
                    }
                } else {
                    Button("Get Started") {
                        showWelcomeScreen = false
                    }
                }
            }
            .padding()

            ProgressView(value: Double(currentPage + 1), total: Double(pages.count))
                .padding(.horizontal)
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

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)

            Text(page.content)
                .multilineTextAlignment(.center)
                .padding()
        }
    }
}

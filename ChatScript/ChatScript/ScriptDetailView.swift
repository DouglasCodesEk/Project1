import SwiftUI

struct ScriptDetailView: View {
    let script: ScriptHistory

    var body: some View {
        VStack {
            Text(script.name)
                .font(.title)
                .padding()

            ScrollView {
                Text(script.content)
                    .padding()
            }

            Button("Copy to Clipboard") {
                copyScriptToClipboard(script)
            }
            .padding()
        }
    }

    private func copyScriptToClipboard(_ script: ScriptHistory) {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(script.content, forType: .string)
    }
}

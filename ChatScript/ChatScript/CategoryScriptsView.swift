import SwiftUI

struct CategoryScriptsView: View {
    let category: String
    let scripts: [PresetScript]

    var body: some View {
        List(scripts) { script in
            NavigationLink(destination: PresetScriptDetailView(script: script)) {
                Text(script.name)
            }
        }
        .navigationTitle(category)
        .frame(minWidth: 400, minHeight: 600)
    }
}

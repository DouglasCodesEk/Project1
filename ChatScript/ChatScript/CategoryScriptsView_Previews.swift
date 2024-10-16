// CategoryScriptsView.swift
import SwiftUI

struct CategoryScriptsView_Previews: PreviewProvider {
    static var previews: some View {
        CategoryScriptsView(category: "Utility", scripts: [
            PresetScript(name: "Activate Finder", category: "Utility", content: "tell application \"Finder\"\n    activate\nend tell")
        ])
    }
}

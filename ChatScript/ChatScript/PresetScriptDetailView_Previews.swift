// PresetScriptDetailView_Previews.swift
import SwiftUI
import SwiftData

struct PresetScriptDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PresetScriptDetailView(script: PresetScript(name: "Sample Script", category: "Utility", content: "tell application \"Finder\"\n    activate\nend tell"))
    }
}

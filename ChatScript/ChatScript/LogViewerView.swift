// LogViewerView.swift

import SwiftUI

struct LogViewerView: View {
    @State private var logContent: String = "Loading logs..."

    var body: some View {
        ScrollView {
            Text(logContent)
                .font(.system(.body, design: .monospaced))
                .padding()
        }
        .onAppear {
            if let logs = Logger.shared.getLogs() {
                logContent = logs
            } else {
                logContent = "No logs available."
            }
        }
        .frame(minWidth: 600, minHeight: 400)
        .navigationTitle("Application Logs")
    }
}

import SwiftUI

struct UploadTransactionsView: View {
    @State private var showFileImporter = false
    @State private var selectedFileURL: URL?

    var body: some View {
        VStack {
            Text("Upload CSV Transactions")
                .font(.largeTitle)
            Button(action: {
                self.showFileImporter = true
            }) {
                Text("Select CSV File")
            }
            .padding()
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        self.selectedFileURL = url
                        parseCSV(at: url)
                    }
                case .failure(let error):
                    print("Failed to select file: \(error.localizedDescription)")
                }
            }
            if let url = selectedFileURL {
                Text("Selected File: \(url.lastPathComponent)")
            }
        }
        .padding()
    }

    func parseCSV(at url: URL) {
        // Implement CSV parsing logic
        CSVParser.shared.parseCSV(at: url)
    }
}
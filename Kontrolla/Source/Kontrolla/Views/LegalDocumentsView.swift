import SwiftUI

struct LegalDocumentsView: View {
    var body: some View {
        VStack {
            Text("Terms of Service")
                .font(.largeTitle)
            ScrollView {
                Text("Your Terms of Service go here...")
            }
        }
        .padding()
    }
}
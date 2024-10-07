import SwiftUI

struct SettingsView: View {
    @State private var selectedVATRate: VATRate = .standard

    var body: some View {
        Form {
            Section(header: Text("VAT Settings")) {
                Picker("Default VAT Rate", selection: $selectedVATRate) {
                    Text("Standard (25%)").tag(VATRate.standard)
                    Text("Reduced (12%)").tag(VATRate.reduced)
                    Text("Low (6%)").tag(VATRate.low)
                    Text("Zero (0%)").tag(VATRate.zero)
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            Section {
                Button(action: {
                    // Save settings
                }) {
                    Text("Save Settings")
                }
            }
        }
        .padding()
    }
}
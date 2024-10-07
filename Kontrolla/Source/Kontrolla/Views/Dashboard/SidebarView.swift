import SwiftUI

struct SidebarView: View {
    var body: some View {
        List {
            NavigationLink(destination: DashboardContentView()) {
                Label("Dashboard", systemImage: "rectangle.grid.2x2")
            }
            NavigationLink(destination: UploadTransactionsView()) {
                Label("Upload Transactions", systemImage: "tray.and.arrow.up")
            }
            NavigationLink(destination: ReportsView()) {
                Label("Reports", systemImage: "doc.plaintext")
            }
            NavigationLink(destination: SettingsView()) {
                Label("Settings", systemImage: "gear")
            }
        }
        .listStyle(SidebarListStyle())
    }
}
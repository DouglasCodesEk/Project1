import SwiftUI

struct MainDashboardView: View {
    var body: some View {
        NavigationView {
            SidebarView()
            DashboardContentView()
        }
    }
}
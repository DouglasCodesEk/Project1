import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var session: SessionStore

    var body: some View {
        Group {
            if session.user != nil {
                if session.user?.isEmailVerified == true {
                    MainDashboardView()
                } else {
                    EmailVerificationView()
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            self.session.listen()
        }
    }
}
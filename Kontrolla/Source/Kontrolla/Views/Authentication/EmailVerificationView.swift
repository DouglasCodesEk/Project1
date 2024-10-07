import SwiftUI
import FirebaseAuth

struct EmailVerificationView: View {
    @EnvironmentObject var session: SessionStore
    @State private var errorMessage = ""
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text("Please Verify Your Email")
                .font(.title)
            Text("We have sent a verification email to \(session.user?.email ?? ""). Please verify your email to continue.")
                .padding()
            Button(action: {
                Auth.auth().currentUser?.reload(completion: { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        self.showAlert = true
                    } else if Auth.auth().currentUser?.isEmailVerified == true {
                        self.session.user = Auth.auth().currentUser
                    } else {
                        self.errorMessage = "Email not verified yet."
                        self.showAlert = true
                    }
                })
            }) {
                Text("I've Verified")
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Alert"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            Button(action: {
                session.signOut()
            }) {
                Text("Logout")
            }
            .padding()
        }
    }
}
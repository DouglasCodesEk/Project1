import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var session: SessionStore
    @Environment(\.presentationMode) var presentationMode
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showVerificationAlert = false

    var body: some View {
        VStack {
            Text("Create Account")
                .font(.largeTitle)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            Button(action: {
                session.signUp(email: email, password: password) { error in
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                    } else {
                        self.showVerificationAlert = true
                    }
                }
            }) {
                Text("Sign Up")
            }
            .padding()
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .alert(isPresented: $showVerificationAlert) {
            Alert(
                title: Text("Verify Your Email"),
                message: Text("A verification email has been sent to \(email). Please verify to continue."),
                dismissButton: .default(Text("OK")) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}
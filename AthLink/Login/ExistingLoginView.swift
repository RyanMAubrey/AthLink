import SwiftUI

struct ExistingLoginView: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var userEmail: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMSG: String?
    @State private var signingIn: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Logo
            Image("athlinklogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .padding(.bottom, 8)

            Text("Welcome Back")
                .font(.title2)
                .fontWeight(.bold)

            Text("Sign in to your account")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 24)

            // Form card
            VStack(spacing: 16) {
                // Email
                VStack(alignment: .leading, spacing: 6) {
                    Text("Email")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    TextField("you@example.com", text: $userEmail)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                }

                // Password
                VStack(alignment: .leading, spacing: 6) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    SecureField("Enter password", text: $password)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .textContentType(.password)
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            .padding(.horizontal, 24)

            // Log In Button
            Button(action: {
                let email = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                let pw = password.trimmingCharacters(in: .whitespacesAndNewlines)

                guard !signingIn else { return }
                signingIn = true

                guard !email.isEmpty else {
                    alertMSG = "Please enter your email address"
                    showAlert = true
                    signingIn = false
                    return
                }

                guard !pw.isEmpty else {
                    alertMSG = "Please enter your password"
                    showAlert = true
                    signingIn = false
                    return
                }

                guard email.contains("@") && email.contains(".") else {
                    alertMSG = "Please enter a valid email address"
                    showAlert = true
                    signingIn = false
                    return
                }

                guard pw.count >= 6 else {
                    alertMSG = "Password must be at least 6 characters"
                    showAlert = true
                    signingIn = false
                    return
                }

                Task {
                    // Turn off auth suppressor and signing in
                    defer {
                        Task { @MainActor in
                            signingIn = false
                            rootView.suppressAuthListener = false
                        }
                    }
                    // Supress auth listener
                    rootView.suppressAuthListener = true
                    do {
                        // Sign in
                        let _ = try await rootView.client.auth.signIn(
                            email: email,
                            password: pw
                        )
                        // Load front end
                        try await rootView.loadProfile()
                        // Set correct root view
                        await MainActor.run {
                            rootView.rootView = rootView.profile.coachAccount
                                ? .Coach
                                : .Home
                        }
                    } catch {
                        print("Sign in failed:", error)
                        alertMSG = error.localizedDescription
                        showAlert = true
                    }
                }
            }) {
                HStack {
                    if signingIn {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                    Text("Log In")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(signingIn)
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Invalid Credentials"), message: Text(alertMSG ?? "Unknown"))
            }

            // Sign Up Button
            Button(action: {
                userEmail = ""
                password = ""
                rootView.path.append("Sign")
            }) {
                Text("Don't have an account? Sign Up")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            .padding(.top, 16)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

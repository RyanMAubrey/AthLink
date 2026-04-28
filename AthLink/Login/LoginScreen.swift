import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var rootView: RootViewObj
    // Draft if needed for coach account
    @EnvironmentObject var signupDraft: SignupDraft
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var whosUsing: String = "Athlete"
    @State private var whosUsingOptions = ["Athlete", "Parent", "Coach"]
    @State private var userEmail: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = "Please fill in every field"
    @State private var signingUp: Bool = false
    private enum Field { case firstName, lastName, email, password }
    @State private var invalidFields: Set<Field> = []
    @State private var shakeToken: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    // Logo
                    Image("athlinklogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.top, 20)

                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Join AthLink today")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Form card
                    VStack(spacing: 16) {
                        // Who's Using
                        VStack(alignment: .leading, spacing: 6) {
                            Text("I am a...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            Picker("Select user", selection: $whosUsing) {
                                ForEach(whosUsingOptions, id: \.self) { option in
                                    Text(option).tag(option)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }

                        // First Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("First Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            TextField("First name", text: $firstName)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(invalidFields.contains(.firstName) ? .red : .clear, lineWidth: 2)
                                )
                                .modifier(ShakeEffect(shakes: invalidFields.contains(.firstName) ? CGFloat(shakeToken) : 0))
                        }

                        // Last Name
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Last Name")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            TextField("Last name", text: $lastName)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .textInputAutocapitalization(.words)
                                .autocorrectionDisabled(true)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(invalidFields.contains(.lastName) ? .red : .clear, lineWidth: 2)
                                )
                                .modifier(ShakeEffect(shakes: invalidFields.contains(.lastName) ? CGFloat(shakeToken) : 0))
                        }

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
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(invalidFields.contains(.email) ? .red : .clear, lineWidth: 2)
                                )
                                .modifier(ShakeEffect(shakes: invalidFields.contains(.email) ? CGFloat(shakeToken) : 0))
                        }

                        // Password
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            SecureField("Create a password", text: $password)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .autocorrectionDisabled(true)
                                .textInputAutocapitalization(.never)
                                .textContentType(.password)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(invalidFields.contains(.password) ? .red : .clear, lineWidth: 2)
                                )
                                .modifier(ShakeEffect(shakes: invalidFields.contains(.password) ? CGFloat(shakeToken) : 0))
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)

                    // Sign Up Button
                    Button(action: {
                        guard !signingUp else { return }
                        signingUp = true
                        // Checks for valid fields and alerts if invalid
                        invalidFields = []
                        if let error = validateForm() {
                            alertMessage = error
                            showAlert = true
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                                shakeToken += 1
                            }
                            signingUp = false
                            return
                        }
                        // If signing up as coach fill draft and append coach login
                        if whosUsing == "Coach" {
                            signupDraft.firstName = firstName
                            signupDraft.lastName = lastName
                            signupDraft.userType = whosUsing
                            signupDraft.email = userEmail
                            signupDraft.password = password
                            rootView.path.append("Coach")
                            signingUp = false
                            return
                        }
                        Task {
                            // Turn off auth suppressor and signing in
                            defer { Task { @MainActor in
                                signingUp = false
                                rootView.suppressAuthListener = false
                                        }
                            }
                            rootView.suppressAuthListener = true
                            do {
                                let email = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
                                let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
                                let res = try await rootView.client.auth.signUp(
                                    email: email,
                                    password: pass
                                )
                                // If the server requires email verification, asks to check for it
                                if res.session == nil {
                                    await MainActor.run {
                                        alertMessage = "Check your email to confirm your account, then log in"
                                        showAlert = true
                                    }
                                    return
                                }
                                // Update frontend
                                let row = Profile(
                                    id: res.user.id,
                                    firstName: firstName,
                                    lastName: lastName,
                                    userType: whosUsing
                                )
                                _ = try await rootView.client
                                    .from("profiles")
                                    .insert(row)
                                    .execute()
                                try await rootView.loadProfile()
                                // Set to athlete rootview
                                await MainActor.run {
                                    rootView.path = NavigationPath()
                                    rootView.rootView = .Home
                                }
                            } catch {
                                // Sets alert for common issues or a simple failed
                                let msg = String(describing: error)
                                await MainActor.run {
                                    if msg.contains("user_already_exists") || msg.contains("User already registered") {
                                        alertMessage = "That email already has an account, try logging in"
                                    } else {
                                        alertMessage = "Signup failed: \(error.localizedDescription)"
                                    }
                                    showAlert = true
                                }
                            }
                        }
                    }) {
                        HStack {
                            if signingUp {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(signingUp)
                    .padding(.horizontal, 24)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Signup"), message: Text(alertMessage))
                    }

                    // Terms
                    VStack(spacing: 4) {
                        Text("By clicking 'Sign Up' you agree to our")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 4) {
                            Button(action: { rootView.path.append("Terms") }) {
                                Text("Terms of Service")
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                            Text("and")
                            Button(action: { rootView.path.append("Privacy") }) {
                                Text("Privacy Policy")
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                        }
                        .font(.caption)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }

    func validateForm() -> String? {
        let email = userEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)

        if firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidFields.insert(.firstName)
            return "Please enter your first name"
        }
        if lastName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            invalidFields.insert(.lastName)
            return "Please enter your last name"
        }
        if email.isEmpty {
            invalidFields.insert(.email)
            return "Please enter your email address"
        }
        if !email.contains("@") || !email.contains(".") {
            invalidFields.insert(.email)
            return "Please enter a valid email address"
        }
        if pass.isEmpty {
            invalidFields.insert(.password)
            return "Please enter a password"
        }
        if pass.count < 6 {
            invalidFields.insert(.password)
            return "Password must be at least 6 characters"
        }
        return nil
    }
}

struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    func effectValue(size: CGSize) -> ProjectionTransform {
        let x = 8 * sin(shakes * .pi * 2)
        return ProjectionTransform(CGAffineTransform(translationX: x, y: 0))
    }
}

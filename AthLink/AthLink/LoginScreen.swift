import SwiftUI

struct LoginScreen: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var signupDraft: SignupDraft
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var whosUsing: String = "Athlete"
    @State private var whosUsingOptions = ["Athlete", "Parent", "Coach"]
    @State private var postalCode: String = ""
    @State private var userEmail: String = ""
    @State private var userPhone: String?
    @State private var password: String = ""
    @State private var showAlert: Bool = false

    // Overlay
    private enum Field { case firstName, lastName, postal, email, password }
    @State private var invalidFields: Set<Field> = []
    @State private var shakeToken: Int = 0

    var body: some View {
        VStack {
            Image("athlinklogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            ScrollView(.vertical){
                VStack {
                    VStack (alignment: .leading) {
                        Text("Who's Using?")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.bottom, -10)
                        ZStack {
                            Picker("Select user", selection: $whosUsing) {
                                ForEach(whosUsingOptions, id: \.self) { whosUsingOptions in
                                    Text(whosUsingOptions).tag(whosUsingOptions)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        .background(Color(red: 0.95, green: 0.95, blue: 0.95))
                        .cornerRadius(8)
                        .padding(.horizontal, 20)
                        .padding(.bottom, -15)
                        // First Name Field
                        Text("First Name")
                            .font(.headline)
                            .padding(.top, 10)
                            .padding(.horizontal, 20)
                        TextField("Enter text", text: $firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            // Overlay
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(invalidFields.contains(.firstName) ? .red : .clear, lineWidth: 2)
                            )
                            .modifier(ShakeEffect(shakes: invalidFields.contains(.firstName) ? CGFloat(shakeToken) : 0))
                        // Last Name Field
                        Text("Last Name")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        TextField("Enter text", text: $lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .textInputAutocapitalization(.words)
                            .autocorrectionDisabled(true)
                            // Overlay
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(invalidFields.contains(.lastName) ? .red : .clear, lineWidth: 2)
                            )
                            .modifier(ShakeEffect(shakes: invalidFields.contains(.lastName) ? CGFloat(shakeToken) : 0))
                        // Postal Code Field
                        Text("Postal Code")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        TextField("Enter text", text: $postalCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            // Overlay
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(invalidFields.contains(.postal) ? .red : .clear, lineWidth: 2)
                            )
                            .modifier(ShakeEffect(shakes: invalidFields.contains(.postal) ? CGFloat(shakeToken) : 0))
                        // Email Field
                        Text("Email")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        TextField("Enter text", text: $userEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            // Overlay
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(invalidFields.contains(.email) ? .red : .clear, lineWidth: 2)
                            )
                            .modifier(ShakeEffect(shakes: invalidFields.contains(.email) ? CGFloat(shakeToken) : 0))
                        // Phone Field
                        Text("Phone (optional)")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        TextField("Enter text", text: Binding(
                            get: { userPhone ?? "" },
                            set: { userPhone = $0.isEmpty ? nil : $0 }
                        ))
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                        // Password Field
                        Text("Password")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        SecureField("Enter text", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                            .autocorrectionDisabled(true)
                            .textInputAutocapitalization(.never)
                            .textContentType(.password)
                            // Overlay
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(invalidFields.contains(.password) ? .red : .clear, lineWidth: 2)
                            )
                            .modifier(ShakeEffect(shakes: invalidFields.contains(.password) ? CGFloat(shakeToken) : 0))
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 5)
                    .padding(.top, 11)
                    
                    Spacer()
                    
                    Button(action: {
                        if filledForm() {
                            if whosUsing == "Coach" {
                                signupDraft.firstName = firstName
                                signupDraft.lastName = lastName
                                signupDraft.userType = whosUsing
                                signupDraft.postalCode = postalCode
                                signupDraft.phoneNumber = userPhone
                                signupDraft.email = userEmail
                                signupDraft.password = password
                                rootView.path.append("Coach")
                            } else {
                                Task {
                                    do {
                                        // Signup new user
                                        let res = try await rootView.client.auth.signUp(
                                               email: userEmail,
                                               password: password
                                             )
                                        // Ensure authenticated session
                                          guard res.session != nil else {
                                            throw NSError(domain: "Auth", code: 0,
                                              userInfo: [NSLocalizedDescriptionKey: "Not signed in after signup (email confirmation still on or session not set)."])
                                          }
                                        // Save the rest of the info
                                        let row = Profile(
                                            id: res.user.id,
                                            firstName: firstName,
                                            lastName: lastName,
                                            coachAccount: false,
                                            phoneNumber: userPhone,
                                            userType: whosUsing,
                                            postalCode: postalCode
                                        )
                                        try await rootView.client
                                          .from("profiles")
                                          .insert(row)
                                          .execute()
                                        // Load the profile data
                                        try await rootView.loadProfile()
                                        // Change root view
                                        rootView.rootView = .Home
                                    } catch {
                                        print("Signup failed:", error)
                                    }
                                }
                            }
                        } else {
                            showAlert = true
                            // Highlight and shake
                            invalidFields = []
                            if firstName.isEmpty { invalidFields.insert(.firstName) }
                            if lastName.isEmpty  { invalidFields.insert(.lastName) }
                            if postalCode.isEmpty { invalidFields.insert(.postal) }
                            if userEmail.isEmpty { invalidFields.insert(.email) }
                            if password.isEmpty  { invalidFields.insert(.password) }
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.45)) {
                                shakeToken += 1
                            }
                        }
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(.horizontal, 100)
                    }
                    .alert(isPresented:$showAlert) {
                        Alert(title: Text("Missing Info"), message: Text("Please  fill in every field"))
                    }
                    
                }
                
                Text("By clicking ‘Sign Up’ or using Athlink, you are agreeing to our")
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
                
                
                HStack(spacing: 4) {
                    Button(action: {
                        rootView.path.append("Terms")
                    }) {
                        Text("Terms of Service")
                            .underline()
                            .foregroundColor(.blue)
                    }
                    
                    Text("and")
                    
                    Button(action: {
                        rootView.path.append("Privacy")
                    }) {
                        Text("Privacy Policy")
                            .underline()
                            .foregroundColor(.blue)
                    }
                }
                
            }
            .font(.system(size: 10))
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
    func filledForm() -> Bool {
        return self.firstName != "" && self.lastName != "" && self.postalCode != "" && self.userEmail != "" && self.password != ""
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

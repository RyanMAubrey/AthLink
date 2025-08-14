//
//  ExistingLoginView.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 6/17/24.
//

import SwiftUI


struct ExistingLoginView: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var userEmail: String = ""
    @State private var password: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMSG: String?

    var body: some View {
        VStack {
            Image("athlinklogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            ScrollView(.vertical) {
                VStack {
                    VStack (alignment: .leading) {
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
                            .textContentType(.password)
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
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 5)
                    .padding(.top, 11)
                    
                    Button(action: {
                        if !userEmail.isEmpty && !password.isEmpty {
                            Task {
                                do {
                                    // Sign into backend
                                    let _ = try await rootView.client.auth.signIn(
                                      email: userEmail,
                                      password: password
                                    )
                                    // Load the profile from Postgres
                                    try await rootView.loadProfile()
                                    // Route the correct rootview
                                    rootView.rootView = rootView.profile.coachAccount
                                      ? .Coach
                                      : .Home
                                } catch {
                                    // catch with error
                                    alertMSG = error.localizedDescription
                                    showAlert = true
                                }
                            }
                        } else {
                            alertMSG = "The Username or Password was invalid"
                            showAlert = true
                        }
                    }) {
                        Text("Log In")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(.horizontal, 100)
                            .padding(.top, 10)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Invalid Credentials"), message: Text(alertMSG ?? "Uknown"))
                    }  
                    Button(action: {
                        userEmail = ""
                        password = ""
                        rootView.path.append("Sign")
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(.horizontal, 100)
                            .padding(.top, 10)
                    }
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
        .onAppear() {
            rootView.checkLocationEnabled()
        }
    }
}

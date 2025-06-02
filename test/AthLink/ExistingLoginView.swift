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
   
    let validEmail = "Admin"
    let validPassword = "test"

    var body: some View {
        VStack {
            Image("athlinklogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            ScrollView(.vertical) {
                VStack {
                    VStack (alignment: .leading) {
                        Text("Email")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        TextField("Enter text", text: $userEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                        
                        Text("Password")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        SecureField("Enter text", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 20)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 5)
                    .padding(.top, 11)
                    
                    Button(action: {
                        if validateLogin() {
                            rootView.rootView = .Home
                        } else {
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
                    .alert(isPresented: $showAlert){
                        Alert(title: Text("Invalid Credentials"), message: Text("Email and/or password invalid"))
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
    }
    func validateLogin() -> Bool {
        return self.userEmail == validEmail && self.password == validPassword
    }
}


#Preview {
    ExistingLoginView()
        .environmentObject(RootViewObj())
}

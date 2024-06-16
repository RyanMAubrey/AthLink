//
//  LoginScreen.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 6/7/24.
//

import SwiftUI

struct LoginScreen: View {
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var whosUsing: String = ""
    @State private var postalCode: String = ""
    @State private var userEmail: String = ""
    @State private var password: String = ""
    
    
    var body: some View {
        
        NavigationView {
            
            VStack {
                
                Image("athlinklogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                
                VStack(alignment: .leading) {
                    
                    Text("First Name")
                        .font(.headline)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    TextField("Enter text", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    
                    Text("Last Name")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    TextField("Enter text", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    
                    Text("Whos Using?")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    TextField("Enter text", text: $whosUsing)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    
                    Text("Postal Code")
                        .font(.headline)
                        .padding(.horizontal, 20)
                    TextField("Enter text", text: $postalCode)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal, 20)
                    
                    Text("email")
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
                    
                    Spacer()
                    
                    Button(action: {
                        // #TODO# add sign up action
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(.horizontal, 100)
                            .padding(.bottom, 20)
                    }
                }
                
                Text("By clicking ‘Sign Up’ or using Athlink, you are agreeing to our")
                    .font(.system(size: 10))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                
                HStack(spacing: 4) {
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Terms of Service")
                            .underline()
                            .foregroundColor(.blue)
                    }
                    
                    Text("and")
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Privacy Policy")
                            .underline()
                            .foregroundColor(.blue)
                    }
                }
                .font(.system(size: 10))
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
            }
            
            
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            
        }
    }
}

#Preview {
    LoginScreen()
}

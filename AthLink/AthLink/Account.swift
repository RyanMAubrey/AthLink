//
//  Account.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/6/24.
//

import SwiftUI

struct Account: View {
    @State private var username = "First Last"
    @State private var password = "1234"
    @State private var email = "athlete123@gmail.com"
    @State private var bio = "Bio here"
    @State private var postalCode = "91711"
    @State private var editingProfile = false
    var profilePic = "athlinklogo"
    @State private var firstName = "First name"
    @State private var lastName = "Last name"
    @State private var phone = "000-000-0000"
    @State private var user = "Athlete"
    @State private var card = "Visa"
    @State private var cardEnding = "0000"
    @State private var notifications = true
    @State private var coachMessaging = true
    @State private var whosUsingOptions = ["Athlete", "Parent"]
    @State private var showingDeleteAlert = false

    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Account")
                    .font(.largeTitle)
                    .padding()
//                Text("Account Information")
//                    .font(.largeTitle)
//                    .font(.headline)
//                    .padding(.bottom, 5)
//                    .padding(.leading, 20)

                VStack(alignment: .leading) {
                    // profile pic
                    HStack {
                        Image(profilePic)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                            .shadow(radius: 10)
                        
                        VStack(alignment: .leading) {
                            // users username
                            Text(username)
                                .font(.title)
                                .fontWeight(.bold)
                            
                        }
                        .padding(.leading, 10)
                    }
                    .padding(.bottom, 10)
                    
                    Group {
                        HStack {
                            Text("First:")
                                .font(.headline)
                            Spacer()
                            TextField("First", text: $firstName)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                                //.multilineTextAlignment(.trailing)
                        }
                        .padding(.bottom, 10)

                        HStack {
                            Text("Last:")
                                .font(.headline)
                            Spacer()
                            TextField("Last", text: $lastName)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                        .padding(.bottom, 10)

                        HStack {
                            Text("Email:")
                                .font(.headline)
                            Spacer()
                            TextField("Email", text: $email)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                        .padding(.bottom, 10)
                            
                        HStack {
                            Text("Password:")
                                .font(.headline)
                            Spacer()
                            SecureField("Password", text: $password)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                        .padding(.bottom, 10)
                        
                        
                        HStack {
                            Text("Phone:")
                                .font(.headline)
                            Spacer()
                            TextField("Phone", text: $phone)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                        .padding(.bottom, 10)

                        HStack {
                            Text("User:")
                                .font(.headline)
                            Spacer()
                            Picker("Select user", selection: $user) {
                                ForEach(whosUsingOptions, id: \.self) { whosUsingOptions in
                                    Text(whosUsingOptions).tag(whosUsingOptions)
                                }
                            .padding(5)
                            .background(Color.white)
                            .cornerRadius(5)
                            }
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                        .padding(.bottom, 10)

                        HStack {
                            Text("Card:")
                                .font(.headline)
                            Spacer()
                            TextField("Card", text: $card)
                                .multilineTextAlignment(.trailing)
                            Text("Ending in \(cardEnding)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.bottom, 20)
                    }
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $notifications) {
                            Text("Turn notifications on or off")
                        }
                        .padding(.horizontal, 5)
                        
                        Toggle(isOn: $coachMessaging) {
                            Text("Turn coach messaging on or off")
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.bottom, 20)

                    Button(action: {
                        // update account information once database set up
                    }) {
                        Text("Save Changes")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }

                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Text("Delete my Account")
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Are you sure you want to delete your account?"),
                            message: Text("This action cannot be undone."),
                            primaryButton: .destructive(Text("Yes I am sure")) {
                                // delete account from database
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding([.leading, .trailing], 20)
                
                Text("@2024-2024 AthLink Inc. All Rights Reserved")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    //.padding(.left, 20)
            }
        }
        .padding(.top, 20)
    }
}

#Preview {
    Account()
}

//
//  Account.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/6/24.
//

import SwiftUI

struct Account: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var navigateTomess: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateTohome: Bool = false
    
    var profilePic = "athlinklogo"
    @State private var firstName = "First name"
    @State private var lastName = "Last name"
    @State private var email = "athlete123@gmail.com"
    @State private var password = "1234"
    @State private var phone = "000-000-0000"
    @State private var user = "Athlete"
    @State private var whosUsingOptions = ["Athlete", "Parent"]
    @State private var card = "Visa"
    @State private var cardEnding = "0000"
    @State private var notifications = true
    @State private var coachMessaging = true
    
    @State private var editingProfile = false
    @State private var showingLogAlert = false
    @State private var showingDeleteAlert = false

    var body: some View {
        if navigateTohome {
            home()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateTosess {
            Sessions()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateTomess {
            Messages()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else {
            VStack {
                ScrollView(.vertical) {
                    VStack(alignment: .center) {
                        Text("Account")
                            .font(.largeTitle)
                            .padding()
                        
                        VStack(alignment: .leading) {
                            // Profile Picture
                            HStack {
                                Image(profilePic)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 10)
                                
                                VStack(alignment: .leading) {
                                    Text((rootView.profile.firstName ?? "First") + " " + (rootView.profile.lastName ?? "Last"))
                                        .font(.title)
                                        .fontWeight(.bold)
                                }
                                .padding(.leading, 10)
                            }
                            .padding(.bottom, 10)
                            
                            FieldRow(title: "First:", text: $firstName)
                            FieldRow(title: "Last:", text: $lastName)
                            FieldRow(title: "Email:", text: $email, keyboardType: .emailAddress)
                            FieldRow(title: "Password:", text: $password, secure: true)
                            FieldRow(title: "Phone:", text: $phone, keyboardType: .phonePad)
                            
                            HStack {
                                Text("User:")
                                    .font(.headline)
                                Spacer()
                                Picker("Select user", selection: $user) {
                                    ForEach(whosUsingOptions, id: \.self) { userOption in
                                        Text(userOption).tag(userOption)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                            }
                            .padding(.bottom, 10)
                            
                            // Payment Section
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Payment:")
                                    .font(.headline)
                                HStack {
                                    Text("Credit Card")
                                    Spacer()
                                    TextField("Card", text: $card)
                                        .multilineTextAlignment(.trailing)
                                    Text("Ending in (...\(cardEnding))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 5)
                            }
                            .padding(.bottom, 20)
                            
                            // Toggles
                            VStack(alignment: .leading, spacing: 10) {
                                Toggle("Turn notifications on or off", isOn: $notifications)
                                Toggle("Turn coach messaging on or off", isOn: $coachMessaging)
                            }
                            .padding(.bottom, 20)
                            
                            // Save Changes Button
                            Button(action: {
                                rootView.profile.firstName = firstName
                                rootView.profile.lastName = lastName
                                rootView.profile.email = email
                                rootView.profile.password = password
                                rootView.profile.phoneNumber = phone
                                rootView.profile.who = user
                                rootView.profile.notifications = notifications
                                rootView.profile.coachMessaging = coachMessaging
                            }) {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                            .padding(.bottom, 10)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 20)
                        
                        // logout, Delete Account, terms
                        VStack(alignment: .center) {
                            // Logout Button
                            Button(action: {
                                showingLogAlert = true
                            }) {
                                Text("Log Out")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding([.top,.bottom], 10)
                            }
                            .alert(isPresented: $showingLogAlert) {
                                Alert(
                                    title: Text("Are you sure you want to log out of your account?"),
                                    primaryButton: .destructive(Text("Yes, I am sure")) {
                                        rootView.rootView = .Login
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            // delete account
                            Button(action: {
                                showingDeleteAlert = true
                            }) {
                                Text("Delete my Account")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                    .padding(.bottom)
                            }
                            .alert(isPresented: $showingDeleteAlert) {
                                Alert(
                                    title: Text("Are you sure you want to delete your account?"),
                                    message: Text("This action cannot be undone."),
                                    primaryButton: .destructive(Text("Yes I am sure")) {
                                        rootView.rootView = .Login
                                    },
                                    secondaryButton: .cancel()
                                )
                            }
                            Text("@2024-2024 AthLink Inc. All Rights Reserved")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.leading)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                // Divider Line
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .padding(10)
                // bottom bar
                HStack (spacing: 20) {
                    // home
                    Button(action: {
                        navigateTohome = true
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "house.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Home")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    // Search
                    Button(action: {
                        rootView.path.append("Search")
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Search")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    // Messages
                    Button(action: {
                        navigateTomess = true
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "bell")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Messages")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    //Sessions
                    Button(action: {
                        navigateTosess = true
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "doc.text")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Sessions")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    // Account
                    Button(action: {
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "person")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.black)
                                .bold()
                            Text("Account")
                                .font(.caption)
                                .foregroundStyle(Color.black)
                                .bold()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear() {
                fSearch.validZ = false
                fSearch.zip = ""
                fSearch.sportVal = 0
                fSearch.fSearch = false
                firstName = rootView.profile.firstName ?? ""
                lastName = rootView.profile.lastName ?? ""
                email = rootView.profile.email ?? ""
                password = rootView.profile.password ?? ""
                phone = rootView.profile.phoneNumber ?? ""
                user = rootView.profile.who ?? ""
                notifications = rootView.profile.notifications
                coachMessaging = rootView.profile.coachMessaging
            }
        }
    }
}

struct FieldRow: View {
    let title: String
    @Binding var text: String
    var secure: Bool = false
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if secure {
                SecureField("Enter Text", text: $text)
                    .keyboardType(keyboardType)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(5)
            } else {
                TextField("Enter Text", text: $text)
                    .keyboardType(keyboardType)
                    .padding(5)
                    .background(Color.white)
                    .cornerRadius(5)
            }
        }
        .padding(.bottom, 10)
    }
}

struct NavigationButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: -10) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 50)
                    .foregroundColor(.gray)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    Account()
        .environmentObject(RootViewObj())
        .environmentObject(SearchHelp())
}

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
    @Binding var isUnSaved: Bool
    @State private var isInitialLoad = true
    @State private var profilePic = "athlinklogo"
    @State private var firstName: String = "" {
        didSet {
            if !isInitialLoad && firstName != oldValue {
                isUnSaved = true
            }       }
    }
    @State private var lastName: String = "" {
        didSet {
            if !isInitialLoad && lastName != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var email: String = "" {
        didSet {
            if !isInitialLoad && email != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var password: String = "" {
        didSet {
            if !isInitialLoad && password != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var phone: String = "" {
        didSet {
            if !isInitialLoad && phone != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var user: String = "" {
        didSet {
            if !isInitialLoad && user != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var card = "Visa"
    @State private var cardEnding = "0000"
    @State private var notifications: Bool = false {
        didSet {
            if !isInitialLoad && notifications != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var coachMessaging: Bool = true {
        didSet {
            if !isInitialLoad && coachMessaging != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var whosUsingOptions: [String] = [""]
    @State private var showingLogAlert: Bool = false
    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        VStack {
            ScrollView(.vertical) {
                VStack(alignment: .center) {
                    // Profile Header
                    Text("Account")
                        .font(.largeTitle)
                        .padding()
                    // Profile Picture
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
                                Text(rootView.profile.fullName)
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
                        
                        // Payment sectiton
                        HStack {
                            VStack (alignment: .leading){
                                Text("Payment:")
                                    .font(.headline)
                                HStack (alignment: .center){
                                    Text("Direct Deposit")
                                        .frame(width: 70, height: 50)
                                        .lineLimit(2)
                                    Image(systemName: "building.columns")
                                        .resizable()
                                        .frame(width:35, height: 35)
                                        .scaledToFit()
                                        .padding(.trailing, 5)
                                    Button(action: {
                                        //TODO add button functionality
                                    }) {
                                        Image(systemName: "plus")
                                    }
                                    Spacer()
                                    TextField("Card", text: $card)
                                        .multilineTextAlignment(.trailing)
                                    Text("Ending in (...\(cardEnding))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
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
                            isUnSaved = false
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear() {
            fSearch.validZ = false
            fSearch.zip = ""
            fSearch.sportVal = 0
            fSearch.fSearch = false
            firstName = rootView.profile.firstName
            lastName = rootView.profile.lastName
            email = rootView.profile.email
            password = rootView.profile.password 
            phone = rootView.profile.phoneNumber ?? ""
            user = rootView.profile.who
            notifications = rootView.profile.notifications
            coachMessaging = rootView.profile.coachMessaging
            
            whosUsingOptions = ["Athlete", "Parent"] 
            isInitialLoad = false
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
    struct Preview: View {
        @State var isUnSaved: Bool = false

        var body: some View {
            Account(isUnSaved: $isUnSaved)
                .environmentObject(RootViewObj())
                .environmentObject(SearchHelp())
        }
    }
    return Preview()
}

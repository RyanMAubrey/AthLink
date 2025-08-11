//
//  Account.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/6/24.
//

import SwiftUI
import Supabase
import PhotosUI

struct Account: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @Binding var isUnSaved: Bool
    @State private var isInitialLoad = true
    @State private var profilePic: PhotosPickerItem?
    @State private var avatarURL: URL?
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
    @State private var postalCode: String = "" {
        didSet {
            if !isInitialLoad && postalCode != oldValue {
                isUnSaved = true
            }       }
    }
    @State private var userType: String = "" {
        didSet {
            if !isInitialLoad && userType != oldValue {
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
    @State private var whosUsingOptions: [String] = ["Athlete", "Parent"]
    @State private var showingLogAlert: Bool = false

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
                            PhotosPicker(selection: $profilePic, matching: .images) {
                                if let avatarURL {
                                    AsyncImage(url: avatarURL) { phase in
                                        switch phase {
                                        case .success(let img):
                                            img.resizable().scaledToFill()
                                        default:
                                            Image("athlinklogo").resizable().scaledToFill()
                                        }
                                    }
                                } else{
                                    Image("athlinklogo").resizable().scaledToFill()
                                }
                              }
                                .frame(width:80, height:80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth:2))
                                .shadow(radius:5)
                                .onChange(of: profilePic) { _, newItem in
                                    Task {
                                        // Turn the picker item into Data → UIImage
                                        guard let item = newItem,
                                              let data = try? await item.loadTransferable(type: Data.self),
                                              let uiImage = UIImage(data: data) else { return }
                                        do {
                                            // Upload to Supabase bucket
                                            try await rootView.uploadImage(image: uiImage)
                                            // Reload the profile to pick up the new URL
                                            try await rootView.loadProfile()
                                            // Load the new image
                                            if rootView.profile.imageURL.hasPrefix("http"),
                                               let url = URL(string: rootView.profile.imageURL) {
                                                avatarURL = url
                                            }
                                        } catch {
                                          print("Photo-upload failed:", error)
                                        }
                                    }
                                }
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
                        FieldRow(title: "Postal Code:", text: $postalCode)
                        FieldRow(title: "Phone:", text: $phone, keyboardType: .phonePad)
                        
                        HStack {
                            Text("User:")
                                .font(.headline)
                            Spacer()
                            Picker("Select user", selection: $userType) {
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
                            // Update backend
                            Task {
                                do {
                                    guard let user = rootView.client.auth.currentUser else{return}
                                    // Table info
                                    let patch = ProfilePatch(
                                        first_name: firstName.isEmpty ? nil : firstName,
                                        last_name:  lastName.isEmpty ? nil : lastName,
                                        phone_number: phone.isEmpty ? nil : phone,
                                        user_type: userType.isEmpty ? nil : userType,
                                        postal_code: postalCode.isEmpty ? nil : postalCode,
                                        notifications: notifications,
                                        coach_messaging: coachMessaging
                                    )
                                    try await rootView.client
                                      .from("profiles")
                                      .update(patch)
                                      .eq("id", value: user.id)
                                      .execute()
                                    // User email
                                    if !email.trimmingCharacters(in: .whitespaces).isEmpty {
                                      try await rootView.client.auth.update(user: UserAttributes(email: email))
                                    }
                                    // User password
                                    if !password.isEmpty {
                                      try await rootView.client.auth.update(user: UserAttributes(password: password))
                                    }
                                    // Update frontend
                                    let row: Profile = try await rootView.client
                                      .from("profiles")
                                      .select("id, first_name, last_name, coach_account, image_url, phone_number, postal_code, user_type, notifications, coach_messaging")
                                      .eq("id", value: user.id)
                                      .single()
                                      .execute()
                                      .value
                                    rootView.profile.apply(row: row)
                                } catch {
                                        print("Update failed:", error)
                                }
                            }
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
                    
                    // Logout Account
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
                                    Task {
                                        try await rootView.client.auth.signOut()
                                    }
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
            // Search Help
            fSearch.validZ = false
            fSearch.zip = ""
            fSearch.sportVal = 0
            fSearch.fSearch = false
            // Setting Variables
            firstName = rootView.profile.firstName
            lastName = rootView.profile.lastName
            phone = rootView.profile.phoneNumber ?? ""
            postalCode = rootView.profile.postalCode
            userType = rootView.profile.userType
            notifications = rootView.profile.notifications
            coachMessaging = rootView.profile.coachMessaging
            // Image
            if rootView.profile.imageURL.hasPrefix("http"),
               let url = URL(string: rootView.profile.imageURL)  {
                avatarURL = url
            } else{
                avatarURL = nil
            }
            // Other
            isInitialLoad = false
        }
    }
    
    private struct ProfilePatch: Encodable {
        let first_name: String?
        let last_name: String?
        let phone_number: String?
        let user_type: String?
        let postal_code: String?
        let notifications: Bool?
        let coach_messaging: Bool?
    }
}

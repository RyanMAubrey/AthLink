//
//  AccountView.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 9/21/24.
//

// make card payment wher ethey set up bank account, just make api format
// when preview profile show profile preview
// put descriptions under the notifications and athlete requests
// change swithces from green to blue
// move availability above notifications
// scrap save changes, make changes automatically save to database

import SwiftUI
import Supabase
import PhotosUI

struct AccountView: View {
    @EnvironmentObject var rootView: RootViewObj
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
    @State private var notifications: Bool = false {
        didSet {
            if !isInitialLoad && notifications != oldValue {
                isUnSaved = true
            }        }
    }
    @State private var athleteMessaging: Bool = true {
        didSet {
            if !isInitialLoad && athleteMessaging != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var selectedAvailability: [String: [String]] = [:] {
        didSet {
            if !isInitialLoad && selectedAvailability != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var about: String = "" {
        didSet {
            if !isInitialLoad && about != oldValue {
                isUnSaved = true
            }
        }
    }
    
    
    @State private var achievements: [String] = [] {
        didSet {
            if !isInitialLoad && achievements != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var experience: [String] = [] {
        didSet {
            if !isInitialLoad && experience != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var trainingLoc: [CoachLocation]?  {
        didSet {
            if !isInitialLoad && trainingLoc != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var sport: [Sports] = [] {
        didSet {
            if !isInitialLoad && sport != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var position: [Sports:[Positions]] = [:] {
        didSet {
            if !isInitialLoad && position != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var iCost: Double? {
        didSet {
            if !isInitialLoad && iCost != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var gCost: Double? {
        didSet {
            if !isInitialLoad && gCost != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var cancel: Int? {
        didSet {
            if !isInitialLoad && cancel != oldValue {
                isUnSaved = true
            }
        }
    }
        
    @State private var card = "Chase"
    @State private var cardEnding = "0000"
    @State private var idollars: Int = 0
    @State private var icents:  Int = 0
    @State private var itotal: Double?
    @State private var gdollars: Int = 0
    @State private var gcents:  Int = 0
    @State private var gtotal: Double?
    @State private var whosUsingOptions = ["Athlete", "Parent"]
    @State private var newExperience = ""
    @State private var newAchievement = ""
    @State private var showingLogAlert = false

    private func updateTotal(type: Bool) {
        // build a Decimal total first
        var totalDecimal: Decimal = 0.00
        if type {
            totalDecimal = Decimal(idollars) + Decimal(icents) / 100
        } else {
            totalDecimal = Decimal(gdollars) + Decimal(gcents) / 100
        }
        // convert that Decimal → Double
        let totalDouble = NSDecimalNumber(decimal: totalDecimal).doubleValue
        // assign (or nil-out if zero)
        if type {
            itotal = (totalDouble == 0) ? nil : totalDouble
        } else {
            gtotal = (totalDouble == 0) ? nil : totalDouble
        }
    }
    
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
                        FieldRow(title: "Phone:", text: $phone, keyboardType: .phonePad)
                        
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
                    }
                    // About
                    Text("About:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    TextEditor(text: $about)
                        .frame(minHeight: 150)
                        .cornerRadius(15)
                        .border(Color.secondary)
                        .padding(.horizontal, -16)
                        .multilineTextAlignment(.center)
                        .overlay(
                            Group {
                                if about.isEmpty {
                                    Text("Write about yourself…")
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                }
                            },
                            alignment: .topLeading
                        )
                    
                    // Experience
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Experience:")
                            .font(.headline)
                        
                        // List existing experience entries
                        ForEach(experience, id: \.self) { exp in
                            Text("• \(exp)")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Add‑new row
                        HStack {
                            TextField("Add experience", text: $newExperience)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button {
                                let trimmed = newExperience.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                experience.append(trimmed)
                                newExperience = ""
                                isUnSaved = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(newExperience.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }

                    // achievements
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Athletic Achievements:")
                            .font(.headline)
                        
                        // List existing achievement entries
                        ForEach(achievements, id: \.self) { ach in
                            Text("• \(ach)")
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        // Add‑new row
                        HStack {
                            TextField("Add achievement", text: $newAchievement)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button {
                                let trimmed = newAchievement.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                achievements.append(trimmed)
                                newAchievement = ""
                                isUnSaved = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            .disabled(newAchievement.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    
                    // Price
                    Text("Price(Only One is Required):")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    // Individual cost
                    HStack(alignment: .center, spacing: 16) {
                        Text("Set a cost for individual sessions")
                            .font(.body)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Picker(selection: $idollars, label: Text("Dollars")) {
                            ForEach(0..<1000) { Text("\($0)") }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60, height: 100)
                        .clipped()
                        .onChange(of: idollars) { updateTotal(type: true) }

                        Picker(selection: $icents, label: Text("Cents")) {
                            ForEach(0..<100) { Text(String(format: "%02d", $0)) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60, height: 100)
                        .clipped()
                        .onChange(of: icents) { updateTotal(type: true) }
                    }

                    // Group cost
                    HStack(alignment: .center, spacing: 16) {
                        Text("Set a cost for group sessions")
                            .font(.body)
                            .lineLimit(nil)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Picker(selection: $gdollars, label: Text("Dollars")) {
                            ForEach(0..<1000) { Text("\($0)") }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60, height: 100)
                        .clipped()
                        .onChange(of: gdollars) { updateTotal(type: false) }

                        Picker(selection: $gcents, label: Text("Cents")) {
                            ForEach(0..<100) { Text(String(format: "%02d", $0)) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 60, height: 100)
                        .clipped()
                        .onChange(of: gcents) { updateTotal(type: false) }
                    }
                    // cancelation picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cancellation Notice:")
                            .font(.headline)

                        HStack {
                            Text("Hours before session:")
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Picker("", selection: Binding(
                                get: { cancel ?? 0 },
                                set: { value in
                                    cancel = (value == 0 ? nil : value)
                                    isUnSaved = true
                                }
                            )) {
                                // 0 means “no notice required”
                                Text("Off").tag(0)
                                ForEach(1..<49) { hour in
                                    Text("\(hour)h").tag(hour)
                                }
                            }
                            .pickerStyle(.wheel)
                            .frame(width: 60, height: 100)
                            .clipped()
                        }
                    }
                    // Availability Grid
                    Text("Availability:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                    AvailabilityGrid(selectedA: $selectedAvailability)
                    
                    // Preview Profile Button
                    Button(action: {
                        rootView.lastPage = "Account"
                        rootView.selectedSession = rootView.profile
                        rootView.path.append("CoachAccount")
                    }) {
                        Text("Preview Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Toggles
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $notifications) {
                            Text("Turn notifications on or off")
                        }
                        .padding(.horizontal, 5)

                        Toggle(isOn: $athleteMessaging) {
                            Text("Turn athlete requests on or off")
                        }
                        .padding(.horizontal, 5)
                    }
                    .padding(.bottom, 20)
                    
                    // Save Changes Button
                    Button(action: {
                        isUnSaved = false
                        rootView.profile.firstName = firstName
                        rootView.profile.lastName = lastName
                        rootView.profile.phoneNumber = phone
                        rootView.profile.availability = selectedAvailability
                        rootView.profile.notifications = notifications
                        rootView.profile.athleteMessaging = athleteMessaging
                        rootView.profile.quote = about
                        rootView.profile.achievements = achievements
                        rootView.profile.experience = experience
                        rootView.profile.trainingLocations = trainingLoc ?? []
                        rootView.profile.sport = sport
                        rootView.profile.position = position
                        rootView.profile.individualCost = itotal
                        rootView.profile.groupCost = gtotal
                        rootView.profile.cancellationNotice = cancel
                        // Update backend
                        Task {
                            do {
                                guard let user = rootView.client.auth.currentUser else{return}
//                                try await rootView.client
//                                    .from("profiles")
//                                    .update([
//                                        "first_name": firstName,
//                                        "last_name":  lastName,
//                                        "image_url": avatarURL?.absoluteString ?? rootView.profile.profilePic
//                                    ])
//                                    .eq("id", value:user.id)
//                                    .execute()
                                // User email
                                if !email.trimmingCharacters(in: .whitespaces).isEmpty {
                                  try await rootView.client.auth.update(user: UserAttributes(email: email))
                                }
                                // User password
                                if !password.isEmpty {
                                  try await rootView.client.auth.update(user: UserAttributes(password: password))
                                }
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
            }
        }
        .onAppear() {
            // Setting Variables
            firstName = rootView.profile.firstName
            lastName = rootView.profile.lastName
            phone = rootView.profile.phoneNumber ?? ""
            selectedAvailability = rootView.profile.availability
            notifications = rootView.profile.notifications
            athleteMessaging = rootView.profile.athleteMessaging
            about = rootView.profile.quote ?? ""
            achievements = rootView.profile.achievements
            experience = rootView.profile.experience
            trainingLoc = rootView.profile.trainingLocations
            sport = rootView.profile.sport
            position = rootView.profile.position
            iCost = rootView.profile.individualCost
            gCost = rootView.profile.groupCost
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
}

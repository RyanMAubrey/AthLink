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
import MapKit

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
    @State private var postalCode: String = "" {
        didSet {
            if !isInitialLoad && postalCode != oldValue {
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
    @State private var trainingLoc: [CoachLocation] = [] {
        didSet {
            if !isInitialLoad && trainingLoc != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var sport: [String] = [] {
        didSet {
            if !isInitialLoad && sport != oldValue {
                isUnSaved = true
            }
        }
    }
    @State private var position: [String:[String]] = [:] {
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
    @State private var newExperience = ""
    @State private var newAchievement = ""
    @State private var showingLogAlert = false
    // Location info
    @State private var showMap:Bool = false
    @State private var selectedLoc: CoachLocation?
    @State private var showAddLocationSheet : Bool = false

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
                        FieldRow(title: "Postal Code:", text: $postalCode)
                        
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
                    // Location Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Locations (Optional):")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        ForEach(trainingLoc, id: \.self) { loc in
                            Button(action: {
                                selectedLoc = loc
                                showMap = true
                            }) {
                                Text("\(loc.name)")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        // Add‑new row
                        HStack {
                            Button {
                                showAddLocationSheet = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                        }
                    }
                    .sheet(isPresented: $showAddLocationSheet) {
                        EmptyView()
                    }
                    .sheet(isPresented: $showMap) {
                        if let loc = selectedLoc {
                            MapViewing(specifiedLocation: loc) {
                                trainingLoc.removeAll { $0.id == loc.id }
                                isUnSaved = true
                                showMap = false
                            }                        }
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
                        // Update backend
                        Task {
                            do {
                                guard let user = rootView.client.auth.currentUser else{return}
                                // Athlete table info
                                let patch = ProfilePatchSecond(
                                    first_name: firstName.isEmpty ? nil : firstName,
                                    last_name:  lastName.isEmpty ? nil : lastName,
                                    postal_code: postalCode.isEmpty ? nil : postalCode,
                                    notifications: notifications
                                )
                                try await rootView.client
                                  .from("profiles")
                                  .update(patch)
                                  .eq("id", value: user.id)
                                  .execute()
                                // Coach table info
                                let cpatch = CoachProfilePatch(
                                    personal_quote: about.isEmpty ? nil : about,
                                    coaching_achievements: achievements.isEmpty ? nil : achievements,
                                    coaching_experience:  experience.isEmpty  ? nil : experience,
                                    time_availability: selectedAvailability.isEmpty ? nil : selectedAvailability,
                                    athlete_messaging: athleteMessaging,
                                    individual_cost: itotal,
                                    group_cost: gtotal,
                                    sports: sport.isEmpty ? nil : sport,
                                    sport_positions: position.isEmpty ? nil : position,
                                    cancellation_notice: cancel
                                )
                                try await rootView.client
                                    .from("coach_profile")
                                    .update(cpatch)
                                    .eq("id", value: user.id)
                                    .execute()
//                                // Location table info
//                                let locrow: CoachLocation = try await rootView.client
//                                    .from("locaiton")
//                                    .select("id, name, lat, lng")
//                                    .eq("coach_id", value: user.id)
//                                    .execute()
//                                    .value
                                // User email
                                if !email.trimmingCharacters(in: .whitespaces).isEmpty {
                                  try await rootView.client.auth.update(user: UserAttributes(email: email))
                                }
                                // User password
                                if !password.isEmpty {
                                  try await rootView.client.auth.update(user: UserAttributes(password: password))
                                }
                                // Update frontend
                                let mainRow: Profile = try await rootView.client
                                  .from("profiles")
                                  .select("id, first_name, last_name, coach_account, image_url, postal_code, user_type, notifications, coach_messaging")
                                  .eq("id", value: user.id)
                                  .single()
                                  .execute()
                                  .value
                                rootView.profile.apply(row: mainRow)
                                let coachRow: CoachProfile = try await rootView.client
                                    .from("coach_profile")
                                    .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, athlete_messaging, individual_cost, group_cost, sports, sport_positions")
                                    .eq("id", value: user.id)
                                    .single()
                                    .execute()
                                    .value
                                rootView.profile.coachApply(row: coachRow)
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

                // logout Account, terms
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
            postalCode = rootView.profile.postalCode
            notifications = rootView.profile.notifications
            selectedAvailability = rootView.profile.timeAvailability
            athleteMessaging = rootView.profile.athleteMessaging
            about = rootView.profile.personalQuote 
            achievements = rootView.profile.coachingAchievements
            experience = rootView.profile.coachingExperience
            trainingLoc = rootView.profile.trainingLocations
            sport = rootView.profile.sports
            position = rootView.profile.sportPositions
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
    // Map Structure
    struct MapViewing: View {
        let specifiedLocation: CoachLocation
        let onDelete: () -> Void
        @State private var camera: MapCameraPosition

        init(specifiedLocation: CoachLocation, onDelete: @escaping () -> Void) {
            self.specifiedLocation = specifiedLocation
            self.onDelete = onDelete
            let region = MKCoordinateRegion(
                center: specifiedLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            _camera = State(initialValue: .region(region))
        }

        var body: some View {
            Map(position: $camera) {
                Marker(specifiedLocation.name, coordinate: specifiedLocation.coordinate)
            }
            .ignoresSafeArea(edges: .top)
            .safeAreaInset(edge: .bottom) {
                Button(action: onDelete) {
                    Text("Delete \(specifiedLocation.name)?")
                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .background(.thinMaterial)
            }
        }
    }

}




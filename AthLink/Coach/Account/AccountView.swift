
import SwiftUI
import Supabase
import PhotosUI
import MapKit

struct AccountView: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var isInitialLoad = true
    @State private var profilePic: PhotosPickerItem?
    @State private var avatarURL: URL?
    @State private var firstName: String = "" {
        didSet {
            if !isInitialLoad && firstName != oldValue {
                rootView.isUnSaved = true
            }       }
    }
    @State private var lastName: String = "" {
        didSet {
            if !isInitialLoad && lastName != oldValue {
                rootView.isUnSaved = true
            }        }
    }
    @State private var notifications: Bool = false {
        didSet {
            if !isInitialLoad && notifications != oldValue {
                rootView.isUnSaved = true
            }        }
    }
    @State private var athleteMessaging: Bool = true {
        didSet {
            if !isInitialLoad && athleteMessaging != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var selectedAvailability: [String: [String]] = [:] {
        didSet {
            if !isInitialLoad && selectedAvailability != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var about: String = "" {
        didSet {
            if !isInitialLoad && about != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    
    @State private var experience: [String] = [] {
        didSet {
            if !isInitialLoad && experience != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var achievements: [String] = [] {
        didSet {
            if !isInitialLoad && achievements != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var trainingLoc: [structLocation] = [] {
        didSet {
            if !isInitialLoad && trainingLoc != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var sport: [String] = [] {
        didSet {
            if !isInitialLoad && sport != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var position: [String:[String]] = [:] {
        didSet {
            if !isInitialLoad && position != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var iCost: Double? {
        didSet {
            if !isInitialLoad && iCost != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var gCost: Double? {
        didSet {
            if !isInitialLoad && gCost != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var cancel: Int? {
        didSet {
            if !isInitialLoad && cancel != oldValue {
                rootView.isUnSaved = true
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
    // Photo error message
    @State private var showPhotoError: Bool = false
    @State private var photoErrorMessage: String = ""
    // Location info
    @State private var camera: MapCameraPosition = .automatic
    @State private var searchLoc: String = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching: Bool = false
    @State private var searchTask: Task<Void, Never>? = nil
    @State private var selectedTrainingLoc: structLocation? = nil
    
    func mapSearch(for query: String) async -> [MKMapItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems
        } catch {
            return []
        }
    }
    
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
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header Card
                    VStack(spacing: 16) {
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
                            } else {
                                Image("athlinklogo").resizable().scaledToFill()
                            }
                        }
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        .onChange(of: profilePic) { _, newItem in
                            Task {
                                // Convert new item into UI image
                                guard let item = newItem,
                                      let data = try? await item.loadTransferable(type: Data.self),
                                      let uiImage = UIImage(data: data) else { return }
                                do {
                                    // Call helper to upload to bucket
                                    try await uploadImage(client: rootView.client, image: uiImage, name: rootView.profile.id.uuidString)
                                    // Load to frontend UI
                                    if rootView.profile.imageURL.hasPrefix("http"),
                                       let url = URL(string: rootView.profile.imageURL) {
                                        avatarURL = url
                                    }
                                } catch {
                                    // Shows message with error
                                    photoErrorMessage = "Photo upload failed: \(error.localizedDescription)"
                                    showPhotoError = true
                                }
                            }
                        }

                        Text(rootView.profile.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .alert("Upload Error", isPresented: $showPhotoError) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(photoErrorMessage)
                    }

                    // Personal Info Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Personal Info")
                            .font(.headline)

                        FieldRow(title: "First:", text: $firstName)
                        FieldRow(title: "Last:", text: $lastName)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Payment Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment")
                            .font(.headline)
                        HStack(spacing: 12) {
                            Image(systemName: "building.columns")
                                .font(.title2)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Direct Deposit")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(card) ending in ...\(cardEnding)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // About Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("About")
                            .font(.headline)
                        TextEditor(text: $about)
                            .frame(minHeight: 120)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .overlay(
                                Group {
                                    if about.isEmpty {
                                        Text("Write about yourself…")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 12)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Experience Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Experience")
                            .font(.headline)

                        ForEach(Array(experience.enumerated()), id: \.offset) { index, exp in
                            HStack {
                                Text("• \(exp)")
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                Button(action: {
                                    var updated = experience
                                    updated.remove(at: index)
                                    experience = updated
                                    rootView.isUnSaved = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                        }

                        HStack {
                            TextField("Add experience", text: $newExperience)
                                .font(.subheadline)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            Button {
                                let trimmed = newExperience.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                experience.append(trimmed)
                                newExperience = ""
                                rootView.isUnSaved = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(newExperience.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Achievements Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Athletic Achievements")
                            .font(.headline)

                        ForEach(Array(achievements.enumerated()), id: \.offset) { index, ach in
                            HStack {
                                Text("• \(ach)")
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                Button(action: {
                                    var updated = achievements
                                    updated.remove(at: index)
                                    achievements = updated
                                    rootView.isUnSaved = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                        }

                        HStack {
                            TextField("Add achievement", text: $newAchievement)
                                .font(.subheadline)
                                .padding(10)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)

                            Button {
                                let trimmed = newAchievement.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                achievements.append(trimmed)
                                newAchievement = ""
                                rootView.isUnSaved = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                            .disabled(newAchievement.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Pricing Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Pricing")
                            .font(.headline)
                        Text("At least one is required")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        // Individual cost
                        HStack(alignment: .center, spacing: 16) {
                            Text("Individual")
                                .font(.subheadline)
                                .fontWeight(.medium)
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

                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)

                        // Group cost
                        HStack(alignment: .center, spacing: 16) {
                            Text("Group")
                                .font(.subheadline)
                                .fontWeight(.medium)
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
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Training Locations Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Training Locations")
                                .font(.headline)
                            Text("(Required)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        // Search bar
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField("Search for a location...", text: $searchLoc)
                                .submitLabel(.search)
                        }
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onChange(of: searchLoc) { _, newValue in
                            searchTask?.cancel()
                            let q = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                            if q.isEmpty {
                                searchResults = []
                                return
                            }
                            searchTask = Task {
                                try? await Task.sleep(nanoseconds: 350_000_000)
                                await MainActor.run { isSearching = true }
                                let items = await mapSearch(for: q)
                                await MainActor.run {
                                    isSearching = false
                                    searchResults = items
                                }
                            }
                        }
                        .onSubmit {
                            Task {
                                isSearching = true
                                searchResults = await mapSearch(for: searchLoc)
                                isSearching = false
                            }
                        }

                        if isSearching {
                            HStack {
                                ProgressView()
                                    .tint(.blue)
                                Text("Searching…")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                Spacer()
                            }
                            .padding(.vertical, 4)
                        }

                        // Search results
                        if !searchResults.isEmpty {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(searchResults.prefix(6), id: \.self) { item in
                                    Button {
                                        let newLoc = structLocation(mapItem: item)
                                        let already = trainingLoc.contains(where: {
                                            $0.name == newLoc.name &&
                                            abs($0.coordinate.latitude - newLoc.coordinate.latitude) < 0.0001 &&
                                            abs($0.coordinate.longitude - newLoc.coordinate.longitude) < 0.0001
                                        })
                                        guard !already else { return }
                                        trainingLoc.append(newLoc)
                                        rootView.isUnSaved = true
                                        camera = .region(MKCoordinateRegion(
                                            center: newLoc.coordinate,
                                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                        ))
                                        searchLoc = ""
                                        searchResults = []
                                    } label: {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(item.name ?? "Unknown place")
                                                    .foregroundColor(.primary)
                                                if let subtitle = item.placemark.title {
                                                    Text(subtitle)
                                                        .font(.caption)
                                                        .foregroundColor(.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                            Spacer()
                                            Image(systemName: "plus.circle.fill")
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 10)
                                    }
                                    .buttonStyle(.plain)
                                    Divider()
                                }
                            }
                            .background(Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 1)
                            )
                        }

                        // Location chips
                        ForEach(Array(trainingLoc.enumerated()), id: \.offset) { index, loc in
                            HStack {
                                Button(action: {
                                    selectedTrainingLoc = loc
                                    camera = .region(MKCoordinateRegion(
                                        center: loc.coordinate,
                                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                                    ))
                                }) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "mappin.circle.fill")
                                            .foregroundColor(.blue)
                                        Text(loc.name)
                                            .font(.subheadline)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                                Spacer()
                                Button(action: {
                                    var updated = trainingLoc
                                    updated.remove(at: index)
                                    trainingLoc = updated
                                    rootView.isUnSaved = true
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red.opacity(0.7))
                                }
                            }
                            .padding(.vertical, 4)
                        }

                        // Map
                        Map(position: $camera, selection: $selectedTrainingLoc) {
                            ForEach(trainingLoc, id: \.id) { loc in
                                Marker(loc.name, coordinate: loc.coordinate)
                                    .tag(loc)
                            }
                        }
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .mapStyle(.hybrid)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Cancellation Notice Card
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Cancellation Notice")
                            .font(.headline)
                        Text("Optional — hours before session")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        HStack {
                            Text("Hours:")
                                .font(.subheadline)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Picker("", selection: Binding(
                                get: { cancel ?? 0 },
                                set: { value in
                                    cancel = (value == 0 ? nil : value)
                                    rootView.isUnSaved = true
                                }
                            )) {
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
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Availability Card
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Availability")
                            .font(.headline)
                        AvailabilityGrid(selectedA: $selectedAvailability)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Settings Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Settings")
                            .font(.headline)
                        Toggle("Notifications", isOn: $notifications)
                            .tint(.blue)
                        Toggle("Athlete Requests", isOn: $athleteMessaging)
                            .tint(.blue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Preview Profile Button
                    Button(action: {
                        rootView.lastPage = "Account"
                        rootView.selectedSession = rootView.profile
                        rootView.path.append("CoachAccount")
                    }) {
                        HStack {
                            Image(systemName: "eye")
                            Text("Preview Profile")
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Save Changes Button
                    Button(action: {
                        rootView.isUnSaved = false
                        Task {
                            do {
                                guard let user = rootView.client.auth.currentUser else { return }
                                let patch = ProfilePatchSecond(
                                    first_name: firstName.isEmpty ? nil : firstName,
                                    last_name:  lastName.isEmpty ? nil : lastName,
                                    notifications: notifications
                                )
                                try await rootView.client
                                    .from("profiles")
                                    .update(patch)
                                    .eq("id", value: user.id)
                                    .execute()
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
                                    cancellation_notice: cancel,
                                    coach_upcoming_sessions: nil,
                                    coach_unsubmitted_sessions: nil,
                                    coach_submitted_sessions: nil,
                                    job_requests: nil,
                                    interested_athletes: nil,
                                    current_athletes: nil,
                                    reviews: nil,
                                    athlete_requests: nil,
                                    training_locations: trainingLoc
                                )
                                try await rootView.client
                                    .from("coach_profile")
                                    .update(cpatch)
                                    .eq("id", value: user.id)
                                    .execute()
                                try await rootView.loadProfile()
                            } catch {
                                print("Update failed:", error)
                            }
                        }
                    }) {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Logout
                    Button(action: { showingLogAlert = true }) {
                        Text("Log Out")
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingLogAlert) {
                        Alert(
                            title: Text("Are you sure you want to log out?"),
                            primaryButton: .destructive(Text("Log Out")) {
                                Task { await rootView.signOut() }
                            },
                            secondaryButton: .cancel()
                        )
                    }

                    Text("2024 AthLink Inc. All Rights Reserved")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear() {
            // Setting Variables
            firstName = rootView.profile.firstName
            lastName = rootView.profile.lastName
            notifications = rootView.profile.notifications
            selectedAvailability = rootView.profile.timeAvailability
            athleteMessaging = rootView.profile.athleteMessaging
            about = rootView.profile.personalQuote
            experience = rootView.profile.coachingExperience
            achievements = rootView.profile.coachingAchievements
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
            // Camera posiiton
            if !trainingLoc.isEmpty {
                if let reg = regionThatFits(trainingLoc) {
                    camera = .region(reg)
                }
            } else {
                if let cl = rootView.currentLocation {
                    camera = .region(MKCoordinateRegion(
                        center:cl.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    ))
                }
            }
        }
        .alert("Unsaved Changees", isPresented: $rootView.showUnSavedAlert) {
            Button("Cancel", role: .cancel) {
                rootView.isUnSaved = false
                if let tab = rootView.pendingTab {
                    rootView.selectedTab = tab
                    rootView.pendingTab = nil
                }
            }
            Button("Save") {
                rootView.isUnSaved = false
                let tab = rootView.pendingTab
                rootView.pendingTab = nil
                if let tab { rootView.selectedTab = tab }
                Task {
                    do {
                        guard let user = rootView.client.auth.currentUser else { return }
                        let patch = ProfilePatchSecond(
                            first_name: firstName.isEmpty ? nil : firstName,
                            last_name:  lastName.isEmpty ? nil : lastName,
                            notifications: notifications
                        )
                        try await rootView.client
                            .from("profiles")
                            .update(patch)
                            .eq("id", value: user.id)
                            .execute()
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
                            cancellation_notice: cancel,
                            coach_upcoming_sessions: nil,
                            coach_unsubmitted_sessions: nil,
                            coach_submitted_sessions: nil,
                            job_requests: nil,
                            interested_athletes: nil,
                            current_athletes: nil,
                            reviews: nil,
                            athlete_requests: nil,
                            training_locations: trainingLoc
                        )
                        try await rootView.client
                            .from("coach_profile")
                            .update(cpatch)
                            .eq("id", value: user.id)
                            .execute()
                        try await rootView.loadProfile()
                    } catch {
                        print("Update failed:", error)
                    }
                }
            }
        } message: {
            Text("You have unsaved data, swiching tabs will loose changes.")
        }
    }
}

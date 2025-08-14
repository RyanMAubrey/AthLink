//
//  AthLinkApp.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 6/7/24.
//

import SwiftUI
import SwiftData
import CoreLocation
import Supabase

// Retreive Info.plist info
func infoValue(key: String) -> String {
    guard let val = Bundle.main.object(forInfoDictionaryKey: key) as? String,
          !val.isEmpty
    else {
        fatalError("⚠️ Missing \(key) in Info.plist")
    }
    return val
}

// Backend main data collection
struct Profile: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var firstName: String
    var lastName: String
    var coachAccount: Bool
    var userType: String
    var postalCode: String
    var imageURL: String?
    var notifications: Bool = false
    var coachMessaging: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case coachAccount = "coach_account"
        case userType = "user_type"
        case postalCode = "postal_code"
        case imageURL = "image_url"
        case notifications
        case coachMessaging = "coach_messaging"
    }
    
    // Equatable Conformance
    static func == (lhs: Profile, rhs: Profile) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Backend coach data collection
struct CoachProfile: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var personalQuote: String
    var coachingAchievements: [String]
    var coachingExperience: [String]
    var timeAvailability: [String: [String]]
    var athleteMessaging: Bool
    var individualCost: Double?
    var groupCost: Double?
    var sports: [String]
    var sportPositions: [String:[String]]
    var cancellationNotice: Int?
    
    // Codable Conformance
    enum CodingKeys: String, CodingKey {
        case id
        case personalQuote = "personal_quote"
        case coachingAchievements = "coaching_achievements"
        case coachingExperience = "coaching_experience"
        case timeAvailability = "time_availability"
        case athleteMessaging = "athlete_messaging"
        case individualCost = "individual_cost"
        case groupCost = "group_cost"
        case sports
        case sportPositions = "sport_positions"
        case cancellationNotice = "cancellation_notice"
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        personalQuote = try c.decodeIfPresent(String.self, forKey: .personalQuote) ?? ""
        coachingAchievements = try c.decodeIfPresent([String].self, forKey: .coachingAchievements) ?? []
        coachingExperience = try c.decodeIfPresent([String].self, forKey: .coachingExperience) ?? []
        timeAvailability = try c.decodeIfPresent([String:[String]].self, forKey: .timeAvailability) ?? [:]
        athleteMessaging = try c.decodeIfPresent(Bool.self, forKey: .athleteMessaging) ?? true
        individualCost = try c.decodeIfPresent(Double.self, forKey: .individualCost) ?? nil
        groupCost = try c.decodeIfPresent(Double.self, forKey: .groupCost) ?? nil
        sports = try c.decodeIfPresent([String].self, forKey: .sports) ?? []
        sportPositions = try c.decodeIfPresent([String:[String]].self, forKey: .sportPositions) ?? [:]
        cancellationNotice = try c.decodeIfPresent(Int.self, forKey: .cancellationNotice) ?? nil
    }
    
    // Equatable Conformance
    static func == (lhs: CoachProfile, rhs: CoachProfile) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Front end UI Class
class ProfileID: Identifiable, ObservableObject, Equatable, Hashable {
    // Finished
    // Basic
    var id: UUID = UUID()
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    @Published var coachAccount: Bool = false
    @Published var imageURL = "athlinklogo"
    @Published var postalCode: String = ""
    @Published var notifications: Bool = false
    // Athlete
    @Published var userType: String = ""
    @Published var coachMessaging: Bool = true
    // Coach
    @Published var personalQuote: String = ""
    @Published var coachingAchievements: [String] = []
    @Published var coachingExperience: [String] = []
    @Published var timeAvailability: [String: [String]] = [:]
    @Published var athleteMessaging: Bool = true
    @Published var trainingLocations: [CoachLocation] = []
    @Published var individualCost: Double? = nil
    @Published var groupCost: Double? = nil
    @Published var sports: [String] = []
    @Published var sportPositions: [String:[String]] = [:]
    @Published var cancellationNotice: Int?
    var rating: Float {
        guard !reviews.isEmpty else { return 0.0 }
        let sum = reviews.reduce(0) { $0 + $1.star }
        return sum / Float(reviews.count)
    }
    var peopleCoached: Int {
        guard !csubmitedSessions.isEmpty else { return 0 }
        var seenID = Set<UUID>()
        for session in csubmitedSessions {
            if !seenID.contains(session.other.id) {
                seenID.insert(session.other.id)
            }
        }
        return seenID.count
    }
    var hoursCoached: String {
        guard !csubmitedSessions.isEmpty else { return "0hr 0mn" }
        let totalSeconds = csubmitedSessions.reduce(0.0) { total, session in
            total + session.finished.timeIntervalSince(session.date)
        }
        let seconds = Int(totalSeconds)
        let hours = seconds / 3600
        return "\(hours)hr"
    }

    // Other
    @Published var interestedCoaches: [ProfileID] = []
    @Published var myCoaches: [ProfileID] = []
    @Published var interestedAthletes: [ProfileID] = []
    @Published var potentialAthletes: [ProfileID] = []
    @Published var messages: [UUID: [Message]] = [:]

    @Published var hasCardOnFile: Bool = false
    
    @Published var myRequests: [Session] = []
    @Published var aupcomingSessions: [Session] = []
    @Published var apastSessions: [Session] = []
    
    @Published var jobRequests: [Session] = []
    @Published var currentAthletes: [ProfileID:(Int,Double)] = [:]
    @Published var cupcomingSessions: [Session] = []
    @Published var cunsubmittedSessions: [Session] = []
    @Published var csubmitedSessions: [Session] = []
    
    @Published var ratings: Int = 0
    @Published var reviews: [Review] = []
    var responseTime: Int = 0
    @Published var offenderWatch: Bool? = nil
    @Published var directDeposit: [String]? = nil
    
    // Map a DB row -> UI object
    func apply(row: Profile) {
        id = row.id
        firstName = row.firstName
        lastName = row.lastName
        coachAccount = row.coachAccount
        userType = row.userType
        postalCode = row.postalCode
        if let pp = row.imageURL, !pp.isEmpty {
            imageURL = pp
        } else {
            imageURL = "athlinklogo"
        }
        notifications = row.notifications
        coachMessaging = row.coachMessaging
    }
    
    // Map a DB coachRow -> UI object
    func coachApply(row: CoachProfile) {
        personalQuote = row.personalQuote
        coachingAchievements = row.coachingAchievements
        coachingExperience = row.coachingExperience
        timeAvailability = row.timeAvailability
        athleteMessaging = row.athleteMessaging
        individualCost = row.individualCost
        groupCost = row.groupCost
        sports = row.sports
        sportPositions = row.sportPositions
        cancellationNotice = row.cancellationNotice
    }
    
    // Equatable Conformance
    static func == (lhs: ProfileID, rhs: ProfileID) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable Conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// Important App Wide Features
@MainActor
class RootViewObj: NSObject, ObservableObject, CLLocationManagerDelegate {
    init(client: SupabaseClient) {
        self.client = client
    }
    // Root View Options
    enum RootView {
        case Login
        case Home
        case Coach
    }
    // If logged in resets nevagation path
    @Published var rootView: RootView = .Login {
        didSet {
            path = NavigationPath()
        }
    }
    @Published var path = NavigationPath()
    @Published var profile = ProfileID()
    @Published var sessType = false
    @Published var lastPage = ""
    
    // Location Managment
    @Published var locationManager: CLLocationManager?
    @Published var userCoordinate: CLLocationCoordinate2D?
    func checkLocationEnabled() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        if locationManager == nil {
            let manager = CLLocationManager()
            manager.delegate = self
            manager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager = manager
        }
        checkLocationAuthorization()
    }
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("You're location is restricted.")
        case .denied:
            print("You have denied this app locations permision. Go into settings to change this.")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    // Delegate Overide
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            checkLocationAuthorization()
        }
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coord = locations.last?.coordinate
        Task { @MainActor in
            self.userCoordinate = coord
        }
    }
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }
    
    // Backend server
    @Published var client: SupabaseClient
    @Published var selectedSession: ProfileID? = nil
    // Turns rootviewobj into the signd in profile
    func loadProfile() async throws {
        // Gets the current session and user
        guard let _ = client.auth.currentSession,
              let user = client.auth.currentUser else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])
        }
        // Fetch Main Data
        let athleteRow: Profile = try await client
          .from("profiles")
          .select("id, first_name, last_name, coach_account, image_url, postal_code, user_type, notifications, coach_messaging")
          .eq("id", value: user.id)
          .single()
          .execute()
          .value
        profile.apply(row: athleteRow)
        // If Coach Fetch Other Data
        if athleteRow.coachAccount {
            let coachRow: CoachProfile = try await client
                .from("coach_profile")
                .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, athlete_messaging, individual_cost, group_cost, sports, sport_positions, cancellation_notice")
                .eq("id", value: user.id)
                .single()
                .execute()
                .value
            profile.coachApply(row: coachRow)
            // Grabs training locations and adds if not empty
            let rows: [CoachLocation] = try await client
                .from("location")
                .select("id,name,lat,lng")
                .eq("coach_id", value: user.id)
                .execute()
                .value
            profile.trainingLocations = rows
        }
    }
    // Profile image
    func uploadImage(image: UIImage) async throws {
        // Gets the current session and user
        guard let _ = client.auth.currentSession,
              let user = client.auth.currentUser else {
            throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])
        }
        // Gets Image Data
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageConvert", code: 0, userInfo: nil)
        }
        // Uploads into bucket
        let fileName = "\(profile.id.uuidString).jpg"
        let _ = try await client.storage
            .from("profile-images")
            .upload(fileName, data: data, options: FileOptions(contentType: "image/jpeg"))
        // Gets url for image
        let urlResponse = try client.storage
            .from("profile-images")
            .getPublicURL(path: fileName)
        let urlString = urlResponse.absoluteString
        // Upload URL to table
        let _ = try await client
            .from("profiles")
            .update(["image_url": urlString])
            .eq("id", value: user.id)
            .execute()
    }
}

@main
struct AthLinkApp: App {
    @StateObject var rootViewObj: RootViewObj
    @StateObject var signupDraftObj: SignupDraft = SignupDraft()
    
    // Backend initializer
    init() {
        let urlString = infoValue(key: "SUPABASE_URL")
        guard let supabaseURL = URL(string: urlString) else {
          fatalError("⚠️ SUPABASE_URL is invalid: \(urlString)")
        }
        let apiKey = infoValue(key: "SUPABASE_PUBLISHABLE_API_KEY")
        // Backend Client
        let client = SupabaseClient(
          supabaseURL: supabaseURL,
          supabaseKey: apiKey
        )
        
        _rootViewObj = StateObject(wrappedValue: RootViewObj(client: client))
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // Athlete home search helper
    @StateObject var fSearch = SearchHelp()
    // check for adding session request to messages
    @State var pushReq = false
    @State var sessType = false
    @State var editMess: (Message, Int)? = nil
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $rootViewObj.path) {
                Group {
                    if rootViewObj.rootView == .Login {
                        ExistingLoginView()
                            .environmentObject(rootViewObj)
                    } else if rootViewObj.rootView == .Home {
                        home()
                            .environmentObject(rootViewObj)
                            .environmentObject(fSearch)
                    } else {
                        CoachHome()
                            .environmentObject(rootViewObj)
                    }
                }
                .navigationDestination(for: String.self) { destination in
                    switch destination {
                    case "Sign":
                        LoginScreen()
                            .environmentObject(rootViewObj)
                            .environmentObject(signupDraftObj)
                    case "Coach":
                        CoachLogin()
                            .environmentObject(rootViewObj)
                            .environmentObject(signupDraftObj)
                    case "Terms":
                        TermsOfServiceView()
                    case "Privacy":
                        PrivacyPolicyView()
                    case "Satisfaction":
                        Satisfaction()
                    case "Receive":
                        Receive()
                    case "Question":
                        Question()
                    case "Support":
                        Support()
                    case "CoachAccount":
                        CouchAccount()
                            .environmentObject(rootViewObj)
                    case "MessageAccount":
                        Chat(pushReq: $pushReq, editMess: $editMess)
                            .environmentObject(rootViewObj)
                    case "Request":
                        RequestSess(chatTog: $pushReq, editMess: $editMess)
                            .environmentObject(rootViewObj)
                    case "SessionInfo":
                        SessionInfo()
                            .environmentObject(rootViewObj)
                    default:
                        EmptyView()
                    }
                }
                .onChange(of: rootViewObj.lastPage) {
                    if rootViewObj.lastPage == "Chat" {
                        rootViewObj.path.append("CoachAccount")
                    //Chat->CouchAccount->Chat
                    }  else if rootViewObj.lastPage == "Remove" {
                        rootViewObj.lastPage = ""
                        rootViewObj.path.removeLast()
                    //Session->CouchAccount->Chat
                    } else if rootViewObj.lastPage == "Sess" {
                        rootViewObj.path.append("MessageAccount")
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

import SwiftUI
import SwiftData
import CoreLocation
import Supabase
import MapKit

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
    var coachAccount: Bool = false
    var userType: String
    var imageURL: String?
    var notifications: Bool = false
    var coachMessaging: Bool = false
    var athleteUpcomingSessions: [Session] = []
    var athletePastSessions: [Session] = []
    var cardOnFile: Bool = false
    var currentCoaches: [UUID] = []
    var interestedCoaches: [UUID] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case coachAccount = "coach_account"
        case userType = "user_type"
        case imageURL = "image_url"
        case notifications
        case coachMessaging = "coach_messaging"
        case athleteUpcomingSessions = "athlete_upcoming_sessions"
        case athletePastSessions = "athlete_past_sessions"
        case cardOnFile = "card_on_file"
        case currentCoaches = "current_coaches"
        case interestedCoaches = "interested_coaches"
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
    var personalQuote: String?
    var coachingAchievements: [String] = []
    var coachingExperience: [String] = []
    var timeAvailability: [String: [String]] = [:]
    var athleteMessaging: Bool = false
    var individualCost: Double?
    var groupCost: Double?
    var sports: [String] = []
    var sportPositions: [String:[String]] = [:]
    var cancellationNotice: Int?
    var coachUpcomingSessions: [Session] = []
    var coachUnsubmittedSessions: [Session] = []
    var coachSubmittedSessions: [Session] = []
    var jobRequests: [Session] = []
    var athleteRequests: [Session] = []
    var interestedAthletes: [UUID] = []
    var currentAthletes: [UUID: Athletes] = [:]
    var trainingLocations: [structLocation] = []

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
        case coachUpcomingSessions = "coach_upcoming_sessions"
        case coachUnsubmittedSessions = "coach_unsubmitted_sessions"
        case coachSubmittedSessions = "coach_submitted_sessions"
        case jobRequests = "job_requests"
        case athleteRequests = "athlete_requests"
        case interestedAthletes = "interested_athletes"
        case currentAthletes = "current_athletes"
        case trainingLocations = "training_locations"
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
    // Basic
    var id: UUID = UUID()
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var coachAccount: Bool = false
    @Published var imageURL = "athlinklogo"
    @Published var notifications: Bool = false
    @Published var messages: [UUID: [MessageRow]] = [:]
    // Athlete
    @Published var userType: String = ""
    @Published var coachMessaging: Bool = true
    @Published var athleteUpcomingSessions: [Session] = []
    @Published var athletePastSessions: [Session] = []
    @Published var currentCoaches: [UUID] = []
    @Published var interestedCoaches: [UUID] = []
    @Published var cardOnFile: Bool = false
    @Published var postedSession: Session? = nil
    // Coach
    @Published var personalQuote: String = ""
    @Published var coachingAchievements: [String] = []
    @Published var coachingExperience: [String] = []
    @Published var timeAvailability: [String: [String]] = [:]
    @Published var athleteMessaging: Bool = true
    @Published var trainingLocations: [structLocation] = []
    @Published var individualCost: Double? = nil
    @Published var groupCost: Double? = nil
    @Published var sports: [String] = []
    @Published var sportPositions: [String:[String]] = [:]
    @Published var cancellationNotice: Int?
    @Published var coachUpcomingSessions: [Session] = []
    @Published var coachUnsubmittedSessions: [Session] = []
    @Published var coachSubmittedSessions: [Session] = []
    @Published var jobRequests: [Session] = []
    @Published var athleteRequests: [Session] = []
    @Published var interestedAthletes: [UUID] = []
    @Published var currentAthletes: [UUID:Athletes] = [:]
    // Computed
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    // Amount of coached athletes from submittes sessions
    var peopleCoached: Int {
        guard !coachSubmittedSessions.isEmpty else { return 0 }
        var seenID = Set<UUID>()
        for session in coachSubmittedSessions {
            if !seenID.contains(session.other) {
                seenID.insert(session.other)
            }
        }
        return seenID.count
    }
    // Amount of hours athletes from submittes sessions
    var hoursCoached: String {
        guard !coachSubmittedSessions.isEmpty else { return "0hr 0mn" }
        let totalSeconds = coachSubmittedSessions.reduce(0.0) { total, session in
            total + session.finished.timeIntervalSince(session.date)
        }
        let seconds = Int(totalSeconds)
        let hours = seconds / 3600
        return "\(hours)hr"
    }
        
    // Map a DB row -> UI object
    func apply(row: Profile) {
        id = row.id
        firstName = row.firstName
        lastName = row.lastName
        coachAccount = row.coachAccount
        userType = row.userType
        if let pp = row.imageURL, !pp.isEmpty {
            imageURL = pp
        } else {
            imageURL = "athlinklogo"
        }
        notifications = row.notifications
        coachMessaging = row.coachMessaging
        athleteUpcomingSessions = row.athleteUpcomingSessions
        athletePastSessions = row.athletePastSessions
        cardOnFile = row.cardOnFile
        currentCoaches = row.currentCoaches
        interestedCoaches = row.interestedCoaches
    }
    
    // Map a DB coachRow -> UI object
    func coachApply(row: CoachProfile) {
        personalQuote = row.personalQuote ?? ""
        coachingAchievements = row.coachingAchievements
        coachingExperience = row.coachingExperience
        timeAvailability = row.timeAvailability
        athleteMessaging = row.athleteMessaging
        individualCost = row.individualCost
        groupCost = row.groupCost
        sports = row.sports
        sportPositions = row.sportPositions
        cancellationNotice = row.cancellationNotice
        coachUpcomingSessions = row.coachUpcomingSessions
        coachUnsubmittedSessions = row.coachUnsubmittedSessions
        coachSubmittedSessions = row.coachSubmittedSessions
        jobRequests = row.jobRequests
        athleteRequests = row.athleteRequests
        interestedAthletes = row.interestedAthletes
        currentAthletes = row.currentAthletes
        trainingLocations = row.trainingLocations
    }
    // Map a DB posted session -> UI object
    func sessionApply(row: PostedSessionRow) {
        guard
            let coach = row.coach,
            let sport = row.sport,
            let type = row.type,
            let typeRate = row.typeRate,
            let start = row.startDate,
            let finish = row.finishDate,
            let location = row.location
        else {
            return
        }

        postedSession = Session(
            id: row.id,
            reqDate: row.createdAt,
            other: coach,
            sport: sport,
            type: type,
            typeRate: typeRate,
            date: start,
            finished: finish,
            location: location,
            rate: row.algoRate,
            description: row.description
        )
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
class RootViewObj: NSObject, ObservableObject {
    // MARK: Initializer
    init(client: SupabaseClient) {
        // Sets up supabase DB
        self.client = client
        // Calls NSObject initializer
        super.init()
        // Gets locaion
        setupLocation()
    }
    
    // Root View Options
    enum RootView: String {
        case Login
        case Home
        case Coach
        case Loading
    }
    
    // MARK: Navigation
    @Published var path = NavigationPath()
    @Published var lastPage = ""
    @Published var chatPartner: PublicUser?
    @Published var selectedJobSession: Session?
    // True: Upcoming session, False: Past session
    @Published var sessType = false
    @Published var selectedAthleteSession: Session?
    // Saved account info
    @Published var isUnSaved: Bool = false
    @Published var showUnSavedAlert: Bool = false
    @Published var pendingTab: Int? = nil
    @Published var selectedTab: Int = 0
    
    // MARK: General Helpers
    
    // Persistant login
    @MainActor
    func restoreSession() async {
        defer {
            if rootView == .Loading { rootView = .Login }
        }
        
        guard client.auth.currentSession != nil, client.auth.currentUser != nil else {
            rootView = .Login
            return
        }
        await client.auth.startAutoRefresh()
        do {
            try await loadProfile()
            rootView = profile.coachAccount ? .Coach : .Home
        } catch {
            await signOut()
        }
    }
    
    // MARK: DB Authentification
    private var authTask: Task<Void, Never>?
    // Set to true while signup/signin is in progress to suppress the auth listener to prevent signedIn event
    var suppressAuthListener = false
    @MainActor
    func startAuthListener() {
        // Make sure no auth task is running
        authTask?.cancel()
        authTask = Task { [weak self] in
            guard let self else { return }

            for await (event, _) in self.client.auth.authStateChanges {
                guard !self.suppressAuthListener else { continue }
                switch event {
                case .signedIn:
                    // Keep session alive and ensure profile is loaded
                    await self.restoreSession()
                case .tokenRefreshed:
                    break
                case .signedOut:
                    // Sign out
                    await self.signOut()
                default:
                    break
                }
            }
        }
    }
    // DB Sign out
    @MainActor
    func signOut() async {
        // Stops refresh token
        await client.auth.stopAutoRefresh()
        
        // Sign out
        do {
            try await client.auth.signOut()
        } catch {
            print("Sign out error:", error)
        }
        
        // Resets front end UI
        profile = ProfileID()
        // Sets rootview to log in
        rootView = .Login
    }
    
    // If logged in resets nevagation path
    @Published var rootView: RootView = .Loading {
        didSet {
            path = NavigationPath()
        }
    }
    
    // MARK: Frontend
    @Published var profile = ProfileID()
    
    // MARK: Backend
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
            .select("id, first_name, last_name, coach_account, image_url, user_type, notifications, coach_messaging, athlete_upcoming_sessions, athlete_past_sessions, card_on_file, current_coaches, interested_coaches")
            .eq("id", value: user.id)
            .single()
            .execute()
            .value
        profile.apply(row: athleteRow)
        
        // If has a posted session, fetch (optional - may not exist)
        do {
            let sessionRow: PostedSessionRow = try await client
                .from("posted_sessions")
                .select("id, created_at, coach, sport, type, type_rate, start_date, finish_date, location, algo_rate, description, lat, long")
                .eq("id", value: user.id)
                .single()
                .execute()
                .value
            profile.sessionApply(row: sessionRow)
        } catch {
            // No posted session exists - this is fine
            print("No posted session found (this is normal)")
        }
        
        // If Coach Fetch Other Data
        if athleteRow.coachAccount {
            // Update 
            let coachRow: CoachProfile = try await client
                .from("coach_profile")
                .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, athlete_messaging, individual_cost, group_cost, sports, sport_positions, cancellation_notice, coach_upcoming_sessions, coach_unsubmitted_sessions, coach_submitted_sessions, job_requests, interested_athletes, current_athletes, athlete_requests, training_locations")
                .eq("id", value: user.id)
                .single()
                .execute()
                .value
            profile.coachApply(row: coachRow)
        }
        
        // If coach, move expired sessions to unsubmitted
        if athleteRow.coachAccount {
            do {
                try await client.rpc("move_past_sessions").execute()
            } catch {
                print("move_past_sessions RPC skipped:", error)
            }
        }

        // TEMP: Seed test data (comment out after running once)
//        await TestData.seed(client: client)
    }
    
    // MARK: Location
    private let locationManager = CLLocationManager()
    // Permission
    @Published var locationStatus: CLAuthorizationStatus = .notDetermined
    @Published var currentLocation: CLLocation? = nil
    // Set lcoation delegate, accuracy, and current status
    func setupLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationStatus = locationManager.authorizationStatus
    }
    // Request from user
    func requestWhenInUseLocation() {
        locationManager.requestWhenInUseAuthorization()
    }
    // Get the location
    func locationUpdate() {
        locationStatus = locationManager.authorizationStatus
        guard locationStatus == .authorizedWhenInUse || locationStatus == .authorizedAlways else { return }
        locationManager.startUpdatingLocation()
    }
    // Stops updates
    func stopUpdate() {
        locationManager.stopUpdatingLocation()
    }
    // Reverse geocode
    @MainActor
    func zipFromLocation() async -> String? {
        guard let loc = currentLocation else { return nil }

        do {
            let placemarkers = try await CLGeocoder().reverseGeocodeLocation(loc)
            return placemarkers.first?.postalCode
        } catch {
            print("Reverse geocode failed:", error)
            return nil
        }
    }
}

// Extension allowing rootview to be a location manager deleagte
extension RootViewObj: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            locationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                locationUpdate()
            } else {
                stopUpdate()
                currentLocation = nil
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        Task { @MainActor in
            currentLocation = location
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error)
    }
}

// MARK: Main App
@main
struct AthLinkApp: App {
    // Main app object
    @StateObject var rootViewObj: RootViewObj
    // Temp signup object
    @StateObject var signupDraftObj: SignupDraft = SignupDraft()
    // Athlete home search helper
    @StateObject var fSearch = SearchHelp()
    
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
          supabaseKey: apiKey,
          options: SupabaseClientOptions(
            auth: .init(
                storage: AuthClient.Configuration.defaultLocalStorage,
                autoRefreshToken: true
            )
          )
        )
        
        _rootViewObj = StateObject(wrappedValue: RootViewObj(client: client))
    }
    
    // Navigation window
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $rootViewObj.path) {
                Group {
                    if rootViewObj.rootView == .Loading {
                        VStack(spacing: 20) {
                            Image("athlinklogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.2)
                            Text("Loading...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.white)
                    } else if rootViewObj.rootView == .Home {
                        home()
                            .environmentObject(rootViewObj)
                            .environmentObject(fSearch)
                    } else if rootViewObj.rootView == .Coach {
                        CoachHome()
                            .environmentObject(rootViewObj)
                    } else {
                        ExistingLoginView()
                            .environmentObject(rootViewObj)
                    }
                }
                // When a rootView appears, if no permission asked for yet, ask
                .onAppear {
                    if rootViewObj.locationStatus == .notDetermined {
                        rootViewObj.requestWhenInUseLocation()
                    }
                }
                // Navigation stack
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
                        Chat()
                            .environmentObject(rootViewObj)
                    case "Request":
                        RequestSess()
                            .environmentObject(rootViewObj)
                    case "SessionInfo":
                        SessionInfo()
                            .environmentObject(rootViewObj)
                    case "CoachRequestSess":
                        CoachRequestSess()
                            .environmentObject(rootViewObj)
                    default:
                        EmptyView()
                    }
                }
            }
            // On start try to restore last session and create an authentication listener
            .task {
                await rootViewObj.restoreSession()
                rootViewObj.startAuthListener()
            }
        }
    }
}

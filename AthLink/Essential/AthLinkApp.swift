import SwiftUI
import SwiftData
import CoreLocation
import Supabase
import MapKit
import StripePaymentSheet
import UserNotifications

// Retreive Info.plist info
func infoValue(key: String) -> String {
    guard let val = Bundle.main.object(forInfoDictionaryKey: key) as? String,
          !val.isEmpty
    else {
        fatalError("⚠️ Missing \(key) in Info.plist")
    }
    return val
}

// User Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02x", $0) }.joined()
        log.info("APNs token received")
        // Saves to user defaults
        UserDefaults.standard.set(token, forKey: "apns_device_token")
    }

     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
         log.error("APNs registration failed: \(error.localizedDescription)")
     }

     func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
         return [.banner, .badge, .sound]
     }
 }
 

// Backend main data collection
struct Profile: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var firstName: String
    var lastName: String
    var coachAccount: Bool = false
    var userType: String
    var imageURL: String?
    var athleteUpcomingSessions: [Session] = []
    var athletePastSessions: [Session] = []
    var stripeCustomerId: String? = nil
    var hasPaymentMethod: Bool = false
    var currentCoaches: [UUID] = []
    var referralCode: String = ""
    var referredBy: String = ""
    var credits: Int = 0
    var deviceToken: String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case coachAccount = "coach_account"
        case userType = "user_type"
        case imageURL = "image_url"
        case athleteUpcomingSessions = "athlete_upcoming_sessions"
        case athletePastSessions = "athlete_past_sessions"
        case stripeCustomerId = "stripe_customer_id"
        case hasPaymentMethod = "has_payment_method"
        case currentCoaches = "current_coaches"
        case referralCode = "referral_code"
        case referredBy = "referred_by"
        case credits
        case deviceToken = "device_token"
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
    var individualCost: Double?
    var groupCost: Double?
    var sports: [String] = []
    var sportPositions: [String:[String]] = [:]
    var cancellationNotice: Int?
    var coachUpcomingSessions: [Session] = []
    var coachPastSessions: [Session] = []
    var jobRequests: [Session] = []
    var athleteRequests: [Session] = []
    var currentAthletes: [UUID: Athletes] = [:]
    var trainingLocations: [structLocation] = []
    var stripeConnectId: String? = nil
    var completedOnboarding: Bool = false
    var completedCheckr: Bool = false

    // Codable Conformance
    enum CodingKeys: String, CodingKey {
        case id
        case personalQuote = "personal_quote"
        case coachingAchievements = "coaching_achievements"
        case coachingExperience = "coaching_experience"
        case timeAvailability = "time_availability"
        case individualCost = "individual_cost"
        case groupCost = "group_cost"
        case sports
        case sportPositions = "sport_positions"
        case cancellationNotice = "cancellation_notice"
        case coachUpcomingSessions = "coach_upcoming_sessions"
        case coachPastSessions = "coach_past_sessions"
        case jobRequests = "job_requests"
        case athleteRequests = "athlete_requests"
        case currentAthletes = "current_athletes"
        case trainingLocations = "training_locations"
        case stripeConnectId = "stripe_connect_id"
        case completedOnboarding = "completed_onboarding"
        case completedCheckr = "completed_checkr"
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
    @Published var messages: [UUID: [MessageRow]] = [:]
    @Published var referralCode: String = ""
    @Published var referredBy: String = ""
    @Published var credits: Int = 0
    @Published var deviceToken: String? = nil
    // Athlete
    @Published var userType: String = ""
    @Published var athleteUpcomingSessions: [Session] = []
    @Published var athletePastSessions: [Session] = []
    @Published var currentCoaches: [UUID] = []
    @Published var stripeCustomerId: String? = nil
    @Published var hasPaymentMethod: Bool = false
    @Published var postedSession: Session? = nil
    // Coach
    @Published var personalQuote: String = ""
    @Published var coachingAchievements: [String] = []
    @Published var coachingExperience: [String] = []
    @Published var timeAvailability: [String: [String]] = [:]
    @Published var trainingLocations: [structLocation] = []
    @Published var individualCost: Double? = nil
    @Published var groupCost: Double? = nil
    @Published var sports: [String] = []
    @Published var sportPositions: [String:[String]] = [:]
    @Published var cancellationNotice: Int?
    @Published var coachUpcomingSessions: [Session] = []
    @Published var coachPastSessions: [Session] = []
    @Published var jobRequests: [Session] = []
    @Published var athleteRequests: [Session] = []
    @Published var currentAthletes: [UUID:Athletes] = [:]
    @Published var stripeConnectId: String? = nil
    @Published var completedOnboarding: Bool = false
    @Published var completedCheckr: Bool = false
    // Computed
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    // Amount of coached athletes from submittes sessions
    var peopleCoached: Int {
        guard !coachPastSessions.isEmpty else { return 0 }
        var seenID = Set<UUID>()
        for session in coachPastSessions {
            if !seenID.contains(session.other) {
                seenID.insert(session.other)
            }
        }
        return seenID.count
    }
    // Amount of hours athletes from submittes sessions
    var hoursCoached: String {
        guard !coachPastSessions.isEmpty else { return "0hr 0mn" }
        let totalSeconds = coachPastSessions.reduce(0.0) { total, session in
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
        athleteUpcomingSessions = row.athleteUpcomingSessions
        athletePastSessions = row.athletePastSessions
        stripeCustomerId = row.stripeCustomerId
        hasPaymentMethod = row.hasPaymentMethod
        currentCoaches = row.currentCoaches
        referralCode = row.referralCode
        referredBy = row.referredBy
        credits = row.credits
        deviceToken = row.deviceToken
    }
    
    // Map a DB coachRow -> UI object
    func coachApply(row: CoachProfile) {
        personalQuote = row.personalQuote ?? ""
        coachingAchievements = row.coachingAchievements
        coachingExperience = row.coachingExperience
        timeAvailability = row.timeAvailability
        individualCost = row.individualCost
        groupCost = row.groupCost
        sports = row.sports
        sportPositions = row.sportPositions
        cancellationNotice = row.cancellationNotice
        coachUpcomingSessions = row.coachUpcomingSessions
        coachPastSessions = row.coachPastSessions
        jobRequests = row.jobRequests
        athleteRequests = row.athleteRequests
        currentAthletes = row.currentAthletes
        trainingLocations = row.trainingLocations
        stripeConnectId = row.stripeConnectId
        completedOnboarding = row.completedOnboarding
        completedCheckr = row.completedCheckr
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
    @Published var selectedCoachSession: Session?
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
            await saveDeviceToken()
            rootView = profile.coachAccount ? .Coach : .Home
        } catch {
            await signOut()
        }
    }
    
    func saveDeviceToken() async {
        guard let token = UserDefaults.standard.string(forKey: "apns_device_token"),
              let user = client.auth.currentUser else { return }
        do {
            try await client
                .from("profiles")
                .update(["device_token": token])
                .eq("id", value: user.id.uuidString)
                .execute()
        } catch {
            log.error("Failed to save device token: \(error.localizedDescription)")
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
            log.error("Sign out failed: \(error.localizedDescription)")
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
            .select("id, first_name, last_name, coach_account, image_url, user_type, athlete_upcoming_sessions, athlete_past_sessions, stripe_customer_id, has_payment_method, current_coaches, referral_code, referred_by, credits, device_token")
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
            log.debug("No posted session found")
        }
        
        // If Coach Fetch Other Data
        if athleteRow.coachAccount {
            // Update 
            let coachRow: CoachProfile = try await client
                .from("coach_profile")
                .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, individual_cost, group_cost, sports, sport_positions, cancellation_notice, coach_upcoming_sessions, coach_past_sessions, job_requests, current_athletes, athlete_requests, training_locations, stripe_connect_id, completed_onboarding, completed_checkr")
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
                log.warning("move_past_sessions RPC skipped: \(error.localizedDescription)")
            }
        }

        // Clean up expired posted sessions on launch
        do {
            try await client.rpc("clean_expired_posted_sessions").execute()
        } catch {
            log.warning("clean_expired_posted_sessions RPC skipped: \(error.localizedDescription)")
        }

        // TEMP: Seed test data (comment out after running once)
        await TestData.seed(client: client)
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
            log.error("Reverse geocode failed: \(error.localizedDescription)")
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
        log.error("Location error: \(error.localizedDescription)")
    }
}

// MARK: Main App
@main
struct AthLinkApp: App {
    // Main app object
    @StateObject var rootViewObj: RootViewObj
    // App deligator
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // Athlete home search helper
    @StateObject var fSearch = SearchHelp()
    
    // Backend initializer
    init() {
        let urlString = infoValue(key: "SUPABASE_URL")
        guard let supabaseURL = URL(string: urlString) else {
          fatalError("⚠️ SUPABASE_URL is invalid: \(urlString)")
        }
        let apiKey = infoValue(key: "SUPABASE_PUBLISHABLE_API_KEY")
        // Set up stripe payment sheet
        let stripKey = infoValue(key: "STRIPE_PUBLISHABLE_API_KEY")
        STPAPIClient.shared.publishableKey = stripKey
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
                    case "Coach":
                        CoachLogin()
                            .environmentObject(rootViewObj)
                    case "Terms":
                        TermsOfServiceView()
                    case "Privacy":
                        PrivacyPolicyView()
                    case "Satisfaction":
                        Satisfaction()
                            .environmentObject(rootViewObj)
                    case "Receive":
                        Receive()
                            .environmentObject(rootViewObj)
                    case "Question":
                        Question()
                    case "Support":
                        Support()
                            .environmentObject(rootViewObj)
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
                    case "CoachSessionInfo":
                        CoachSessionInfo()
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
            // Stripe return url handler
            .onOpenURL() { incomingURL in
                let _ = StripeAPI.handleURLCallback(with: incomingURL)

                if incomingURL.scheme == "athlink" {
                    switch incomingURL.host {
                    case "stripe-connect-return":
                        Task {
                            guard let connectId = rootViewObj.profile.stripeConnectId else { return }
                            do {
                                let url = URL(string: "\(infoValue(key: "SUPABASE_URL"))/functions/v1/check-connect-status")!
                                var request = URLRequest(url: url)
                                request.httpMethod = "POST"
                                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.setValue("Bearer \(rootViewObj.client.auth.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                                request.httpBody = try JSONEncoder().encode(["connect_id": connectId])
                                let (data, _) = try await URLSession.shared.data(for: request)
                                if let json = try? JSONDecoder().decode([String: Bool].self, from: data),
                                   let completed = json["completedOnboarding"], completed {
                                    await MainActor.run { rootViewObj.profile.completedOnboarding = true }
                                }
                            } catch {
                                log.error("Check connect status failed: \(error.localizedDescription)")
                            }
                        }
                    case "stripe-connect-refresh":
                        Task {
                            guard let connectId = rootViewObj.profile.stripeConnectId else { return }
                            do {
                                let url = URL(string: "\(infoValue(key: "SUPABASE_URL"))/functions/v1/create-onboarding-link")!
                                var request = URLRequest(url: url)
                                request.httpMethod = "POST"
                                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                request.setValue("Bearer \(rootViewObj.client.auth.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                                request.httpBody = try JSONEncoder().encode([
                                    "connect_id": connectId,
                                    "return_url": "athlink://stripe-connect-return",
                                    "refresh_url": "athlink://stripe-connect-refresh"
                                ])
                                let (data, _) = try await URLSession.shared.data(for: request)
                                if let json = try? JSONDecoder().decode([String: String].self, from: data),
                                   let onboardingURL = json["onboardingUrl"],
                                   let link = URL(string: onboardingURL) {
                                    await MainActor.run { UIApplication.shared.open(link) }
                                }
                            } catch {
                                log.error("Refresh onboarding link failed: \(error.localizedDescription)")
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
    }
}

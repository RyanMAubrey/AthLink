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

// UI Component
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

// Array Extension
extension Array {
    func chunked(into size: Int, dropLastPartialChunk: Bool = false) -> [[Element]] {
        var chunks: [[Element]] = []
        
        for i in stride(from:0,to:self.count,by:size) {
            let chunk = Array(self[i..<(Swift.min(i+size,self.count))])
            if dropLastPartialChunk && chunk.count<size {
                continue
            }
            chunks.append(chunk)
        }
        return chunks
    }
}

// Retreive Info.plist info
func infoValue(key: String) -> String {
    guard let val = Bundle.main.object(forInfoDictionaryKey: key) as? String,
          !val.isEmpty
    else {
        fatalError("⚠️ Missing \(key) in Info.plist")
    }
    return val
}

// Coach Login Helper
final class SignupDraft: ObservableObject {
    @Published var userType: String = "Athlete"
    @Published var firstName = ""
    @Published var lastName  = ""
    @Published var postalCode = ""
    @Published var phoneNumber: String? = nil
    @Published var email = ""
    @Published var password = ""
}

// Athlete Side Search Helper
class SearchHelp: ObservableObject {
    @Published var zEditing : Bool = false
    @Published var zip : String = ""
    @Published var validZ : Bool = false {
        didSet {
            filled()
        }
    }
    @Published var sportVal : Int = 0 {
        didSet {
            filled()
        }
    }
    @Published var fSearch : Bool = false
    func filled() {
        if (sportVal != 0 && validZ) {
            fSearch = true
        } else {
            fSearch = false
        }
    }
    // validates zip code
    func validate() {
        let zipCodePattern = "^[0-9]{5}(?:-[0-9]{4})?$"
        let regex = try! NSRegularExpression(pattern: zipCodePattern)
        let range = NSRange(location: 0, length: zip.utf16.count)
        validZ = regex.firstMatch(in: zip, options: [], range: range) != nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if !validZ {
            zip = ""
        }
    }
}

// Time Selector
struct AvailabilityGrid: View {
    @Binding var selectedA: [String: [String]]
    
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let times = Array(6..<12).map { "\($0) AM" } + Array(12..<18).map { "\($0 - 12) PM" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Draws day columns
            HStack(spacing: 2) {
                Text("")
                    .frame(width: 40)
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(3)
                }
            }
            // Draws time rowns
            ForEach(times.indices, id: \.self) { index in
                HStack(spacing: 2) {
                    Text(times[index])
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    ForEach(0..<7) { dayIndex in
                        Button(action: {
                            toggleAvailability(day: days[dayIndex], timeSlot: times[index])
                        }) {
                            Rectangle()
                                .fill(isSelected(day: days[dayIndex], timeSlot: times[index]) ? Color.blue : Color.gray.opacity(0.2))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 25)
                    }
                }
                .frame(height: 30)
            }
        }
        .padding(5)
    }
    
    func toggleAvailability(day: String, timeSlot: String) {
        if selectedA[day]?.contains(timeSlot) ?? false {
            selectedA[day]?.removeAll(where: { $0 == timeSlot })
        } else {
            selectedA[day, default: []].append(timeSlot)
        }
    }
    
    func isSelected(day: String, timeSlot: String) -> Bool {
        return selectedA[day]?.contains(timeSlot) ?? false
    }
}

// Sports types
enum Sports: Hashable, CustomStringConvertible {
    case Football
    
    var description: String {
        switch self {
        case .Football:
            return "Football"
        }
    }
}

// Sports Positions
enum Positions: Hashable, CustomStringConvertible {
    enum FootballPositions: Hashable, CustomStringConvertible {
        case defensive_Tackle
        case nose_Tackle
        case defensive_End
        case middle_Linebacker
        case outside_Linebacker
        case strongSide_Linebacker
        case weakSide_Linebacker
        case cornerback
        case free_Safety
        case strong_Safety
        case kicker
        case punter
        case long_Snapper
        case holder
        case kick_Returner
        case punt_Returner
        case gunner
        
        var description: String {
            switch self {
            case .defensive_Tackle:
                return "Defensive Tackle"
            case .nose_Tackle:
                return "Nose Tackle"
            case .defensive_End:
                return "Defensive End"
            case .middle_Linebacker:
                return "Middle Linebacker"
            case .outside_Linebacker:
                return "Outside Linebacker"
            case .strongSide_Linebacker:
                return "Strong Side Linebacker"
            case .weakSide_Linebacker:
                return "Weak Side Linebacker"
            case .cornerback:
                return "Cornerback"
            case .free_Safety:
                return "Free Safety"
            case .strong_Safety:
                return "Strong Safety"
            case .kicker:
                return "Kicker"
            case .punter:
                return "Punter"
            case .long_Snapper:
                return "Long Snapper"
            case .holder:
                return "Holder"
            case .kick_Returner:
                return "Kick Returner"
            case .punt_Returner:
                return "Punt Returner"
            case .gunner:
                return "Gunner"
            }
        }
    }
    case football(Positions.FootballPositions)
    
    var description: String {
        switch self {
        case .football(let pos):
            return pos.description
        }
    }
}

// Session Types
enum GroupType {
    case Individual, Group
    var description: String {
        switch self {
        case .Individual:
            return "Individual"
        case .Group:
            return "Group"
        }
    }
}

// Location Struct
struct CoachLocation: Identifiable, Hashable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let name: String
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: CoachLocation, rhs: CoachLocation) -> Bool {
        return (lhs.coordinate.latitude == rhs.coordinate.latitude) && (lhs.coordinate.longitude == rhs.coordinate.longitude)
    }
}

// Session Struct
struct Session: Identifiable, Equatable {
    let id: UUID = UUID()
    var req_date: Date
    let other: ProfileID
    var sport: Sports
    var type: GroupType
    // Coach hourly rate for type
    var typeRate: Double
    // Computed total cost
    var cost: Double {
          // Get the duration of the session in seconds
          let durationInSeconds = finished.timeIntervalSince(date)
          // Ensure duration is positive to prevent negative costs
          guard durationInSeconds > 0 else { return 0.0 }
          // Convert duration to hours
          let durationInHours = durationInSeconds / 3600.0
          // Calculate and return the total cost
          return durationInHours * typeRate
      }
    var date: Date
    var finished: Date
    var location: CoachLocation?
    //implement with algorithm
    var rate: Double
    
    // Find the time between sessions
    var totalTime: (Int,Int) {
        // Get the duration of the session in seconds
        let durationInSeconds = Int(finished.timeIntervalSince(date))
        // Ensure duration is positive to prevent negative costs
        guard durationInSeconds > 0 else { return (0,0) }
        return (durationInSeconds / 3600, (durationInSeconds % 3600) / 60)
    }
    // Optional message
    var description: String?
    var sf: String {
        switch sport {
        case .Football:
            return "football"
        }
    }

    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
}

// Message Struct
struct Message: Identifiable, Equatable {
    let id: UUID = UUID()
    var receiver: ProfileID
    var date: Date
    var mess: String
    var seen: Bool = false
    
    // for session posting
    var sess: Session?
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
}

// Review Struct
struct Review: Identifiable, Equatable {
    let id : UUID = UUID()
    var reviewer: ProfileID
    var date: Date
    var star: Float
    var quote: String
    
    static func == (lhs: Review, rhs: Review) -> Bool {
        return lhs.id == rhs.id
    }
}

// Backend data collection
struct Profile: Codable, Identifiable, Equatable, Hashable {
    var id: UUID
    var firstName: String
    var lastName: String
    var coachAccount: Bool
    var phoneNumber: String?
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
        case phoneNumber = "phone_number"
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
    @Published var phoneNumber: String?
    @Published var postalCode: String = ""
    @Published var notifications: Bool = false
    // Athlete
    @Published var userType: String = ""
    @Published var coachMessaging: Bool = true
    // Coach
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
    
    @Published var athleteMessaging: Bool = true
    @Published var quote: String? = nil
    @Published var achievements: [String] = []
    @Published var experience: [String] = []
    @Published var trainingLocations: [CoachLocation] = []
    @Published var ratings: Int = 0
    @Published var reviews: [Review] = []
    var responseTime: Int = 0
    @Published var availability: [String: [String]] = [:]
    @Published var cancellationNotice: Int?
    @Published var sport: [Sports] = []
    @Published var position: [Sports:[Positions]] = [:]
    @Published var individualCost: Double? = nil
    @Published var groupCost: Double? = nil
    @Published var offenderWatch: Bool? = nil
    @Published var directDeposit: [String]? = nil
    
    // Map a DB row -> UI object
    func apply(row: Profile) {
        id = row.id
        firstName = row.firstName
        lastName = row.lastName
        coachAccount = row.coachAccount
        phoneNumber = (row.phoneNumber?.isEmpty == false) ? row.phoneNumber : nil
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
    // Build a DB payload from the UI object
    func toRow() -> Profile {
        Profile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            coachAccount: coachAccount,
            phoneNumber: phoneNumber,
            userType: userType,
            postalCode: postalCode,
            imageURL: imageURL.hasPrefix("http") ? imageURL : nil,
            notifications: notifications,
            coachMessaging: coachMessaging
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
class RootViewObj: ObservableObject {
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
        // Fetch Table Data
        let row: Profile = try await client
          .from("profiles")
          .select("id, first_name, last_name, coach_account, image_url, phone_number, postal_code, user_type, notifications, coach_messaging")
          .eq("id", value: user.id)
          .single()
          .execute()
          .value
        profile.apply(row: row)
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

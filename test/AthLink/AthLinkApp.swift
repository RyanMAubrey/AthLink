    //
    //  AthLinkApp.swift
    //  AthLink
    //
    //  Created by Kellen O'Rourke on 6/7/24.
    //

    import SwiftUI
    import SwiftData
    import CoreLocation

    enum Sports: Hashable, CustomStringConvertible {
        case Football
        
        var description: String {
            switch self {
            case .Football:
                return "Football"
            }
        }
    }

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

    //TEsTING
    func createTestProfiles() -> RootViewObj {
        let testProfile1 = ProfileID()
        testProfile1.firstName = "John"
        testProfile1.lastName = "Doe"
        testProfile1.email = "john.doe@example.com"

        let testProfile2 = ProfileID()
        testProfile2.firstName = "Jane"
        testProfile2.lastName = "Smith"
        testProfile2.email = "jane.smith@example.com"

        testProfile1.messages[testProfile2.id] = [
            Message(receiver: testProfile2, date: Date(), mess: "Hi Jane!"),
            Message(receiver: testProfile1, date: Date(), mess: "Hello John!"),
            Message(receiver: testProfile2, date: Date(), mess: "Good Day")
        ]
        testProfile2.messages[testProfile1.id] = [
            Message(receiver: testProfile1, date: Date(), mess: "Hi John!")
        ]
        
        testProfile1.interestedCoaches.append(testProfile2)
        testProfile1.myCoaches.append(testProfile2)
        
        let coach = ProfileID()
        coach.coachAccount = true
        coach.firstName = "Larry"
        coach.lastName = "Smith"
        coach.email = "larry.smith@example.com"
        coach.sport = [Sports.Football]
        coach.profilePic = "coachprofile"
        coach.position[Sports.Football] = [Positions.football(Positions.FootballPositions.defensive_End)]
        coach.ratings = 2
        coach.individualCost = 100
        coach.groupCost = 70
        coach.acheivments.append("Rocky Mountain College NAIA D1:2010-2012 \nFull Ride Scholarship \nAll Conference Team MVP")
        coach.experience.append("Personal Soccer Trainer. Men & Women. Ages 10-55. 15 Years Experience")
        coach.quote = "Hello I am blah blah blah..."
        
        // Coach reviews
        let review1 = Review(
            reviewer: testProfile1,
            date: Date(),
            star: 5.0,
            quote: "Excellent coaching! Really enjoyed the session."
        )
        let review2 = Review(
            reviewer: testProfile2,
            date: Date(),
            star: 4.0,
            quote: "Very knowledgeable and engaging coach."
        )
        coach.reviews.append(review1)
        coach.reviews.append(review2)
        
        // Add a session to csubmitedSessions (for historical data)
        coach.csubmitedSessions.append(
            Session(req_date: Date(), other: testProfile2, sport: .Football, type: .Individual, cost: 110, date: Date(), finished: Date(), location: CoachLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: "nan"), rate:20, description: "Hello")
        )
        
        // Add a session to upcomingSessions (for requests)
        let requestSession = Session(req_date: Date(), other: coach, sport: .Football, type: .Group, cost: 110, date: Date(), finished: Date(), location: CoachLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: "nan"), rate:20, description: "Hello there")
        testProfile1.aupcomingSessions.append(requestSession)
        
        // Also add a job request (for Tab 0 in Jobs)
        testProfile1.jobRequests.append(requestSession)
        
        // Add a posting (for Tab 1) – if you prefer to store it in jobPostings,
        // you might decide to include it in your test data here.
        // For example, you could add it to a custom property on the profile or just let the Jobs view’s state handle it.
        
        // For current athletes (Tab 2), add an entry to the dictionary.
        // Here we map the athlete (e.g. coach) to a tuple, for example (sessionCount, total)
        //testProfile1.currentAthletes[coach] = (3, 330)
        
        testProfile1.myCoaches.append(coach)
        testProfile1.aupcomingSessions.append(
            Session(req_date: Date(), other: coach, sport: .Football, type: .Individual, cost: 110, date: Date(), finished: Date(), location: CoachLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: "nan"), rate:20, description: "Hello")
        )
       testProfile1.apastSessions.append(
            Session(req_date: Date(), other: coach, sport: .Football, type: .Individual, cost: 110, date: Date(), finished: Date(), location: CoachLocation(coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), name: "nan"), rate:20, description: "Hello")
        )
        testProfile1.messages[coach.id] = []
        let testProfile3 = ProfileID()
        // (Re)using testProfile2’s values for Jane in this example:
        testProfile2.firstName = "Jane"
        testProfile2.lastName = "Smith"
        testProfile2.email = "jane.smith@example.com"
        testProfile1.interestedAthletes.append(testProfile3)
        testProfile1.messages[testProfile3.id] = []

        let rootView = RootViewObj()
        rootView.profile = testProfile1
        return rootView
    }

    enum GroupType {
        case Individual, Group
        var descritpion: String {
            switch self {
            case .Individual:
                return "Individual"
            case .Group:
                return "Group"
            }
        }
    }

    struct Session: Identifiable, Equatable {
        let id: UUID = UUID()
        var req_date: Date
        let other: ProfileID
        var sport: Sports
        var type: GroupType
        var cost: Double
        var date: Date
        var finished: Date
        var location: CoachLocation?
        //implement with algorithm
        var rate: Double
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

    class ProfileID: Identifiable, ObservableObject, Equatable, Hashable {
        // ID
        let id: UUID = UUID()
        @Published var coachAccount: Bool = false
        @Published var profilePic = "athlinklogo"
        
        // connects
        @Published var interestedCoaches: [ProfileID] = []
        @Published var myCoaches: [ProfileID] = []
        @Published var interestedAthletes: [ProfileID] = []
        @Published var potentialAthletes: [ProfileID] = []
        @Published var messages: [UUID: [Message]] = [:]

        // Athlete
        // Essential
        @Published var notifications: Bool = false
        @Published var coachMessaging: Bool = true
        @Published var who: String = ""
        @Published var firstName: String = ""
        @Published var lastName: String = ""
        var fullName: String {
            "\(firstName) \(lastName)"
        }
        @Published var postalCode: String? = nil
        @Published var email: String = ""
        @Published var password: String = ""
        
        // Optional
        @Published var phoneNumber: String? = nil
        @Published var hasCardOnFile: Bool = false
        
        // sessions
        @Published var myRequests: [Session] = []
        @Published var aupcomingSessions: [Session] = []
        @Published var apastSessions: [Session] = []
        
        // Coach
        // sessions
        @Published var jobRequests: [Session] = []
        @Published var currentAthletes: [ProfileID:(Int,Double)] = [:]
        @Published var cupcomingSessions: [Session] = []
        @Published var cunsubmittedSessions: [Session] = []
        @Published var csubmitedSessions: [Session] = []
        
        // other
        @Published var athletehMessaging: Bool = true
        @Published var quote: String? = nil
        // add settings option
        @Published var acheivments: [String] = []
        @Published var experience: [String] = []
        @Published var trainingLocations: [CoachLocation] = []
        @Published var ratings: Int = 0
        @Published var reviews: [Review] = []
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
            let minutes = (seconds % 3600) / 60
            return "\(hours)hr \(minutes)mn"
        }
        var responseTime: Int = 0
        // add settings option
        @Published var cancellationNotice: Int = 0
        @Published var sport: [Sports] = []
        @Published var position: [Sports:[Positions]] = [:]
        @Published var individualCost: Double? = nil
        @Published var groupCost: Double? = nil
        @Published var offenderWatch: Bool? = nil
        @Published var directDeposit: [String]? = nil
        
        static func == (lhs: ProfileID, rhs: ProfileID) -> Bool {
            return lhs.id == rhs.id
        }
        
        // Hashable conformance
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    class RootViewObj: ObservableObject {
        enum RootView {
            case Login
            case Home
            case Coach
        }
        @Published var rootView: RootView = .Login {
            didSet {
                path = NavigationPath()
            }
        }
        @Published var selectedSession: ProfileID? = nil {
            didSet {
                print(selectedSession?.fullName ?? "no one")
            }
        }
        @Published var path = NavigationPath()
        @Published var profile = ProfileID()
    }

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

    struct CoachLocation: Identifiable, Hashable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let name: String
        
        static func == (lhs: CoachLocation,rhs: CoachLocation) -> Bool {
            return lhs.id == rhs.id
        }
        
        // Hashable conformance
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    struct AvailabilityGrid: View {
        @Binding var selectedA: [String: [String]]
        
        let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        let times = Array(6..<12).map { "\($0) AM" } + Array(12..<18).map { "\($0 - 12) PM" }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
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

    @main
    struct AthLinkApp: App {
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
        
        @StateObject var rootViewObj: RootViewObj = createTestProfiles()
        @StateObject var fSearch = SearchHelp()
        @State var lastPage = ""
        // check for adding session request to messages
        @State var pushReq = false
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
                        case "Coach":
                            CoachLogin()
                                .environmentObject(rootViewObj)
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
                            CouchAccount(prevMess: $lastPage)
                                .environmentObject(rootViewObj)
                        case "MessageAccount":
                            Chat(prevMess : $lastPage, pushReq: $pushReq, editMess: $editMess)
                                .environmentObject(rootViewObj)
                        case "Request":
                            RequestSess(chatTog: $pushReq, editMess: $editMess)
                                .environmentObject(rootViewObj)
                        default:
                            EmptyView()
                        }
                    }
                    .onChange(of: lastPage) {
                        if lastPage == "Chat" {
                            rootViewObj.path.append("CoachAccount")
                        //Chat->CouchAccount->Chat
                        }  else if lastPage == "Remove" {
                            lastPage = ""
                            rootViewObj.path.removeLast()
                        //Session->CouchAccount->Chat
                        } else if lastPage == "Sess" {
                            rootViewObj.path.append("MessageAccount")
                        }
                    }
                }
            }
            .modelContainer(sharedModelContainer)
        }
    }

//
//  AthLinkApp.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 6/7/24.
//

import SwiftUI
import SwiftData

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
    coach.sport = ["Basketball"]
    coach.rating = 4.5
    coach.trainingLocations = ["Los Angeles", "Santa Monica"]
    coach.individualCost = 100
    coach.groupCost = 70

    testProfile1.aupcomingSessions.append(
        Session(other: coach, sport: "Basketball", type: "Individual", cost: "$110", date: Date())
    )

    let rootView = RootViewObj()
    rootView.profile = testProfile1
    return rootView
}

struct Session: Identifiable, Equatable {
    let id: UUID = UUID()
    let other: ProfileID
    let sport: String
    let type: String
    let cost: String
    let date: Date
    
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

class ProfileID: Identifiable, ObservableObject, Equatable {
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
    
    // sessions
    @Published var aupcomingSessions: [Session] = []
    @Published var apastSessions: [Session] = []
    
    // Coach
    // sessions
    @Published var cupcomingSessions: [Session] = []
    @Published var cunsubmittedSessions: [Session] = []
    @Published var csubmitedSessions: [Session] = []
    
    // other
    @Published var athletehMessaging: Bool = true
    @Published var quote: String? = nil
    @Published var trainingLocations: [String]? = nil
    @Published var rating: Float = 0.0
    @Published var ratings: Int = 0
    @Published var reviews: [Review]? = nil
    @Published var sport: [String]? = nil
    @Published var individualCost: Int? = nil
    @Published var groupCost: Int? = nil
    @Published var offenderWatch: Bool? = nil
    @Published var directDeposit: [String]? = nil
    
    static func == (lhs: ProfileID, rhs: ProfileID) -> Bool {
        return lhs.id == rhs.id
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
    @Published var selectedSession: ProfileID? = nil
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
                        CouchAccount()
                            .environmentObject(rootViewObj)
                    case "MessageAccount":
                        Chat()
                            .environmentObject(rootViewObj)
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

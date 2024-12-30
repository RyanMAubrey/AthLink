//
//  AthLinkApp.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 6/7/24.
//

import SwiftUI
import SwiftData

class ID: Identifiable, ObservableObject {
    // ID
    let id = UUID()
    
    // Essential
    @Published var coachAccount: Bool = false
    @Published var notifications: Bool = false
    @Published var coachMessaging: Bool = true
    @Published var who: String? = nil
    @Published var firstName: String? = nil
    @Published var lastName: String? = nil
    @Published var postalCode: String? = nil
    @Published var email: String? = nil
    @Published var password: String? = nil

    // Optional
    @Published var phoneNumber: String? = nil
    @Published var imageName: String? = nil
    
    // Coach
    @Published var athletehMessaging: Bool = true
    @Published var message: String? = nil
    @Published var trainingLocations: [String]? = nil
    @Published var rating: Float = 0.0
    @Published var ratings: Int = 0
    @Published var sport: [String]? = nil
    @Published var individualCost: Int? = nil
    @Published var groupCost: Int? = nil
    @Published var offenderWatch: Bool? = nil
    @Published var directDeposit: [String]? = nil
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
    @Published var path = NavigationPath()
    @Published var profile = ID()
}

class SearchHelp: ObservableObject {
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
    @Published var zip : String = ""
    
    func filled() {
        if (sportVal != 0 && validZ) {
            fSearch = true
        } else {
            fSearch = false
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
    
    @StateObject var rootViewObj: RootViewObj = RootViewObj()
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
                            .onChange(of: fSearch.fSearch) {
                                if fSearch.fSearch {
                                    rootViewObj.path.removeLast()
                                    rootViewObj.path.append("FSearch")
                                } else {
                                    rootViewObj.path.removeLast()
                                    rootViewObj.path.append("Search")
                                }
                            }
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
                    case "Search":
                        Search()
                            .environmentObject(rootViewObj)
                            .environmentObject(fSearch)
                    case "FSearch":
                        FSearch()
                            .environmentObject(rootViewObj)
                            .environmentObject(fSearch)
                    case "Satisfaction":
                        Satisfaction()
                    case "Receive":
                        Receive()
                    case "Question":
                        Question()
                    case "Support":
                        Support()
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

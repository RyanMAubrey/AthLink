import SwiftUI
import Supabase
import CoreLocation

struct Job: View {
    @EnvironmentObject var rootView: RootViewObj
    @State var selectedTab: Int = 0
    @State var showFilltering: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar at Top
            HStack(spacing: 0) {
                // Requests Tab
                Button(action: { selectedTab = 0 }) {
                    VStack(spacing: 4) {
                        Text("Requests")
                            .font(.subheadline)
                            .fontWeight(selectedTab == 0 ? .semibold : .regular)
                        
                        Rectangle()
                            .fill(selectedTab == 0 ? Color.blue : Color.clear)
                            .frame(height: 3)
                    }
                    .foregroundColor(selectedTab == 0 ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
                
                // Postings Tab
                Button(action: { selectedTab = 1 }) {
                    VStack(spacing: 4) {
                        Text("Postings")
                            .font(.subheadline)
                            .fontWeight(selectedTab == 1 ? .semibold : .regular)
                        
                        Rectangle()
                            .fill(selectedTab == 1 ? Color.blue : Color.clear)
                            .frame(height: 3)
                    }
                    .foregroundColor(selectedTab == 1 ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
                
                // Current Athletes Tab
                Button(action: { selectedTab = 2 }) {
                    VStack(spacing: 4) {
                        Text("Current Athletes")
                            .font(.subheadline)
                            .fontWeight(selectedTab == 2 ? .semibold : .regular)
                        
                        Rectangle()
                            .fill(selectedTab == 2 ? Color.blue : Color.clear)
                            .frame(height: 3)
                    }
                    .foregroundColor(selectedTab == 2 ? .blue : .gray)
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
            // Content Based on Selected Tab
            Group {
                if selectedTab == 0 {
                    Requests()
                        .environmentObject(rootView)
                } else if selectedTab == 1 {
                    Posts()
                        .environmentObject(rootView)
                } else {
                    Currents()
                        .environmentObject(rootView)
                }
            }
        }
    }
    
    /*
     Job Requests from athletes
     */
    struct Requests: View {
        @EnvironmentObject var rootView: RootViewObj

        var body: some View {
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text("Job Requests")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Text("\(rootView.profile.jobRequests.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                .padding(.top)
                
                if rootView.profile.jobRequests.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Job Requests")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Athlete requests will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // List of requests
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(rootView.profile.jobRequests, id: \.self) { session in
                                Button(action: {
                                    rootView.selectedJobSession = session
                                    rootView.lastPage = "Requests"
                                    rootView.path.append("CoachRequestSess")
                                }) {
                                    RequestCard(session: session, client: rootView.client)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    struct RequestCard: View {
        let session: Session
        let client: SupabaseClient
        
        @State private var athlete: PublicUser?
        @State private var isLoading = true
        
        var body: some View {
            HStack(spacing: 12) {
                // Sport Icon
                Image(systemName: session.sf)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                
                // Main Content
                VStack(alignment: .leading, spacing: 4) {
                    // Sport Name
                    Text(session.sport.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Athlete Name and Description
                    if let athlete = athlete {
                        HStack(spacing: 4) {
                            Text(athlete.fullName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                            Text("-")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(session.description ?? "Requesting session...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                        
                        // Credit Card Status
                        HStack(spacing: 4) {
                            Image(systemName: athlete.cardOnFile ? "creditcard.fill" : "creditcard")
                                .font(.caption)
                                .foregroundColor(athlete.cardOnFile ? .green : .orange)
                            Text(athlete.cardOnFile ? "Card on File" : "No Card")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(athlete.cardOnFile ? .green : .orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            (athlete.cardOnFile ? Color.green : Color.orange).opacity(0.1)
                        )
                        .cornerRadius(6)
                        
                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Right Side Info
                VStack(alignment: .trailing, spacing: 6) {
                    // Date
                    Text(session.date, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    // Job Type
                    Text("Type: \(session.type.description)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    // Requested Rate
                    Text("Rate: $\(Int(session.typeRate))/hr")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .task {
                await loadAthlete()
            }
        }
        
        private func loadAthlete() async {
            do {
                let fetchedAthlete: PublicUser = try await client
                    .from("profiles")
                    .select("id, first_name, last_name, image_url, card_on_file")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                
                athlete = fetchedAthlete
                isLoading = false
            } catch {
                print("Failed to fetch athlete:", error)
                isLoading = false
            }
        }
    }
    
    /*
     Athlete Postings
     */
    struct Posts: View {
        @EnvironmentObject var rootView: RootViewObj
        @State var showFilltering: Bool = false
        @StateObject var selectedFilters: PostFilters = PostFilters()
        @State var filteredSessions: [Session] = []
        
        func fetchPosts() async {
            // Check if coach has a location
            guard let loc = rootView.currentLocation else { return }
            
            // Get filtered Posts
            do {
                let params = selectedFilters.toRPCParams(from: loc)
                let rows: [PostedSessionRow] = try await rootView.client
                    .rpc("search_posted_sessions", params: params)
                    .execute()
                    .value

                filteredSessions = rows.compactMap { $0.toSession() }
            } catch {
                print("No fetched sessions")
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                // Header with Settings Button
                HStack {
                    Text("Athlete Postings")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Settings Button
                    Button(action: {
                        showFilltering = true
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                    .disabled(rootView.currentLocation == nil)
                }
                .padding()
                .background(Color.white)
                
                // Content
                if rootView.currentLocation == nil {
                    // Location Not Enabled
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "location.slash.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Location Required")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Enable location to see athlete postings near you")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            if rootView.locationStatus == .denied || rootView.locationStatus == .restricted {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            } else {
                                rootView.requestWhenInUseLocation()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Enable Location")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue, in: Capsule())
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                } else if filteredSessions.isEmpty {
                    // Empty State
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Postings Found")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Try adjusting your filters or check back later")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            showFilltering = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "slider.horizontal.3")
                                Text("Adjust Filters")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue, in: Capsule())
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                } else {
                    // List of Postings
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredSessions, id: \.self) { session in
                                Button(action: {
                                    rootView.selectedJobSession = session
                                    rootView.lastPage = "Posts"
                                    rootView.path.append("CoachRequestSess")
                                }) {
                                    PostingCard(session: session, client: rootView.client)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showFilltering, onDismiss: {
                Task {
                    await fetchPosts()
                }
            }) {
                OptionsSheet(choices: selectedFilters)
            }
            .task {
                do {
                    try await rootView.loadProfile()
                    if rootView.currentLocation != nil {
                        await fetchPosts()
                    }
                } catch {
                    print("loadProfile failed:", error)
                }
            }
            .onChange(of: rootView.currentLocation) { old, new in
                if new != nil {
                    Task {
                        await fetchPosts()
                    }
                }
            }
        }
    }
    class PostFilters: ObservableObject  {
        @Published var sortChoice: String = "Newest"
        @Published var hourlyChoice: Double = 0
        @Published var distanceChoice: Double = 0
        @Published var sportChoice: String = "All"
        
        struct RPCParams: Encodable {
            let start_lat: Double
            let start_long: Double
            let radius_meters: Double
            let sport_filter: String
            let max_hourly: Double
            let sort_choice: String
            let result_limit: Int
            let result_offset: Int
        }
        
        func toRPCParams(from loc: CLLocation) -> RPCParams {
            RPCParams(
                start_lat: loc.coordinate.latitude,
                start_long: loc.coordinate.longitude,
                // Convert miles to meters
                radius_meters: distanceChoice * 1609.34,
                sport_filter: sportChoice.lowercased(),
                max_hourly: hourlyChoice,
                sort_choice: sortChoice,
                result_limit: 50,
                result_offset: 0
            )
        }
    }
    
    // Modal for options sheet
    struct OptionsSheet: View {
        @ObservedObject var choices: PostFilters
        @Environment(\.dismiss) var dismiss
        
        var sortBy: [String] = ["Newest", "Oldest", "Distance", "Lowest Price", "Highest Price"]
        var hourlyRate: ClosedRange<Double> = 0...100
        var distance: ClosedRange<Double> = 0...100
        var sport: [String] = ["All", "Football"]
        
        var body: some View {
            NavigationView {
                Form {
                    // Sort By
                    Section(header: Text("Sort By")) {
                        Picker("Sort by", selection: $choices.sortChoice) {
                            ForEach(sortBy, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    // Hourly Rate
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Hourly Rate")
                                    .font(.subheadline)
                                Spacer()
                                Text(choices.hourlyChoice == 0 ? "Any" : "$\(Int(choices.hourlyChoice))/hr")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: $choices.hourlyChoice, in: hourlyRate, step: 5)
                                .tint(.blue)
                            
                            HStack {
                                Text("$0")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("$100")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Hourly Rate")
                    } footer: {
                        Text(choices.hourlyChoice == 0 ? "Showing all hourly rates" : "Showing sessions up to $\(Int(choices.hourlyChoice)) per hour")
                    }
                    
                    // Distance
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Max Distance")
                                    .font(.subheadline)
                                Spacer()
                                Text(choices.distanceChoice == 0 ? "Any" : "\(Int(choices.distanceChoice)) mi")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                            }
                            
                            Slider(value: $choices.distanceChoice, in: distance, step: 5)
                                .tint(.blue)
                            
                            HStack {
                                Text("0 mi")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("100 mi")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    } header: {
                        Text("Distance")
                    } footer: {
                        Text(choices.distanceChoice == 0 ? "Showing all locations" : "Showing sessions within \(Int(choices.distanceChoice)) miles")
                    }
                    
                    // Sport
                    Section(header: Text("Sport")) {
                        Picker("Sport", selection: $choices.sportChoice) {
                            ForEach(sport, id: \.self) { sport in
                                Text(sport)
                                    .tag(sport)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    
                    // Reset Button
                    Section {
                        Button(action: {
                            choices.sortChoice = "Newest"
                            choices.hourlyChoice = 0
                            choices.distanceChoice = 0
                            choices.sportChoice = "All"
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "arrow.counterclockwise")
                                Text("Reset Filters")
                                Spacer()
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
                .navigationTitle("Filter Options")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
        }
    }
    struct PostingCard: View {
        let session: Session
        let client: SupabaseClient
        
        @State private var athlete: PublicUser?
        @State private var isLoading = true
        
        var body: some View {
            HStack(spacing: 12) {
                // Sport Icon
                Image(systemName: session.sf)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                // Main Content
                VStack(alignment: .leading, spacing: 4) {
                    // Sport Name
                    Text(session.sport.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    // Athlete Name and Description
                    if let athlete = athlete {
                        HStack(spacing: 4) {
                            Text(athlete.fullName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text("-")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(session.description ?? "Looking for...")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                            // Credit Card Status
                            HStack(spacing: 4) {
                                Image(systemName: athlete.cardOnFile ? "creditcard.fill" : "creditcard")
                                    .font(.caption)
                                    .foregroundColor(athlete.cardOnFile ? .green : .orange)
                                Text(athlete.cardOnFile ? "Card on File" : "No Card on File")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(athlete.cardOnFile ? .green : .orange)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                (athlete.cardOnFile ? Color.green : Color.orange).opacity(0.1)
                            )
                            .cornerRadius(6)
                        }
                        
                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Right Side Info
                VStack(alignment: .trailing, spacing: 4) {
                    // Date
                    Text(session.date, style: .date)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Job Type
                    Text("Job: \(session.type.description)")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    // Rate
                    Text("Rate: $\(Int(session.typeRate))/hr")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    // Options Button
                    Image(systemName: "ellipsis.rectangle.fill")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .task {
                await loadAthlete()
            }
        }
        
        private func loadAthlete() async {
            do {
                // Use the fetchID method from PublicUser
                let fetchedAthlete: PublicUser = try await client
                    .from("profiles")
                    .select("id, first_name, last_name, image_url, card_on_file")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                
                athlete = fetchedAthlete
            } catch {
                print("Failed to fetch athlete:", error)
            }
        }
    }
    
    /*
     Current athletes
     */
    struct Currents: View {
        @EnvironmentObject var rootView: RootViewObj
        
        var body: some View {
            VStack(alignment: .leading) {
                // Header
                HStack {
                    Text("Current Athletes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    Spacer()
                    
                    Text("\(rootView.profile.currentAthletes.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                .padding(.top)
                
                if rootView.profile.currentAthletes.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Current Athletes")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Athletes you've coached will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    // List of athletes
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(rootView.profile.currentAthletes.keys), id: \.self) { athleteID in
                                if let athleteData = rootView.profile.currentAthletes[athleteID] {
                                    Button(action: {
                                    
                                    }) {
                                        AthleteCard(
                                            athleteID: athleteID,
                                            athleteData: athleteData,
                                            client: rootView.client
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .disabled(true)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
    
    struct AthleteCard: View {
        let athleteID: UUID
        let athleteData: Athletes
        let client: SupabaseClient
        
        @State private var athlete: PublicUser?
        @State private var isLoading = true
        
        var body: some View {
            HStack(spacing: 12) {
                // Athlete Icon/Avatar
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "person.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                
                // Main Content
                VStack(alignment: .leading, spacing: 6) {
                    if let athlete = athlete {
                        // Athlete Name
                        Text(athlete.fullName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        // Sessions Count
                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(athleteData.sessions) session\(athleteData.sessions == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Payment Status
                        HStack(spacing: 4) {
                            Image(systemName: athlete.cardOnFile ? "creditcard.fill" : "creditcard")
                                .font(.caption)
                                .foregroundColor(athlete.cardOnFile ? .green : .orange)
                            Text(athlete.cardOnFile ? "Card on File" : "No Card")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(athlete.cardOnFile ? .green : .orange)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            (athlete.cardOnFile ? Color.green : Color.orange).opacity(0.1)
                        )
                        .cornerRadius(6)
                        
                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text("Unknown Athlete")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Revenue Info
                VStack(alignment: .trailing, spacing: 6) {
                    Text("Revenue")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text("$\(String(format: "%.2f", athleteData.totalGained))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 4)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            .task {
                await loadAthlete()
            }
        }
        
        private func loadAthlete() async {
            do {
                let fetchedAthlete: PublicUser = try await client
                    .from("profiles")
                    .select("id, first_name, last_name, image_url, card_on_file")
                    .eq("id", value: athleteID.uuidString)
                    .single()
                    .execute()
                    .value
                
                athlete = fetchedAthlete
                isLoading = false
            } catch {
                print("Failed to fetch athlete:", error)
                isLoading = false
            }
        }
    }
}

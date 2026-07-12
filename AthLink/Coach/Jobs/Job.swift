import SwiftUI
import Supabase
import CoreLocation

struct Job: View {
    @EnvironmentObject var rootView: RootViewObj
    @State var selectedTab: Int = 0
    @State var showFilltering: Bool = false
    
    @State private var showInfoAlert: Bool = false
    @State private var infoAlertMessage: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButtonWithInfo(title: "Direct Requests", index: 0, infoMessage: "Requests athletes send directly to you. Accept, decline, or message the athlete from the request.")
                tabButtonWithInfo(title: "Open Requests", index: 1, infoMessage: "Marketplace requests from athletes looking for a coach. Use filters to find requests that fit your rate, distance, and session type.")
                tabButtonWithInfo(title: "My Athletes", index: 2, infoMessage: "Athletes you currently coach. Tap an athlete to continue the conversation.")
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            
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
        .alert(isPresented: $showInfoAlert) {
            Alert(title: Text("Info"), message: Text(infoAlertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func tabButtonWithInfo(title: String, index: Int, infoMessage: String) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(selectedTab == index ? .semibold : .regular)
                    Button(action: {
                        infoAlertMessage = infoMessage
                        showInfoAlert = true
                    }) {
                        Image(systemName: "info.circle")
                            .font(.subheadline)
                    }
                    .buttonStyle(.plain)
                }
                Rectangle()
                    .fill(selectedTab == index ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
            .foregroundColor(selectedTab == index ? .blue : .gray)
            .frame(maxWidth: .infinity)
        }
    }
    
    struct Requests: View {
        @EnvironmentObject var rootView: RootViewObj

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("Direct Requests")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    Spacer()
                }
                .padding(.top)
                
                if rootView.profile.jobRequests.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "tray.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("No Direct Requests")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text("Requests sent directly to you will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
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
                Image(systemName: session.sf)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sport.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    if let athlete = athlete {
                        Text(athlete.fullName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }

                    Text(athLinkDateWithDayAndYear(session.date))
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let desc = session.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(athLinkDateWithDayAndYear(session.date))
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(session.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(athLinkWholeDollar(session.typeRate))/hr")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    if let athlete = athlete {
                        HStack(spacing: 4) {
                            Image(systemName: athlete.hasPaymentMethod ? "creditcard.fill" : "creditcard")
                                .font(.caption2)
                            Text(athlete.hasPaymentMethod ? "Card on File" : "No Card")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(athlete.hasPaymentMethod ? .green : .orange)
                    }
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
                    .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                athlete = fetchedAthlete
                isLoading = false
            } catch {
                log.error("Failed to fetch athlete: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    struct Posts: View {
        @EnvironmentObject var rootView: RootViewObj
        @State var showFilltering: Bool = false
        @StateObject var selectedFilters: PostFilters = PostFilters()
        @State var filteredSessions: [Session] = []
        private var filtersApplied: Bool {
            selectedFilters.sortChoice != "Newest" ||
            selectedFilters.hourlyChoice != 200 ||
            selectedFilters.distanceChoice != 100 ||
            selectedFilters.sportChoice != "Football" ||
            selectedFilters.sessionTypeChoice != "Both"
        }
        
        func fetchPosts() async {
            guard let loc = rootView.currentLocation else { return }
            
            do {
                let params = selectedFilters.toRPCParams(from: loc)
                let rows: [PostedSessionRow] = try await rootView.client
                    .rpc("search_posted_sessions", params: params)
                    .execute()
                    .value

                filteredSessions = rows.compactMap { $0.toSession() }
            } catch {
                log.error("Postings fetch error: \(error.localizedDescription)")
            }
        }
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("Open Requests")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
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
                
                if rootView.currentLocation == nil {
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
                    VStack(spacing: 16) {
                        Spacer()
                        
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text(filtersApplied ? "No Requests Found" : "No Open Requests")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        
                        Text(filtersApplied ? "Try adjusting your filters or check back later." : "New athlete requests will show up here.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        if filtersApplied {
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
                        }
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    
                } else {
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
                    log.error("loadProfile failed: \(error.localizedDescription)")
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
        @Published var hourlyChoice: Double = 200
        @Published var distanceChoice: Double = 100
        @Published var sportChoice: String = "Football"
        @Published var sessionTypeChoice: String = "Both" // Added for Individual/Group
        
        struct RPCParams: Encodable {
            let start_lat: Double
            let start_long: Double
            let radius_meters: Double
            let sport_filter: String
            let max_hourly: Double
            let sort_choice: String
            let result_limit: Int
            let result_offset: Int
            let session_type: String // Added for Individual/Group
        }
        
        func toRPCParams(from loc: CLLocation) -> RPCParams {
            RPCParams(
                start_lat: loc.coordinate.latitude,
                start_long: loc.coordinate.longitude,
                radius_meters: distanceChoice * 1609.34,
                sport_filter: sportChoice.lowercased(),
                max_hourly: hourlyChoice,
                sort_choice: sortChoice,
                result_limit: 50,
                result_offset: 0,
                session_type: sessionTypeChoice.lowercased()
            )
        }
    }
    
    struct OptionsSheet: View {
        @ObservedObject var choices: PostFilters
        @Environment(\.dismiss) var dismiss
        
        var sortBy: [String] = ["Newest", "Oldest", "Distance", "Lowest Price", "Highest Price"]
        var hourlyRate: ClosedRange<Double> = 0...200
        var distance: ClosedRange<Double> = 0...100
        var sport: [String] = ["Football"]
        var sessionTypes: [String] = ["Individual", "Group", "Both"]
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Sort By")) {
                        Picker("Sort by", selection: $choices.sortChoice) {
                            ForEach(sortBy, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
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
                                Text("$200")
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
                    
                    Section(header: Text("Sport")) {
                        Picker("Sport", selection: $choices.sportChoice) {
                            ForEach(sport, id: \.self) { sport in
                                Text(sport)
                                    .tag(sport)
                            }
                        }
                        .pickerStyle(.inline)
                    }
                    
                    Section(header: Text("Session Type")) {
                        Picker("Session Type", selection: $choices.sessionTypeChoice) {
                            ForEach(sessionTypes, id: \.self) { type in
                                Text(type).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Section {
                        Button(action: {
                            choices.sortChoice = "Newest"
                            choices.hourlyChoice = 200
                            choices.distanceChoice = 100
                            choices.sportChoice = "Football"
                            choices.sessionTypeChoice = "Both"
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
                Image(systemName: session.sf)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .padding(12)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.sport.description)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    if let athlete = athlete {
                        Text(athlete.fullName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    }

                    Text(athLinkDateWithDayAndYear(session.date))
                        .font(.caption)
                        .foregroundColor(.gray)

                    if let desc = session.description, !desc.isEmpty {
                        Text(desc)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(athLinkDateWithDayAndYear(session.date))
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(session.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("\(athLinkWholeDollar(session.typeRate))/hr")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)

                    if let athlete = athlete {
                        HStack(spacing: 4) {
                            Image(systemName: athlete.hasPaymentMethod ? "creditcard.fill" : "creditcard")
                                .font(.caption2)
                            Text(athlete.hasPaymentMethod ? "Card on File" : "No Card")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(athlete.hasPaymentMethod ? .green : .orange)
                    }
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
                    .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                athlete = fetchedAthlete
                isLoading = false
            } catch {
                log.error("Failed to fetch athlete: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
    
    struct Currents: View {
        @EnvironmentObject var rootView: RootViewObj
        @State private var searchText = ""
        @State private var athleteNames: [UUID: String] = [:]

        private var filteredKeys: [UUID] {
            let keys = Array(rootView.profile.currentAthletes.keys)
            if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                return keys
            }
            return keys.filter { id in
                guard let name = athleteNames[id] else { return true }
                return name.localizedCaseInsensitiveContains(searchText)
            }
        }

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("My Athletes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()
                }
                .padding(.top)

                if !rootView.profile.currentAthletes.isEmpty {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search by name", text: $searchText)
                            .foregroundColor(.primary)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                if rootView.profile.currentAthletes.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()

                        Image(systemName: "person.3.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("No Athletes Yet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)

                        Text("Athletes you've coached will appear here.")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(filteredKeys, id: \.self) { athleteID in
                                if let athleteData = rootView.profile.currentAthletes[athleteID] {
                                    AthleteCard(
                                        athleteID: athleteID,
                                        athleteData: athleteData,
                                        client: rootView.client,
                                        onNameLoaded: { name in
                                            athleteNames[athleteID] = name
                                        },
                                        onTap: { athlete in
                                            rootView.chatPartner = athlete
                                            rootView.path.append("MessageAccount")
                                        }
                                    )
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
        var onNameLoaded: ((String) -> Void)? = nil
        var onTap: ((PublicUser) -> Void)? = nil

        @State private var athlete: PublicUser?
        @State private var isLoading = true

        var body: some View {
            Button(action: {
                if let athlete {
                    onTap?(athlete)
                }
            }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 56, height: 56)

                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "person.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    if let athlete = athlete {
                        Text(athlete.fullName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        HStack(spacing: 4) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text("\(athleteData.sessions) session\(athleteData.sessions == 1 ? "" : "s")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        HStack(spacing: 4) {
                            Image(systemName: athlete.hasPaymentMethod ? "creditcard.fill" : "creditcard")
                                .font(.caption2)
                            Text(athlete.hasPaymentMethod ? "Card on File" : "No Card")
                                .font(.caption2)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(athlete.hasPaymentMethod ? .green : .orange)

                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.black)
                    } else {
                        Text("Unknown Athlete")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("Revenue")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(athLinkWholeDollar(athleteData.totalGained))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            }
            .buttonStyle(.plain)
            .disabled(athlete == nil)
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
                    .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                    .eq("id", value: athleteID.uuidString)
                    .single()
                    .execute()
                    .value
                athlete = fetchedAthlete
                onNameLoaded?(fetchedAthlete.fullName)
                isLoading = false
            } catch {
                log.error("Failed to fetch athlete: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}

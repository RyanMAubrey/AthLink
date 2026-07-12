import SwiftUI
import CoreLocation
import Supabase

struct FSearch: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State var sett: Bool = false
    @State var nEditing: Bool = false
    @State var zMessage: String = "Enter Zip Code"
    @State var name: String = ""
    @State var alg: Int = 2
    @State var selectedA: [String: [String]] = [:]
    @State var hr: Float = 255
    @State var maxDistance: Double = 105
    @State private var hisEditing = false

    // Search state
    @State private var results: [CoachSearchResult] = []
    @State private var isLoading = false
    @State private var hasSearched = false

    var loc: String {
        fSearch.validZ ? "location.fill" : "location"
    }

    // Maps time-of-day bucket to the hour strings coaches store
    private let morningHours  = Set(Array(6..<12).map { "\($0) AM" })
    private let afternoonHours = Set((12..<18).map { $0 == 12 ? "0 PM" : "\($0 - 12) PM" })
    private let nightHours    = Set((18..<24).map { "\($0 - 12) PM" })

    private func coachMatchesAvailability(_ coach: CoachSearchResult) -> Bool {
        for (day, slots) in selectedA {
            guard !slots.isEmpty else { continue }
            let coachSlots = Set(coach.timeAvailability[day] ?? [])
            for slot in slots {
                let hours: Set<String>
                switch slot {
                case "Morning":   hours = morningHours
                case "Afternoon": hours = afternoonHours
                case "Night":     hours = nightHours
                default: continue
                }
                // Coach must have at least one hour in this bucket for this day
                if coachSlots.isDisjoint(with: hours) { return false }
            }
        }
        return true
    }

    // Filtered results (sorting + hourly rate handled server-side, name + availability client-side)
    var filteredResults: [CoachSearchResult] {
        var list = results

        // Filter by name (client-side for instant feedback)
        if !name.isEmpty {
            let lower = name.lowercased()
            list = list.filter { $0.fullName.lowercased().contains(lower) }
        }

        // Filter by availability (client-side bucket matching)
        let hasAvailabilityFilter = selectedA.values.contains { !$0.isEmpty }
        if hasAvailabilityFilter {
            list = list.filter { coachMatchesAvailability($0) }
        }

        return list
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar area
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    // Sport picker
                    Menu {
                        Button("Select a Sport") { fSearch.sportVal = 0 }
                        Button("Football") { fSearch.sportVal = 1 }
                    } label: {
                        HStack {
                            Text(fSearch.sportVal == 1 ? "Football" : "Select a Sport")
                                .foregroundColor(fSearch.sportVal == 0 ? .gray : .primary)
                            Spacer()
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                    // Zip bar
                    HStack {
                        Image(systemName: loc)
                            .foregroundColor(.blue)
                        TextField(zMessage, text: $fSearch.zip)
                            .foregroundColor(Color.primary)
                            .onSubmit { fSearch.validate() }
                        if fSearch.zEditing {
                            Button(action: {
                                fSearch.zip = ""
                                fSearch.zEditing = false
                                fSearch.validZ = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onTapGesture { fSearch.zEditing = true }
                }

                // Name search + filter
                HStack(spacing: 8) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search by name", text: $name)
                            .foregroundColor(Color.primary)
                        if nEditing {
                            Button(action: {
                                name = ""
                                nEditing = false
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .onTapGesture { nEditing = true }

                    Button(action: { sett = true }) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                    .sheet(isPresented: $sett, onDismiss: {
                        Task { await performSearch() }
                    }) {
                        filterSheet
                    }
                }
            }
            .padding()
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Results
            if isLoading {
                Spacer()
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.2)
                    Text("Searching coaches...")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
            } else if filteredResults.isEmpty && hasSearched {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray.opacity(0.4))
                    Text("No coaches found")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text("Try adjusting your filters or search area")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                }
                Spacer()
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredResults) { coach in
                            CoachCard(coach: coach)
                                .onTapGesture {
                                    navigateToCoach(coach)
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await performSearch()
        }
        .onChange(of: fSearch.sportVal) {
            Task { await performSearch() }
        }
        .onChange(of: fSearch.zip) {
            zMessage = fSearch.validZ ? "Enter Zip Code" : "Enter a Valid Zip Code"
            if fSearch.validZ {
                Task { await performSearch() }
            }
        }
    }

    // Map sort picker int to RPC string
    private var sortString: String {
        switch alg {
        case 2: return "Distance"
        case 3: return "Lowest Price"
        case 4: return "Highest Price"
        case 5: return "Ratings"
        default: return "Distance"
        }
    }

    // Search Logic — single RPC call
    private func performSearch() async {
        guard fSearch.validZ, fSearch.sportVal > 0 else { return }
        isLoading = true
        defer { isLoading = false; hasSearched = true }

        // Map sport tag to string (lowercase to match sport_type enum in DB)
        let sportName: String
        switch fSearch.sportVal {
        case 1: sportName = "football"
        default: return
        }

        do {
            // Geocode the zip to lat/long
            guard let zipCoord = await coordinatesFromZip(fSearch.zip) else {
                results = []
                return
            }

            // Single RPC call — filtering, sorting, joins all server-side
            let params = SearchCoachesParams(
                start_lat: zipCoord.latitude,
                start_long: zipCoord.longitude,
                radius_meters: maxDistance > 100 ? 0 : maxDistance * 1609.34,
                sport_filter: sportName,
                max_hourly: hr > 250 ? 0 : Double(hr),
                sort_choice: sortString,
                result_limit: 50,
                result_offset: 0
            )
            let rows: [CoachSearchRPCRow] = try await rootView.client
                .rpc("search_coaches", params: params)
                .execute()
                .value

            // Map RPC rows to CoachSearchResult
            results = rows.compactMap { row in
                // Skip self
                guard row.coachId != rootView.profile.id else { return nil }

                // Find closest training location from JSONB
                let locations = row.trainingLocations ?? []
                let zipLocation = CLLocation(latitude: zipCoord.latitude, longitude: zipCoord.longitude)
                var closestLoc: structLocation?
                var closestDist: Double?

                for loc in locations {
                    let locCL = CLLocation(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
                    let dist = zipLocation.distance(from: locCL) / 1609.344
                    if closestDist == nil || dist < closestDist! {
                        closestDist = dist
                        closestLoc = loc
                    }
                }

                return CoachSearchResult(
                    id: row.coachId,
                    firstName: row.firstName,
                    lastName: row.lastName,
                    imageURL: row.imageUrl,
                    sports: row.sports.map { $0.capitalized },
                    individualCost: row.individualCost,
                    groupCost: row.groupCost,
                    rating: Float(row.avgRating),
                    reviewCount: Int(row.reviewCount),
                    closestLocation: closestLoc,
                    distanceMiles: closestDist ?? (row.distanceMeters.map { $0 / 1609.344 }),
                    timeAvailability: row.timeAvailability ?? [:]
                )
            }

        } catch {
            log.error("Coach search failed: \(error.localizedDescription)")
            results = []
        }
    }

    // Navigate to Coach
    private func navigateToCoach(_ coach: CoachSearchResult) {
        Task {
            do {
                let fetched = try await loadProfile(client: rootView.client, id: coach.id)
                rootView.selectedSession = fetched
                rootView.lastPage = "Search"
                rootView.path.append("CoachAccount")
            } catch {
                log.error("Failed to load coach profile: \(error.localizedDescription)")
            }
        }
    }

    // Filter Sheet
    private var filterSheet: some View {
        NavigationView {
            Form {
                // Sort By
                Section(header: Text("Sort By")) {
                    Picker("Sort by", selection: $alg) {
                        Text("Distance").tag(2)
                        Text("Lowest Price").tag(3)
                        Text("Highest Price").tag(4)
                        Text("Ratings").tag(5)
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
                            Text(hr > 250 ? "Any" : "$\(Int(hr))/hr")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(hr > 250 ? .secondary : .blue)
                        }

                        Slider(value: $hr, in: 10...255, step: 5)
                            .tint(.blue)

                        HStack {
                            Text("$10")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Any")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Hourly Rate")
                } footer: {
                    Text(hr > 250 ? "No hourly rate limit applied" : "Only showing coaches up to $\(Int(hr)) per hour")
                }

                // Distance
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max Distance")
                                .font(.subheadline)
                            Spacer()
                            Text(maxDistance > 100 ? "Any" : "\(Int(maxDistance)) mi")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(maxDistance > 100 ? .secondary : .blue)
                        }

                        Slider(value: $maxDistance, in: 5...105, step: 5)
                            .tint(.blue)

                        HStack {
                            Text("5 mi")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Spacer()
                            Text("Any")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Distance")
                } footer: {
                    Text(maxDistance > 100 ? "No distance limit applied" : "Only showing coaches within \(Int(maxDistance)) miles")
                }

                // Availability
                Section(header: Text("Availability")) {
                    AvailabilityBucketGrid(selectedA: $selectedA)
                }

                // Reset Button
                Section {
                    Button(action: {
                        alg = 2
                        hr = 255
                        maxDistance = 105
                        selectedA = [:]
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
                        sett = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// Coach Card
struct CoachCard: View {
    let coach: CoachSearchResult

    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let urlStr = coach.imageURL, !urlStr.isEmpty, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img):
                        img.resizable().scaledToFill()
                    default:
                        Image("athlinklogo").resizable().scaledToFill()
                    }
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            } else {
                Image("athlinklogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(coach.fullName)
                    .font(.headline)

                // Rating
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        let threshold = Float(index) + 1
                        if coach.rating >= threshold {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                        } else if coach.rating >= threshold - 0.5 {
                            Image(systemName: "star.leadinghalf.fill")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                        } else {
                            Image(systemName: "star")
                                .foregroundColor(.yellow)
                                .font(.caption2)
                        }
                    }
                    Text("(\(coach.reviewCount))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                // Sports
                Text(coach.sports.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Distance
                if let dist = coach.distanceMiles, let loc = coach.closestLocation {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text(String(format: "%.1f mi - %@", dist, loc.name))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            Spacer()

            // Price
            VStack(alignment: .trailing, spacing: 2) {
                if let ind = coach.individualCost {
                    Text(String(format: "$%.0f/hr", ind))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Individual")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                if let grp = coach.groupCost {
                    Text(String(format: "$%.0f/hr", grp))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("Group")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AvailabilityBucketGrid: View {
    @Binding var selectedA: [String: [String]]

    private let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    private let slots = ["Morning", "Afternoon", "Night"]
    private let slotLabels = [
        "Morning": "6a–12p",
        "Afternoon": "1p–5p",
        "Night": "6p–12a"
    ]

    @State private var dragMode: Bool? = nil
    @State private var draggedCells: Set<String> = []

    private let labelWidth: CGFloat = 36
    private let cellSpacing: CGFloat = 4
    private let cellHeight: CGFloat = 32

    var body: some View {
        GeometryReader { geo in
            let gridWidth = geo.size.width - labelWidth - 8
            let cellWidth = (gridWidth - cellSpacing * 2) / 3

            VStack(alignment: .leading, spacing: 4) {
                // Slot headers
                HStack(spacing: cellSpacing) {
                    Text("")
                        .frame(width: labelWidth)
                    ForEach(slots, id: \.self) { slot in
                        VStack(spacing: 1) {
                            Text(slotLabels[slot] ?? "")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                            Text(slot)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .frame(width: cellWidth)
                    }
                }

                // Grid with drag gesture
                ZStack(alignment: .topLeading) {
                    VStack(spacing: 4) {
                        ForEach(days, id: \.self) { day in
                            HStack(spacing: cellSpacing) {
                                Text(day)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .frame(width: labelWidth, alignment: .leading)
                                ForEach(slots, id: \.self) { slot in
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(isSelected(day: day, slot: slot) ? Color.blue : Color.gray.opacity(0.15))
                                        .frame(width: cellWidth, height: cellHeight)
                                        .overlay(
                                            Image(systemName: isSelected(day: day, slot: slot) ? "checkmark" : "")
                                                .font(.caption2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                }
                            }
                        }
                    }

                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    guard let (day, slot) = cellAt(point: value.location, cellWidth: cellWidth) else { return }
                                    let key = "\(day)-\(slot)"

                                    if dragMode == nil {
                                        dragMode = !isSelected(day: day, slot: slot)
                                    }

                                    guard !draggedCells.contains(key) else { return }
                                    draggedCells.insert(key)

                                    if dragMode == true {
                                        if !isSelected(day: day, slot: slot) {
                                            selectedA[day, default: []].append(slot)
                                        }
                                    } else {
                                        selectedA[day]?.removeAll { $0 == slot }
                                    }
                                }
                                .onEnded { _ in
                                    dragMode = nil
                                    draggedCells.removeAll()
                                }
                        )
                }
            }
            .padding(4)
        }
        .frame(height: 44 + CGFloat(days.count) * (cellHeight + 4) + 8)
    }

    private func cellAt(point: CGPoint, cellWidth: CGFloat) -> (String, String)? {
        let x = point.x - labelWidth
        let y = point.y

        guard x >= 0 else { return nil }

        let slotIndex = Int(x / (cellWidth + cellSpacing))
        let dayIndex = Int(y / (cellHeight + 4))

        guard slotIndex >= 0, slotIndex < slots.count, dayIndex >= 0, dayIndex < days.count else { return nil }
        return (days[dayIndex], slots[slotIndex])
    }

    private func isSelected(day: String, slot: String) -> Bool {
        selectedA[day]?.contains(slot) ?? false
    }
}

// ** RPC params for search_coaches **
struct SearchCoachesParams: Encodable {
    let start_lat: Double
    let start_long: Double
    let radius_meters: Double
    let sport_filter: String
    let max_hourly: Double
    let sort_choice: String
    let result_limit: Int
    let result_offset: Int
}

// ** RPC response row from search_coaches **
struct CoachSearchRPCRow: Codable {
    let coachId: UUID
    let firstName: String
    let lastName: String
    let imageUrl: String?
    let sports: [String]
    let individualCost: Double?
    let groupCost: Double?
    let trainingLocations: [structLocation]?
    let timeAvailability: [String: [String]]?
    let avgRating: Double
    let reviewCount: Int64
    let distanceMeters: Double?

    enum CodingKeys: String, CodingKey {
        case coachId = "coach_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case imageUrl = "image_url"
        case sports
        case individualCost = "individual_cost"
        case groupCost = "group_cost"
        case trainingLocations = "training_locations"
        case timeAvailability = "time_availability"
        case avgRating = "avg_rating"
        case reviewCount = "review_count"
        case distanceMeters = "distance_meters"
    }
}


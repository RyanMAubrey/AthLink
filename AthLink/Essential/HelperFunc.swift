import SwiftUI
import SwiftData
import CoreLocation
import Supabase
import MapKit

// MARK: Enums
// ** Sports types **
enum Sports: String, Hashable, Codable, CustomStringConvertible {
    case Football = "football"

    // Custom String Conformance
    var description: String {
        switch self {
        case .Football: return "Football"
        }
    }
    
    // Converts from string back to enum
    static func from(_ string: String) -> Sports? {
        switch string.lowercased() {
        case "football": return .Football
        default: return nil
        }
    }
}

// ** Sports Positions **
enum Positions: Hashable, Codable, CustomStringConvertible {
    case football(Positions.FootballPositions)
    
    // Custom String Conformance
    var description: String {
        switch self {
        case .football(let pos):
            return pos.description
        }
    }
    
    // Football enum
    enum FootballPositions: Hashable, Codable, CustomStringConvertible {
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
        
        // Custom String Conformance
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
}

// ** Session Types **
enum GroupType: String, Hashable, Codable, CustomStringConvertible {
    case Individual = "individual"
    case Group = "group"
    
    // Custom String Conformance
    var description: String {
        switch self {
        case .Individual: return "Individual"
        case .Group: return "Group"
        }
    }
}

// MARK: DB -> UI Data Sructures
// ** Location Struct **
struct structLocation: Identifiable, Codable, Equatable, Hashable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    var name: String
    
    // Static default
    static let `default` = structLocation(id: UUID(), coordinate: CLLocationCoordinate2D(latitude:0.0, longitude:0.0), name:"N/A")
    
    // Create Locally
    init(id: UUID=UUID(), coordinate: CLLocationCoordinate2D, name: String) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
    }
    
    // Create with MKMapItem
    init(mapItem: MKMapItem) {
        self.id = UUID()
        self.coordinate = mapItem.placemark.coordinate
        self.name = mapItem.name ?? mapItem.placemark.name ?? "Uknown Location"
    }
    // Create with CLL
    init(mapItem: CLLocation) {
        self.id = UUID()
        self.coordinate = mapItem.coordinate
        self.name = mapItem.description
    }
    // Turn to MKMapItem
    func toMapItem() -> MKMapItem {
        let item = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        item.name = self.name
        return item
    }
    
    // Codable Conformance
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case lat
        case lng
    }
    
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try c.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.name = try c.decode(String.self, forKey: .name)
        let lat = try c.decode(Double.self, forKey: .lat)
        let lng = try c.decode(Double.self, forKey: .lng)
        self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(name, forKey: .name)
        try c.encode(coordinate.latitude,  forKey: .lat)
        try c.encode(coordinate.longitude, forKey: .lng)
    }
    
    // Equatable conformance
    static func == (lhs: structLocation, rhs: structLocation) -> Bool {
        return (lhs.id == rhs.id) && (lhs.coordinate.latitude == rhs.coordinate.latitude) && (lhs.coordinate.longitude == rhs.coordinate.longitude)
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ** Session Struct **
struct Session: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    // Date created
    var reqDate: Date
    let other: UUID
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
    // Date of session start
    var date: Date
    // Date of session end
    var finished: Date
    var location: structLocation
    // TODO: Implement with algorithm
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
    
    // Initializer
    init (
        id: UUID = UUID(),
        reqDate: Date,
        other: UUID,
        sport: Sports,
        type: GroupType,
        typeRate: Double,
        date: Date,
        finished: Date,
        location: structLocation,
        rate: Double = 0.0,
        description: String? = nil
    ) {
        self.id = id
        self.reqDate = reqDate
        self.other = other
        self.sport = sport
        self.type = type
        self.typeRate = typeRate
        self.date = date
        self.finished = finished
        self.location = location
        self.rate = rate
        self.description = description
    }
        
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case reqDate = "required_date"
        case other
        case sport
        case type
        case typeRate = "type_rate"
        case date
        case finished
        case location
        case rate
        case description
    }
    
    // Equatable conformance
    static func == (lhs: Session, rhs: Session) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ** Athlete side posted session **
struct PostedSessionRow: Identifiable, Codable, Hashable {
    let id: UUID
    let createdAt: Date
    let coach: UUID?
    let sport: Sports?
    let type: GroupType?
    let typeRate: Double?
    let startDate: Date?
    let finishDate: Date?
    let location: structLocation?
    let algoRate: Double
    let description: String?
    let lat: Double?
    let long: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case createdAt = "created_at"
        case coach
        case sport
        case type
        case typeRate = "type_rate"
        case startDate = "start_date"
        case finishDate = "finish_date"
        case location
        case algoRate = "algo_rate"
        case description
        case lat
        case long
    }
    
    // Convert to a regular session
    func toSession() -> Session? {
        guard
            let sport,
            let type,
            let typeRate,
            let startDate,
            let finishDate,
            let location
        else {
            return nil
        }

        return Session(
            id: id,
            reqDate: createdAt,
            // "other" = the athlete (id), since coaches browse these postings
            other: id,
            sport: sport,
            type: type,
            typeRate: typeRate,
            date: startDate,
            finished: finishDate,
            location: location,
            rate: algoRate,
            description: description
        )
    }
}

// ** Insert/Update struct for posted_sessions table **
struct PostedSessionUpsert: Codable {
    let id: UUID
    let sport: Sports?
    let type: GroupType?
    let typeRate: Double?
    let startDate: Date?
    let finishDate: Date?
    let location: structLocation?
    let description: String?
    let lat: Double?
    let long: Double?
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, sport, type, location, description, lat, long
        case typeRate = "type_rate"
        case startDate = "start_date"
        case finishDate = "finish_date"
    }
}

// ** Message Struct **
struct MessageRow: Identifiable, Codable, Equatable, Hashable {
    var id: UUID?
    var message: String?
    var createdAt: Date?
    var senderId: UUID
    var receiverId: UUID
    var request: Session?
    var senderRole: Bool
    
    // Codable conformance
    enum CodingKeys: String, CodingKey {
        case id
        case message
        case createdAt = "created_at"
        case senderId = "sender_id"
        case receiverId = "receiver_id"
        case request
        case senderRole = "sender_role"
    }
    
    // Equatable conformance
    static func == (lhs: MessageRow, rhs: MessageRow) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ** Review Struct **
struct Review: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var coach: UUID
    var reviewer: UUID
    var date: Date
    var star: Float
    var quote: String

    enum CodingKeys: String, CodingKey {
        case id
        case coach
        case reviewer
        case date
        case star
        case quote
    }
    
    // Equatable conformance
    static func == (lhs: Review, rhs: Review) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// ** Athlete mini struct **
struct Athletes: Identifiable, Codable {
    var id: UUID
    var totalGained: Double
    var sessions: Int
    
    // Codable Conformance
    enum CodingKeys: String, CodingKey {
        case id
        case totalGained = "total_gained"
        case sessions
    }
}

// ** PublicUser **
struct PublicUser: Identifiable, Codable, Hashable {
    let id: UUID
    let firstName: String
    let lastName: String
    let avatarURL: String?
    let cardOnFile: Bool
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    
    // Codable Confromance
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName  = "last_name"
        case avatarURL = "image_url"
        case cardOnFile = "card_on_file"
    }
}

// MARK: Navigation helpers
// ** Coach Login Helper **
final class SignupDraft: ObservableObject {
    @Published var userType: String = "Athlete"
    @Published var firstName = ""
    @Published var lastName  = ""
    @Published var email = ""
    @Published var password = ""
}

// ** Athlete Side Search Helper **
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

// MARK: Backend encodable helper/other
// ** Athlete Account **
struct ProfilePatchFirst: Encodable {
    let first_name: String?
    let last_name: String?
    let user_type: String?
    let notifications: Bool?
    let coach_messaging: Bool?
}

// ** Coach table **
struct CoachProfilePatch: Encodable {
    let personal_quote: String? 
    let coaching_achievements: [String]?
    let coaching_experience: [String]?
    let time_availability: [String: [String]]?
    let athlete_messaging: Bool?
    let individual_cost: Double?
    let group_cost: Double?
    let sports: [String]?
    let sport_positions: [String: [String]]?
    let cancellation_notice: Int?
    let coach_upcoming_sessions: [Session]?
    let coach_unsubmitted_sessions: [Session]?
    let coach_submitted_sessions: [Session]?
    let job_requests: [Session]?
    let interested_athletes: [UUID]?
    let current_athletes: [UUID: Athletes]?
    let reviews: [Review]?
    let athlete_requests: [Session]?
    let training_locations: [structLocation]?
}

// ** Athlete Sessions **
struct ProfileSessionPatch: Encodable {
    let athlete_upcoming_sessions: [Session]?
    let athlete_past_sessions: [Session]?
}

// ** Coach Account **
struct ProfilePatchSecond: Encodable {
    let first_name: String?
    let last_name: String?
    let notifications: Bool?
}

// ** Search result for coach discovery **
struct CoachSearchResult: Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let imageURL: String?
    let sports: [String]
    let individualCost: Double?
    let groupCost: Double?
    let rating: Float
    let reviewCount: Int
    let closestLocation: structLocation?
    let distanceMiles: Double?
    let timeAvailability: [String: [String]]
    // Computed
    var fullName: String { "\(firstName) \(lastName)" }
}

// Forward geocode a zip code to coordinates
func coordinatesFromZip(_ zip: String) async -> CLLocationCoordinate2D? {
    do {
        let placemarks = try await CLGeocoder().geocodeAddressString(zip)
        return placemarks.first?.location?.coordinate
    } catch {
        print("Forward geocode failed:", error)
        return nil
    }
}

// Load a new ProfileID from backend
func loadProfile(client: SupabaseClient, id: UUID) async throws -> ProfileID {
    // New profile
    let newProfile: ProfileID = ProfileID()

    // Gets the current session and user
    guard let _ = client.auth.currentSession,
          let _ = client.auth.currentUser else {
        throw NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "No signed-in user"])
    }
    // Fetch Main Data
    let athleteRow: Profile = try await client
        .from("profiles")
        .select("id, first_name, last_name, coach_account, image_url, user_type, notifications, coach_messaging, athlete_upcoming_sessions, athlete_past_sessions, card_on_file, current_coaches, interested_coaches")
        .eq("id", value: id)
        .single()
        .execute()
        .value
    newProfile.apply(row: athleteRow)
    // If Coach Fetch Other Data
    if athleteRow.coachAccount {
        let coachRow: CoachProfile = try await client
            .from("coach_profile")
            .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, athlete_messaging, individual_cost, group_cost, sports, sport_positions, cancellation_notice, coach_upcoming_sessions, coach_unsubmitted_sessions, coach_submitted_sessions, job_requests, interested_athletes, current_athletes, athlete_requests, training_locations")
            .eq("id", value: id)
            .single()
            .execute()
            .value
        newProfile.coachApply(row: coachRow)
    }
    return newProfile
}

//**UI Components**
// Account Bars
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
// Time Selector
struct AvailabilityGrid: View {
    @Binding var selectedA: [String: [String]]

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let times = Array(6..<12).map { "\($0) AM" } + Array(12..<24).map { "\($0 - 12) PM" }

    // Drag state
    @State private var dragMode: Bool? = nil // true = selecting, false = deselecting
    @State private var draggedCells: Set<String> = [] // "day-time" keys touched this drag

    private let labelWidth: CGFloat = 40
    private let cellSpacing: CGFloat = 2
    private let cellHeight: CGFloat = 25
    private let rowHeight: CGFloat = 30
    private let headerHeight: CGFloat = 24

    var body: some View {
        GeometryReader { geo in
            let gridWidth = geo.size.width - labelWidth - 10 // minus padding
            let cellWidth = (gridWidth - cellSpacing * 6) / 7

            VStack(alignment: .leading, spacing: 4) {
                // Day headers
                HStack(spacing: cellSpacing) {
                    Text("")
                        .frame(width: labelWidth)
                    ForEach(days, id: \.self) { day in
                        Text(day)
                            .font(.caption)
                            .frame(width: cellWidth)
                    }
                }
                .frame(height: headerHeight)

                // Time rows with gesture overlay
                ZStack(alignment: .topLeading) {
                    // Grid cells
                    VStack(spacing: 4) {
                        ForEach(times.indices, id: \.self) { index in
                            HStack(spacing: cellSpacing) {
                                Text(times[index])
                                    .font(.caption)
                                    .frame(width: labelWidth, alignment: .leading)
                                ForEach(0..<7, id: \.self) { dayIndex in
                                    Rectangle()
                                        .fill(isSelected(day: days[dayIndex], timeSlot: times[index]) ? Color.blue : Color.gray.opacity(0.2))
                                        .frame(width: cellWidth, height: cellHeight)
                                }
                            }
                            .frame(height: rowHeight)
                        }
                    }

                    // Gesture overlay (covers just the cell area)
                    Color.clear
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                .onChanged { value in
                                    guard let (day, time) = cellAt(point: value.location, cellWidth: cellWidth) else { return }
                                    let key = "\(day)-\(time)"

                                    // First cell touched sets the mode
                                    if dragMode == nil {
                                        let wasSelected = isSelected(day: day, timeSlot: time)
                                        dragMode = !wasSelected // if was off, we're selecting; if was on, we're deselecting
                                    }

                                    guard !draggedCells.contains(key) else { return }
                                    draggedCells.insert(key)

                                    if dragMode == true {
                                        if !isSelected(day: day, timeSlot: time) {
                                            selectedA[day, default: []].append(time)
                                        }
                                    } else {
                                        selectedA[day]?.removeAll(where: { $0 == time })
                                    }
                                }
                                .onEnded { _ in
                                    dragMode = nil
                                    draggedCells.removeAll()
                                }
                        )
                }
            }
            .padding(5)
        }
        .frame(height: headerHeight + CGFloat(times.count) * (rowHeight + 4) + 10)
    }

    private func cellAt(point: CGPoint, cellWidth: CGFloat) -> (String, String)? {
        let x = point.x - labelWidth
        let y = point.y

        guard x >= 0 else { return nil }

        let dayIndex = Int(x / (cellWidth + cellSpacing))
        let timeIndex = Int(y / (rowHeight + 4))

        guard dayIndex >= 0, dayIndex < 7, timeIndex >= 0, timeIndex < times.count else { return nil }
        return (days[dayIndex], times[timeIndex])
    }

    func isSelected(day: String, timeSlot: String) -> Bool {
        return selectedA[day]?.contains(timeSlot) ?? false
    }
}
struct AvailabilityGridRead: View {
    let selectedA: [String: [String]]

    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let times = Array(6..<12).map { "\($0) AM" } + Array(12..<24).map { "\($0 - 12) PM" }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header row
            HStack(spacing: 2) {
                Text("").frame(width: 40)
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(3)
                }
            }

            // Time rows
            ForEach(times.indices, id: \.self) { timeIndex in
                let timeSlot = times[timeIndex]

                HStack(spacing: 2) {
                    Text(timeSlot)
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)

                    ForEach(days.indices, id: \.self) { dayIndex in
                        let day = days[dayIndex]
                        let isSelected = selectedA[day]?.contains(timeSlot) ?? false

                        Rectangle()
                            .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
                            .frame(maxWidth: .infinity)
                            .frame(height: 25)
                    }
                }
                .frame(height: 30)
            }
        }
        .padding(5)
    }
}

//**Extensions**
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
// Find map region with all points
func regionThatFits(_ locs: [structLocation], paddingFactor: Double = 1.25) -> MKCoordinateRegion? {
    guard !locs.isEmpty else { return nil }

    var minLat = locs[0].coordinate.latitude
    var maxLat = locs[0].coordinate.latitude
    var minLng = locs[0].coordinate.longitude
    var maxLng = locs[0].coordinate.longitude

    for l in locs {
        minLat = min(minLat, l.coordinate.latitude)
        maxLat = max(maxLat, l.coordinate.latitude)
        minLng = min(minLng, l.coordinate.longitude)
        maxLng = max(maxLng, l.coordinate.longitude)
    }

    let center = CLLocationCoordinate2D(
        latitude: (minLat + maxLat) / 2,
        longitude: (minLng + maxLng) / 2
    )

    var span = MKCoordinateSpan(
        latitudeDelta: max(0.002, maxLat - minLat),
        longitudeDelta: max(0.002, maxLng - minLng)
    )

    span = MKCoordinateSpan(
        latitudeDelta: span.latitudeDelta * paddingFactor,
        longitudeDelta: span.longitudeDelta * paddingFactor
    )

    return MKCoordinateRegion(center: center, span: span)
}
// Find closest area and distance
func closestDistanceMeters(_ locs: [structLocation], myLocal: CLLocation?) -> (structLocation, CLLocationDistance)? {
    guard let me = myLocal, !locs.isEmpty else { return nil }

    var bestDist: CLLocationDistance = .greatestFiniteMagnitude
    var bestLoc: structLocation? = nil

    for l in locs {
        let other = CLLocation(latitude: l.coordinate.latitude,
                               longitude: l.coordinate.longitude)
        let d = me.distance(from: other)
        if d < bestDist {
            bestDist = d
            bestLoc = l
        }
    }

    guard let bestLoc else { return nil }
    return (bestLoc, bestDist)
}

// Check if coach has a review from you and gets it
func getReview(client: SupabaseClient, coachID: UUID, reviewerID: UUID) async -> Review? {
    do {
        let reviews: [Review] = try await client
            .from("reviews")
            .select()
            .eq("coach", value: coachID)
            .eq("reviewer", value: reviewerID)
            .execute()
            .value
        return reviews.first
    } catch {
        print("Failed to get review:", error)
        return nil
    }
}

// ** Submit a new review for a coach **
func submitReview(client: SupabaseClient, coachID: UUID, reviewerID: UUID, star: Float, quote: String) async -> Bool {
    do {
        let newReview = Review(id: UUID(), coach: coachID, reviewer: reviewerID, date: Date(), star: star, quote: quote)
        try await client
            .from("reviews")
            .insert(newReview)
            .execute()
        return true
    } catch {
        print("Failed to submit review:", error)
        return false
    }
}


// ** Update an existing review **
func updateReview(client: SupabaseClient, reviewID: UUID, star: Float, quote: String) async -> Bool {
    do {
        struct ReviewUpdate: Encodable {
            let star: Float
            let quote: String
            let date: Date
        }
        try await client
            .from("reviews")
            .update(ReviewUpdate(star: star, quote: quote, date: Date()))
            .eq("id", value: reviewID)
            .execute()
        return true
    } catch {
        print("Failed to update review:", error)
        return false
    }
}

// ** Store coaches rating and number of reviews **
struct CoachRating: Codable {
    let avgStar: Float
    let reviewCount: Int
    
    // Codable Conformance
    enum CodingKeys: String, CodingKey {
        case avgStar = "avg_star"
        case reviewCount = "review_count"
    }
}

// ** Get coaches rating and number of reviews **
func getCoachRating(client: SupabaseClient, coachID: UUID) async -> CoachRating? {
    do {
        let result: [CoachRating] = try await client
            .rpc("get_coach_rating", params: ["p_coach_id": coachID])
            .execute()
            .value
        return result.first
    } catch {
        print("Failed to get coach rating:", error)
        return nil
    }
}

// ** Profile image **
func uploadImage(client: SupabaseClient, image: UIImage, name: String) async throws {
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
    let fileName = "\(name).jpg"
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

//
//  HelperFunc.swift
//  AthLink
//
//  Created by RyanAubrey on 8/12/25.
//

import SwiftUI
import SwiftData
import CoreLocation
import Supabase

// **Enums**
// Sports types
enum Sports: Hashable, Codable, CustomStringConvertible {
    case Football
    
    var description: String {
        switch self {
        case .Football:
            return "Football"
        }
    }
}
// Sports Positions
enum Positions: Hashable, Codable, CustomStringConvertible {
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

//**Important data structures**
// Location Struct
struct CoachLocation: Identifiable, Codable, Hashable, Equatable {
    var id: UUID
    var coordinate: CLLocationCoordinate2D
    var name: String
    
    // Create Locally
    init(id: UUID=UUID(), coordinate: CLLocationCoordinate2D, name: String) {
        self.id = id
        self.coordinate = coordinate
        self.name = name
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
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Equatable conformance
    static func == (lhs: CoachLocation, rhs: CoachLocation) -> Bool {
        return lhs.id == rhs.id
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

//**Navigation helpers**
// Coach Login Helper
final class SignupDraft: ObservableObject {
    @Published var userType: String = "Athlete"
    @Published var firstName = ""
    @Published var lastName  = ""
    @Published var postalCode = ""
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

// **Backend encodable helper**
// Main table
struct ProfilePatchFirst: Encodable {
    let first_name: String?
    let last_name: String?
    let user_type: String?
    let postal_code: String?
    let notifications: Bool?
    let coach_messaging: Bool?
}
// Coach table
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
}
struct ProfilePatchSecond: Encodable {
    let first_name: String?
    let last_name: String?
    let postal_code: String?
    let notifications: Bool?
}
// Location table
struct LocationPatch: Encodable {
    let id: UUID?
    let coach_id: UUID?
    let name: String?
    let lat: Double?
    let lng: Double?
}

// **UI Components**
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

// **Extensions**
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

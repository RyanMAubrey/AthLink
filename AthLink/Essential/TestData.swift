import Foundation
import CoreLocation
import Supabase

struct TestData {
    static let myID = UUID(uuidString: "7aaef0ad-0e6b-4990-bdb7-0178e4cd5535")!
    static let fakeCoachID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    static let fakeAthleteID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

    static let parkLocation = structLocation(
        coordinate: CLLocationCoordinate2D(latitude: 33.4484, longitude: -112.0740),
        name: "Central Park Field"
    )
    static let gymLocation = structLocation(
        coordinate: CLLocationCoordinate2D(latitude: 33.4500, longitude: -112.0700),
        name: "Elite Training Gym"
    )
    static let fieldLocation = structLocation(
        coordinate: CLLocationCoordinate2D(latitude: 33.4520, longitude: -112.0680),
        name: "Westside Sports Complex"
    )

    static func seed(client: SupabaseClient) async {
        let cal = Calendar.current
        let now = Date()

        // -- ATHLETE SESSIONS (you as athlete, fakeCoachID as the coach) --

        let athleteUpcoming: [Session] = [
            Session(
                reqDate: cal.date(byAdding: .day, value: -3, to: now)!,
                other: fakeCoachID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: 2, to: cal.date(bySettingHour: 10, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 2, to: cal.date(bySettingHour: 11, minute: 30, second: 0, of: now)!)!,
                location: parkLocation,
                description: "Focus on route running"
            ),
            Session(
                reqDate: cal.date(byAdding: .day, value: -1, to: now)!,
                other: fakeCoachID,
                sport: .Football,
                type: .Group,
                typeRate: 40.0,
                date: cal.date(byAdding: .day, value: 5, to: cal.date(bySettingHour: 16, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 5, to: cal.date(bySettingHour: 18, minute: 0, second: 0, of: now)!)!,
                location: fieldLocation
            )
        ]

        let athletePast: [Session] = [
            Session(
                reqDate: cal.date(byAdding: .day, value: -14, to: now)!,
                other: fakeCoachID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: -7, to: cal.date(bySettingHour: 9, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: -7, to: cal.date(bySettingHour: 10, minute: 30, second: 0, of: now)!)!,
                location: parkLocation,
                description: "Worked on footwork drills"
            ),
            Session(
                reqDate: cal.date(byAdding: .day, value: -20, to: now)!,
                other: fakeCoachID,
                sport: .Football,
                type: .Group,
                typeRate: 40.0,
                date: cal.date(byAdding: .day, value: -10, to: cal.date(bySettingHour: 14, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: -10, to: cal.date(bySettingHour: 16, minute: 0, second: 0, of: now)!)!,
                location: gymLocation
            ),
            Session(
                reqDate: cal.date(byAdding: .day, value: -30, to: now)!,
                other: fakeCoachID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: -21, to: cal.date(bySettingHour: 11, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: -21, to: cal.date(bySettingHour: 12, minute: 0, second: 0, of: now)!)!,
                location: fieldLocation,
                description: "Film review + throwing mechanics"
            )
        ]

        // -- COACH SESSIONS (you as coach, fakeAthleteID as the athlete) --

        let coachUpcoming: [Session] = [
            Session(
                reqDate: cal.date(byAdding: .day, value: -2, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: 1, to: cal.date(bySettingHour: 15, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 1, to: cal.date(bySettingHour: 16, minute: 30, second: 0, of: now)!)!,
                location: parkLocation,
                description: "Quarterback mechanics session"
            ),
            Session(
                reqDate: cal.date(byAdding: .day, value: -1, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Group,
                typeRate: 40.0,
                date: cal.date(byAdding: .day, value: 4, to: cal.date(bySettingHour: 9, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 4, to: cal.date(bySettingHour: 11, minute: 0, second: 0, of: now)!)!,
                location: fieldLocation
            )
        ]

        let coachPast: [Session] = [
            Session(
                reqDate: cal.date(byAdding: .day, value: -15, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: -5, to: cal.date(bySettingHour: 10, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: -5, to: cal.date(bySettingHour: 11, minute: 30, second: 0, of: now)!)!,
                location: gymLocation,
                description: "Agility ladder + cone drills"
            ),
            Session(
                reqDate: cal.date(byAdding: .day, value: -25, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: -14, to: cal.date(bySettingHour: 13, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: -14, to: cal.date(bySettingHour: 14, minute: 0, second: 0, of: now)!)!,
                location: parkLocation
            ),
            Session(
                reqDate: cal.date(byAdding: .day, value: -35, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Group,
                typeRate: 40.0,
                date: cal.date(byAdding: .day, value: -25, to: cal.date(bySettingHour: 16, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: -25, to: cal.date(bySettingHour: 18, minute: 0, second: 0, of: now)!)!,
                location: fieldLocation,
                description: "Group conditioning and drills"
            )
        ]

        // -- JOB REQUESTS (athletes requesting sessions with you as coach) --

        let jobRequests: [Session] = [
            Session(
                reqDate: cal.date(byAdding: .day, value: -1, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Individual,
                typeRate: 55.0,
                date: cal.date(byAdding: .day, value: 3, to: cal.date(bySettingHour: 14, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 3, to: cal.date(bySettingHour: 15, minute: 30, second: 0, of: now)!)!,
                location: parkLocation,
                description: "Want to work on catching drills"
            ),
            Session(
                reqDate: now,
                other: fakeAthleteID,
                sport: .Football,
                type: .Group,
                typeRate: 35.0,
                date: cal.date(byAdding: .day, value: 6, to: cal.date(bySettingHour: 10, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 6, to: cal.date(bySettingHour: 12, minute: 0, second: 0, of: now)!)!,
                location: fieldLocation,
                description: "Group conditioning for my team"
            )
        ]

        // -- ATHLETE REQUESTS (you requesting sessions as coach to athletes) --

        let athleteRequests: [Session] = [
            Session(
                reqDate: cal.date(byAdding: .day, value: -2, to: now)!,
                other: fakeAthleteID,
                sport: .Football,
                type: .Individual,
                typeRate: 60.0,
                date: cal.date(byAdding: .day, value: 7, to: cal.date(bySettingHour: 11, minute: 0, second: 0, of: now)!)!,
                finished: cal.date(byAdding: .day, value: 7, to: cal.date(bySettingHour: 12, minute: 30, second: 0, of: now)!)!,
                location: gymLocation,
                description: "Follow-up mechanics session"
            )
        ]

        // -- CURRENT ATHLETES --

        let currentAthletes: [UUID: Athletes] = [
            fakeAthleteID: Athletes(
                id: fakeAthleteID,
                totalGained: 240.0,
                sessions: 4
            )
        ]

        // Write to Supabase
        do {
            // Athlete side
            let athletePatch = ProfileSessionPatch(
                athlete_upcoming_sessions: athleteUpcoming,
                athlete_past_sessions: athletePast
            )
            try await client
                .from("profiles")
                .update(athletePatch)
                .eq("id", value: myID.uuidString)
                .execute()

            // Coach side
            let coachPatch = CoachProfilePatch(
                personal_quote: nil, coaching_achievements: nil,
                coaching_experience: nil, time_availability: nil,
                individual_cost: nil,
                group_cost: nil, sports: nil, sport_positions: nil,
                cancellation_notice: nil,
                coach_upcoming_sessions: coachUpcoming,
                coach_past_sessions: coachPast,
                job_requests: jobRequests,
                current_athletes: currentAthletes, reviews: nil,
                athlete_requests: athleteRequests, training_locations: nil
            )
            try await client
                .from("coach_profile")
                .update(coachPatch)
                .eq("id", value: myID.uuidString)
                .execute()

            print("TEST DATA SEEDED SUCCESSFULLY")
        } catch {
            print("TEST DATA SEED FAILED:", error)
        }
    }
}

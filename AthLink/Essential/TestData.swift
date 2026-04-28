import Foundation
import CoreLocation
import Supabase

// MARK: - Test Data Seeder
// Seeds YOUR OWN coach_profile and profiles rows with JSONB data.
// Fake users, messages, reviews, locations, and posted_sessions are inserted via SQL.

struct TestData {

    // Your UUID
    static let myId = UUID(uuidString: "3d48af13-2565-45c6-bc20-fbb65f13931a")!

    // Fake athlete UUIDs (must match SQL)
    static let athlete1 = UUID(uuidString: "aaaaaaaa-1111-1111-1111-aaaaaaaaaaaa")!
    static let athlete2 = UUID(uuidString: "bbbbbbbb-2222-2222-2222-bbbbbbbbbbbb")!
    static let athlete3 = UUID(uuidString: "cccccccc-3333-3333-3333-cccccccccccc")!
    static let athlete4 = UUID(uuidString: "dddddddd-4444-4444-4444-dddddddddddd")!
    static let athlete5 = UUID(uuidString: "eeeeeeee-5555-5555-5555-eeeeeeeeeeee")!

    // Fake coach UUIDs (must match SQL)
    static let coach1 = UUID(uuidString: "ffffffff-6666-6666-6666-ffffffffffff")!
    static let coach2 = UUID(uuidString: "11111111-7777-7777-7777-111111111111")!

    // Reusable locations
    static let bostonCommon = structLocation(
        id: UUID(uuidString: "a0a0a0a0-0001-0001-0001-a0a0a0a0a0a0")!,
        coordinate: CLLocationCoordinate2D(latitude: 42.3551, longitude: -71.0657),
        name: "Boston Common"
    )
    static let harvardStadium = structLocation(
        id: UUID(uuidString: "a0a0a0a0-0002-0002-0002-a0a0a0a0a0a0")!,
        coordinate: CLLocationCoordinate2D(latitude: 42.3662, longitude: -71.1268),
        name: "Harvard Stadium"
    )
    static let mitField = structLocation(
        id: UUID(uuidString: "a0a0a0a0-0003-0003-0003-a0a0a0a0a0a0")!,
        coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0942),
        name: "MIT Athletic Fields"
    )
    static let fenway = structLocation(
        id: UUID(uuidString: "a0a0a0a0-0004-0004-0004-a0a0a0a0a0a0")!,
        coordinate: CLLocationCoordinate2D(latitude: 42.3467, longitude: -71.0972),
        name: "Fenway Park Area"
    )

    // MARK: - Main Entry Point
    static func seed(client: SupabaseClient) async {
        print("--- TEST DATA: Starting seed ---")

        // 1. Coach profile
        do {
            try await seedCoachProfile(client: client)
            print("TEST DATA: Coach profile seeded")
        } catch {
            print("TEST DATA: Coach profile FAILED: \(error)")
        }

        // 2. Athlete sessions
        do {
            try await seedAthleteSessions(client: client)
            print("TEST DATA: Athlete sessions seeded")
        } catch {
            print("TEST DATA: Athlete sessions FAILED: \(error)")
        }

        // 3. Posted session
        do {
            try await seedPostedSession(client: client)
            print("TEST DATA: Posted session seeded")
        } catch {
            print("TEST DATA: Posted session FAILED: \(error)")
        }

        // 4. Fake searchable coaches
        do {
            try await seedFakeCoaches(client: client)
            print("TEST DATA: Fake coaches seeded")
        } catch {
            print("TEST DATA: Fake coaches FAILED: \(error)")
        }

        print("--- TEST DATA: Seed complete! ---")
    }

    // MARK: - Coach Profile
    private static func seedCoachProfile(client: SupabaseClient) async throws {
        let now = Date()
        let cal = Calendar.current

        // 3 upcoming coach sessions (future, spaced across the week for calendar testing)
        let upcomingSessions: [Session] = [
            Session(reqDate: now, other: athlete1, sport: .Football, type: .Individual, typeRate: 75.0,
                    date: cal.date(byAdding: .hour, value: 25, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 26, to: now)!,
                    location: bostonCommon, rate: 0.0, description: "Footwork drills and route running"),
            Session(reqDate: now, other: athlete2, sport: .Football, type: .Individual, typeRate: 75.0,
                    date: cal.date(byAdding: .hour, value: 73, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 75, to: now)!,
                    location: harvardStadium, rate: 0.0, description: "Film review + on-field practice"),
            Session(reqDate: now, other: athlete3, sport: .Football, type: .Group, typeRate: 50.0,
                    date: cal.date(byAdding: .hour, value: 121, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 123, to: now)!,
                    location: mitField, rate: 0.0, description: "Group defensive back camp"),
        ]

        // 5 submitted (completed) sessions — for CoachSession submitted tab + receipt
        let submittedSessions: [Session] = [
            Session(reqDate: cal.date(byAdding: .day, value: -45, to: now)!, other: athlete1, sport: .Football, type: .Individual, typeRate: 65.0,
                    date: cal.date(byAdding: .day, value: -40, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -40, to: now)!)!,
                    location: bostonCommon, rate: 4.8),
            Session(reqDate: cal.date(byAdding: .day, value: -35, to: now)!, other: athlete2, sport: .Football, type: .Individual, typeRate: 65.0,
                    date: cal.date(byAdding: .day, value: -30, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -30, to: now)!)!,
                    location: harvardStadium, rate: 4.9),
            Session(reqDate: cal.date(byAdding: .day, value: -25, to: now)!, other: athlete4, sport: .Football, type: .Group, typeRate: 45.0,
                    date: cal.date(byAdding: .day, value: -20, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 2, to: cal.date(byAdding: .day, value: -20, to: now)!)!,
                    location: mitField, rate: 4.7),
            Session(reqDate: cal.date(byAdding: .day, value: -15, to: now)!, other: athlete5, sport: .Football, type: .Individual, typeRate: 70.0,
                    date: cal.date(byAdding: .day, value: -10, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -10, to: now)!)!,
                    location: fenway, rate: 5.0),
            Session(reqDate: cal.date(byAdding: .day, value: -8, to: now)!, other: athlete3, sport: .Football, type: .Individual, typeRate: 70.0,
                    date: cal.date(byAdding: .day, value: -5, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -5, to: now)!)!,
                    location: bostonCommon, rate: 4.6),
        ]

        // 2 unsubmitted (past, not yet reviewed) — for CoachSession unsubmitted tab + submit sheet
        let unsubmittedSessions: [Session] = [
            Session(reqDate: cal.date(byAdding: .day, value: -3, to: now)!, other: athlete4, sport: .Football, type: .Individual, typeRate: 75.0,
                    date: cal.date(byAdding: .day, value: -2, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -2, to: now)!)!,
                    location: harvardStadium, rate: 0.0, description: "Quarterback mechanics session"),
            Session(reqDate: cal.date(byAdding: .day, value: -2, to: now)!, other: athlete1, sport: .Football, type: .Group, typeRate: 50.0,
                    date: cal.date(byAdding: .day, value: -1, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 2, to: cal.date(byAdding: .day, value: -1, to: now)!)!,
                    location: mitField, rate: 0.0, description: "Group agility session"),
        ]

        // 2 job requests — for Jobs > Requests tab
        let jobRequests: [Session] = [
            Session(reqDate: now, other: athlete5, sport: .Football, type: .Individual, typeRate: 75.0,
                    date: cal.date(byAdding: .day, value: 5, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: 5, to: now)!)!,
                    location: bostonCommon, rate: 0.0, description: "Want help with my 40-yard dash time"),
            Session(reqDate: now, other: athlete1, sport: .Football, type: .Group, typeRate: 50.0,
                    date: cal.date(byAdding: .day, value: 8, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 2, to: cal.date(byAdding: .day, value: 8, to: now)!)!,
                    location: fenway, rate: 0.0, description: "Looking for group speed training"),
        ]

        // 1 athlete request — coach sent to athlete
        let athleteRequests: [Session] = [
            Session(reqDate: now, other: athlete2, sport: .Football, type: .Group, typeRate: 50.0,
                    date: cal.date(byAdding: .day, value: 6, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 2, to: cal.date(byAdding: .day, value: 6, to: now)!)!,
                    location: mitField, rate: 0.0, description: "Group speed & agility camp"),
        ]

        // Current athletes — for Jobs > Current Athletes tab
        let currentAthletes: [UUID: Athletes] = [
            athlete1: Athletes(id: athlete1, totalGained: 325.0, sessions: 5),
            athlete2: Athletes(id: athlete2, totalGained: 195.0, sessions: 3),
            athlete4: Athletes(id: athlete4, totalGained: 135.0, sessions: 2),
            athlete5: Athletes(id: athlete5, totalGained: 70.0, sessions: 1),
        ]

        let patch = CoachProfilePatch(
            personal_quote: "Building champions on and off the field. 10+ years of coaching experience at the collegiate and professional level.",
            coaching_achievements: [
                "NAIA All-American Selection Committee Member",
                "Led 3 athletes to D1 scholarships in 2024",
                "Certified Strength & Conditioning Specialist (CSCS)",
                "USA Football Level 2 Certified Coach",
                "Former Arena Football League player"
            ],
            coaching_experience: [
                "Head DB Coach - Boston College Club Football (2022-Present)",
                "Private Skills Trainer - New England Area (2020-Present)",
                "Assistant Coach - Brookline High School (2018-2020)",
                "Player Development Intern - New England Patriots (Summer 2019)"
            ],
            time_availability: [
                "Mon": ["6 AM", "7 AM", "8 AM", "4 PM", "5 PM"],
                "Tue": ["6 AM", "7 AM", "4 PM", "5 PM"],
                "Wed": ["6 AM", "7 AM", "8 AM", "4 PM", "5 PM"],
                "Thu": ["6 AM", "7 AM", "4 PM", "5 PM"],
                "Fri": ["6 AM", "7 AM", "8 AM", "9 AM"],
                "Sat": ["8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM"],
                "Sun": ["9 AM", "10 AM", "11 AM"]
            ],
            athlete_messaging: true,
            individual_cost: 75.0,
            group_cost: 50.0,
            sports: ["Football"],
            sport_positions: [
                "Football": ["Cornerback", "Free Safety", "Strong Safety", "Outside Linebacker"]
            ],
            cancellation_notice: 24,
            coach_upcoming_sessions: upcomingSessions,
            coach_unsubmitted_sessions: unsubmittedSessions,
            coach_submitted_sessions: submittedSessions,
            job_requests: jobRequests,
            interested_athletes: [athlete3],
            current_athletes: currentAthletes,
            reviews: nil,
            athlete_requests: athleteRequests,
            training_locations: [bostonCommon, harvardStadium, mitField, fenway]
        )

        try await client
            .from("coach_profile")
            .update(patch)
            .eq("id", value: myId.uuidString)
            .execute()
    }

    // MARK: - Athlete Sessions
    private static func seedAthleteSessions(client: SupabaseClient) async throws {
        let now = Date()
        let cal = Calendar.current

        // 3 upcoming athlete sessions — for Sessions > Upcoming tab
        let athleteUpcoming: [Session] = [
            Session(reqDate: now, other: coach1, sport: .Football, type: .Individual, typeRate: 60.0,
                    date: cal.date(byAdding: .day, value: 3, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: 3, to: now)!)!,
                    location: bostonCommon, rate: 0.0, description: "QB mechanics with Coach Rivera"),
            Session(reqDate: now, other: coach2, sport: .Football, type: .Group, typeRate: 35.0,
                    date: cal.date(byAdding: .day, value: 5, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 2, to: cal.date(byAdding: .day, value: 5, to: now)!)!,
                    location: harvardStadium, rate: 0.0, description: "Speed camp with Coach Thompson"),
            Session(reqDate: now, other: coach1, sport: .Football, type: .Individual, typeRate: 60.0,
                    date: cal.date(byAdding: .day, value: 10, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: 10, to: now)!)!,
                    location: mitField, rate: 0.0, description: "Film review and route trees"),
        ]

        // 5 past athlete sessions — for Sessions > Previous tab + SessionInfo + reviews
        let athletePast: [Session] = [
            Session(reqDate: cal.date(byAdding: .day, value: -60, to: now)!, other: coach1, sport: .Football, type: .Individual, typeRate: 55.0,
                    date: cal.date(byAdding: .day, value: -55, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -55, to: now)!)!,
                    location: bostonCommon, rate: 4.7, description: "First session - assessment"),
            Session(reqDate: cal.date(byAdding: .day, value: -45, to: now)!, other: coach2, sport: .Football, type: .Group, typeRate: 30.0,
                    date: cal.date(byAdding: .day, value: -40, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 2, to: cal.date(byAdding: .day, value: -40, to: now)!)!,
                    location: harvardStadium, rate: 4.5, description: "Group combine prep"),
            Session(reqDate: cal.date(byAdding: .day, value: -30, to: now)!, other: coach1, sport: .Football, type: .Individual, typeRate: 60.0,
                    date: cal.date(byAdding: .day, value: -25, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -25, to: now)!)!,
                    location: fenway, rate: 4.9, description: "Coverage technique deep dive"),
            Session(reqDate: cal.date(byAdding: .day, value: -14, to: now)!, other: coach2, sport: .Football, type: .Individual, typeRate: 40.0,
                    date: cal.date(byAdding: .day, value: -10, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -10, to: now)!)!,
                    location: mitField, rate: 5.0, description: "Agility ladder and cone drills"),
            Session(reqDate: cal.date(byAdding: .day, value: -7, to: now)!, other: coach1, sport: .Football, type: .Individual, typeRate: 60.0,
                    date: cal.date(byAdding: .day, value: -3, to: now)!,
                    finished: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: -3, to: now)!)!,
                    location: bostonCommon, rate: 4.8, description: "Game day prep and mental reps"),
        ]

        let sessionPatch = ProfileSessionPatch(
            athlete_upcoming_sessions: athleteUpcoming,
            athlete_past_sessions: athletePast
        )

        try await client
            .from("profiles")
            .update(sessionPatch)
            .eq("id", value: myId.uuidString)
            .execute()

        // Set current/interested coaches
        struct CoachListPatch: Encodable {
            let current_coaches: [UUID]
            let interested_coaches: [UUID]
        }
        try await client
            .from("profiles")
            .update(CoachListPatch(current_coaches: [coach1, coach2], interested_coaches: []))
            .eq("id", value: myId.uuidString)
            .execute()
    }

    // MARK: - Posted Session (your own listing on the job board)
    private static func seedPostedSession(client: SupabaseClient) async throws {
        let now = Date()
        let cal = Calendar.current

        let upsert = PostedSessionUpsert(
            id: myId,
            sport: .Football,
            type: .Individual,
            typeRate: 75.0,
            startDate: cal.date(byAdding: .day, value: 3, to: now)!,
            finishDate: cal.date(byAdding: .hour, value: 1, to: cal.date(byAdding: .day, value: 3, to: now)!)!,
            location: bostonCommon,
            description: "Looking for 1-on-1 defensive back training - all levels welcome",
            lat: 42.3551,
            long: -71.0657
        )

        try await client.from("posted_sessions").upsert(upsert).execute()
    }

    // MARK: - Fake Searchable Coaches
    // RLS + FK on auth.users blocks client-side inserts for fake users.
    // Run this SQL in Supabase SQL Editor instead:
    //
    // -- Create fake auth users
    // INSERT INTO auth.users (id, instance_id, role, aud, email, encrypted_password, email_confirmed_at, created_at, updated_at)
    // VALUES
    //   ('ffffffff-6666-6666-6666-ffffffffffff', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'marcus@test.com', crypt('password123', gen_salt('bf')), now(), now(), now()),
    //   ('11111111-7777-7777-7777-111111111111', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'sarah@test.com', crypt('password123', gen_salt('bf')), now(), now(), now())
    // ON CONFLICT (id) DO NOTHING;
    //
    // -- Create profiles
    // INSERT INTO public.profiles (id, first_name, last_name, user_type, coach_account, image_url)
    // VALUES
    //   ('ffffffff-6666-6666-6666-ffffffffffff', 'Marcus', 'Rivera', 'Coach', true, ''),
    //   ('11111111-7777-7777-7777-111111111111', 'Sarah', 'Thompson', 'Coach', true, '')
    // ON CONFLICT (id) DO NOTHING;
    //
    // -- Create coach_profile rows
    // INSERT INTO public.coach_profile (id, sports, individual_cost, group_cost, training_locations, personal_quote, coaching_achievements, coaching_experience, time_availability, sport_positions, cancellation_notice, athlete_messaging)
    // VALUES
    //   ('ffffffff-6666-6666-6666-ffffffffffff',
    //    '["Football"]', 65.0, 40.0,
    //    '[{"id":"a0a0a0a0-0001-0001-0001-a0a0a0a0a0a0","name":"Boston Common","coordinate":{"latitude":42.3551,"longitude":-71.0657}},{"id":"a0a0a0a0-0002-0002-0002-a0a0a0a0a0a0","name":"Harvard Stadium","coordinate":{"latitude":42.3662,"longitude":-71.1268}}]',
    //    'Speed kills — let me help you unlock your next gear.',
    //    '["Former D1 Wide Receiver at Boston College","Trained 5 NFL Combine attendees","EXOS Performance Specialist Certified"]',
    //    '["Private Speed Trainer - Boston Area (2021-Present)","WR Coach - BC Club Football (2019-2021)"]',
    //    '{"Mon":["6 AM","7 AM","8 AM","4 PM","5 PM"],"Wed":["6 AM","7 AM","8 AM","4 PM","5 PM"],"Fri":["6 AM","7 AM"],"Sat":["8 AM","9 AM","10 AM","0 PM","1 PM","6 PM","7 PM"]}',
    //    '{"Football":["Wide Receiver","Running Back","Cornerback"]}',
    //    12, true),
    //   ('11111111-7777-7777-7777-111111111111',
    //    '["Football"]', 45.0, 30.0,
    //    '[{"id":"a0a0a0a0-0003-0003-0003-a0a0a0a0a0a0","name":"MIT Athletic Fields","coordinate":{"latitude":42.3601,"longitude":-71.0942}},{"id":"a0a0a0a0-0004-0004-0004-a0a0a0a0a0a0","name":"Fenway Park Area","coordinate":{"latitude":42.3467,"longitude":-71.0972}}]',
    //    'Every rep counts. Let''s build your game from the ground up.',
    //    '["USA Football Level 1 Certified","Former Captain - MIT Women''s Flag Football","Youth Camp Director - Cambridge Recreation"]',
    //    '["Group Skills Trainer - Cambridge Area (2022-Present)","Flag Football Coach - Cambridge Youth League (2020-2022)"]',
    //    '{"Tue":["0 PM","1 PM","2 PM","6 PM","7 PM"],"Thu":["0 PM","1 PM","2 PM","6 PM","7 PM"],"Sat":["8 AM","9 AM","10 AM","0 PM","1 PM"],"Sun":["9 AM","10 AM","0 PM","1 PM"]}',
    //    '{"Football":["Quarterback","Linebacker","Safety"]}',
    //    24, true)
    // ON CONFLICT (id) DO NOTHING;
    //
    private static func seedFakeCoaches(client: SupabaseClient) async throws {
        print("TEST DATA: Fake coaches must be seeded via SQL Editor — see comments in TestData.swift")
    }
}

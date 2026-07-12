import SwiftUI
import Supabase

struct CoachSession: View {
    @EnvironmentObject var rootView: RootViewObj
    @State var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabButton(title: "Upcoming", index: 0)
                tabButton(title: "Previous", index: 1)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            Group {
                if selectedTab == 0 {
                    UpcomingTab()
                        .environmentObject(rootView)
                } else {
                    PreviousTab()
                        .environmentObject(rootView)
                }
            }
        }
        .task {
            do {
                try await rootView.client.rpc("move_past_sessions").execute()
                try await rootView.loadProfile()
            } catch {
                log.error("Failed to move past sessions: \(error.localizedDescription)")
            }
        }
    }

    private func tabButton(title: String, index: Int) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(selectedTab == index ? .semibold : .regular)

                Rectangle()
                    .fill(selectedTab == index ? Color.blue : Color.clear)
                    .frame(height: 3)
            }
            .foregroundColor(selectedTab == index ? .blue : .gray)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Upcoming Tab
    struct UpcomingTab: View {
        @EnvironmentObject var rootView: RootViewObj
        @State private var viewMode: Int = 0 // 0 = calendar, 1 = list

        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("Upcoming Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()

                    HStack(spacing: 2) {
                        Button(action: { viewMode = 0 }) {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .padding(8)
                                .background(viewMode == 0 ? Color.blue.opacity(0.15) : Color.clear)
                                .foregroundColor(viewMode == 0 ? .blue : .gray)
                                .cornerRadius(8)
                        }
                        Button(action: { viewMode = 1 }) {
                            Image(systemName: "list.bullet")
                                .font(.subheadline)
                                .padding(8)
                                .background(viewMode == 1 ? Color.blue.opacity(0.15) : Color.clear)
                                .foregroundColor(viewMode == 1 ? .blue : .gray)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.trailing)
                }
                .padding(.top)

                if viewMode == 0 {
                    WeeklyCalendar(sessions: rootView.profile.coachUpcomingSessions) { session in
                        rootView.selectedCoachSession = session
                        rootView.sessType = true
                        rootView.path.append("CoachSessionInfo")
                    }
                } else {
                    if rootView.profile.coachUpcomingSessions.isEmpty {
                        VStack(spacing: 16) {
                            Spacer()
                            Image(systemName: "calendar.badge.clock")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No Upcoming Sessions")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.gray)
                            Text("Booked sessions will appear here")
                                .font(.subheadline)
                                .foregroundColor(.gray.opacity(0.7))
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(rootView.profile.coachUpcomingSessions, id: \.id) { session in
                                    Button(action: {
                                        rootView.selectedCoachSession = session
                                        rootView.sessType = true
                                        rootView.path.append("CoachSessionInfo")
                                    }) {
                                        SessionCard(session: session, client: rootView.client)
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
    }

    // MARK: - Previous Tab
    struct PreviousTab: View {
        @EnvironmentObject var rootView: RootViewObj

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("Previous Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()
                }
                .padding(.top)

                if rootView.profile.coachPastSessions.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No Past Sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Text("Completed sessions will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(rootView.profile.coachPastSessions, id: \.id) { session in
                                Button(action: {
                                    rootView.selectedCoachSession = session
                                    rootView.sessType = false
                                    rootView.path.append("CoachSessionInfo")
                                }) {
                                    SessionCard(session: session, client: rootView.client)
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

    // MARK: - Session Card
    struct SessionCard: View {
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

                    if let athlete {
                        Text(athlete.fullName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    } else if isLoading {
                        Text("Loading...")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    Text(session.type.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text(athLinkDateWithDayAndYear(session.date))
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Text(session.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text(athLinkWholeDollar(session.cost))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
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
                let fetched: PublicUser = try await client
                    .from("profiles")
                    .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                athlete = fetched
                isLoading = false
            } catch {
                log.error("Failed to fetch athlete: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}

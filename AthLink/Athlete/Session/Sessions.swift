import SwiftUI

struct Sessions: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var selectedTab: Int = 0

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

            if selectedTab == 0 {
                UpcomingTab()
                    .environmentObject(rootView)
            } else {
                SessionListView(sessions: rootView.profile.athletePastSessions, type: false)
                    .environmentObject(rootView)
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            do {
                try await rootView.client.rpc("move_past_sessions").execute()
                try await rootView.loadProfile()
            } catch {
                log.error("Failed to move past sessions: \(error.localizedDescription)")
            }
        }
        .onAppear() {
            fSearch.validZ = false
            fSearch.zip = ""
            fSearch.sportVal = 0
            fSearch.fSearch = false
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
}

// MARK: - Upcoming Tab

struct UpcomingTab: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var viewMode: Int = 0 // 0 = calendar, 1 = list
    @State private var coaches: [UUID: ProfileID] = [:]

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

            if viewMode == 1 {
                SessionListView(sessions: rootView.profile.athleteUpcomingSessions, type: true)
                    .environmentObject(rootView)
            } else {
                WeeklyCalendar(sessions: rootView.profile.athleteUpcomingSessions) { session in
                    rootView.selectedAthleteSession = session
                    rootView.sessType = true
                    rootView.path.append("SessionInfo")
                }
            }
        }
    }
}

// MARK: - Session List View

struct SessionListView: View {
    @EnvironmentObject var rootView: RootViewObj
    let sessions: [Session]
    let type: Bool
    @State private var coaches: [UUID: ProfileID] = [:]

    var body: some View {
        VStack(alignment: .leading) {
            if !type {
                HStack {
                    Text("Past Sessions")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.top)
            }

            if sessions.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: type ? "calendar.badge.clock" : "checkmark.circle")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))
                    Text(type ? "No Upcoming Sessions" : "No Past Sessions")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                    Text(type ? "Booked sessions will appear here" : "Completed sessions will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(sessions) { session in
                            let coach = coaches[session.other]
                            Button(action: {
                                rootView.selectedAthleteSession = session
                                rootView.sessType = type
                                rootView.path.append("SessionInfo")
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: session.sf)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .padding(12)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(coach?.fullName ?? "Loading...")
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(session.sport.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("\(session.type.description) - \(session.totalTime.0)h \(session.totalTime.1)m")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: 6) {
                                        Text(session.date, style: .date)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(session.date, style: .time)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Text(String(format: "$%.2f", session.cost))
                                            .font(.subheadline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.green)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .task {
                                guard coaches[session.other] == nil else { return }
                                do {
                                    let fetched = try await loadProfile(client: rootView.client, id: session.other)
                                    coaches[session.other] = fetched
                                } catch {
                                    log.error("loadProfile failed: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

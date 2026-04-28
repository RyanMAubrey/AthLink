import SwiftUI

struct CoachRequestSess: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var athlete: PublicUser?
    @State private var isLoading = true

    private var session: Session? { rootView.selectedJobSession }
    private var isFromRequests: Bool { rootView.lastPage == "Requests" }

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let session, let athlete {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Header
                        VStack(spacing: 8) {
                            // Avatar
                            if let urlStr = athlete.avatarURL,
                               let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Image(systemName: "person.crop.circle.fill")
                                            .resizable()
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                            } else {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray.opacity(0.5))
                                    .frame(width: 60, height: 60)
                            }

                            Text(athlete.fullName)
                                .font(.title3)
                                .fontWeight(.bold)

                            Text(isFromRequests ? "Session Request" : "Athlete Posting")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 0.4627, green: 0.8392, blue: 1.0).opacity(0.2))

                        // Details
                        VStack(spacing: 0) {
                            detailRow(icon: "figure.run", label: "Sport", value: session.sport.description)
                            divider
                            detailRow(icon: "person.2", label: "Type", value: session.type.description)
                            divider
                            detailRow(icon: "dollarsign.circle", label: "Rate", value: String(format: "$%.2f/hr", session.typeRate))
                            divider
                            detailRow(icon: "calendar", label: "Date", value: session.date.formatted(date: .abbreviated, time: .shortened))
                            divider
                            detailRow(icon: "clock", label: "End", value: session.finished.formatted(date: .abbreviated, time: .shortened))
                            if session.location.name != "nan" {
                                divider
                                detailRow(icon: "mappin.circle", label: "Location", value: session.location.name)
                            }
                            if let desc = session.description, !desc.isEmpty {
                                divider
                                detailRow(icon: "text.quote", label: "Note", value: desc)
                            }
                        }
                        .padding()

                        // Credit Card Status
                        HStack(spacing: 6) {
                            Image(systemName: athlete.cardOnFile ? "creditcard.fill" : "creditcard")
                                .foregroundColor(athlete.cardOnFile ? .green : .orange)
                            Text(athlete.cardOnFile ? "Card on File" : "No Card on File")
                                .fontWeight(.semibold)
                                .foregroundColor(athlete.cardOnFile ? .green : .orange)
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background((athlete.cardOnFile ? Color.green : Color.orange).opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)

                        divider.padding(.horizontal)

                        // Requested date
                        HStack {
                            Text("Requested:")
                                .font(.caption)
                                .foregroundColor(.gray)
                            Text(session.reqDate.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }

                // Action Buttons
                VStack(spacing: 10) {
                    if isFromRequests {
                        // Accept request
                        Button(action: { acceptRequest(session: session, athlete: athlete) }) {
                            Text("Accept Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    } else {
                        // Send offer (from postings)
                        Button(action: { sendOffer(session: session, athlete: athlete) }) {
                            Text("Send Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    // Message athlete
                    Button(action: { messageAthlete(athlete: athlete) }) {
                        Text("Message Athlete")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    if isFromRequests {
                        // Decline
                        Button(action: { declineRequest(session: session) }) {
                            Text("Decline Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding()
            } else {
                Spacer()
                Text("Session not found")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
        .task {
            await loadAthlete()
        }
    }

    // MARK: - Helpers

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
            .padding(.vertical, 8)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
        .font(.subheadline)
    }

    // MARK: - Data

    private func loadAthlete() async {
        defer { isLoading = false }
        guard let session else { return }
        do {
            let fetched: PublicUser = try await rootView.client
                .from("profiles")
                .select("id, first_name, last_name, image_url, card_on_file")
                .eq("id", value: session.other.uuidString)
                .single()
                .execute()
                .value
            athlete = fetched
        } catch {
            print("Failed to load athlete:", error)
        }
    }

    // MARK: - Actions

    private func acceptRequest(session: Session, athlete: PublicUser) {
        let myId = rootView.profile.id
        // Update local state
        rootView.profile.coachUpcomingSessions.append(session)
        rootView.profile.currentAthletes[session.other] = Athletes(id: athlete.id, totalGained: 0, sessions: 0)
        rootView.profile.jobRequests.removeAll { $0 == session }

        Task {
            do {
                // 1. Send acceptance message
                let msg = MessageRow(
                    message: "Session request accepted",
                    senderId: myId,
                    receiverId: session.other,
                    request: session,
                    senderRole: true
                )
                try await rootView.client
                    .from("messages")
                    .insert(msg)
                    .execute()

                // 2. Update coach_profile: remove from job_requests, add to upcoming + current_athletes
                let coachPatch = CoachProfilePatch(
                    personal_quote: nil, coaching_achievements: nil,
                    coaching_experience: nil, time_availability: nil,
                    athlete_messaging: nil, individual_cost: nil,
                    group_cost: nil, sports: nil, sport_positions: nil,
                    cancellation_notice: nil,
                    coach_upcoming_sessions: rootView.profile.coachUpcomingSessions,
                    coach_unsubmitted_sessions: nil, coach_submitted_sessions: nil,
                    job_requests: rootView.profile.jobRequests,
                    interested_athletes: nil,
                    current_athletes: rootView.profile.currentAthletes,
                    reviews: nil, athlete_requests: nil, training_locations: nil
                )
                try await rootView.client
                    .from("coach_profile")
                    .update(coachPatch)
                    .eq("id", value: myId.uuidString)
                    .execute()

                // 3. Add to athlete's upcoming sessions
                let athleteRow: Profile = try await rootView.client
                    .from("profiles")
                    .select("id, first_name, last_name, coach_account, image_url, user_type, notifications, coach_messaging, athlete_upcoming_sessions, athlete_past_sessions, card_on_file, current_coaches, interested_coaches")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                var athleteSessions = athleteRow.athleteUpcomingSessions
                athleteSessions.append(session)
                let athletePatch = ProfileSessionPatch(
                    athlete_upcoming_sessions: athleteSessions,
                    athlete_past_sessions: nil
                )
                try await rootView.client
                    .from("profiles")
                    .update(athletePatch)
                    .eq("id", value: session.other.uuidString)
                    .execute()
            } catch {
                print("Failed to accept request:", error)
            }
        }
        rootView.path.removeLast()
    }

    private func sendOffer(session: Session, athlete: PublicUser) {
        Task {
            do {
                let msg = MessageRow(
                    message: "Sent you a session offer",
                    senderId: rootView.profile.id,
                    receiverId: session.other,
                    request: session,
                    senderRole: true
                )
                try await rootView.client
                    .from("messages")
                    .insert(msg)
                    .execute()
            } catch {
                print("Failed to send offer:", error)
            }
        }
        rootView.path.removeLast()
    }

    private func messageAthlete(athlete: PublicUser) {
        rootView.chatPartner = athlete
        rootView.path.removeLast()
        rootView.path.append("MessageAccount")
    }

    private func declineRequest(session: Session) {
        let myId = rootView.profile.id
        rootView.profile.jobRequests.removeAll { $0 == session }

        Task {
            do {
                let coachPatch = CoachProfilePatch(
                    personal_quote: nil, coaching_achievements: nil,
                    coaching_experience: nil, time_availability: nil,
                    athlete_messaging: nil, individual_cost: nil,
                    group_cost: nil, sports: nil, sport_positions: nil,
                    cancellation_notice: nil, coach_upcoming_sessions: nil,
                    coach_unsubmitted_sessions: nil, coach_submitted_sessions: nil,
                    job_requests: rootView.profile.jobRequests,
                    interested_athletes: nil,
                    current_athletes: nil, reviews: nil,
                    athlete_requests: nil, training_locations: nil
                )
                try await rootView.client
                    .from("coach_profile")
                    .update(coachPatch)
                    .eq("id", value: myId.uuidString)
                    .execute()
            } catch {
                print("Failed to decline request:", error)
            }
        }
        rootView.path.removeLast()
    }
}

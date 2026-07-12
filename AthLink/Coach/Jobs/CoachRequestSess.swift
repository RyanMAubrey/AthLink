import SwiftUI

struct CoachRequestSess: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var athlete: PublicUser?
    @State private var isLoading = true

    @State private var editMode = false
    @State private var editDate = Date()
    @State private var editEndDate = Date()
    @State private var editSport: Sports = .Football
    @State private var editType: GroupType = .Individual
    @State private var editRate: String = ""
    @State private var editNote: String = ""

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
                    VStack(spacing: 16) {
                        // Header
                        VStack(spacing: 8) {
                            if let urlStr = athlete.avatarURL,
                               let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Image("athlinklogo")
                                            .resizable()
                                            .scaledToFit()
                                    }
                                }
                                .frame(width: 64, height: 64)
                                .clipShape(Circle())
                            } else {
                                Image("athlinklogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .clipShape(Circle())
                            }

                            Text(athlete.fullName)
                                .font(.title3)
                                .fontWeight(.bold)

                            Text(isFromRequests ? "Session Request" : "Athlete Posting")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 24)

                        if editMode {
                            // Editable details card
                            VStack(spacing: 16) {
                                DatePicker("Start", selection: $editDate)
                                    .font(.subheadline)

                                DatePicker("End", selection: $editEndDate)
                                    .font(.subheadline)

                                HStack {
                                    Text("Sport")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Picker("Sport", selection: $editSport) {
                                        ForEach(Sports.allCases, id: \.self) { s in
                                            Text(s.description).tag(s)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                .font(.subheadline)

                                HStack {
                                    Text("Type")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Picker("Type", selection: $editType) {
                                        ForEach(GroupType.allCases, id: \.self) { t in
                                            Text(t.description).tag(t)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                .font(.subheadline)

                                HStack {
                                    Text("Rate ($/hr)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    Spacer()
                                TextField("0", text: $editRate)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.trailing)
                                        .font(.subheadline)
                                        .frame(width: 80)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    TextField("Add a note...", text: $editNote, axis: .vertical)
                                        .font(.subheadline)
                                        .lineLimit(3...6)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 24)
                        } else {
                            // Read-only details card
                            VStack(spacing: 0) {
                                detailRow(icon: "calendar", label: "Date & Time", value: athLinkSessionDateTime(session.date))
                                divider
                                detailRow(icon: "clock", label: "Time", value: "\(formatTime(session.date)) - \(formatTime(session.finished))")
                                divider
                                detailRow(icon: "figure.run", label: "Sport", value: session.sport.description)
                                divider
                                detailRow(icon: "person.2", label: "Type", value: session.type.description)
                                divider
                                detailRow(icon: "dollarsign.circle", label: "Rate", value: "\(athLinkWholeDollar(session.typeRate))/hr")
                                if session.location.name != "nan" {
                                    divider
                                    detailRow(icon: "mappin.circle", label: "Location", value: session.location.name)
                                }
                                if let desc = session.description, !desc.isEmpty {
                                    divider
                                    detailRow(icon: "text.quote", label: "Note", value: desc)
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 24)
                        }

                        if !editMode {
                            // Payment & request info card
                            VStack(spacing: 12) {
                                HStack(spacing: 6) {
                                    Image(systemName: athlete.hasPaymentMethod ? "creditcard.fill" : "creditcard")
                                        .foregroundColor(athlete.hasPaymentMethod ? .green : .orange)
                                    Text(athlete.hasPaymentMethod ? "Card on File" : "No Card on File")
                                        .fontWeight(.semibold)
                                        .foregroundColor(athlete.hasPaymentMethod ? .green : .orange)
                                    Spacer()
                                }
                                .font(.subheadline)

                                HStack {
                                    Text("Requested:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(session.reqDate.formatted(date: .abbreviated, time: .shortened))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                            .padding(.horizontal, 24)
                        }

                        // Cost summary
                        VStack(spacing: 12) {
                            let displayCost: Double = {
                                if editMode {
                                    let hours = editEndDate.timeIntervalSince(editDate) / 3600.0
                                    let rate = Double(editRate) ?? 0
                                    return max(0, hours * rate)
                                }
                                return session.cost
                            }()
                            HStack {
                                Text("Session Cost")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(athLinkWholeDollar(displayCost))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                            }
                            let commission = displayCost * 0.09
                            let payout = displayCost - commission
                            HStack {
                                Text("Commission (9%)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text("-\(athLinkWholeDollar(commission))")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)
                            HStack {
                                Text("Your Payout")
                                    .font(.headline)
                                Spacer()
                                Text(athLinkWholeDollar(payout))
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 24)
                    }
                    .padding(.bottom, 16)
                }
                .background(Color(.systemGroupedBackground))

                // Action Buttons
                VStack(spacing: 10) {
                    if isFromRequests {
                        Button(action: { acceptRequest(session: session, athlete: athlete) }) {
                            Text("Accept Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(12)
                    } else if editMode {
                        Button(action: { sendOffer(session: session, athlete: athlete) }) {
                            Text("Send Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(12)

                        Button(action: { editMode = false }) {
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .cornerRadius(12)
                    } else {
                        Button(action: { enterEditMode(session: session) }) {
                            Text("Send Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.borderedProminent)
                        .cornerRadius(12)
                    }

                    if !editMode {
                        Button(action: { messageAthlete(athlete: athlete) }) {
                            Text("Message Athlete")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .foregroundColor(.black)
                        .background(Color(.systemGray5))
                        .cornerRadius(12)
                    }

                    if isFromRequests {
                        Button(action: { declineRequest(session: session) }) {
                            Text("Decline Request")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
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

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    // MARK: - Data

    private func loadAthlete() async {
        defer { isLoading = false }
        guard let session else { return }
        do {
            let fetched: PublicUser = try await rootView.client
                .from("profiles")
                .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                .eq("id", value: session.other.uuidString)
                .single()
                .execute()
                .value
            athlete = fetched
        } catch {
            log.error("Failed to load athlete: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions

    private func acceptRequest(session: Session, athlete: PublicUser) {
        let myId = rootView.profile.id
        rootView.profile.coachUpcomingSessions.append(session)
        rootView.profile.currentAthletes[session.other] = Athletes(id: athlete.id, totalGained: 0, sessions: 0)
        rootView.profile.jobRequests.removeAll { $0 == session }

        Task {
            do {
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

                let coachPatch = CoachProfilePatch(
                    personal_quote: nil, coaching_achievements: nil,
                    coaching_experience: nil, time_availability: nil,
                    individual_cost: nil,
                    group_cost: nil, sports: nil, sport_positions: nil,
                    cancellation_notice: nil,
                    coach_upcoming_sessions: rootView.profile.coachUpcomingSessions,
                    coach_past_sessions: nil,
                    job_requests: rootView.profile.jobRequests,
                    current_athletes: rootView.profile.currentAthletes,
                    reviews: nil, athlete_requests: nil, training_locations: nil
                )
                try await rootView.client
                    .from("coach_profile")
                    .update(coachPatch)
                    .eq("id", value: myId.uuidString)
                    .execute()

                let athleteRow: Profile = try await rootView.client
                    .from("profiles")
                    .select("id, first_name, last_name, coach_account, image_url, user_type, athlete_upcoming_sessions, athlete_past_sessions, stripe_customer_id, has_payment_method, current_coaches, referral_code, referred_by, credits")
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

                await sendPushNotification(
                    client: rootView.client,
                    userId: session.other,
                    title: "Session Accepted",
                    body: "\(rootView.profile.fullName) accepted your session request"
                )
            } catch {
                log.error("Failed to accept request: \(error.localizedDescription)")
            }
        }
        rootView.path.removeLast()
    }

    private func enterEditMode(session: Session) {
        editDate = session.date
        editEndDate = session.finished
        editSport = session.sport
        editType = session.type
        editRate = "\(Int(session.typeRate.rounded()))"
        editNote = session.description ?? ""
        editMode = true
    }

    private func sendOffer(session: Session, athlete: PublicUser) {
        let rate = Double(editRate) ?? session.typeRate
        let editedSession = Session(
            reqDate: Date(),
            other: session.other,
            sport: editSport,
            type: editType,
            typeRate: rate,
            date: editDate,
            finished: editEndDate,
            location: session.location,
            description: editNote.isEmpty ? nil : editNote
        )

        Task {
            do {
                let msg = MessageRow(
                    message: "Sent you a session offer",
                    senderId: rootView.profile.id,
                    receiverId: session.other,
                    request: editedSession,
                    senderRole: true
                )
                try await rootView.client
                    .from("messages")
                    .insert(msg)
                    .execute()

                await sendPushNotification(
                    client: rootView.client,
                    userId: session.other,
                    title: "New Session Offer",
                    body: "\(rootView.profile.fullName) sent you a session offer"
                )
            } catch {
                log.error("Failed to send offer: \(error.localizedDescription)")
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
                    individual_cost: nil,
                    group_cost: nil, sports: nil, sport_positions: nil,
                    cancellation_notice: nil, coach_upcoming_sessions: nil,
                    coach_past_sessions: nil,
                    job_requests: rootView.profile.jobRequests,
                    current_athletes: nil, reviews: nil,
                    athlete_requests: nil, training_locations: nil
                )
                try await rootView.client
                    .from("coach_profile")
                    .update(coachPatch)
                    .eq("id", value: myId.uuidString)
                    .execute()

                await sendPushNotification(
                    client: rootView.client,
                    userId: session.other,
                    title: "Session Declined",
                    body: "\(rootView.profile.fullName) declined your session request"
                )
            } catch {
                log.error("Failed to decline request: \(error.localizedDescription)")
            }
        }
        rootView.path.removeLast()
    }
}

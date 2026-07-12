import SwiftUI

struct Chat: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var rows: [MessageRow] = []
    @State private var isLoading = true
    @State private var messageText = ""
    @State private var isSending = false
    @State private var showSessionRequestInfo = false

    private var partner: PublicUser? { rootView.chatPartner }
    private var myId: UUID { rootView.profile.id }
    private var partnerId: UUID? { partner?.id }
    private var isCoach: Bool { rootView.rootView == .Coach }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            chatHeader

            Divider()

            // Messages
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if rows.isEmpty {
                emptyState
            } else {
                messageList
            }

            Divider()

            // Input bar
            inputBar
        }
        .navigationBarBackButtonHidden(true)
        .task {
            await loadMessages()
        }
        .onAppear {
            Task { await loadMessages() }
        }
        .confirmationDialog("Send \(partner?.fullName ?? "this athlete") a session request?", isPresented: $showSessionRequestInfo, titleVisibility: .visible) {
            Button("Create Session Request") {
                rootView.lastPage = "Chat"
                rootView.path.append("Request")
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The session will be sent in this chat for them to accept before it is booked.")
        }
    }

    // MARK: - Header

    private var chatHeader: some View {
        HStack(spacing: 12) {
            // Back button
            Button(action: { rootView.path.removeLast() }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.primary)
            }

            // Avatar
            if let urlStr = partner?.avatarURL,
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
                .frame(width: 36, height: 36)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: 36, height: 36)
            }

            Text(partner?.fullName ?? "Chat")
                .font(.headline)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.4))
            Text("No messages yet")
                .font(.subheadline)
                .foregroundColor(.gray)
            Text("Send a message to start the conversation")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.7))
            Spacer()
        }
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(rows) { msg in
                        messageBubble(msg)
                            .id(msg.id)
                    }
                }
                .padding()
            }
            .onChange(of: rows.count) {
                if let last = rows.last?.id {
                    withAnimation {
                        proxy.scrollTo(last, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let last = rows.last?.id {
                    proxy.scrollTo(last, anchor: .bottom)
                }
            }
        }
    }

    // MARK: - Message Bubble

    @ViewBuilder
    private func messageBubble(_ msg: MessageRow) -> some View {
        let isMine = msg.senderId == myId

        HStack {
            if isMine { Spacer(minLength: 60) }

            VStack(alignment: isMine ? .trailing : .leading, spacing: 4) {
                // Session request card
                if msg.request != nil {
                    sessionRequestCard(msg, isMine: isMine)
                }

                // Text message
                if let text = msg.message, !text.isEmpty {
                    Text(text)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(isMine ? Color.blue : Color(.systemGray5))
                        .foregroundColor(isMine ? .white : .primary)
                        .cornerRadius(16)
                }

            }

            if !isMine { Spacer(minLength: 60) }
        }
    }

    // MARK: - Session Request Card
    @ViewBuilder
    private func sessionRequestCard(_ msg: MessageRow, isMine: Bool) -> some View {
        let session = msg.request!
        let isResolved = msg.resolved == true

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                Text("Session Request")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                if isResolved {
                    Text("Resolved")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(6)
                }
            }

            Divider()

            HStack {
                Text("Sport:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(session.sport.description)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            HStack {
                Text("Type:")
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(session.type.description)
                    .font(.caption)
                    .fontWeight(.medium)
            }

            HStack {
                Text("Date:")
                    .font(.caption)
                    .foregroundColor(.gray)
                    Text(athLinkSessionDateTime(session.date))
                        .font(.caption)
                        .fontWeight(.medium)
            }

            if session.typeRate > 0 {
                HStack {
                    Text("Rate:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text("\(athLinkWholeDollar(session.typeRate))/hr")
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }

            // Action buttons (only for receiver, only when not resolved)
            if !isMine && !isResolved {
                Divider()

                HStack(spacing: 8) {
                    Button(action: {
                        guard let msgId = msg.id, let session = msg.request else { return }
                        Task {
                            if let idx = rows.firstIndex(where: { $0.id == msg.id }) {
                                rows[idx].resolved = true
                            }

                            if isCoach {
                                rootView.profile.coachUpcomingSessions.append(session)
                            } else {
                                rootView.profile.athleteUpcomingSessions.append(session)
                            }

                            do {
                                if isCoach {
                                    let patch = CoachProfilePatch(
                                        personal_quote: nil, coaching_achievements: nil,
                                        coaching_experience: nil, time_availability: nil,
                                        individual_cost: nil,
                                        group_cost: nil, sports: nil, sport_positions: nil,
                                        cancellation_notice: nil,
                                        coach_upcoming_sessions: rootView.profile.coachUpcomingSessions,
                                        coach_past_sessions: nil, job_requests: nil,
                                        current_athletes: nil, reviews: nil,
                                        athlete_requests: nil, training_locations: nil
                                    )
                                    try await rootView.client
                                        .from("coach_profile")
                                        .update(patch)
                                        .eq("id", value: myId.uuidString)
                                        .execute()

                                    let theirProfile: Profile = try await rootView.client
                                        .from("profiles")
                                        .select("id, first_name, last_name, coach_account, image_url, user_type, athlete_upcoming_sessions, athlete_past_sessions, stripe_customer_id, has_payment_method, current_coaches, referral_code, referred_by, credits")
                                        .eq("id", value: msg.senderId.uuidString)
                                        .single()
                                        .execute()
                                        .value
                                    var theirSessions = theirProfile.athleteUpcomingSessions
                                    theirSessions.append(session)
                                    let theirPatch = ProfileSessionPatch(
                                        athlete_upcoming_sessions: theirSessions,
                                        athlete_past_sessions: nil
                                    )
                                    try await rootView.client
                                        .from("profiles")
                                        .update(theirPatch)
                                        .eq("id", value: msg.senderId.uuidString)
                                        .execute()
                                } else {
                                    let patch = ProfileSessionPatch(
                                        athlete_upcoming_sessions: rootView.profile.athleteUpcomingSessions,
                                        athlete_past_sessions: nil
                                    )
                                    try await rootView.client
                                        .from("profiles")
                                        .update(patch)
                                        .eq("id", value: myId.uuidString)
                                        .execute()

                                    let theirProfile: CoachProfile = try await rootView.client
                                        .from("coach_profile")
                                        .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, individual_cost, group_cost, sports, sport_positions, cancellation_notice, coach_upcoming_sessions, coach_past_sessions, job_requests, current_athletes, athlete_requests, training_locations, stripe_connect_id, completed_onboarding, completed_checkr")
                                        .eq("id", value: msg.senderId.uuidString)
                                        .single()
                                        .execute()
                                        .value
                                    var theirSessions = theirProfile.coachUpcomingSessions
                                    theirSessions.append(session)
                                    let theirPatch = CoachProfilePatch(
                                        personal_quote: nil, coaching_achievements: nil,
                                        coaching_experience: nil, time_availability: nil,
                                        individual_cost: nil,
                                        group_cost: nil, sports: nil, sport_positions: nil,
                                        cancellation_notice: nil,
                                        coach_upcoming_sessions: theirSessions,
                                        coach_past_sessions: nil, job_requests: nil,
                                        current_athletes: nil, reviews: nil,
                                        athlete_requests: nil, training_locations: nil
                                    )
                                    try await rootView.client
                                        .from("coach_profile")
                                        .update(theirPatch)
                                        .eq("id", value: msg.senderId.uuidString)
                                        .execute()
                                }

                                try await rootView.client
                                    .from("messages")
                                    .update(["resolved": true])
                                    .eq("id", value: msgId.uuidString)
                                    .execute()

                                await sendPushNotification(
                                    client: rootView.client,
                                    userId: msg.senderId,
                                    title: "Session Accepted",
                                    body: "\(rootView.profile.fullName) accepted your session request"
                                )
                            } catch {
                                log.error("Failed to accept session: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Accept")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        // Makes sure the message is good
                        guard let msgId = msg.id else { return }
                        Task {
                            // Finds where the message is in rows
                            if let idx = rows.firstIndex(where: { $0.id == msg.id }) {
                                rows[idx].resolved = true
                            }
                            do {
                                // Pushes to backend
                                try await rootView.client
                                    .from("messages")
                                    .update(["resolved": true])
                                    .eq("id", value: msgId.uuidString)
                                    .execute()

                                await sendPushNotification(
                                    client: rootView.client,
                                    userId: msg.senderId,
                                    title: "Session Declined",
                                    body: "\(rootView.profile.fullName) declined your session request"
                                )
                            } catch {
                                log.error("Failed to deny session: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        Text("Deny")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.85))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        guard let msgId = msg.id else { return }
                        Task {
                            if let idx = rows.firstIndex(where: { $0.id == msg.id }) {
                                rows[idx].resolved = true
                            }
                            do {
                                try await rootView.client
                                    .from("messages")
                                    .update(["resolved": true])
                                    .eq("id", value: msgId.uuidString)
                                    .execute()
                            } catch {
                                log.error("Failed to resolve for edit: \(error.localizedDescription)")
                            }
                        }
                        rootView.selectedJobSession = msg.request
                        rootView.lastPage = "Chat"
                        rootView.path.append("Request")
                    }) {
                        Text("Edit")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(12)
        .background(isResolved ? Color(.systemGray5) : Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isResolved ? Color.gray.opacity(0.2) : Color.blue.opacity(0.3), lineWidth: 1)
        )
        .opacity(isResolved ? 0.6 : 1.0)
    }

    // MARK: - Input Bar
    private var inputBar: some View {
        HStack(spacing: 10) {
            Button(action: {
                showSessionRequestInfo = true
            }) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }

            TextField("Message...", text: $messageText)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)

            Button(action: { Task { await sendMessage() } }) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(messageText.trimmingCharacters(in: .whitespaces).isEmpty || isSending ? .gray : .blue)
            }
            .disabled(messageText.trimmingCharacters(in: .whitespaces).isEmpty || isSending)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
    }

    // MARK: - Data

    private func loadMessages() async {
        defer { isLoading = false }
        guard let partnerId else { return }
        do {
            let fetched: [MessageRow] = try await rootView.client
                .from("messages")
                .select("id, message, created_at, sender_id, receiver_id, request, sender_role, resolved")
                .or("and(sender_id.eq.\(myId),receiver_id.eq.\(partnerId),sender_role.eq.\(isCoach)),and(sender_id.eq.\(partnerId),receiver_id.eq.\(myId),sender_role.eq.\(!isCoach))")
                .order("created_at", ascending: true)
                .execute()
                .value
            rows = fetched
        } catch {
            log.error("Failed to load chat: \(error.localizedDescription)")
        }
    }

    private func sendMessage() async {
        let text = messageText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty, let partnerId else { return }
        messageText = ""
        isSending = true
        defer { isSending = false }

        let newMsg = MessageRow(
            senderId: myId,
            receiverId: partnerId,
            senderRole: rootView.rootView == .Coach
        )
        // Insert with message text
        var msgWithText = newMsg
        msgWithText.message = text

        do {
            let inserted: MessageRow = try await rootView.client
                .from("messages")
                .insert(msgWithText)
                .select("id, message, created_at, sender_id, receiver_id, request, sender_role, resolved")
                .single()
                .execute()
                .value
            rows.append(inserted)
            await sendPushNotification(client: rootView.client, userId: partnerId, title: rootView.profile.fullName, body: text)
        } catch {
            log.error("Failed to send message: \(error.localizedDescription)")
            // Put text back so user doesn't lose it
            messageText = text
        }
    }
}

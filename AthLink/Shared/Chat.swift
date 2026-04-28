import SwiftUI

struct Chat: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var rows: [MessageRow] = []
    @State private var isLoading = true
    @State private var messageText = ""
    @State private var isSending = false

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
                if let session = msg.request {
                    sessionRequestCard(session, isMine: isMine)
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

                // Timestamp
                if let date = msg.createdAt {
                    Text(date, style: .relative)
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }

            if !isMine { Spacer(minLength: 60) }
        }
    }

    // MARK: - Session Request Card

    private func sessionRequestCard(_ session: Session, isMine: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
                Text("Session Request")
                    .font(.subheadline)
                    .fontWeight(.semibold)
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
                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .fontWeight(.medium)
            }

            if session.typeRate > 0 {
                HStack {
                    Text("Rate:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(String(format: "$%.2f/hr", session.typeRate))
                        .font(.caption)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Input Bar

    private var inputBar: some View {
        HStack(spacing: 10) {
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
                .select("id, message, created_at, sender_id, receiver_id, request, sender_role")
                .or("and(sender_id.eq.\(myId),receiver_id.eq.\(partnerId),sender_role.eq.\(isCoach)),and(sender_id.eq.\(partnerId),receiver_id.eq.\(myId),sender_role.eq.\(!isCoach))")
                .order("created_at", ascending: true)
                .execute()
                .value
            rows = fetched
        } catch {
            print("Failed to load chat:", error)
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
                .select("id, message, created_at, sender_id, receiver_id, request, sender_role")
                .single()
                .execute()
                .value
            rows.append(inserted)
        } catch {
            print("Failed to send message:", error)
            // Put text back so user doesn't lose it
            messageText = text
        }
    }
}

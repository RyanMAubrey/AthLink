import SwiftUI
import Supabase

struct Messages: View {
    @EnvironmentObject var rootView: RootViewObj
    @State var people: [(PublicUser, MessageRow)] = []

    @State private var isLoading = true
    @State private var searchText = ""

    private var filtered: [(PublicUser, MessageRow)] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return people
        }
        return people.filter {
            $0.0.fullName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Messages")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)

                Spacer()

                Text("\(people.count)")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.trailing)
            }
            .padding(.top)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search by name", text: $searchText)
                    .foregroundColor(.primary)
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)

            // Content
            if isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if filtered.isEmpty {
                VStack(spacing: 16) {
                    Spacer()

                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No Messages")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)

                    Text("Conversations will appear here")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.7))
                        .multilineTextAlignment(.center)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(filtered, id: \.0.id) { (profile, message) in
                            Button(action: {
                                // Set partner and append navigation
                                rootView.chatPartner = profile
                                rootView.path.append("MessageAccount")
                            }) {
                                ConversationCard(profile: profile, message: message, myId: rootView.profile.id)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            defer { isLoading = false }
            do {
                let myId = rootView.profile.id
                // Get every message you're involved in
                let rows: [MessageRow] = try await rootView.client
                    .from("messages")
                    .select("id, message, created_at, sender_id, receiver_id, request, sender_role")
                    .or("and(sender_id.eq.\(myId),sender_role.eq.\(rootView.rootView == .Coach)),and(receiver_id.eq.\(myId),sender_role.eq.\(rootView.rootView != .Coach))")
                    .order("created_at", ascending: false)
                    .execute()
                    .value

                // Find latest message for each unique partner
                var uniqueRow: [UUID: MessageRow] = [:]
                for row in rows {
                    let partner = (row.senderId == myId) ? row.receiverId : row.senderId
                    if uniqueRow[partner] == nil {
                        uniqueRow[partner] = row
                    }
                }

                // One batch fetch for all partner profiles
                let partnerIds = Array(uniqueRow.keys)
                guard !partnerIds.isEmpty else { return }
                let profiles: [PublicUser] = try await rootView.client
                    .from("profiles")
                    .select("id, first_name, last_name, image_url, card_on_file")
                    .in("id", values: partnerIds.map { $0.uuidString })
                    .execute()
                    .value

                // Match profiles to their latest message
                people = profiles.compactMap { profile in
                    guard let msg = uniqueRow[profile.id] else { return nil }
                    return (profile, msg)
                }
            } catch {
                print("Failed to load messages:", error)
            }
        }
    }
}

// Cobversation Card
struct ConversationCard: View {
    let profile: PublicUser
    let message: MessageRow
    let myId: UUID

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let urlStr = profile.avatarURL,
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
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .foregroundColor(.gray.opacity(0.5))
                    .frame(width: 50, height: 50)
            }

            // Name + preview
            VStack(alignment: .leading, spacing: 4) {
                Text(profile.fullName)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(message.request != nil ? "Session Request" : (message.message ?? ""))
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }

            Spacer()

            // Time + chevron
            VStack(alignment: .trailing, spacing: 6) {
                if let date = message.createdAt {
                    Text(date, style: .relative)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}


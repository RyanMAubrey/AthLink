import SwiftUI
import Supabase

struct CoachSession: View {
    @EnvironmentObject var rootView: RootViewObj
    @State var selectedTab: Int = 0

    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            HStack(spacing: 0) {
                tabButton(title: "Calendar", index: 0)
                tabButton(title: "Unsubmitted", index: 1)
                tabButton(title: "Submitted", index: 2)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            // Content
            Group {
                if selectedTab == 0 {
                    CoachCalendar()
                        .environmentObject(rootView)
                } else if selectedTab == 1 {
                    UnsubmittedTab()
                        .environmentObject(rootView)
                } else {
                    SubmittedTab()
                        .environmentObject(rootView)
                }
            }
        }
        .task {
            // Move expired sessions server-side, then refresh
            do {
                try await rootView.client.rpc("move_past_sessions").execute()
                try await rootView.loadProfile()
            } catch {
                print("Failed to move past sessions:", error)
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

    // MARK: - Unsubmitted Tab

    struct UnsubmittedTab: View {
        @EnvironmentObject var rootView: RootViewObj
        @State private var selectedSession: Session?

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("Unsubmitted")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()

                    Text("\(rootView.profile.coachUnsubmittedSessions.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                .padding(.top)

                if rootView.profile.coachUnsubmittedSessions.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No Unsubmitted Sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Text("Completed sessions awaiting submission will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(rootView.profile.coachUnsubmittedSessions, id: \.id) { session in
                                Button(action: { selectedSession = session }) {
                                    SessionCard(session: session, client: rootView.client)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                SubmitSheet(session: session, rootView: rootView)
            }
        }
    }

    // MARK: - Submit Sheet

    struct SubmitSheet: View {
        let session: Session
        @ObservedObject var rootView: RootViewObj
        @Environment(\.dismiss) var dismiss

        // Editable copies — don't persist unless submitted
        @State private var editType: GroupType
        @State private var editSport: Sports
        @State private var editStart: Date
        @State private var editEnd: Date
        @State private var editLocation: String

        @State private var athlete: PublicUser?

        init(session: Session, rootView: RootViewObj) {
            self.session = session
            self.rootView = rootView
            _editType = State(initialValue: session.type)
            _editSport = State(initialValue: session.sport)
            _editStart = State(initialValue: session.date)
            _editEnd = State(initialValue: session.finished)
            _editLocation = State(initialValue: session.location.name)
        }

        private var editedCost: Double {
            let seconds = editEnd.timeIntervalSince(editStart)
            guard seconds > 0 else { return 0 }
            return (seconds / 3600.0) * session.typeRate
        }

        private var editedTime: String {
            let fmt = DateFormatter()
            fmt.dateFormat = "h:mm a"
            return "\(fmt.string(from: editStart)) - \(fmt.string(from: editEnd))"
        }

        var body: some View {
            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                // Header
                HStack {
                    Button("Cancel") { dismiss() }
                        .fontWeight(.medium)
                        .foregroundColor(.red)
                    Spacer()
                    Text("Session Details")
                        .font(.headline)
                    Spacer()
                    Button("Submit") { submitSession() }
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)

                ScrollView {
                    VStack(spacing: 16) {
                        // Athlete card
                        if let athlete {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                    .frame(width: 44, height: 44)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(10)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Athlete")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text(athlete.fullName)
                                        .font(.headline)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                        }

                        // Details card
                        VStack(spacing: 0) {
                            // Cost
                            detailRow(icon: "dollarsign.circle", label: "Total") {
                                Text(String(format: "$%.2f", editedCost))
                                    .fontWeight(.semibold)
                                    .foregroundColor(.green)
                            }
                            sectionDivider

                            // Time
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "clock")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    Text("Time")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                DatePicker("Start", selection: $editStart, displayedComponents: [.hourAndMinute])
                                    .font(.subheadline)
                                DatePicker("End", selection: $editEnd, displayedComponents: [.hourAndMinute])
                                    .font(.subheadline)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            sectionDivider

                            // Type
                            detailRow(icon: "person.2", label: "Type") {
                                Picker("Type", selection: $editType) {
                                    Text("Individual").tag(GroupType.Individual)
                                    Text("Group").tag(GroupType.Group)
                                }
                                .pickerStyle(.menu)
                            }
                            sectionDivider

                            // Location
                            detailRow(icon: "mappin.circle", label: "Location") {
                                Text(editLocation)
                                    .fontWeight(.medium)
                            }
                            sectionDivider

                            // Sport
                            detailRow(icon: "figure.run", label: "Sport") {
                                Text(editSport.description)
                                    .fontWeight(.medium)
                            }
                            sectionDivider

                            // Date
                            detailRow(icon: "calendar", label: "Date") {
                                Text(session.date.formatted(date: .abbreviated, time: .omitted))
                                    .fontWeight(.medium)
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)

                        // Submit button
                        Button(action: { submitSession() }) {
                            Text("Submit to AthLink")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(.systemGroupedBackground))
            .task {
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
                    print("Failed to fetch athlete:", error)
                }
            }
        }

        private var sectionDivider: some View {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal)
        }

        private func detailRow<Content: View>(icon: String, label: String, @ViewBuilder content: () -> Content) -> some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                content()
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
        }

        private func submitSession() {
            // Build the edited session
            let submitted = Session(
                id: session.id,
                reqDate: session.reqDate,
                other: session.other,
                sport: editSport,
                type: editType,
                typeRate: session.typeRate,
                date: editStart,
                finished: editEnd,
                location: session.location,
                rate: session.rate,
                description: session.description
            )

            // Move from unsubmitted to submitted locally
            rootView.profile.coachUnsubmittedSessions.removeAll { $0.id == session.id }
            rootView.profile.coachSubmittedSessions.append(submitted)

            // Persist to Supabase
            Task {
                do {
                    let patch = CoachProfilePatch(
                        personal_quote: nil, coaching_achievements: nil,
                        coaching_experience: nil, time_availability: nil,
                        athlete_messaging: nil, individual_cost: nil,
                        group_cost: nil, sports: nil, sport_positions: nil,
                        cancellation_notice: nil, coach_upcoming_sessions: nil,
                        coach_unsubmitted_sessions: rootView.profile.coachUnsubmittedSessions,
                        coach_submitted_sessions: rootView.profile.coachSubmittedSessions,
                        job_requests: nil,
                        interested_athletes: nil, current_athletes: nil,
                        reviews: nil, athlete_requests: nil, training_locations: nil
                    )
                    try await rootView.client
                        .from("coach_profile")
                        .update(patch)
                        .eq("id", value: rootView.profile.id.uuidString)
                        .execute()
                } catch {
                    print("Failed to submit session:", error)
                }
            }
            dismiss()
        }
    }

    // MARK: - Submitted Tab

    struct SubmittedTab: View {
        @EnvironmentObject var rootView: RootViewObj
        @State private var selectedSession: Session?

        var body: some View {
            VStack(alignment: .leading) {
                HStack {
                    Text("Submitted")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.leading)

                    Spacer()

                    Text("\(rootView.profile.coachSubmittedSessions.count)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .padding(.trailing)
                }
                .padding(.top)

                if rootView.profile.coachSubmittedSessions.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))
                        Text("No Submitted Sessions")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                        Text("Sessions submitted for payment will appear here")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(rootView.profile.coachSubmittedSessions, id: \.id) { session in
                                Button(action: { selectedSession = session }) {
                                    SessionCard(session: session, client: rootView.client)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .sheet(item: $selectedSession) { session in
                CoachReceiptSheet(session: session, rootView: rootView)
            }
        }
    }

    // MARK: - Coach Receipt Sheet

    struct CoachReceiptSheet: View {
        let session: Session
        @ObservedObject var rootView: RootViewObj
        @Environment(\.dismiss) var dismiss

        @State private var athlete: PublicUser?

        private var commission: Double { session.cost * 0.09 }
        private var payout: Double { session.cost - commission }

        private var pdfURL: URL {
            let data = coachReceiptPDF()
            let tmp = FileManager.default.temporaryDirectory
                .appendingPathComponent("coach-receipt.pdf")
            try? data.write(to: tmp)
            return tmp
        }

        var body: some View {
            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(.systemGray4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.green)
                    Text("Session Submitted")
                        .font(.title3)
                        .fontWeight(.bold)
                    if let athlete {
                        Text("with \(athlete.fullName)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()

                // Details
                VStack(spacing: 0) {
                    receiptRow(icon: "calendar", label: "Date", value: session.date.formatted(date: .abbreviated, time: .omitted))
                    divider
                    receiptRow(icon: "clock", label: "Time", value: "\(session.totalTime.0)h \(session.totalTime.1)m")
                    divider
                    receiptRow(icon: "figure.run", label: "Sport", value: session.sport.description)
                    divider
                    receiptRow(icon: "person.2", label: "Type", value: session.type.description)
                    divider
                    receiptRow(icon: "mappin.circle", label: "Location", value: session.location.name)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)

                // Earnings breakdown
                VStack(spacing: 10) {
                    HStack {
                        Text("Session Cost")
                            .font(.subheadline)
                        Spacer()
                        Text(String(format: "$%.2f", session.cost))
                            .font(.subheadline)
                    }
                    HStack {
                        Text("Commission (9%)")
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Spacer()
                        Text(String(format: "-$%.2f", commission))
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 1)
                    HStack {
                        Text("Your Payout")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "$%.2f", payout))
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                .padding(.top, 12)

                Spacer()

                // Actions
                VStack(spacing: 10) {
                    ShareLink(item: pdfURL) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Save or Share Receipt")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }

                    Button("Done") { dismiss() }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
            .task {
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
                    print("Failed to fetch athlete:", error)
                }
            }
        }

        private var divider: some View {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
        }

        private func receiptRow(icon: String, label: String, value: String) -> some View {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .frame(width: 24)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.vertical, 6)
        }

        private func coachReceiptPDF() -> Data {
            let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
            let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
            return renderer.pdfData { context in
                context.beginPage()
                let athleteName = athlete?.fullName ?? "Athlete"
                let text = """
                           Coach Receipt
                           -------------
                           Athlete: \(athleteName)
                           Date:    \(session.date.formatted(.dateTime.month().day().year()))
                           Type:    \(session.type.description)
                           Sport:   \(session.sport.description)
                           Location: \(session.location.name)
                           Duration: \(session.totalTime.0)h \(session.totalTime.1)m

                           Session Cost:    \(String(format: "$%.2f", session.cost))
                           Commission (9%): \(String(format: "-$%.2f", commission))
                           -------------
                           Your Payout:     \(String(format: "$%.2f", payout))
                           """
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 18),
                    .paragraphStyle: {
                        let style = NSMutableParagraphStyle()
                        style.alignment = .left
                        return style
                    }()
                ]
                let textArea = pageSize.insetBy(dx: 40, dy: 40)
                text.draw(in: textArea, withAttributes: attributes)
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
            .task {
                await loadAthlete()
            }
        }

        private func loadAthlete() async {
            do {
                let fetched: PublicUser = try await client
                    .from("profiles")
                    .select("id, first_name, last_name, image_url, card_on_file")
                    .eq("id", value: session.other.uuidString)
                    .single()
                    .execute()
                    .value
                athlete = fetched
                isLoading = false
            } catch {
                print("Failed to fetch athlete:", error)
                isLoading = false
            }
        }
    }
}

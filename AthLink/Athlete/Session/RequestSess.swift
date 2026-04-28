import SwiftUI
import MapKit

struct RequestSess: View {
    @EnvironmentObject var rootView: RootViewObj
    @Environment(\.dismiss) var dismiss

    // Determine mode: direct request to coach vs general posting
    private var isDirectRequest: Bool {
        rootView.lastPage == "Search" && rootView.selectedSession != nil
    }
    private var targetCoach: ProfileID? {
        isDirectRequest ? rootView.selectedSession : nil
    }

    // Form fields
    @State private var sport: Sports = .Football
    @State private var sessionType: GroupType = .Individual
    @State private var typeRate: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    @State private var description: String = ""
    @State private var location: structLocation? = nil

    // Map / location search
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var camera: MapCameraPosition = .automatic

    // State
    @State private var isSaving = false
    @State private var showDeleteAlert = false

    // Post mode only
    private var isEditingPost: Bool {
        !isDirectRequest && rootView.profile.postedSession != nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Image(systemName: isDirectRequest ? "paperplane.fill" : "doc.text.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.blue)
                    if let coach = targetCoach {
                        Text("Send \(coach.fullName) a request")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("with your needs")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    } else {
                        Text(isEditingPost ? "Edit Your Session" : "Post a Session")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Coaches in your area will see this posting")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0.4627, green: 0.8392, blue: 1.0).opacity(0.15))

                VStack(spacing: 16) {
                    // Description
                    VStack(alignment: .leading, spacing: 6) {
                        Text(isDirectRequest ? "Message (optional)" : "Description (optional)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        TextEditor(text: $description)
                            .frame(minHeight: 80)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                Group {
                                    if description.isEmpty {
                                        Text(isDirectRequest ? "Give any request (optional)" : "Describe what you're looking for...")
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 12)
                                    }
                                },
                                alignment: .topLeading
                            )
                    }

                    divider

                    // Start Date
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Session Time")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        DatePicker("Start", selection: $startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        DatePicker("End", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
                    }

                    divider

                    // Location
                    locationSection

                    divider

                    // Sport
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sport")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Picker("Sport", selection: $sport) {
                            Text("Football").tag(Sports.Football)
                        }
                        .pickerStyle(.segmented)
                    }

                    divider

                    // Session Type
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Session Type")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.gray)
                        Picker("Type", selection: $sessionType) {
                            Text("Individual").tag(GroupType.Individual)
                            Text("Group").tag(GroupType.Group)
                        }
                        .pickerStyle(.segmented)
                    }

                    // Hourly rate — only for posting mode
                    if !isDirectRequest {
                        divider

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Max Hourly Rate")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            HStack {
                                Text("$")
                                    .foregroundColor(.gray)
                                TextField("0.00", text: $typeRate)
                                    .keyboardType(.decimalPad)
                                Text("/hr")
                                    .foregroundColor(.gray)
                            }
                            .padding(10)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                }
                .padding()

                // Action buttons
                VStack(spacing: 10) {
                    Button(action: { Task { await submitAction() } }) {
                        if isSaving {
                            ProgressView()
                                .tint(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        } else {
                            Text(buttonTitle)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                    }
                    .background(canSubmit ? Color.blue : Color.gray)
                    .cornerRadius(12)
                    .disabled(!canSubmit || isSaving)

                    if isEditingPost {
                        Button(action: { showDeleteAlert = true }) {
                            Text("Delete Request")
                                .fontWeight(.semibold)
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                        }
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear { prefill() }
        .alert("Delete Session Post?", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await deletePost() }
            }
        } message: {
            Text("This will remove your posted session. Coaches will no longer see it.")
        }
    }

    // MARK: - Location Section

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Training Location")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)

            // Coach's training locations (direct request mode)
            if isDirectRequest, let coach = targetCoach, !coach.trainingLocations.isEmpty {
                ForEach(coach.trainingLocations) { loc in
                    Button {
                        location = loc
                        camera = .region(MKCoordinateRegion(
                            center: loc.coordinate,
                            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                        ))
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: location?.id == loc.id ? "mappin.circle.fill" : "mappin.circle")
                                .foregroundColor(location?.id == loc.id ? .blue : .gray)
                            Text(loc.name)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Spacer()
                            if location?.id == loc.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                        .padding(10)
                        .background(location?.id == loc.id ? Color.blue.opacity(0.1) : Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }

                Text("Or search for another location:")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Current selection (non-coach location)
            if let loc = location,
               !(isDirectRequest && (targetCoach?.trainingLocations.contains(where: { $0.id == loc.id }) ?? false)) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                    Text(loc.name)
                        .font(.subheadline)
                        .lineLimit(2)
                    Spacer()
                    Button(action: { location = nil }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red.opacity(0.7))
                    }
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search for a location", text: $searchText)
                    .onSubmit {
                        Task {
                            isSearching = true
                            searchResults = await mapSearch(for: searchText)
                            isSearching = false
                        }
                    }
            }
            .padding(10)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if isSearching {
                HStack {
                    ProgressView().tint(.blue)
                    Text("Searching...")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.vertical, 4)
            }

            // Search results
            if !searchResults.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(searchResults.prefix(6), id: \.self) { item in
                        Button {
                            let newLoc = structLocation(mapItem: item)
                            location = newLoc
                            camera = .region(MKCoordinateRegion(
                                center: newLoc.coordinate,
                                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                            ))
                            searchText = ""
                            searchResults = []
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(item.name ?? "Unknown place")
                                        .foregroundColor(.primary)
                                    if let subtitle = item.placemark.title {
                                        Text(subtitle)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                Spacer()
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.blue)
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 10)
                        }
                        .buttonStyle(.plain)
                        Divider()
                    }
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10).stroke(Color(.separator), lineWidth: 1)
                )
            }

            // Map preview
            if location != nil {
                Map(position: $camera) {
                    if let loc = location {
                        Marker(loc.name, coordinate: loc.coordinate)
                    }
                }
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .mapStyle(.hybrid)
            }
        }
    }

    // MARK: - Helpers

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
    }

    private var buttonTitle: String {
        if isDirectRequest {
            return "Submit Request"
        }
        return isEditingPost ? "Edit Request" : "Submit Request"
    }

    private var canSubmit: Bool {
        if isDirectRequest {
            return endDate > startDate && location != nil
        }
        guard let rate = Double(typeRate), rate > 0 else { return false }
        return endDate > startDate && location != nil
    }

    private func prefill() {
        if isDirectRequest {
            // Default to current location for direct requests
            setDefaultLocation()
            return
        }
        // Post mode: prefill from existing post
        guard let existing = rootView.profile.postedSession else {
            setDefaultLocation()
            return
        }
        sport = existing.sport
        sessionType = existing.type
        typeRate = String(format: "%.2f", existing.typeRate)
        startDate = existing.date
        endDate = existing.finished
        description = existing.description ?? ""
        location = existing.location
        camera = .region(MKCoordinateRegion(
            center: existing.location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        ))
    }

    private func setDefaultLocation() {
        if let cl = rootView.currentLocation {
            Task {
                let placemarks = try? await CLGeocoder().reverseGeocodeLocation(cl)
                let name = placemarks?.first?.name ?? placemarks?.first?.locality ?? "Current Location"
                location = structLocation(
                    coordinate: cl.coordinate,
                    name: name
                )
                camera = .region(MKCoordinateRegion(
                    center: cl.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                ))
            }
        }
    }

    // MARK: - Map Search

    private func mapSearch(for query: String) async -> [MKMapItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        do {
            let response = try await MKLocalSearch(request: request).start()
            return response.mapItems
        } catch {
            return []
        }
    }

    // MARK: - Actions

    private func submitAction() async {
        if isDirectRequest {
            await sendDirectRequest()
        } else {
            await submitOrUpdatePost()
        }
    }

    /// Direct request: adds Session to coach's job_requests and sends a message
    private func sendDirectRequest() async {
        guard let coach = targetCoach, let loc = location else { return }
        isSaving = true
        defer { isSaving = false }

        let myId = rootView.profile.id
        let rate: Double = coach.individualCost ?? coach.groupCost ?? 0

        let session = Session(
            reqDate: Date(),
            other: myId,
            sport: sport,
            type: sessionType,
            typeRate: sessionType == .Individual ? (coach.individualCost ?? 0) : (coach.groupCost ?? 0),
            date: startDate,
            finished: endDate,
            location: loc,
            rate: rate,
            description: description.isEmpty ? nil : description
        )

        do {
            // 1. Fetch coach's current job_requests
            let coachRow: CoachProfile = try await rootView.client
                .from("coach_profile")
                .select("id, personal_quote, coaching_achievements, coaching_experience, time_availability, athlete_messaging, individual_cost, group_cost, sports, sport_positions, cancellation_notice, coach_upcoming_sessions, coach_unsubmitted_sessions, coach_submitted_sessions, job_requests, interested_athletes, current_athletes, athlete_requests, training_locations")
                .eq("id", value: coach.id.uuidString)
                .single()
                .execute()
                .value

            var updatedRequests = coachRow.jobRequests
            updatedRequests.append(session)

            // 2. Update coach's job_requests
            let patch = CoachProfilePatch(
                personal_quote: nil, coaching_achievements: nil,
                coaching_experience: nil, time_availability: nil,
                athlete_messaging: nil, individual_cost: nil,
                group_cost: nil, sports: nil, sport_positions: nil,
                cancellation_notice: nil, coach_upcoming_sessions: nil,
                coach_unsubmitted_sessions: nil, coach_submitted_sessions: nil,
                job_requests: updatedRequests,
                interested_athletes: nil, current_athletes: nil,
                reviews: nil, athlete_requests: nil, training_locations: nil
            )
            try await rootView.client
                .from("coach_profile")
                .update(patch)
                .eq("id", value: coach.id.uuidString)
                .execute()

            // 3. Send a message with the session request attached
            let msg = MessageRow(
                message: description.isEmpty ? "Session request" : description,
                senderId: myId,
                receiverId: coach.id,
                request: session,
                senderRole: false
            )
            try await rootView.client
                .from("messages")
                .insert(msg)
                .execute()

            rootView.path.removeLast()
        } catch {
            print("Failed to send session request:", error)
        }
    }

    /// Post mode: upsert to posted_sessions
    private func submitOrUpdatePost() async {
        guard let loc = location, let rate = Double(typeRate) else { return }
        isSaving = true
        defer { isSaving = false }

        let upsert = PostedSessionUpsert(
            id: rootView.profile.id,
            sport: sport,
            type: sessionType,
            typeRate: rate,
            startDate: startDate,
            finishDate: endDate,
            location: loc,
            description: description.isEmpty ? nil : description,
            lat: loc.coordinate.latitude,
            long: loc.coordinate.longitude
        )

        do {
            try await rootView.client
                .from("posted_sessions")
                .upsert(upsert)
                .execute()

            rootView.profile.postedSession = Session(
                id: rootView.profile.id,
                reqDate: Date(),
                other: rootView.profile.id,
                sport: sport,
                type: sessionType,
                typeRate: rate,
                date: startDate,
                finished: endDate,
                location: loc,
                rate: 0,
                description: description.isEmpty ? nil : description
            )
            rootView.path.removeLast()
        } catch {
            print("Failed to upsert posted session:", error)
        }
    }

    private func deletePost() async {
        do {
            try await rootView.client
                .from("posted_sessions")
                .delete()
                .eq("id", value: rootView.profile.id.uuidString)
                .execute()

            rootView.profile.postedSession = nil
            rootView.path.removeLast()
        } catch {
            print("Failed to delete posted session:", error)
        }
    }
}

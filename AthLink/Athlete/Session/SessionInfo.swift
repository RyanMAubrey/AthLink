import SwiftUI
import UIKit
import PDFKit

extension URL: @retroactive Identifiable {
    public var id: URL { self }
}

struct SessionInfo: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var receiptURL: URL?
    @State private var tempRev: Review?
    @State private var reviewRating: Float = 0
    @State private var reviewComment: String = ""
    @State private var isLoading = true
    @State private var fetchedCoach: PublicUser?
    @State private var existingReview: Review?
    @State private var coachRatings: CoachRating?
    @State private var reviewChecked = false
    @State private var removeSessionMessage: Bool = false
    @State private var editMode: Bool = false
    @State private var editDate: Date = Date()
    @State private var editEndDate: Date = Date()
    @State private var editSport: Sports = .Football
    @State private var editType: GroupType = .Individual
    @State private var editNote: String = ""

    var body: some View {
        if let sa = rootView.selectedAthleteSession, let fc = fetchedCoach {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: sa.sf)
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                        Text("Session with \(fc.fullName)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(sa.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)

                    // Details card
                    Group {
                    if !editMode {
                        VStack(spacing: 0) {
                            detailRow(icon: "calendar", label: "Date", value: sa.date.formatted(date: .abbreviated, time: .omitted))
                            divider
                            detailRow(icon: "clock", label: "Time", value: "\(formatTime(sa.date)) - \(formatTime(sa.finished))")
                            divider
                            detailRow(icon: "timer", label: "Duration", value: "\(sa.totalTime.0)h \(sa.totalTime.1)m")
                            divider
                            detailRow(icon: "figure.run", label: "Sport", value: sa.sport.description)
                            divider
                            detailRow(icon: "person.2", label: "Type", value: sa.type.description)
                            divider
                            detailRow(icon: "mappin.circle", label: "Location", value: sa.location.name)
                            if let desc = sa.description, !desc.isEmpty {
                                divider
                                detailRow(icon: "text.quote", label: "Note", value: desc)
                            }
                        }
                    } else {
                        VStack(spacing: 12) {
                            DatePicker("Start", selection: $editDate, in: Date()...)
                                .font(.subheadline)

                            DatePicker("End", selection: $editEndDate, in: editDate...)
                                .font(.subheadline)

                            HStack {
                                Image(systemName: "figure.run")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Sport")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Picker("", selection: $editSport) {
                                    ForEach(Sports.allCases, id: \.self) { sport in
                                        Text(sport.description).tag(sport)
                                    }
                                }
                                .tint(.primary)
                            }

                            HStack {
                                Image(systemName: "person.2")
                                    .foregroundColor(.blue)
                                    .frame(width: 24)
                                Text("Type")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Picker("", selection: $editType) {
                                    ForEach(GroupType.allCases, id: \.self) { type in
                                        Text(type.description).tag(type)
                                    }
                                }
                                .tint(.primary)
                            }

                            divider

                            VStack(alignment: .leading, spacing: 6) {
                                HStack {
                                    Image(systemName: "text.quote")
                                        .foregroundColor(.blue)
                                        .frame(width: 24)
                                    Text("Note")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                TextField("Add a note...", text: $editNote)
                                    .font(.subheadline)
                                    .padding(10)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)

                    // Receipt card (past sessions only)
                    if !rootView.sessType {
                        let price = sa.cost
                        let tax = price * 0.0875
                        let commission = price * 0.09
                        let total = price + tax + commission

                        VStack(spacing: 12) {
                            HStack {
                                Text("Receipt")
                                    .font(.headline)
                                Spacer()
                            }

                            receiptRow(label: "Session Cost", value: String(format: "$%.2f", price))
                            receiptRow(label: "Sales Tax (8.75%)", value: String(format: "$%.2f", tax))
                            receiptRow(label: "Service Fee (9%)", value: String(format: "$%.2f", commission))

                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 1)

                            HStack {
                                Text("Total")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", total))
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }

                            Button(action: {
                                let pdfData = receiptPDF(session: sa, coach: fc)
                                let tmp = FileManager.default.temporaryDirectory
                                    .appendingPathComponent("session-receipt.pdf")
                                do {
                                    try pdfData.write(to: tmp)
                                    receiptURL = tmp
                                } catch {
                                    log.error("Failed to write PDF: \(error.localizedDescription)")
                                }
                            }) {
                                HStack {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Save or Share Receipt")
                                        .fontWeight(.semibold)
                                }
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 24)
                    }

                    // Review section (past sessions only)
                    if !rootView.sessType && reviewChecked {
                        VStack(spacing: 12) {
                            HStack {
                                Text("Review")
                                    .font(.headline)
                                Spacer()
                                if let coachRatings {
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.yellow)
                                            .font(.caption)
                                        Text(String(format: "%.1f", coachRatings.avgStar))
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                        Text("(\(coachRatings.reviewCount))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }

                            if let existing = existingReview {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 2) {
                                        ForEach(0..<5) { index in
                                            let threshold = Float(index) + 1
                                            if existing.star >= threshold {
                                                Image(systemName: "star.fill")
                                                    .foregroundColor(.yellow)
                                            } else if existing.star >= threshold - 0.5 {
                                                Image(systemName: "star.leadinghalf.fill")
                                                    .foregroundColor(.yellow)
                                            } else {
                                                Image(systemName: "star")
                                                    .foregroundColor(.gray.opacity(0.4))
                                            }
                                        }
                                        .font(.body)
                                    }

                                    if !existing.quote.isEmpty {
                                        Text(existing.quote)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }

                                    HStack {
                                        Text(existing.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                        Spacer()
                                        Button(action: { tempRev = existing }) {
                                            Text("Edit")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                            } else {
                                Button(action: {
                                    tempRev = Review(id: UUID(), coach: sa.other, reviewer: rootView.profile.id, date: Date(), star: 0.00, quote: "")
                                }) {
                                    HStack {
                                        Image(systemName: "star.bubble")
                                        Text("Leave a Review")
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 24)
                    }
                    // Actions (upcoming sessions only)
                    if rootView.sessType {
                        VStack(spacing: 10) {
                            if editMode {
                                Button(action: {
                                    Task {
                                        do {
                                            var updatedSession = sa
                                            updatedSession.date = editDate
                                            updatedSession.finished = editEndDate
                                            updatedSession.sport = editSport
                                            updatedSession.type = editType
                                            updatedSession.description = editNote.isEmpty ? nil : editNote

                                            // Update my local athlete sessions
                                            if let index = rootView.profile.athleteUpcomingSessions.firstIndex(where: { $0.id == sa.id }) {
                                                rootView.profile.athleteUpcomingSessions[index] = updatedSession
                                            }

                                            // Push to my profiles table
                                            let athletePatch = ProfileSessionPatch(
                                                athlete_upcoming_sessions: rootView.profile.athleteUpcomingSessions,
                                                athlete_past_sessions: nil
                                            )
                                            try await rootView.client
                                                .from("profiles")
                                                .update(athletePatch)
                                                .eq("id", value: rootView.profile.id.uuidString)
                                                .execute()

                                            // Fetch coach's profile
                                            let theirProfile: CoachProfile = try await rootView.client
                                                .from("coach_profile")
                                                .select()
                                                .eq("id", value: sa.other.uuidString)
                                                .single()
                                                .execute()
                                                .value

                                            // Replace session in their upcoming list
                                            var updatedCoachSessions = theirProfile.coachUpcomingSessions
                                            if let index = updatedCoachSessions.firstIndex(where: { $0.id == sa.id }) {
                                                updatedCoachSessions[index] = updatedSession
                                            }

                                            // Push to their coach_profile table
                                            let coachPatch = CoachProfilePatch(
                                                personal_quote: nil, coaching_achievements: nil,
                                                coaching_experience: nil, time_availability: nil,
                                                individual_cost: nil,
                                                group_cost: nil, sports: nil, sport_positions: nil,
                                                cancellation_notice: nil,
                                                coach_upcoming_sessions: updatedCoachSessions,
                                                coach_past_sessions: nil,
                                                job_requests: nil,
                                                current_athletes: nil, reviews: nil,
                                                athlete_requests: nil, training_locations: nil
                                            )
                                            try await rootView.client
                                                .from("coach_profile")
                                                .update(coachPatch)
                                                .eq("id", value: sa.other.uuidString)
                                                .execute()

                                            rootView.selectedAthleteSession = updatedSession
                                            editMode = false
                                        } catch {
                                            log.error("Failed to edit session: \(error.localizedDescription)")
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                        Text("Save Changes")
                                            .fontWeight(.semibold)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue)
                                    .cornerRadius(12)
                                }

                                Button(action: {
                                    editMode = false
                                }) {
                                    Text("Discard Changes")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.gray)
                                }
                            } else {
                                Button(action: {
                                    editDate = sa.date
                                    editEndDate = sa.finished
                                    editSport = sa.sport
                                    editType = sa.type
                                    editNote = sa.description ?? ""
                                    editMode = true
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                        Text("Edit Session")
                                            .fontWeight(.semibold)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                                }

                                Button(action: {
                                    removeSessionMessage = true
                                }) {
                                    HStack {
                                        Image(systemName: "xmark.circle")
                                        Text("Cancel Session")
                                            .fontWeight(.semibold)
                                    }
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(12)
                                }
                                .alert("Cancel Session?", isPresented: $removeSessionMessage) {
                                    Button("Keep", role: .cancel) { }
                                    Button("Cancel Session", role: .destructive) {
                                        Task {
                                            do {
                                                // Remove from my local athlete sessions
                                                rootView.profile.athleteUpcomingSessions.removeAll { $0.id == sa.id }

                                                // Push to my profiles table
                                                let athletePatch = ProfileSessionPatch(
                                                    athlete_upcoming_sessions: rootView.profile.athleteUpcomingSessions,
                                                    athlete_past_sessions: nil
                                                )
                                                try await rootView.client
                                                    .from("profiles")
                                                    .update(athletePatch)
                                                    .eq("id", value: rootView.profile.id.uuidString)
                                                    .execute()

                                                // Fetch coach's profile
                                                let theirProfile: CoachProfile = try await rootView.client
                                                    .from("coach_profile")
                                                    .select()
                                                    .eq("id", value: sa.other.uuidString)
                                                    .single()
                                                    .execute()
                                                    .value

                                                // Remove session from their upcoming list
                                                var updatedCoachSessions = theirProfile.coachUpcomingSessions
                                                updatedCoachSessions.removeAll { $0.id == sa.id }

                                                // Push to their coach_profile table
                                                let coachPatch = CoachProfilePatch(
                                                    personal_quote: nil, coaching_achievements: nil,
                                                    coaching_experience: nil, time_availability: nil,
                                                    individual_cost: nil,
                                                    group_cost: nil, sports: nil, sport_positions: nil,
                                                    cancellation_notice: nil,
                                                    coach_upcoming_sessions: updatedCoachSessions,
                                                    coach_past_sessions: nil,
                                                    job_requests: nil,
                                                    current_athletes: nil, reviews: nil,
                                                    athlete_requests: nil, training_locations: nil
                                                )
                                                try await rootView.client
                                                    .from("coach_profile")
                                                    .update(coachPatch)
                                                    .eq("id", value: sa.other.uuidString)
                                                    .execute()
                                            } catch {
                                                log.error("Failed to cancel session: \(error.localizedDescription)")
                                            }
                                            rootView.path.removeLast()
                                        }
                                    }
                                } message: {
                                    Text("This will permanently delete the session for both coach and athlete.")
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.bottom, 32)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(rootView.sessType ? "Upcoming Session" : "Past Session")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $receiptURL) { url in
                ShareLink(item: url) {
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
                    .padding()
                }
                .presentationDetents([.height(120)])
            }
            .sheet(item: $tempRev) { _ in
                reviewSheet(session: sa)
            }
            .task { await loadReviewData() }
        } else {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .task { await loadCoach() }
        }
    }

    private func reviewSheet(session: Session) -> some View {
        VStack(spacing: 16) {
            Capsule()
                .fill(Color(.systemGray4))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            Text(existingReview != nil ? "Edit Review" : "Leave a Review")
                .font(.title3)
                .fontWeight(.bold)

            if let coachRatings {
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text(String(format: "%.1f", coachRatings.avgStar))
                        .font(.headline)
                    Text("(\(coachRatings.reviewCount) reviews)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }

            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your Rating")
                    .font(.subheadline)
                    .fontWeight(.medium)
                HStack {
                    Slider(value: $reviewRating, in: 0...5, step: 0.5)
                        .tint(.blue)
                    Text(String(format: "%.1f", reviewRating))
                        .font(.headline)
                        .frame(width: 40)
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your Comment")
                    .font(.subheadline)
                    .fontWeight(.medium)
                TextEditor(text: $reviewComment)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .overlay(
                        Group {
                            if reviewComment.isEmpty {
                                Text("Write your review here...")
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 12)
                            }
                        },
                        alignment: .topLeading
                    )
            }
            .padding(.horizontal)

            Button(existingReview != nil ? "Update Review" : "Submit Review") {
                Task {
                    var success = false
                    if let existing = existingReview {
                        success = await updateReview(
                            client: rootView.client,
                            reviewID: existing.id,
                            star: reviewRating,
                            quote: reviewComment
                        )
                    } else {
                        success = await submitReview(
                            client: rootView.client,
                            coachID: session.other,
                            reviewerID: rootView.profile.id,
                            star: reviewRating,
                            quote: reviewComment
                        )
                    }
                    if success {
                        let reviewId = existingReview?.id ?? UUID()
                        existingReview = Review(id: reviewId, coach: session.other, reviewer: rootView.profile.id, date: Date(), star: reviewRating, quote: reviewComment)
                        coachRatings = await getCoachRating(client: rootView.client, coachID: session.other)
                    }
                    tempRev = nil
                }
            }
            .disabled(reviewRating == 0)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(reviewRating > 0 ? Color.blue : Color.gray)
            .cornerRadius(12)
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .presentationDetents([.height(480)])
        .onAppear {
            if let existing = existingReview {
                reviewRating = existing.star
                reviewComment = existing.quote
            } else {
                reviewRating = 0
                reviewComment = ""
            }
        }
    }

    private func loadCoach() async {
        guard let session = rootView.selectedAthleteSession else { return }
        do {
            fetchedCoach = try await rootView.client
                .from("profiles")
                .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                .eq("id", value: session.other.uuidString)
                .single()
                .execute()
                .value
        } catch {
            log.error("Could not load coach: \(error.localizedDescription)")
        }
        isLoading = false
    }

    private func loadReviewData() async {
        guard let session = rootView.selectedAthleteSession else { return }
        existingReview = await getReview(client: rootView.client, coachID: session.other, reviewerID: rootView.profile.id)
        coachRatings = await getCoachRating(client: rootView.client, coachID: session.other)
        reviewChecked = true
    }

    private func formatTime(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: date)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .frame(height: 1)
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
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
        .padding(.vertical, 8)
    }

    private func receiptRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    func receiptPDF(session: Session, coach: PublicUser) -> Data {
        let price = session.cost
        let tax = price * 0.0875
        let com = price * 0.09
        let total = price + tax + com

        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        return renderer.pdfData { context in
            context.beginPage()
            let text = """
                       AthLink Receipt
                       ---------------
                       Coach:    \(coach.fullName)
                       Date:     \(session.date.formatted(.dateTime.month().day().year()))
                       Duration: \(session.totalTime.0)h \(session.totalTime.1)m
                       Type:     \(session.type.description)
                       Sport:    \(session.sport.description)
                       Location: \(session.location.name)

                       Session Cost:     \(String(format: "$%.2f", price))
                       Sales Tax (8.75%): \(String(format: "$%.2f", tax))
                       Service Fee (9%): \(String(format: "$%.2f", com))
                       ---------------
                       Total:            \(String(format: "$%.2f", total))
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

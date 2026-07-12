import SwiftUI
import UIKit
import PDFKit

struct CoachSessionInfo: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var receiptURL: URL?
    @State private var isLoading = true
    @State private var fetchedAthlete: PublicUser?
    @State private var removeSessionMessage: Bool = false
    @State private var editMode: Bool = false
    @State private var editDate: Date = Date()
    @State private var editEndDate: Date = Date()
    @State private var editSport: Sports = .Football
    @State private var editType: GroupType = .Individual
    @State private var editNote: String = ""

    var body: some View {
        if let session = rootView.selectedCoachSession, let athlete = fetchedAthlete {
            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: session.sf)
                            .font(.system(size: 44))
                            .foregroundColor(.blue)
                        Text("Session with \(athlete.fullName)")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text(athLinkSessionDateTime(session.date))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)

                    // Details card
                    Group {
                    if !editMode {
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
                            divider
                            detailRow(icon: "mappin.circle", label: "Location", value: session.location.name)
                            if let desc = session.description, !desc.isEmpty {
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

                    // Earnings card (past sessions only)
                    if !rootView.sessType {
                        let commission = session.cost * 0.09
                        let payout = session.cost - commission

                        VStack(spacing: 12) {
                            HStack {
                                Text("Earnings")
                                    .font(.headline)
                                Spacer()
                            }

                            receiptRow(label: "Session Cost", value: athLinkWholeDollar(session.cost))
                            receiptRow(label: "Commission (9%)", value: "-\(athLinkWholeDollar(commission))", color: .red)

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

                            if receiptURL == nil {
                                Button(action: {
                                    let pdfData = earningsPDF(session: session, athlete: athlete, commission: commission, payout: payout)
                                    let tmp = FileManager.default.temporaryDirectory
                                        .appendingPathComponent("coach-receipt.pdf")
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
                                            // Build updated session from edit fields
                                            var updatedSession = session
                                            updatedSession.date = editDate
                                            updatedSession.finished = editEndDate
                                            updatedSession.sport = editSport
                                            updatedSession.type = editType
                                            updatedSession.description = editNote.isEmpty ? nil : editNote

                                            // Update my local coach sessions
                                            if let index = rootView.profile.coachUpcomingSessions.firstIndex(where: { $0.id == session.id }) {
                                                rootView.profile.coachUpcomingSessions[index] = updatedSession
                                            }

                                            // Push to my coach_profile
                                            let coachPatch = CoachProfilePatch(
                                                personal_quote: nil, coaching_achievements: nil,
                                                coaching_experience: nil, time_availability: nil,
                                                individual_cost: nil,
                                                group_cost: nil, sports: nil, sport_positions: nil,
                                                cancellation_notice: nil,
                                                coach_upcoming_sessions: rootView.profile.coachUpcomingSessions,
                                                coach_past_sessions: nil,
                                                job_requests: nil,
                                                current_athletes: nil, reviews: nil,
                                                athlete_requests: nil, training_locations: nil
                                            )
                                            try await rootView.client
                                                .from("coach_profile")
                                                .update(coachPatch)
                                                .eq("id", value: rootView.profile.id.uuidString)
                                                .execute()

                                            // Fetch athlete's profile
                                            let theirProfile: Profile = try await rootView.client
                                                .from("profiles")
                                                .select("id, first_name, last_name, coach_account, image_url, user_type, athlete_upcoming_sessions, athlete_past_sessions, stripe_customer_id, has_payment_method, current_coaches, referral_code, referred_by, credits")
                                                .eq("id", value: session.other.uuidString)
                                                .single()
                                                .execute()
                                                .value

                                            // Replace session in their upcoming list
                                            var updatedAthleteSessions = theirProfile.athleteUpcomingSessions
                                            if let index = updatedAthleteSessions.firstIndex(where: { $0.id == session.id }) {
                                                updatedAthleteSessions[index] = updatedSession
                                            }

                                            // Push to their profiles table
                                            let athletePatch = ProfileSessionPatch(
                                                athlete_upcoming_sessions: updatedAthleteSessions,
                                                athlete_past_sessions: nil
                                            )
                                            try await rootView.client
                                                .from("profiles")
                                                .update(athletePatch)
                                                .eq("id", value: session.other.uuidString)
                                                .execute()

                                            rootView.selectedCoachSession = updatedSession
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
                                    editDate = session.date
                                    editEndDate = session.finished
                                    editSport = session.sport
                                    editType = session.type
                                    editNote = session.description ?? ""
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
                                            // Get local copy of their profile
                                            let theirProfile: Profile = try await rootView.client
                                                .from("profiles")
                                                .select("id, first_name, last_name, coach_account, image_url, user_type, athlete_upcoming_sessions, athlete_past_sessions, stripe_customer_id, has_payment_method, current_coaches, referral_code, referred_by, credits")
                                                .eq("id", value: session.other.uuidString)
                                                .single()
                                                .execute()
                                                .value
                                            // Remove session from their upcoming list
                                            var updatedAthleteSessions = theirProfile.athleteUpcomingSessions
                                            updatedAthleteSessions.removeAll { $0.id == session.id }

                                            // Push to their table
                                            let athletePatch = ProfileSessionPatch(
                                                athlete_upcoming_sessions: updatedAthleteSessions,
                                                athlete_past_sessions: nil
                                            )
                                            try await rootView.client
                                                .from("profiles")
                                                .update(athletePatch)
                                                .eq("id", value: session.other.uuidString)
                                                .execute()
                                            
                                            // Remove from my local state
                                            rootView.profile.coachUpcomingSessions.removeAll { $0.id == session.id }

                                            // Push to my table
                                            let coachPatch = CoachProfilePatch(
                                                personal_quote: nil, coaching_achievements: nil,
                                                coaching_experience: nil, time_availability: nil,
                                                individual_cost: nil,
                                                group_cost: nil, sports: nil, sport_positions: nil,
                                                cancellation_notice: nil,
                                                coach_upcoming_sessions: rootView.profile.coachUpcomingSessions,
                                                coach_past_sessions: nil,
                                                job_requests: nil,
                                                current_athletes: nil, reviews: nil,
                                                athlete_requests: nil, training_locations: nil
                                            )
                                            try await rootView.client
                                                .from("coach_profile")
                                                .update(coachPatch)
                                                .eq("id", value: rootView.profile.id.uuidString)
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
        } else {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .task { await loadAthlete() }
        }
    }

    // MARK: - Helpers

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

    private func receiptRow(label: String, value: String, color: Color = .primary) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }

    // MARK: - Data

    private func loadAthlete() async {
        guard let session = rootView.selectedCoachSession else { return }
        do {
            fetchedAthlete = try await rootView.client
                .from("profiles")
                .select("id, first_name, last_name, image_url, stripe_customer_id, has_payment_method")
                .eq("id", value: session.other.uuidString)
                .single()
                .execute()
                .value
        } catch {
            log.error("Could not load athlete: \(error.localizedDescription)")
        }
        isLoading = false
    }

    // MARK: - PDF

    func earningsPDF(session: Session, athlete: PublicUser, commission: Double, payout: Double) -> Data {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        return renderer.pdfData { context in
            context.beginPage()
            let text = """
                       Coach Receipt
                       -------------
                       Athlete:  \(athlete.fullName)
                       Date:     \(session.date.formatted(.dateTime.month().day().year()))
                       Duration: \(session.totalTime.0)h \(session.totalTime.1)m
                       Sport:    \(session.sport.description)
                       Type:     \(session.type.description)
                       Location: \(session.location.name)

                       Session Cost:     \(String(format: "$%.2f", session.cost))
                       Commission (9%):  \(String(format: "-$%.2f", commission))
                       -------------
                       Your Payout:      \(String(format: "$%.2f", payout))
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

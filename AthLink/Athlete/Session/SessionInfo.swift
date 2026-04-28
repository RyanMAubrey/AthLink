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
    // Session coach
    @State private var fetchedCoach: PublicUser?
    // If you already reviewed the coach
    @State private var existingReview: Review?
    // The session  coaches reviews and rating
    @State private var coachRatings: CoachRating?
    // Check for data
    @State private var reviewChecked = false
    
    var body: some View {
        if let sa = rootView.selectedAthleteSession, let fc = fetchedCoach {
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 36))
                            .foregroundColor(.blue)
                        Text("Session with \(fc.fullName)")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if !rootView.sessType {
                            Button(action: {
                                let pdfData = receiptPDF(session: sa, coach: fc)
                                let tmp = FileManager.default.temporaryDirectory
                                    .appendingPathComponent("session-receipt.pdf")
                                do {
                                    try pdfData.write(to: tmp)
                                    receiptURL = tmp
                                } catch {
                                    print("Failed to write PDF:", error)
                                }
                            }) {
                                Label("View Receipt", systemImage: "doc.text")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.4627, green: 0.8392, blue: 1.0).opacity(0.15))
                    
                    // Details
                    ScrollView {
                        VStack(spacing: 0) {
                            detailRow(icon: "calendar", label: "Date", value: sa.date.formatted())
                            sectionDivider
                            detailRow(icon: "mappin.circle", label: "Location", value: sa.location.name)
                            sectionDivider
                            detailRow(icon: "person.2", label: "Type", value: sa.type.description)
                            sectionDivider
                            detailRow(icon: "figure.run", label: "Sport", value: sa.sport.description)
                            sectionDivider
                            detailRow(icon: "dollarsign.circle", label: "Cost", value: String(format: "$%.2f", sa.cost))
                            
                            // Review section
                            if !rootView.sessType && reviewChecked {
                                sectionDivider

                                if let existing = existingReview {
                                    // Show existing review
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Your Review")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)

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
                                                        .foregroundColor(.yellow)
                                                }
                                            }
                                            .font(.caption)
                                            Text(String(format: "%.1f", existing.star))
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }

                                        if !existing.quote.isEmpty {
                                            Text(existing.quote)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }

                                        Text(existing.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption2)
                                            .foregroundColor(.gray)

                                        Button(action: {
                                            tempRev = existing
                                        }) {
                                            Text("Edit Review")
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                                .foregroundColor(.blue)
                                        }
                                        .padding(.top, 4)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                    .padding(.top, 8)
                                } else {
                                    Button(action: {
                                        tempRev = Review(id: UUID(), coach: sa.other, reviewer: rootView.profile.id, date: Date(), star: 0.00, quote: "")
                                    }) {
                                        Text("Leave a Review")
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.blue)
                                            .cornerRadius(12)
                                    }
                                    .padding(.top, 12)
                                }
                            }
                        }
                        .padding()
                    }
                }
                .background(Color(.systemGroupedBackground))
                // Receipt sheet
                .sheet(item: $receiptURL) { url in
                    let price = sa.cost
                    let tax = price * 0.0875
                    let commission = price * 0.09
                    let total = price + tax + commission
                    
                    VStack(spacing: 16) {
                        Capsule()
                            .fill(Color(.systemGray4))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                        
                        Text("Receipt")
                            .font(.title2).bold()
                        
                        VStack(spacing: 10) {
                            receiptRow(label: "Original Price", value: String(format: "$%.2f", price))
                            receiptRow(label: "Sales Tax (8.75%)", value: String(format: "$%.2f", tax))
                            receiptRow(label: "Commission (9%)", value: String(format: "$%.2f", commission))
                            
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
                        }
                        .padding(.horizontal)
                        
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Save or Share Receipt")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 24)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                        
                        Button("Done") { receiptURL = nil }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .padding()
                    .presentationDetents([.height(340)])
                }
                // Review sheet
                .sheet(item: $tempRev) { _ in
                    VStack(spacing: 16) {
                        Capsule()
                            .fill(Color(.systemGray4))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)

                        if let coachRatings {
                            HStack {
                                Label(String(format: "%.1f", coachRatings.avgStar), systemImage: "star.fill")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
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
                                        coachID: sa.other,
                                        reviewerID: rootView.profile.id,
                                        star: reviewRating,
                                        quote: reviewComment
                                    )
                                }
                                if success {
                                    let reviewId = existingReview?.id ?? UUID()
                                    existingReview = Review(id: reviewId, coach: sa.other, reviewer: rootView.profile.id, date: Date(), star: reviewRating, quote: reviewComment)
                                    coachRatings = await getCoachRating(client: rootView.client, coachID: sa.other)
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

    private func loadCoach() async {
        guard let session = rootView.selectedAthleteSession else { return }
        do {
            fetchedCoach = try await rootView.client
                .from("profiles")
                .select("id, first_name, last_name, image_url, card_on_file")
                .eq("id", value: session.other.uuidString)
                .single()
                .execute()
                .value
        } catch {
            print("Could not load coach:", error)
        }
        isLoading = false
    }

    private func loadReviewData() async {
        guard let session = rootView.selectedAthleteSession else { return }
        existingReview = await getReview(client: rootView.client, coachID: session.other, reviewerID: rootView.profile.id)
        coachRatings = await getCoachRating(client: rootView.client, coachID: session.other)
        reviewChecked = true
    }

    private var sectionDivider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
            .padding(.horizontal)
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
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func receiptRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
        }
        .font(.subheadline)
    }

    func receiptPDF(session: Session, coach: PublicUser) -> Data {
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        return renderer.pdfData { context in
            context.beginPage()
            let costString = String(format: "$%.2f", session.cost)
            let tax = session.cost * 0.0875
            let com = session.cost * 0.09
            let total = session.cost + tax + com
            let text = """
                       Receipt
                       -------
                       Coach: \(coach.fullName)
                       Date:  \(session.date.formatted(.dateTime.month().day().year()))
                       Type:  \(session.type.description)
                       Sport: \(session.sport.description)
                       Cost:        \(costString)
                       Sales Tax:   \(String(format: "$%.2f", tax))
                       Commission:  \(String(format: "$%.2f", com))
                       Total:       \(String(format: "$%.2f", total))
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

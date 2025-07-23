//
//  SessionInfo.swift
//  AthLink
//
//  Created by RyanAubrey on 7/6/25.
//

import SwiftUI
import UIKit
import PDFKit

extension URL: @retroactive Identifiable {
    public var id: URL { self }
}

struct SessionInfo: View {
    @EnvironmentObject var rootView: RootViewObj
    // Temp URL to stor PDF
    @State private var receiptURL: URL?
    @State private var tempRev: Review?
    @State private var reviewRating: Float = 0
    @State private var reviewComment: String = ""
    
    var body: some View {
        if let ss = rootView.selectedSession,
           let ls = ss.cupcomingSessions.first(where: { $0.other == rootView.profile }) {
            let costString = String(format: "$%.2f", ls.cost)

            Form {
                VStack {
                    HStack {
                        VStack {
                            // title
                            Text("Training Session with \(ss.fullName)")
                                .font(.title3)
                                .bold()
                            //recipt
                            if !rootView.sessType {
                                Button(action: {
                                    // Create the PDF
                                    let pdfData = receiptPDF(session: ls, coach: ss)
                                    // Store PDF at URL
                                    let tmp = FileManager.default.temporaryDirectory
                                        .appendingPathComponent("session-receipt.pdf")
                                    do {
                                        try pdfData.write(to: tmp)
                                        receiptURL = tmp
                                    } catch {
                                        print("Failed to write PDF:", error)
                                    }
                                }) {
                                    Label("Receipt", systemImage: "doc.text")
                                }
                                .font(.headline)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .foregroundColor(.primary)
                                .background(Color(UIColor.systemGray5))
                                .cornerRadius(8)
                            }
                        }
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                        .listRowBackground(Color.clear)
                    // sessiond date
                    Section(header: Label("Date:", systemImage: "calendar")) {
                        Text(ls.date.formatted())
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                        .listRowBackground(Color.clear)
                    // session location
                    if let loc = ls.location {
                        Section(header: Label("Location:", systemImage: "mappin.and.ellipse")) {
                            Text(loc.name)
                        }
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                        .listRowBackground(Color.clear)
                    // session type
                    Section(header: Label("Type:", systemImage: "tag")) {
                        Text(ls.type.descritpion)
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                        .listRowBackground(Color.clear)
                    // session sport
                    Section(header: Label("Sport:", systemImage: "sportscourt")) {
                        Text(ls.sport.description)
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                        .listRowBackground(Color.clear)
                    // cost
                    Section(header: Label("Cost:", systemImage: "dollarsign.circle")) {
                        Text(costString)
                    }
                    // Rating Button
                    if !rootView.sessType {
                        let alreadyReview = ss.reviews.contains { review in
                            review.reviewer.id == rootView.profile.id
                        }
                        if !alreadyReview {
                            Divider()
                                .padding(.vertical, 8)
                                .listRowBackground(Color.clear)
                            Section {
                                Button(action: {
                                    tempRev = Review(reviewer: rootView.profile, date: Date(), star: 0.00, quote:"")
                                }) {
                                    Text("Enter a Review")
                                        .font(.headline)
                                        .padding(.vertical, 6)
                                        .padding(.horizontal, 12)
                                        .foregroundColor(.white)
                                        .background(Color.accentColor)
                                        .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                }
                // Receipt sheet
                .sheet(item: $receiptURL) { url in
                    let price = ls.cost
                    let tax = price * 0.0875
                    let commission = price * 0.09
                    let total = price + tax + commission
                    
                    VStack(spacing: 16) {
                        // Grab bar
                        Capsule()
                            .fill(Color(UIColor.systemGray4))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                        
                        Text("Receipt")
                            .font(.title2).bold()
                        
                        // Original
                        HStack {
                            Text("Original Price")
                            Spacer()
                            Text(String(format: "$%.2f", price))
                        }
                        // Tax
                        HStack {
                            Text("Sales Tax (8.75%)")
                            Spacer()
                            Text(String(format: "$%.2f", tax))
                        }
                        // Commission
                        HStack {
                            Text("Commission (9%)")
                            Spacer()
                            Text(String(format: "$%.2f", commission))
                        }
                        Divider()
                        // Total row
                        HStack {
                            Text("Total")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", total))
                                .font(.headline)
                        }
                        // Share Button
                        ShareLink(item: url) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Save or Share Receipt")
                            }
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                            .background(Color(UIColor.systemGray5))
                            .cornerRadius(10)
                        }
                        // Done button
                        Button("Done") {
                            receiptURL = nil
                        }
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray5))
                        .cornerRadius(8)
                    }
                    .padding()
                    // Sheet height
                    .presentationDetents([.height(320)])
                }
                
                // Review sheet
                .sheet(item: $tempRev) { _ in
                    VStack(spacing: 16) {
                        // Grab-bar
                        Capsule()
                            .fill(Color(UIColor.systemGray4))
                            .frame(width: 40, height: 5)
                            .padding(.top, 8)
                        HStack {
                            // review
                            Label(String(format: "%.1f", ss.rating), systemImage: "star.fill")
                                .font(.headline)
                            // Number reviews
                            Text("(\(ss.ratings))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        // line
                        Rectangle().frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(8)
                            .listRowBackground(Color.clear)
                        // Rating slider
                        Section(header: Text("Your Rating")) {
                            HStack {
                                Slider(value: $reviewRating, in: 0...5, step: 0.5)
                                Text(String(format: "%.1f★", reviewRating))
                                    .font(.headline)
                                    .frame(width: 50)
                            }
                            .padding(.horizontal, -16)
                        }

                        // Comment bubble
                        Section(header: Text("Your Comment")) {
                            TextEditor(text: $reviewComment)
                                .frame(minHeight: 150)
                                .cornerRadius(15)
                                .border(Color.secondary)
                                .padding(.horizontal, -16)
                                .multilineTextAlignment(.center)
                                .overlay(
                                    Group {
                                        if reviewComment.isEmpty {
                                            Text("Write your review here…")
                                                .foregroundColor(.secondary)
                                                .padding(.horizontal, 20)
                                                .padding(.vertical, 12)
                                        }
                                    },
                                    alignment: .topLeading
                                )
                        }

                        // Submit button
                        Button("Submit") {
                            // append the new review onto the coach
                            if let coach = rootView.selectedSession {
                                let newReview = Review(
                                    reviewer: rootView.profile,
                                    date: Date(),
                                    star: Float(reviewRating),
                                    quote: reviewComment
                                )
                                coach.reviews.append(newReview)
                            }
                            tempRev = nil
                        }
                        .disabled(reviewRating == 0)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(reviewRating > 0 ? Color.accentColor : Color.gray)
                        .cornerRadius(8)
                        Spacer()
                    }
                    .padding()
                    .presentationDetents([.height(420)])
                    onAppear {
                            reviewRating  = 0
                            reviewComment = ""
                        }
                }
            }
        }
    }
    
    func receiptPDF(session: Session, coach: ProfileID) -> Data {
        // US Letter page size
        let pageSize = CGRect(x: 0, y: 0, width: 612, height: 792)
        // Capture drawing into a PDF
        let renderer = UIGraphicsPDFRenderer(bounds: pageSize)
        // Produce the pdf data
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
                       Type:  \(session.type.descritpion)
                       Sport: \(session.sport.description)
                       Cost:        \(costString)
                       Sales Tax:   \(String(format: "$%.2f", tax))
                       Commission:  \(String(format: "$%.2f", com))
                       Total:       \(String(format: "$%.2f", total))
                       """
            // Text styling
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18),
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.alignment = .left
                    return style
                }()
            ]
            // Draw into margins
            let textArea = pageSize.insetBy(dx: 40, dy: 40)
            text.draw(in: textArea, withAttributes: attributes)
        }
    }
}

//#Preview {
//    SessionInfo()
//}

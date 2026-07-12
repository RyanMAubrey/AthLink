import SwiftUI

struct Support: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var copiedEmail = false

    private let phoneNumber = "1-800-000-0000"
    private let email = "support@athlink.com"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "headphones.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
                    .padding(.top, 32)

                Text("Customer Support")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("We're here to help. Reach out to us by phone or email.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Phone card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "phone.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Call Us")
                            .font(.headline)
                    }

                    Text("Our team is available to answer any questions you may have.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Button(action: {
                        let cleaned = phoneNumber.replacingOccurrences(of: "-", with: "")
                        if let url = URL(string: "tel:\(cleaned)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "phone.arrow.up.right")
                            Text(phoneNumber)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)

                // Email card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 10) {
                        Image(systemName: "envelope.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 28)
                        Text("Email Us")
                            .font(.headline)
                    }

                    Text("Send us an email and we'll get back to you as soon as possible.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    HStack(spacing: 10) {
                        Button(action: {
                            if let url = URL(string: "mailto:\(email)") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "envelope.arrow.triangle.branch")
                                Text(email)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }

                        Button(action: {
                            UIPasteboard.general.string = email
                            copiedEmail = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copiedEmail = false
                            }
                        }) {
                            Image(systemName: copiedEmail ? "checkmark" : "doc.on.doc")
                                .foregroundColor(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)

                // FAQ link
                Button(action: {
                    rootView.path.append("Question")
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .font(.title3)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Check our FAQ")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                            Text("Find quick answers to common questions")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Support")
        .navigationBarTitleDisplayMode(.inline)
    }
}

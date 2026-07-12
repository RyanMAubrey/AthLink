import SwiftUI

struct Satisfaction: View {
    @EnvironmentObject var rootView: RootViewObj

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
                    .padding(.top, 32)

                Text("Satisfaction Guarantee")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Your experience matters to us. If you're not satisfied with your coaching session, we've got you covered.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // What's covered
                VStack(alignment: .leading, spacing: 16) {
                    Text("What's Covered")
                        .font(.headline)

                    GuaranteeRow(icon: "dollarsign.arrow.circlepath", title: "First Hour Refund", description: "If you're unhappy with your session, we'll refund the cost of the first hour.")

                    GuaranteeRow(icon: "clock", title: "24-Hour Window", description: "Submit your request within 24 hours of your session ending.")

                    GuaranteeRow(icon: "bubble.left.and.bubble.right", title: "No Questions Asked", description: "Simply contact our support team and we'll process your refund.")
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)

                // How to claim
                VStack(alignment: .leading, spacing: 16) {
                    Text("How to Claim")
                        .font(.headline)

                    HStack(alignment: .top, spacing: 12) {
                        Text("1")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Contact Support")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Reach out within 24 hours of your session.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("2")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Provide Details")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Let us know what went wrong so we can improve.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("3")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 28, height: 28)
                            .background(Color.blue)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Get Your Refund")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("We'll process your refund within 5-7 business days.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)

                // Contact support button
                Button(action: {
                    rootView.path.append("Support")
                }) {
                    HStack {
                        Image(systemName: "headphones")
                        Text("Contact Support")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Satisfaction Guarantee")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct GuaranteeRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

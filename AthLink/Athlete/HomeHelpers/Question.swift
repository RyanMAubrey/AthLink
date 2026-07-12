import SwiftUI

struct Question: View {
    @EnvironmentObject var rootView: RootViewObj
    private var isCoach: Bool { rootView.rootView == .Coach }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
                    .padding(.top, 32)

                Text("Frequently Asked Questions")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Find answers to common questions about AthLink.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)

                VStack(spacing: 12) {
                    if isCoach {
                        FAQItem(
                            question: "How do I find athlete requests?",
                            answer: "Tap \"Find an Athlete\" on the coach home screen or open Jobs. Direct Requests are sent to you, Open Requests are marketplace postings, and My Athletes shows athletes you've coached."
                        )

                        FAQItem(
                            question: "How do cancellations work?",
                            answer: "Your cancellation notice controls when athletes may cancel without being charged. If you do not want to charge an athlete after that window, handle the cancellation from your coach session view and waive the charge."
                        )

                        FAQItem(
                            question: "How do I invite my own athletes?",
                            answer: "Use Invite Your Athletes from the coach home screen to share your personal invite. Athletes who sign up through it are pre-connected to you for easier booking."
                        )

                        FAQItem(
                            question: "How do coach referrals work?",
                            answer: "Share your coach referral code. Referral rewards are gated on the new coach completing paid sessions, not just signup."
                        )
                    } else {
                        FAQItem(
                            question: "How do I book a session?",
                            answer: "Tap \"Find a Coach\" on the home screen to browse available coaches. You can also tap \"Request Session\" to post what you're looking for and let coaches come to you."
                        )

                        FAQItem(
                            question: "How do I cancel or reschedule?",
                            answer: "Go to your Sessions tab and select the session you'd like to change. You can cancel or request a reschedule from there. Cancellations made more than 24 hours before the session are fully refunded."
                        )

                        FAQItem(
                            question: "How does payment work?",
                            answer: "Payment is handled securely through Stripe. Your card is charged after a session is confirmed. You can manage your payment methods in your Account settings."
                        )

                        FAQItem(
                            question: "What is the Satisfaction Guarantee?",
                            answer: "If you're unsatisfied with a session, contact support within 24 hours and we'll refund the cost of the first hour. No questions asked."
                        )

                        FAQItem(
                            question: "How do I become a coach?",
                            answer: "From the home screen, tap \"Become a Coach\" to upgrade your account. You'll need to set up payouts and complete a background check through your coach settings."
                        )
                    }

                    FAQItem(
                        question: "How do background checks work?",
                        answer: "All coaches on AthLink undergo a background check to help ensure athlete safety. Coaches can complete this process from their Account settings."
                    )

                    FAQItem(
                        question: "How do I contact support?",
                        answer: "You can reach our support team by phone or email. Tap the Support button on the home screen or go to Account > Support for contact details."
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("FAQ")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            Text(answer)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
        } label: {
            Text(question)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.leading)
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

import SwiftUI

struct Receive: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var copied = false
    private var isCoach: Bool { rootView.rootView == .Coach }
    

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.blue)
                    .padding(.top, 32)

                Text(isCoach ? "Refer a Coach" : "Give $40, Get $40")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(isCoach ? "Earn a referral bonus after a coach you invite completes their first 5 paid sessions. New coaches start with 0% AthLink fees for 30 days." : "Invite a friend to AthLink. When they sign up with your code, you both instantly receive $40 in coaching credit.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                // Credits balance
                if !isCoach {
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.green)
                        Text("Your Balance:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(rootView.profile.credits)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }

                // Referral code card
                VStack(spacing: 16) {
                    Text(isCoach ? "Your Coach Referral Code" : "Your Referral Code")
                        .font(.headline)

                    Text(rootView.profile.referralCode)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.blue)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(10)

                    HStack(spacing: 12) {
                        Button(action: {
                            UIPasteboard.general.string = rootView.profile.referralCode
                            copied = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                copied = false
                            }
                        }) {
                            HStack {
                                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                                Text(copied ? "Copied" : "Copy Code")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                        }

                        Button(action: {
                            let message = isCoach
                                ? "Start coaching on AthLink with 0% platform fees for your first 30 days. Use my referral code \(rootView.profile.referralCode): https://athlink.com"
                                : "Join me on AthLink! Use my referral code \(rootView.profile.referralCode) to get $40 in free coaching. Download the app: https://athlink.com"
                            let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let window = windowScene.windows.first {
                                window.rootViewController?.present(activityVC, animated: true)
                            }
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)

                // How it works
                VStack(alignment: .leading, spacing: 16) {
                    Text("How It Works")
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
                            Text(isCoach ? "Share Your Code With a Coach" : "Share Your Code")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(isCoach ? "Send your personal code to another coach." : "Send your referral code to a friend.")
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
                            Text(isCoach ? "They Start Coaching" : "They Sign Up")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(isCoach ? "Their referral is tracked through onboarding and paid sessions." : "Your friend creates an account and enters your code.")
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
                            Text(isCoach ? "Bonus Unlocks After 5 Sessions" : "You Both Get $40 Instantly")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(isCoach ? "The referrer bonus is paid only after the new coach completes 5 paid sessions without refunds or chargebacks." : "$40 in credit is added to both accounts right away.")
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

                // Fine print
                Text(isCoach ? "Referral rewards are not paid for rejected background checks, self-referrals, refunded sessions, or chargebacks." : "Credits are applied instantly when your friend signs up with your code. Referral credits cannot be combined with other promotions.")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(isCoach ? "Refer a Coach" : "Refer a Friend")
        .navigationBarTitleDisplayMode(.inline)
    }
}

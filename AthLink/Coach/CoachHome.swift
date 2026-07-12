import SwiftUI

struct CoachHome: View {
    @EnvironmentObject var rootView: RootViewObj

    var body: some View {
        TabView(selection: $rootView.selectedTab) {
            // Home Tab
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image("athlinklogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 44, height: 44)
                    Text("Coach")
                        .font(.title2)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 10)

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Search + coach actions
                        VStack(spacing: 10) {
                            Button(action: { rootView.selectedTab = 1 }) {
                                HStack(spacing: 10) {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Find an Athlete")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .frame(height: 50)
                                .background(Color.blue)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)

                        // Getting Started
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Getting Started")
                                .font(.headline)
                                .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    quickAction(icon: "person.crop.circle.badge.plus", title: "Invite Your\nAthletes") {
                                        shareInvite(message: "Book with me on AthLink using my invite code \(rootView.profile.referralCode). AthLink handles scheduling, payments, and session protection.")
                                    }
                                    quickAction(icon: "person.2.badge.plus", title: "Refer a\nCoach") {
                                        rootView.path.append("Receive")
                                    }
                                    quickAction(icon: "questionmark.circle", title: "FAQ") {
                                        rootView.path.append("Question")
                                    }
                                    quickAction(icon: "phone.circle", title: "Support") {
                                        rootView.path.append("Support")
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Divider
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)
                            .padding(.horizontal)

                        // Switch to athlete
                        Button(action: { rootView.rootView = .Home }) {
                            HStack(spacing: 12) {
                                Image(systemName: "sportscourt.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Athlete Section")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text("Switch to your athlete account")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal)

                        // Location helper
                        if rootView.locationStatus == .denied || rootView.locationStatus == .restricted {
                            Button(action: {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                } else {
                                    rootView.requestWhenInUseLocation()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text("Enable Location")
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue, in: Capsule())
                            }
                        }
                        
                        // Onboarding helper
                        if !rootView.profile.completedCheckr || !rootView.profile.completedOnboarding {
                            Button(action: {
                                rootView.selectedTab = 4
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text({
                                        switch (rootView.profile.completedCheckr, rootView.profile.completedOnboarding) {
                                        case (false, false):
                                            return "Set up payouts & background check"
                                        case (false, true):
                                            return "Complete your background check"
                                        case (true, false):
                                            return "Set up your payouts"
                                        default:
                                            return ""
                                        }
                                    }())
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.orange, in: Capsule())
                            }
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)

            // Jobs
            Job()
                .environmentObject(rootView)
                .tabItem { Label("Jobs", systemImage: "briefcase") }
                .tag(1)

            // Messages
            Messages()
                .environmentObject(rootView)
                .environmentObject(SearchHelp())
                .tabItem { Label("Messages", systemImage: "bell") }
                .tag(2)

            // Sessions
            CoachSession()
                .environmentObject(rootView)
                .tabItem { Label("Sessions", systemImage: "calendar") }
                .tag(3)

            // Account
            AccountView()
                .environmentObject(rootView)
                .tabItem { Label("Account", systemImage: "person") }
                .tag(4)
        }
        .onChange(of: rootView.selectedTab) { old, new in
            if rootView.isUnSaved && old == 4 {
                rootView.pendingTab = new
                rootView.selectedTab = old
                rootView.showUnSavedAlert = true
            }
        }
    }

    private func quickAction(icon: String, title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(width: 100, height: 90)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
        }
    }

    private func shareInvite(message: String) {
        let activityVC = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

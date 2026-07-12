import SwiftUI

struct CoachLogin: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var signingUp = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                VStack(spacing: 20) {
                    // Logo
                    Image("athlinklogo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.top, 40)

                    Text("Become a Coach")
                        .font(.title2)
                        .fontWeight(.bold)

                    // Info card
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Start coaching athletes on AthLink")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        VStack(alignment: .leading, spacing: 12) {
                            InfoRow(icon: "person.2.fill", text: "Connect with athletes looking for coaching")
                            InfoRow(icon: "calendar", text: "Manage your schedule and training sessions")
                            InfoRow(icon: "banknote", text: "Get paid directly for your sessions")
                            InfoRow(icon: "gearshape", text: "Set up payouts and background checks in Settings")
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 24)

                    // Sign Up Button
                    Button(action: {
                        guard !signingUp else { return }
                        signingUp = true
                        Task {
                            // Turn off auth suppressor and signing in
                            defer { Task { @MainActor in
                                signingUp = false
                                rootView.suppressAuthListener = false
                            } }
                            rootView.suppressAuthListener = true
                            do {
                                // Makes sure your logged in
                                guard let user = rootView.client.auth.currentUser else {
                                    throw NSError(domain: "Auth", code: 0,
                                      userInfo: [NSLocalizedDescriptionKey: "You must be logged in to become a coach."])
                                }
                                // Sets front end to a coach account
                                rootView.profile.coachAccount = true
                                // Sets back end to a coach account
                                try await rootView.client
                                    .from("profiles")
                                    .update(["coach_account": true])
                                    .eq("id", value: user.id)
                                    .execute()
                                // Creates a coach profile
                                let newCoach = CoachProfile(
                                    id: user.id,
                                    coachingAchievements: [],
                                    coachingExperience: [],
                                    timeAvailability: [:],
                                    sports: [],
                                    sportPositions: [:],
                                    coachUpcomingSessions: [],
                                    coachPastSessions: [],
                                    jobRequests: [],
                                    athleteRequests: [],
                                    currentAthletes: [:],
                                    trainingLocations: []
                                )
                                // Push to backend
                                try await rootView.client
                                  .from("coach_profile")
                                  .upsert(newCoach)
                                  .execute()
                                // Create Stripe Connect account for coach payouts
                                let connectURL = URL(string: "\(infoValue(key: "SUPABASE_URL"))/functions/v1/create-connect-account")!
                                var connectReq = URLRequest(url: connectURL)
                                connectReq.httpMethod = "POST"
                                connectReq.setValue("application/json", forHTTPHeaderField: "Content-Type")
                                connectReq.setValue("Bearer \(rootView.client.auth.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
                                connectReq.httpBody = try JSONEncoder().encode([
                                    "email": user.email ?? "",
                                    "name": rootView.profile.fullName
                                ])
                                let (connectData, _) = try await URLSession.shared.data(for: connectReq)
                                if let connectJSON = try? JSONDecoder().decode([String: String].self, from: connectData),
                                   let connectId = connectJSON["connectId"] {
                                    try await rootView.client
                                        .from("coach_profile")
                                        .update(["stripe_connect_id": connectId])
                                        .eq("id", value: user.id)
                                        .execute()
                                }
                                // Update frontend
                                try await rootView.loadProfile()
                                // Reset rootview and navigation path to coach
                                rootView.path = NavigationPath()
                                rootView.rootView = .Coach
                            } catch {
                                await MainActor.run {
                                    alertMessage = "Failed to create coach account: \(error.localizedDescription)"
                                    showAlert = true
                                }
                                log.error("Coach account creation failed: \(error.localizedDescription)")
                            }
                        }
                    }) {
                        HStack {
                            if signingUp {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text("Sign Up")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .cornerRadius(12)
                    }
                    .disabled(signingUp)
                    .padding(.horizontal, 24)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Coach Signup"), message: Text(alertMessage))
                    }

                    // Terms
                    VStack(spacing: 4) {
                        Text("By clicking 'Sign Up' you agree to our")
                            .font(.caption)
                            .foregroundColor(.gray)
                        HStack(spacing: 4) {
                            Button(action: { rootView.path.append("Terms") }) {
                                Text("Terms of Service")
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                            Text("and")
                            Button(action: { rootView.path.append("Privacy") }) {
                                Text("Privacy Policy")
                                    .underline()
                                    .foregroundColor(.blue)
                            }
                        }
                        .font(.caption)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

private struct InfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

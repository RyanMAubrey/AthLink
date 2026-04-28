import SwiftUI

struct CoachLogin: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var signupDraft: SignupDraft
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
                        .padding(.top, 20)

                    Text("Become a Coach")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Complete these optional steps to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    // Form card
                    VStack(alignment: .leading, spacing: 20) {
                        // OffenderWatch
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Image(systemName: "shield.checkmark.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("OffenderWatch Screening")
                                    .font(.headline)
                            }
                            Text("Optional — complete a background screening for athlete safety")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Link(destination: URL(string: "https://www.example.com")!) {
                                HStack {
                                    Image(systemName: "arrow.up.right.square")
                                    Text("Complete your screening")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }

                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 1)

                        // Direct Deposit
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 10) {
                                Image(systemName: "building.columns")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                Text("Direct Deposit")
                                    .font(.headline)
                            }
                            Text("Optional — set up your bank account for payouts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Add bank account")
                                }
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(8)
                            }
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
                                if let user = rootView.client.auth.currentUser {
                                    rootView.profile.coachAccount = true
                                    try await rootView.client
                                        .from("profiles")
                                        .update(["coach_account": true])
                                        .eq("id", value: user.id)
                                        .execute()
                                    
                                    let newCoach = CoachProfile(
                                        id: user.id,
                                        coachingAchievements: [],
                                        coachingExperience: [],
                                        timeAvailability: [:],
                                        athleteMessaging: true,
                                        sports: [],
                                        sportPositions: [:],
                                        coachUpcomingSessions: [],
                                        coachUnsubmittedSessions: [],
                                        coachSubmittedSessions: [],
                                        jobRequests: [],
                                        athleteRequests: [],
                                        interestedAthletes: [],
                                        currentAthletes: [:],
                                        trainingLocations: []
                                    )

                                    try await rootView.client
                                      .from("coach_profile")
                                      .upsert(newCoach)
                                      .execute()
                                    try await rootView.loadProfile()
                                } else {
                                    let res = try await rootView.client.auth.signUp(
                                        email: signupDraft.email,
                                        password: signupDraft.password
                                    )
                                    guard res.session != nil else {
                                        throw NSError(domain: "Auth", code: 0,
                                          userInfo: [NSLocalizedDescriptionKey: "Not signed in after signup (email confirmation still on or session not set)."])
                                    }
                                    let rowP = Profile(
                                        id: res.user.id,
                                        firstName: signupDraft.firstName,
                                        lastName: signupDraft.lastName,
                                        coachAccount: true,
                                        userType: signupDraft.userType
                                    )
                                    try await rootView.client
                                      .from("profiles")
                                      .insert(rowP)
                                      .execute()
                
                                    let newCoach = CoachProfile(
                                      id: res.user.id,
                                      coachingAchievements: [],
                                      coachingExperience: [],
                                      timeAvailability: [:],
                                      athleteMessaging: true,
                                      sports: [],
                                      sportPositions: [:],
                                      coachUpcomingSessions: [],
                                      coachUnsubmittedSessions: [],
                                      coachSubmittedSessions: [],
                                      jobRequests: [],
                                      athleteRequests: [],
                                      interestedAthletes: [],
                                      currentAthletes: [:],
                                      trainingLocations: []
                                    )

                                    try await rootView.client
                                      .from("coach_profile")
                                      .insert(newCoach)
                                      .execute()
                                    try await rootView.loadProfile()
                                }
                                rootView.path = NavigationPath()
                                rootView.rootView = .Coach
                            } catch {
                                await MainActor.run {
                                    alertMessage = "Signup failed: \(error.localizedDescription)"
                                    showAlert = true
                                }
                                print("Signup failed:", error)
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

import SwiftUI
import Supabase
import PhotosUI

struct Account: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var isInitialLoad = true
    @State private var profilePic: PhotosPickerItem?
    @State private var avatarURL: URL?
    @State private var firstName: String = "" {
        didSet {
            if !isInitialLoad && firstName != oldValue {
                rootView.isUnSaved = true
            }       }
    }
    @State private var lastName: String = "" {
        didSet {
            if !isInitialLoad && lastName != oldValue {
                rootView.isUnSaved = true
            }        }
    }
    @State private var userType: String = "" {
        didSet {
            if !isInitialLoad && userType != oldValue {
                rootView.isUnSaved = true
            }        }
    }
    
    // TODO: Payment info
    @State private var card = "Visa"
    @State private var cardEnding = "0000"
    
    @State private var notifications: Bool = false {
        didSet {
            if !isInitialLoad && notifications != oldValue {
                rootView.isUnSaved = true
            }        }
    }
    @State private var coachMessaging: Bool = true {
        didSet {
            if !isInitialLoad && coachMessaging != oldValue {
                rootView.isUnSaved = true
            }
        }
    }
    @State private var whosUsingOptions: [String] = ["Athlete", "Parent"]
    // Logout alert
    @State private var showingLogAlert: Bool = false
    // Photo error message
    @State private var showPhotoError: Bool = false
    @State private var photoErrorMessage: String = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Profile Header Card
                    VStack(spacing: 16) {
                        PhotosPicker(selection: $profilePic, matching: .images) {
                            if let avatarURL {
                                AsyncImage(url: avatarURL) { phase in
                                    switch phase {
                                    case .success(let img):
                                        img.resizable().scaledToFill()
                                    default:
                                        Image("athlinklogo").resizable().scaledToFill()
                                    }
                                }
                            } else {
                                Image("athlinklogo").resizable().scaledToFill()
                            }
                        }
                        .frame(width: 90, height: 90)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 3))
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                        .onChange(of: profilePic) { _, newItem in
                            Task {
                                // Convert new item into UI image
                                guard let item = newItem,
                                      let data = try? await item.loadTransferable(type: Data.self),
                                      let uiImage = UIImage(data: data) else { return }
                                do {
                                    // Call helper to upload to bucket
                                    try await uploadImage(client: rootView.client, image: uiImage, name: rootView.profile.id.uuidString)
                                    // Load to frontend UI
                                    if rootView.profile.imageURL.hasPrefix("http"),
                                       let url = URL(string: rootView.profile.imageURL) {
                                        avatarURL = url
                                    }
                                } catch {
                                    // Shows message with error
                                    photoErrorMessage = "Photo upload failed: \(error.localizedDescription)"
                                    showPhotoError = true
                                }
                            }
                        }

                        Text(rootView.profile.fullName)
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .alert("Upload Error", isPresented: $showPhotoError) {
                        Button("OK", role: .cancel) {}
                    } message: {
                        Text(photoErrorMessage)
                    }

                    // Personal Info Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Personal Info")
                            .font(.headline)

                        FieldRow(title: "First:", text: $firstName)
                        FieldRow(title: "Last:", text: $lastName)

                        VStack(alignment: .leading, spacing: 6) {
                            Text("User:")
                                .font(.headline)
                            Picker("Select user", selection: $userType) {
                                ForEach(whosUsingOptions, id: \.self) { userOption in
                                    Text(userOption).tag(userOption)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Payment Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Payment")
                            .font(.headline)
                        HStack(spacing: 12) {
                            Image(systemName: "building.columns")
                                .font(.title2)
                                .foregroundColor(.blue)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Direct Deposit")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text("\(card) ending in ...\(cardEnding)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button(action: {}) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Settings Card
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Settings")
                            .font(.headline)
                        Toggle("Notifications", isOn: $notifications)
                            .tint(.blue)
                        Toggle("Coach Messaging", isOn: $coachMessaging)
                            .tint(.blue)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    .padding(.horizontal)

                    // Save Button
                    Button(action: {
                        rootView.isUnSaved = false
                        Task {
                            do {
                                // Update Backend
                                guard let user = rootView.client.auth.currentUser else { return }
                                let patch = ProfilePatchFirst(
                                    first_name: firstName.isEmpty ? nil : firstName,
                                    last_name: lastName.isEmpty ? nil : lastName,
                                    user_type: userType.isEmpty ? nil : userType,
                                    notifications: notifications,
                                    coach_messaging: coachMessaging
                                )
                                try await rootView.client
                                    .from("profiles")
                                    .update(patch)
                                    .eq("id", value: user.id)
                                    .execute()
                                try await rootView.loadProfile()
                            } catch {
                                print("Update failed:", error)
                            }
                        }
                    }) {
                        Text("Save Changes")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Logout
                    Button(action: { showingLogAlert = true }) {
                        Text("Log Out")
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                    }
                    .alert(isPresented: $showingLogAlert) {
                        Alert(
                            title: Text("Are you sure you want to log out?"),
                            primaryButton: .destructive(Text("Log Out")) {
                                // Sign out of auth
                                Task { await rootView.signOut() }
                            },
                            secondaryButton: .cancel()
                        )
                    }

                    Text("2024 AthLink Inc. All Rights Reserved")
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.bottom, 20)
                }
                .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .onAppear() {
            // Setting Variables
            firstName = rootView.profile.firstName
            lastName = rootView.profile.lastName
            userType = rootView.profile.userType
            notifications = rootView.profile.notifications
            coachMessaging = rootView.profile.coachMessaging
            // Image
            if rootView.profile.imageURL.hasPrefix("http"),
               let url = URL(string: rootView.profile.imageURL)  {
                avatarURL = url
            } else{
                avatarURL = nil
            }
            // Other
            isInitialLoad = false
        }
        // Alert for unsaves changes
        .alert("Unsaved Changees", isPresented: $rootView.showUnSavedAlert) {
            // Set tab to other tab and doesnt save
            Button("Cancel", role: .cancel) {
                rootView.isUnSaved = false
                if let tab = rootView.pendingTab {
                    rootView.selectedTab = tab
                    rootView.pendingTab = nil
                }
            }
            // Set tab to other tab and saves
            Button("Save") {
                rootView.isUnSaved = false
                let tab = rootView.pendingTab
                rootView.pendingTab = nil
                if let tab { rootView.selectedTab = tab }
                Task {
                    do {
                        guard let user = rootView.client.auth.currentUser else { return }
                        let patch = ProfilePatchFirst(
                            first_name: firstName.isEmpty ? nil : firstName,
                            last_name: lastName.isEmpty ? nil : lastName,
                            user_type: userType.isEmpty ? nil : userType,
                            notifications: notifications,
                            coach_messaging: coachMessaging
                        )
                        try await rootView.client
                            .from("profiles")
                            .update(patch)
                            .eq("id", value: user.id)
                            .execute()
                        try await rootView.loadProfile()
                    } catch {
                        print("Update failed:", error)
                    }
                }
            }
        } message: {
            Text("You have unsaved data, swiching tabs will loose changes.")
        }
    }
}


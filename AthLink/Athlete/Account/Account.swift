import SwiftUI
import Supabase
import PhotosUI
import StripePaymentSheet

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
    @State private var whosUsingOptions: [String] = ["Athlete", "Parent"]
    // Logout alert
    @State private var showingLogAlert: Bool = false
    // Photo error message
    @State private var showPhotoError: Bool = false
    @State private var photoErrorMessage: String = ""
    // Stripe
    @State private var paymentSheet: PaymentSheet?
    @State private var showPaymentSheet: Bool = false
    @State private var paymentLoading: Bool = false
    struct StripeResponse: Decodable {
        let setupIntent: String
        let ephemeralKey: String
        let customer: String
    }
    
    // Checks if customer still has a payment method on file
    private func checkPaymentMethod() async {
        do {
            let url = URL(string: "\(infoValue(key: "SUPABASE_URL"))/functions/v1/check-payment")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(rootView.client.auth.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(["customer_id": rootView.profile.stripeCustomerId ?? ""])

            let (data, _) = try await URLSession.shared.data(for: request)
            let result = try JSONDecoder().decode([String: Bool].self, from: data)
            let hasMethod = result["hasPaymentMethod"] ?? false

            await MainActor.run { rootView.profile.hasPaymentMethod = hasMethod }
            guard let user = rootView.client.auth.currentUser else { return }
            try await rootView.client
                .from("profiles")
                .update(["has_payment_method": hasMethod])
                .eq("id", value: user.id)
                .execute()
        } catch {
            log.error("Check payment method failed: \(error.localizedDescription)")
        }
    }

    // Sets up payment sheets for cards and apple pay
    private func preparePaymentSheet() async {
        paymentLoading = true
        defer { paymentLoading = false }
        
        do {
            // Creates http request to edge function to get empherical key and intent
            let url = URL(string: "\(infoValue(key: "SUPABASE_URL"))/functions/v1/quick-function")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(rootView.client.auth.currentSession?.accessToken ?? "")", forHTTPHeaderField: "Authorization")
            // Gives it stripe id
            request.httpBody = try JSONEncoder().encode(["customer_id": rootView.profile.stripeCustomerId ?? ""])
                
            // Decode the response
            let (data, _) = try await URLSession.shared.data(for: request)
            let stripeResponse = try JSONDecoder().decode(StripeResponse.self, from: data)
            
            // Set payment sheet info
            var configuration = PaymentSheet.Configuration()
            configuration.merchantDisplayName = "AthLink"
            configuration.customer = .init(id: stripeResponse.customer, ephemeralKeySecret: stripeResponse.ephemeralKey)
            configuration.returnURL = "athlink://stripe-redirect"
            configuration.paymentMethodOrder = ["card"]
            paymentSheet = PaymentSheet(setupIntentClientSecret: stripeResponse.setupIntent, configuration: configuration)
            DispatchQueue.main.async {
                showPaymentSheet = true
            }
        } catch {
            log.error("Failed to prepare payment sheet: \(error.localizedDescription)")
        }
    }
    
    
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
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Payment")
                            .font(.headline)

                        HStack(spacing: 14) {
                            Image(systemName: "creditcard.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 10))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(rootView.profile.hasPaymentMethod
                                     ? "Card on File"
                                     : "No Payment Method")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(rootView.profile.hasPaymentMethod
                                     ? "Tap to update your payment method"
                                     : "Add a card to book sessions")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if paymentLoading {
                                ProgressView()
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            Task { await preparePaymentSheet() }
                        }
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
                                    user_type: userType.isEmpty ? nil : userType
                                )
                                try await rootView.client
                                    .from("profiles")
                                    .update(patch)
                                    .eq("id", value: user.id)
                                    .execute()
                                try await rootView.loadProfile()
                            } catch {
                                log.error("Profile update failed: \(error.localizedDescription)")
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

                    Text("2026 AthLink Inc. All Rights Reserved")
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
        .alert("Unsaved Changes", isPresented: $rootView.showUnSavedAlert) {
            // Set tab to other tab and doesnt save
            Button("Leave", role: .destructive) {
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
                            user_type: userType.isEmpty ? nil : userType
                        )
                        try await rootView.client
                            .from("profiles")
                            .update(patch)
                            .eq("id", value: user.id)
                            .execute()
                        try await rootView.loadProfile()
                    } catch {
                        log.error("Profile update failed: \(error.localizedDescription)")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You have unsaved changes. Save them before leaving this page?")
        }
        // Payment sheet
        .stripePaymentSheet(isPresented: $showPaymentSheet, paymentSheet: paymentSheet) { result in
            switch result {
            case .completed:
                log.info("Payment method saved")
            case .canceled:
                log.info("Payment sheet canceled")
            case .failed(let error):
                log.error("Payment sheet failed: \(error.localizedDescription)")
            }
            Task { await checkPaymentMethod()
            }
        }
    }
}

extension View {
    @ViewBuilder
    func stripePaymentSheet(isPresented: Binding<Bool>, paymentSheet: PaymentSheet?, onCompletion: @escaping (PaymentSheetResult) -> Void) -> some View {
        if let paymentSheet {
            self.paymentSheet(isPresented: isPresented, paymentSheet: paymentSheet, onCompletion: onCompletion)
        } else {
            self
        }
    }
}

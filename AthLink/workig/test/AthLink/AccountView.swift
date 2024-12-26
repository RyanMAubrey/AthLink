//
//  AccountView.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 9/21/24.
//

// make card payment wher ethey set up bank account, just make api format
// when preview profile show profile preview
// put descriptions under the notifications and athlete requests
// change swithces from green to blue
// move availability above notifications
// scrap save changes, make changes automatically save to database
//
//

import SwiftUI

import SwiftUI

struct AccountView: View {
    @State private var username = "First Last"
    @State private var password = "1234"
    @State private var email = "coach123@gmail.com"
    @State private var bio = "Bio here"
    @State private var postalCode = "91711"
    @State private var editingProfile = false
    var profilePic = "athlinklogo"
    @State private var firstName = "First name"
    @State private var lastName = "Last name"
    @State private var phone = "000-000-0000"
    @State private var user = "Athlete"
    @State private var card = "Chase"
    @State private var cardEnding = "0000"
    @State private var notifications = true
    @State private var coachMessaging = true
    @State private var whosUsingOptions = ["Athlete", "Parent"]
    @State private var showingDeleteAlert = false
    @State private var selectedAvailability: [String: [String]] = [:]
    
    @State private var trainingLocation: String = ""
    @State private var individualRate: String = ""
    @State private var groupRate: String = ""
    @State private var quote: String = ""
    @State private var about: String = ""
    @State private var coachingExperience: String = ""
    @State private var athleticAchievement: String = ""
    @State private var sportPosition: String = ""
    @FocusState private var focusedField: Field?
    
    @State private var locations: [String] = [] // Array to store locations
    @State private var newLocation: String = "" // String for new location
    
    enum Field: Hashable {
            case quote, about, coachingExperience, athleticAchievement
        }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Profile Header
                    Text("Account")
                        .font(.largeTitle)
                        .padding()

                    VStack(alignment: .leading) {
                        // Profile Pic and Name
                        HStack {
                            Image(profilePic)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                .shadow(radius: 10)
                            
                            VStack(alignment: .leading) {
                                Text(username)
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .padding(.leading, 10)
                        }
                        .padding(.bottom, 10)

                        Text("Information:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 10)
                        Group {
                            HStack {
                                Text("First:")
                                    .font(.headline)
                                Spacer()
                                TextField("First", text: $firstName)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .padding(.bottom, 10)

                            HStack {
                                Text("Last:")
                                    .font(.headline)
                                Spacer()
                                TextField("Last", text: $lastName)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .padding(.bottom, 10)

                            HStack {
                                Text("Email:")
                                    .font(.headline)
                                Spacer()
                                TextField("Email", text: $email)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .padding(.bottom, 10)

                            HStack {
                                Text("Password:")
                                    .font(.headline)
                                Spacer()
                                SecureField("Password", text: $password)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .padding(.bottom, 10)

                            HStack {
                                Text("Phone:")
                                    .font(.headline)
                                Spacer()
                                TextField("Phone", text: $phone)
                                    .padding(5)
                                    .background(Color.white)
                                    .cornerRadius(5)
                            }
                            .padding(.bottom, 10)

//                            HStack {
//                                Text("User:")
//                                    .font(.headline)
//                                Spacer()
//                                Picker("Select user", selection: $user) {
//                                    ForEach(whosUsingOptions, id: \.self) { option in
//                                        Text(option).tag(option)
//                                    }
//                                }
//                                .padding(5)
//                                .background(Color.white)
//                                .cornerRadius(5)
//                            }
//                            .padding(.bottom, 10)

                            HStack {
                                Text("Direct Deposit:")
                                    .font(.headline)
                                Spacer()
                                TextField("Card", text: $card)
                                    .multilineTextAlignment(.trailing)
                            }
                            .padding(.bottom, 20)
                        }

                        
                        
                        Text("Availability:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.top, 10)

                        AvailabilityGrid(selectedA: $selectedAvailability)
                        
                        // Training Location
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Training Location:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 10)
                            }
                            Spacer()
                            Button(action: {
                                // TODO: add location

                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title)
                            }
                            .padding(.leading, 8)
                        }

                        
                        // Hourly Rate
                        VStack(alignment: .leading) {
                            Text("Hourly Rate:")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 10)
                            HStack {
                                Text("Individual:")
                                Spacer()
                                TextField("$", text: $individualRate)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)
                            }
                            HStack {
                                Text("Group:")
                                Spacer()
                                TextField("$", text: $groupRate)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(width: 100)
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Photo Upload:")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .padding(.top, 10)
                            }
                            Spacer()
                            Button(action: {
                                // TODO: add location

                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title)
                            }
                            .padding(.leading, 8)
                        }
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("About:")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.top, 10)
                            
                            VStack(alignment: .leading) {
                                Text("Quote:")
                                TextField("Enter quote...", text: $quote)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: focusedField == .quote ? 80 : 40)  // Expanded height when focused
                                    .focused($focusedField, equals: .quote)
                                    .animation(.easeInOut(duration: 0.3), value: focusedField) // Smooth animation
                            }
                            
                            // About Section
                            VStack(alignment: .leading) {
                                Text("About:")
                                TextField("Enter about info...", text: $about)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: focusedField == .about ? 60 : 40)
                                    .focused($focusedField, equals: .about)
                                    .animation(.easeInOut, value: focusedField)
                            }
                            
                            // Coaching Experience Section
                            VStack(alignment: .leading) {
                                Text("Coaching Experience:")
                                TextField("Enter experience...", text: $coachingExperience)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: focusedField == .coachingExperience ? 60 : 40)
                                    .focused($focusedField, equals: .coachingExperience)
                                    .animation(.easeInOut, value: focusedField)
                            }
                            
                            // Athletic Achievement Section
                            VStack(alignment: .leading) {
                                Text("Athletic Achievement:")
                                TextField("Enter achievement...", text: $athleticAchievement)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .frame(height: focusedField == .athleticAchievement ? 60 : 40)
                                    .focused($focusedField, equals: .athleticAchievement)
                                    .animation(.easeInOut, value: focusedField)
                            }
                        }
                        
                        // Sport/Position
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Sport/Position:")
                                    .font(.headline)
                            }
                            Spacer()
                            Button(action: {
                                // TODO: add location

                            }) {
                                Image(systemName: "plus.circle")
                                    .font(.title)
                            }
                            .padding(.leading, 8)
                        }
                        
                        Button(action: {
                            // input preview profile
                        }) {
                            Text("Preview Profile")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Toggle(isOn: $notifications) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Turn notifications on or off")
                                        .font(.headline)
                                    Text("Enable or disable notifications for updates and alerts.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding(.horizontal, 5)

                            Toggle(isOn: $coachMessaging) {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Turn athlete requests on or off")
                                        .font(.headline)
                                    Text("Allow athletes to send coaching requests.")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: .blue))
                            .padding(.horizontal, 5)
                        }

                        .padding(.bottom, 20)
                        Button(action: {
                            // update account information once database set up
                        }) {
                            Text("Save Changes")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }

                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding([.leading, .trailing], 20)


                    // Turn messages off, Save Changes, Delete Account
                    VStack(alignment: .center) {
                        VStack(alignment: .leading) {

            
                        }
                        
                        Button(action: {
                            // sign out
                        }) {
                            Text("Sign Out")
                                .font(.headline)
                                .foregroundColor(.red)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(action: {
                            showingDeleteAlert = true
                        }) {
                            Text("Delete my Account")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .alert(isPresented: $showingDeleteAlert) {
                            Alert(
                                title: Text("Are you sure you want to delete your account?"),
                                message: Text("This action cannot be undone."),
                                primaryButton: .destructive(Text("Yes I am sure")) {
                                    // delete account from database
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)

                    Text("@2024-2024 AthLink Inc. All Rights Reserved")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.top)
                }
            }
            .padding(.top, 20)
        }
    }
}

struct AvailabilityGrid: View {
    @Binding var selectedA: [String: [String]]
    
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let times = Array(6..<12).map { "\($0) AM" } + Array(12..<18).map { "\($0 - 12) PM" }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 2) {
                Text("")
                    .frame(width: 40)
                ForEach(days, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(3)
                }
            }
            
            ForEach(times.indices, id: \.self) { index in
                HStack(spacing: 2) {
                    Text(times[index])
                        .font(.caption)
                        .frame(width: 40, alignment: .leading)
                    ForEach(0..<7) { dayIndex in
                        Button(action: {
                            toggleAvailability(day: days[dayIndex], timeSlot: times[index])
                        }) {
                            Rectangle()
                                .fill(isSelected(day: days[dayIndex], timeSlot: times[index]) ? Color.blue : Color.gray.opacity(0.2))
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(height: 25)
                    }
                }
                .frame(height: 30)
            }
        }
        .padding(5)
    }
    
    func toggleAvailability(day: String, timeSlot: String) {
        if selectedA[day]?.contains(timeSlot) ?? false {
            selectedA[day]?.removeAll(where: { $0 == timeSlot })
        } else {
            selectedA[day, default: []].append(timeSlot)
        }
    }
    
    func isSelected(day: String, timeSlot: String) -> Bool {
        return selectedA[day]?.contains(timeSlot) ?? false
    }
}


struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}


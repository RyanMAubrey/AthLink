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

import SwiftUI

struct AccountView: View {
    @EnvironmentObject var rootView: RootViewObj
    
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
    @State private var showingLogAlert = false
    @State private var showingDeleteAlert = false
    @State private var selectedAvailability: [String: [String]] = [:]

    var body: some View {
        VStack(alignment: .center) {
            ScrollView(.vertical) {
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
                        HStack {
                            VStack (alignment: .leading){
                                Text("Payment:")
                                    .font(.headline)
                                HStack (alignment: .center){
                                    Text("Direct Deposit")
                                        .frame(width: 70, height: 50)
                                        .lineLimit(2)
                                    Image(systemName: "building.columns")
                                        .resizable()
                                        .frame(width:35, height: 35)
                                        .scaledToFit()
                                        .padding(.trailing, 5)
                                    Button(action: {
                                        //TODO add button functionality
                                    }) {
                                        Image(systemName: "plus")
                                    }
                                    Spacer()
                                    TextField("Card", text: $card)
                                        .multilineTextAlignment(.trailing)
                                    Text("Ending in (...\(cardEnding))")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.bottom, 20)
                    }

                    Text("Availability:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 10)

                    AvailabilityGrid(selectedA: $selectedAvailability)
                    
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
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Toggle(isOn: $notifications) {
                            Text("Turn notifications on or off")
                        }
                        .padding(.horizontal, 5)

                        Toggle(isOn: $coachMessaging) {
                            Text("Turn athlete requests on or off")
                        }
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

                // logout, Delete Account, terms
                VStack(alignment: .center) {
                    // Logout Button
                    Button(action: {
                        showingLogAlert = true
                    }) {
                        Text("Log Out")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding([.top,.bottom], 10)
                    }
                    .alert(isPresented: $showingLogAlert) {
                        Alert(
                            title: Text("Are you sure you want to log out of your account?"),
                            primaryButton: .destructive(Text("Yes, I am sure")) {
                                rootView.rootView = .Login
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    // delete account
                    Button(action: {
                        showingDeleteAlert = true
                    }) {
                        Text("Delete my Account")
                            .font(.headline)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.bottom)
                    }
                    .alert(isPresented: $showingDeleteAlert) {
                        Alert(
                            title: Text("Are you sure you want to delete your account?"),
                            message: Text("This action cannot be undone."),
                            primaryButton: .destructive(Text("Yes I am sure")) {
                                rootView.rootView = .Login
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    Text("@2024-2024 AthLink Inc. All Rights Reserved")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .padding(.leading)
                }
            }
        }
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(RootViewObj())
    }
}

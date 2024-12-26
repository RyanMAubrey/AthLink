//
//  Account.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/6/24.
//

import SwiftUI

struct Account: View {
    @State private var path = NavigationPath()
    @StateObject var fsearch = Cond()
    @State private var navigateTomess: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateTohome: Bool = false

    @State private var username = "First Last"
    @State private var password = "1234"
    @State private var email = "athlete123@gmail.com"
    @State private var bio = "Bio here"
    @State private var postalCode = "91711"
    @State private var editingProfile = false
    var profilePic = "athlinklogo"
    @State private var firstName = "First name"
    @State private var lastName = "Last name"
    @State private var phone = "000-000-0000"
    @State private var user = "Athlete"
    @State private var card = "Visa"
    @State private var cardEnding = "0000"
    @State private var notifications = true
    @State private var coachMessaging = true
    @State private var whosUsingOptions = ["Athlete", "Parent"]
    @State private var showingDeleteAlert = false

    var body: some View {
        if navigateTohome{
            home()
        } else if navigateTosess{
            Sessions()
        } else if navigateTomess{
            Messages()
        } else {
            NavigationStack(path: $path){
                VStack{
                    ScrollView(.vertical) {
                        VStack(alignment: .leading) {
                            Text("Account")
                                .font(.largeTitle)
                                .padding()
                            
                            VStack(alignment: .leading) {
                                // profile pic
                                HStack {
                                    Image(profilePic)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                        .shadow(radius: 10)
                                    
                                    VStack(alignment: .leading) {
                                        // users username
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
                                        //.multilineTextAlignment(.trailing)
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
                                        Text("User:")
                                            .font(.headline)
                                        Spacer()
                                        Picker("Select user", selection: $user) {
                                            ForEach(whosUsingOptions, id: \.self) { whosUsingOptions in
                                                Text(whosUsingOptions).tag(whosUsingOptions)
                                            }
                                            .padding(5)
                                            .background(Color.white)
                                            .cornerRadius(5)
                                        }
                                        .padding(5)
                                        .background(Color.white)
                                        .cornerRadius(5)
                                    }
                                    .padding(.bottom, 10)
                                    
                                    HStack {
                                        Text("Card:")
                                            .font(.headline)
                                        Spacer()
                                        TextField("Card", text: $card)
                                            .multilineTextAlignment(.trailing)
                                        Text("Ending in \(cardEnding)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.bottom, 20)
                                }
                                
                                VStack(alignment: .leading, spacing: 10) {
                                    Toggle(isOn: $notifications) {
                                        Text("Turn notifications on or off")
                                    }
                                    .padding(.horizontal, 5)
                                    
                                    Toggle(isOn: $coachMessaging) {
                                        Text("Turn coach messaging on or off")
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
                                
                                Button(action: {
                                    showingDeleteAlert = true
                                }) {
                                    Text("Delete my Account")
                                        .font(.headline)
                                        .foregroundColor(.red)
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
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .padding([.leading, .trailing], 20)
                            
                            Text("@2024-2024 AthLink Inc. All Rights Reserved")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .padding(.leading, 20)
                        }
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(10)
                    // bottom bar
                    HStack (spacing: 20) {
                        // home
                        Button(action: {
                            navigateTohome = true
                        }) {
                            VStack (spacing: -10){
                                Image(systemName: "house.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 50)
                                    .foregroundStyle(Color.gray)
                                //.padding(.top, 8)
                                Text("Home")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                //.padding([.bottom, .horizontal], 8)
                            }
                        }
                        // Search
                        Button(action: {
                            path.append("Search")
                        }) {
                            VStack (spacing: -10){
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 50)
                                    .foregroundStyle(Color.gray)
                                //.padding(.top, 8)
                                Text("Search")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                //.padding([.bottom, .horizontal], 8)
                            }
                        }
                        // Messages
                        Button(action: {
                            navigateTomess = true
                        }) {
                            VStack (spacing: -10){
                                Image(systemName: "bell")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 50)
                                    .foregroundStyle(Color.gray)
                                //.padding(.top, 8)
                                Text("Messages")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                //.padding([.bottom, .horizontal], 8)
                            }
                        }
                        //Sessions
                        Button(action: {
                            navigateTosess = true
                        }) {
                            VStack (spacing: -10){
                                Image(systemName: "doc.text")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 50)
                                    .foregroundStyle(Color.gray)
                                //.padding(.top, 8)
                                Text("Sessions")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                //.padding([.bottom, .horizontal], 8)
                            }
                        }
                        // Account
                        Button(action: {
                        }) {
                            VStack (spacing: -10){
                                Image(systemName: "person")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 50)
                                    .foregroundStyle(Color.gray)
                                //.padding(.top, 8)
                                Text("Account")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                //.padding([.bottom, .horizontal], 8)
                            }
                        }
                    }
                }
                .navigationDestination(for: String.self) { destination in
                    if destination == "Search" {
                        Search()
                            .environmentObject(fsearch)
                    } else if destination == "FSearch" {
                        FSearch()
                            .environmentObject(fsearch)
                    }
                }
                .onChange(of: fsearch.fSearch) {
                    if fsearch.fSearch {
                        path.removeLast()
                        path.append("FSearch")
                    } else {
                        path.removeLast()
                        path.append("Search")
                    }
                }
                .onAppear() {
                    fsearch.validZ = false
                    fsearch.zip = ""
                    fsearch.sportVal = 0
                    fsearch.fSearch = false
                }
                
            }
        }
    }
}

#Preview {
    Account()
}

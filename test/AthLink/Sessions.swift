//
//  Sessions.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/7/24.
//
// #TODO# click to go to profile of coaches

import SwiftUI

struct Session: Identifiable {
    let id = UUID()
    let name: String
    let sport: String
    let type: String
    let cost: String
    let date: String
    var profilePic = "athlinklogo"
}

struct Sessions: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var navigateTomess: Bool = false
    @State private var navigateTohome: Bool = false
    @State private var navigateToaccount: Bool = false
    @State private var selectedTab : String = "Upcoming"

    let upcomingSessions: [Session] = [
        Session(name: "Larry Smith", sport: "Basketball", type: "Individual", cost: "$110", date: "May 30, 2024 - 10:00 AM")
    ]

    let previousSessions: [Session] = [
        Session(name: "Larry Smith", sport: "Basketball", type: "Individual", cost: "$110", date: "May 26, 2024 - 10:00 AM"),
        Session(name: "Gary Jones", sport: "Soccer", type: "Group", cost: "$70", date: "May 20, 2024 - 11:30 AM")
    ]

    var body: some View {
        if navigateTomess{
            Messages()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateTohome{
            home()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateToaccount{
            Account()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        }  else {
            VStack(spacing: 0) {
                Text("Sessions")
                    .font(.largeTitle)
                    .padding()
                HStack {
                    Button(action: {
                        selectedTab = "Upcoming"
                    }) {
                        Text("Upcoming")
                            .padding()
                            .foregroundColor(selectedTab == "Upcoming" ? .white : .blue)
                            .background(selectedTab == "Upcoming" ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        selectedTab = "Previous"
                    }) {
                        Text("Previous")
                            .padding()
                            .foregroundColor(selectedTab == "Previous" ? .white : .blue)
                            .background(selectedTab == "Previous" ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                if selectedTab == "Upcoming" {
                    SessionListView(sessions: upcomingSessions)
                } else {
                    SessionListView(sessions: previousSessions)
                }
                                    
                // line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(.bottom, 10)
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
                            Text("Home")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    // Search
                    Button(action: {
                        rootView.path.append("Search")
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "magnifyingglass")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Search")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
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
                            Text("Messages")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    //Sessions
                    Button(action: {
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "doc.text")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.black)
                                .bold()
                            Text("Sessions")
                                .font(.caption)
                                .foregroundStyle(Color.black)
                                .bold()
                        }
                    }
                    // Account
                    Button(action: {
                        navigateToaccount = true
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "person")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Account")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear() {
                fSearch.validZ = false
                fSearch.zip = ""
                fSearch.sportVal = 0
                fSearch.fSearch = false
            }
        }
        
    }
}

struct SessionListView: View {
    let sessions: [Session]

    var body: some View {
        List(sessions) { session in
            HStack {
                Image(session.profilePic)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    .shadow(radius: 3)
                VStack(alignment: .leading) {
                    Text(session.name)
                        .font(.headline)
                    Text(session.sport)
                        .font(.subheadline)
                    Text(session.type + ": " + session.cost)
                    Text(session.date)
                }
                .padding()
            }
        }
    }
}

#Preview {
    Sessions()
        .environmentObject(RootViewObj())
        .environmentObject(SearchHelp())
}

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
    @State private var selectedTab = "Upcoming"

    let upcomingSessions: [Session] = [
        Session(name: "Larry Smith", sport: "Basketball", type: "Individual", cost: "$110", date: "May 30, 2024 - 10:00 AM")
    ]

    let previousSessions: [Session] = [
        Session(name: "Larry Smith", sport: "Basketball", type: "Individual", cost: "$110", date: "May 26, 2024 - 10:00 AM"),
        Session(name: "Gary Jones", sport: "Soccer", type: "Group", cost: "$70", date: "May 20, 2024 - 11:30 AM")
    ]

    var body: some View {
        VStack {
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

            Spacer()
        }
        .navigationBarTitle("Sessions")
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
}

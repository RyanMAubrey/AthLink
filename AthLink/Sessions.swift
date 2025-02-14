//
//  Sessions.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/7/24.
//
// #TODO# click to go to profile of coaches

import SwiftUI

struct Sessions: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var selectedTab : String = "Upcoming"
    
    var body: some View {
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
                SessionListView(sessions: rootView.profile.aupcomingSessions)
                    .environmentObject(rootView)
            } else {
                SessionListView(sessions: rootView.profile.apastSessions)
                    .environmentObject(rootView)
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

struct SessionListView: View {
    @EnvironmentObject var rootView: RootViewObj
    let sessions: [Session]

    var body: some View {
        List(sessions) { session in
            Button(action: {
                rootView.selectedSession = session.other
                rootView.path.append("CoachAccount")
            }) {
                HStack {
                    Image(session.other.profilePic)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        .shadow(radius: 3)
                    VStack(alignment: .leading) {
                        Text(session.other.fullName)
                            .font(.headline)
                        Text(session.sport)
                            .font(.subheadline)
                        Text(session.type + ": " + session.cost)
                        Text(session.date.formatted())
                    }
                    .padding()
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    let coach = ProfileID()
    coach.coachAccount = true
    coach.firstName = "Larry"
    coach.lastName = "Smith"
    coach.email = "larry.smith@example.com"
    coach.sport = [Sports.Football]
    coach.trainingLocations = ["Los Angeles", "Santa Monica"]
    coach.individualCost = 100
    coach.groupCost = 70

    let rootView = RootViewObj()
    rootView.profile.aupcomingSessions.append(
        Session(other: coach, sport: "Basketball", type: "Individual", cost: "$110", date: Date(), finished: 2 * 3600)
    )
    
    return Sessions()
        .environmentObject(rootView)
        .environmentObject(SearchHelp())
}

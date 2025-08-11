//
//  CoachSession.swift
//  AthLink
//
//  Created by RyanAubrey on 7/9/25.
//

import SwiftUI

struct CoachSession: View {
    @EnvironmentObject var rootView: RootViewObj
    @Binding var tabType: Bool
    
    var body: some View {
        if tabType{
            SessionListViewCoach(sessions: rootView.profile.cunsubmittedSessions, type: tabType)
                .environmentObject(rootView)
        } else{
            SessionListViewCoach(sessions: rootView.profile.csubmitedSessions, type: tabType)
                .environmentObject(rootView)
        }
    }
}


struct SessionListViewCoach: View {
    @EnvironmentObject var rootView: RootViewObj
    let sessions: [Session]
    let type: Bool
    @State private var selectedSession: Session?
    
    var body: some View {
        List(sessions) { session in
            Button(action: {
                selectedSession = session
            }) {
                HStack{
                    Image(session.other.imageURL)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                    VStack(alignment: .leading)  {
                        Text(session.other.fullName)
                            .font(.headline)
                        Text(session.sport.description)
                            .font(.subheadline)
                        Text(session.type.description + ": " + "$\(session.cost)")
                        // Finds the time between the end and start and formats it
                        Text(session.totalTime.0.description + ":" + session.totalTime.1.description)
                    }
                    .padding()
                }
            }
        }
        .sheet(item: $selectedSession) { sS in
            VStack {
                Capsule()
                    .fill(Color(UIColor.systemGray4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)
                
                Text("Information")
                    .font(.title2).bold()
                    .padding()

                Form {
                    // Athlete
                    Section(header: Text("Athlete")) {
                        Text(sS.other.fullName)
                    }
                    Section(header: Text("Total:")) {
                        Text(String(format: "$%.2f", sS.cost))
                    }
                    Section(header: Text("Time:")) {
                        Text(String(format: "%d:%02d", sS.totalTime.0, sS.totalTime.1))
                    }
                    Section(header: Text("Type:")) {
                        Text(sS.type.description)
                    }
                    if let location = sS.location {
                        Section(header: Text("Location:")) {
                            Text(location.name)
                        }
                    }
                    Section(header: Text("Sport:")) {
                        Text(sS.sport.description)
                    }
                }
                // Submit button
                if type {
                    Button(action: {
                        // Add to submited
                        rootView.profile.csubmitedSessions.append(sS)
                        // Remove from unsubmitted
                        rootView.profile.cunsubmittedSessions.removeAll(where: { $0.id == sS.id })
                        selectedSession = nil
                    }) { Text("Submit Session")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
    }
}

//#Preview {
//    CoachSession(tabType: .constant(false))
//        .environmentObject(RootViewObj())
//}

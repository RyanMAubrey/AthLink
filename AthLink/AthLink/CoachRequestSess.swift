//
//  CoachRequestSess.swift
//   Athlink
//
//  Created by RyanAubrey on 4/8/25.
//
import SwiftUI

struct CoachRequestSess: View {
    @EnvironmentObject var rootView: RootViewObj
    @Binding var chosenSess: Session
    @Binding var algo: Bool
    
    var body: some View {
        VStack {
            HStack {
                //name
                Text(chosenSess.other.fullName)
                //date requested
                Text(chosenSess.req_date.description)
            }
            //line
            Rectangle().frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(8)
            // credit card
            Image(systemName: "creditcard.fill")
                .foregroundColor(chosenSess.other.hasCardOnFile ? .teal : .red)
            //line
            Rectangle().frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(8)
            //rec rate
            HStack {
                Text("Recommended Rate: $\(chosenSess.rate)/hr")
                Button(action: {
                    
                }) {
                    Image(systemName: "info.circle")
                }
            }
            //line
            Rectangle().frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(8)
            // session time
            Text("Session Time: \(chosenSess.date.description)")
            //line
            Rectangle().frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(8)
            //training lcoation
            if let tl = chosenSess.location {
                Text("Location: \(tl.name)")
                //line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
            }
            //Sport
            Text("Session Time: \(chosenSess.sport)")
            //line
            Rectangle().frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(8)
            // Type
            Text("Session Time: \(chosenSess.type.description)")
            //line
            Rectangle().frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(8)
            // bottom buttone
            if (algo) {
                // sending request
                Button(action: {
                    rootView.path.removeLast()
                    rootView.path.append("Request")
                }) {
                    Text("Send Request")
                }
                // messaging athlete
                Button(action: {
                    rootView.profile.potentialAthletes.append(chosenSess.other)
                    rootView.path.removeLast()
                    rootView.selectedSession = chosenSess.other
                    rootView.path.append("MessageAccount")
                }) {
                    Text("Message Athlete")
                }
            } else {
                // accepting request
                Button(action: {
                    rootView.profile.cupcomingSessions.append(chosenSess)
                    rootView.profile.currentAthletes[chosenSess.other] = (0,0)
                    // removes session from Coach job request
                    rootView.profile.jobRequests.removeAll() { $0 == chosenSess }
                    // removes session from Athletes request
                    chosenSess.other.myRequests.removeAll() { $0 == chosenSess }
                    rootView.path.removeLast()
                }) {
                    Text("Accept Request")
                }
                // messaging athlete
                Button(action: {
                    rootView.profile.potentialAthletes.append(chosenSess.other)
                    rootView.path.removeLast()
                    rootView.selectedSession = chosenSess.other
                    rootView.path.append("MessageAccount")
                }) {
                    Text("Message Athlete")
                }
                // deleting request
                Button(action: {
                    // removes session from Coach job request
                    rootView.profile.jobRequests.removeAll() { $0 == chosenSess }
                    // removes session from Athletes request
                    chosenSess.other.myRequests.removeAll() { $0 == chosenSess }
                    rootView.path.removeLast()
                }) {
                    Text("Delete Request")
                }
            }
        }
    }
}

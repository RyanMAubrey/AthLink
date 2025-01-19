//
//  CouchAccount.swift
//  AthLink
//
//  Created by RyanAubrey on 12/20/24.
//

import SwiftUI

struct CouchAccount: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var sessionReq: Bool = false
    @State private var messageCo : Bool = false
    
    var body: some View {
        //top bar
        guard let selectedSession = rootView.selectedSession else {
            fatalError("selectedSession must not be nil when CouchAccount is opened.")
        }
        return Group {
            // Top Section
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .padding(8)
                    .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                    .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                HStack (alignment: .top) {
                    // Profile Image
                    Image(selectedSession.profilePic)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                    // First Stack
                    VStack (alignment: .leading) {
                        Text(selectedSession.fullName)
                            .font(.headline)
                        HStack(spacing: 2) {
                            ForEach(1..<6) { index in
                                if selectedSession.rating - Float(index) >= 0  {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                } else if selectedSession.rating - Float(index) == -0.5 {
                                    Image(systemName: "star.leadinghalf.fill")
                                        .foregroundColor(.yellow)
                                } else {
                                    Image(systemName: "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        HStack {
                            Text(String(selectedSession.rating))
                            Text("(\(selectedSession.ratings))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if let quote = selectedSession.quote {
                            Text("\"\(quote)\"")
                        }
                        if let sport = selectedSession.sport {
                            HStack(spacing: 4) {
                                ForEach(sport.indices, id: \.self) { index in
                                    if index == 0 {
                                        Text(sport[index])
                                    } else {
                                        Text(", \(sport[index])")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.trailing)
                    // Second Stack
                    VStack(alignment: .trailing) {
                        if let individualCost = selectedSession.individualCost,
                           let groupCost = selectedSession.groupCost {
                            VStack (alignment: .leading) {
                                Text("Individual: ")
                                Text("\(individualCost)/hr").bold()
                                Text("Group: ")
                                Text("\(groupCost)/hr").bold()
                            }
                        } else if let individualCost = selectedSession.individualCost {             VStack (alignment: .leading) {
                                Text("Individual: ")
                                Text("\(individualCost)/hr").bold()
                            }
                        } else if let groupCost = selectedSession.groupCost {
                            VStack (alignment: .leading) {
                                Text("Group: ")
                                Text("\(groupCost)/hr").bold()
                            }
                        } else {
                            Text("Cost not available")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
            }
            Spacer()
            
            // Below Top Section
            ScrollView(.vertical) {
                //buttons
                HStack {
                    Button(action: {
                        sessionReq = true
                    }) {
                        Text("Request Session")
                            .bold()
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    Button(action: {
                        messageCo = true
                    }) {
                        Text("MessageCo")
                            .bold()
                            .padding()
                            .foregroundColor(.black)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                //info
                HStack {
                    VStack {
                        
                    }
                    VStack {
                        
                    }
                }
                //line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
            }
        }
    }
}

#Preview {
    let mockSession = ProfileID()
    mockSession.coachAccount = true
    mockSession.firstName = "John"
    mockSession.lastName = "Doe"
    mockSession.rating = 4.5
    mockSession.ratings = 10
    mockSession.individualCost = 100
    mockSession.groupCost = 80
    mockSession.quote = "Never give up!"
    mockSession.sport = ["Basketball", "Soccer"]
    
    let rootView = RootViewObj()
    rootView.selectedSession = mockSession
    
    return CouchAccount()
        .environmentObject(rootView)
}

//
//  CouchAccount.swift
//  AthLink
//
//  Created by RyanAubrey on 12/20/24.
//

import SwiftUI

struct CouchAccount: View {
    //test:
    @State private var selectedAvailability: [String: [String]] = [:]
    
    
    @EnvironmentObject var rootView: RootViewObj
    @State private var sessionReq: Bool = false
    @Binding var prevMess: String
    
    var body: some View {
        //top bar
        if let selectedSession = rootView.selectedSession {
            // Top Section
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .padding(8)
                    .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                    .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                HStack (alignment: .center) {
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
                        } else if let individualCost = selectedSession.individualCost {
                            VStack (alignment: .leading) {
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
                VStack {
                    //Request
                    Button(action: {
                        rootView.path.append("Request")
                    }) {
                        Text("Request Session")
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 5)
                    //Message
                    Button(action: {
                        if prevMess == "Chat" {
                            prevMess = "Remove"
                        } else {
                            prevMess = "Sess"
                        }
                    }) {
                        Text("Message Coach")
                            .bold()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                //info
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Image(systemName: "mappin.circle")
                            .padding(.bottom, 5)
                        Text("Location")
                        Spacer()
                        VStack {
                            Text("Laguna Niguel, CA")
                            Text("1500 Miles")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        Image(systemName: "person")
                            .padding(.bottom, 5)
                        Text("People Coached")
                        Spacer()
                        Text("\(selectedSession.peopleCoached)")
                    }
                    HStack {
                        Image(systemName: "clock")
                            .padding(.bottom, 5)
                        Text("Hours Coaching")
                        Spacer()
                        Text("\(selectedSession.hoursCoached)")
                    }
                    HStack {
                        Image(systemName: "phone")
                            .padding(.bottom, 5)
                        Text("Response Time")
                        Spacer()
                        Text("\(selectedSession.responseTime)hr")
                    }
                    HStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .padding(.bottom, 5)
                        Text("Cancellation Notice")
                        Spacer()
                        Text("\(selectedSession.cancellationNotice)hr")
                    }
                }
                .padding([.leading,.trailing], 15)
                if let quote = selectedSession.quote {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("About")
                        .bold()
                    //About
                    Text(quote)
                }
                if !selectedSession.experience.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("Coaching Experience")
                        .bold()
                    //Experience
                    ForEach(selectedSession.experience, id: \.self) { ach in
                        Text(ach)
                            .padding([.leading,.trailing], 5)
                    }
                }
                if !selectedSession.acheivments.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("Athletic Acheivment")
                        .bold()
                    //Acheivments
                    VStack(alignment: .leading) {
                        ForEach(selectedSession.acheivments, id: \.self) { ach in
                            Text(ach)
                        }
                    }
                }
                //line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
                //Review
                VStack (alignment: .leading){
                    HStack {
                        Text("Reveiw")
                            .bold()
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
                        Text(String(selectedSession.rating))
                        Text("(\(selectedSession.ratings))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    if let lastReview = selectedSession.reviews.last {
                        VStack(alignment: .leading) {
                            Text(lastReview.quote)
                            Text(lastReview .reviewer.fullName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(lastReview.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("No reveiws yet")
                    }
                }
                //line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
                //Training Location
                Text("Training Locations")
                    .bold()
                if !selectedSession.trainingLocations.isEmpty {
                    VStack(alignment: .leading) {
                        ForEach(selectedSession.trainingLocations, id:\.self ) { loc in
                            Text(loc)
                        }
                    }
                } else {
                    Text("No Locations Yet")
                }
                //Sports/Position
                if !selectedSession.sport.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("Sports/Positions")
                        .bold()
                    VStack(alignment: .leading) {
                        ForEach(selectedSession.sport,  id: \.self) { sp in
                            VStack(alignment: .leading) {
                                Text("\(sp):")
                                ForEach(selectedSession.position[sp] ?? [],  id: \.self) { p in
                                    Text("\(p)")
                                }
                            }
                        }
                    }
                }
                //line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
                //Schedule
                Text("Avaliability")
                    .bold()
                AvailabilityGrid(selectedA: $selectedAvailability)
            }
            .onAppear() {
                if prevMess == "Sess" {
                    prevMess = ""
                }
            }
        }
    }
}

//#Preview {
//    let mockSession = ProfileID()
//    mockSession.coachAccount = true
//    mockSession.firstName = "John"
//    mockSession.lastName = "Doe"
//    mockSession.ratings = 10
//    mockSession.individualCost = 100
//    mockSession.groupCost = 80
//    mockSession.quote = "Never give up!"
//    mockSession.sport = [Sports.Football]
//    let pm: Bool = false
//    let rootView = RootViewObj()
//    rootView.selectedSession = mockSession
//    
//    return CouchAccount(prevMess: $pm)
//        .environmentObject(rootView)
//}

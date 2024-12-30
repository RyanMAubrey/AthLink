//
//  CouchAccount.swift
//  AthLink
//
//  Created by RyanAubrey on 12/20/24.
//

import SwiftUI

struct CouchAccount: View {
    
    @State private var sessionReq: Bool = false
    @State private var messageCo : Bool = false
    
    let int_coach : Coach = Coach(name: "Jill", message: "Info", date: "na", imageName: "coachprofile", sport: ["Soccer"], cost: ("Individual","115"))
    
    var body: some View {
        //top bar
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 150)
                .padding(8)
                .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
            HStack {
                Image(int_coach.imageName)
                    .resizable()
                    .scaledToFit()
                    .clipShape(Circle())
                    .padding(.leading, 10)
                VStack (alignment: .leading) {
                    Text(int_coach.name)
                        .font(.headline)
                    HStack(spacing: 2) {
                        ForEach(1..<6) { index in
                            if int_coach.rating - Float(index) >= 0  {
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                            } else if int_coach.rating - Float(index) == -0.5 {
                                Image(systemName: "star.leadinghalf.fill")
                                    .foregroundColor(.yellow)
                            } else {
                                Image(systemName: "star")
                                    .foregroundColor(.yellow)
                            }
                        }
                    }
                    HStack {
                        Text(String(int_coach.rating))
                        Text("(\(int_coach.ratings))")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                    }                    
                    Text("\"\(int_coach.message)\"")
                    HStack(spacing: 4) {
                        ForEach(int_coach.sport.indices, id: \.self) { index in
                            if index == 0 {
                                Text(int_coach.sport[index])
                            } else {
                                Text(", \(int_coach.sport[index])")
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                Spacer()
                VStack (alignment: .trailing) {
                    (Text(int_coach.cost.0) + Text(": " )  +  Text(int_coach.cost.1).bold() + Text("/hr").bold())
                        .padding(.trailing, 10)
                    Spacer()
                }
                .padding(0)
            }
            
            .frame(maxWidth: .infinity, maxHeight: 100)
        }
        Spacer()
        
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

#Preview {
    CouchAccount()
}

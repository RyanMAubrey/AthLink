//
//  CoachHome.swift
//  AthLink
//
//  Created by RyanAubrey on 12/26/24.
//

import SwiftUI

struct CoachHome: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var navigateTojob: Bool = false
    @State private var navigateTomess: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateToacc: Bool = false
    
    var body: some View {
        if navigateTojob {
            
        } else if navigateTomess {
            
        } else if navigateTosess {
            
        } else if navigateToacc {
            AccountView()
                .environmentObject(rootView)
        } else {
            VStack {
                Image("athlinklogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                ScrollView(.vertical) {
                    Text("Getting Started")
                        .font(.headline)
                    // started
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // satisfaction
                            Button(action: {
                                rootView.path.append("Satisfaction")
                            }) {
                                VStack {
                                    Image(systemName: "rosette")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Satisfaction Gurantee")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .frame(width: 110, height: 110)
                            .background(Color(.systemGray4))
                            .cornerRadius(25)
                            
                            // Receive $80
                            Button(action: {
                                rootView.path.append("Receive")}) {
                                VStack {
                                    Image(systemName: "dollarsign.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Receive $80")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .frame(width: 110, height: 110)
                            .background(Color(.systemGray4))
                            .cornerRadius(25)
                            
                            // Frequently Asked Questions
                            Button(action: {
                                rootView.path.append("Question")}) {
                                VStack {
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("FAQ")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .frame(width: 110, height: 110)
                            .background(Color(.systemGray4))
                            .cornerRadius(25)
                            
                            // Customer Support
                            Button(action: {
                                rootView.path.append("Support")}) {
                                VStack {
                                    Image(systemName: "phone.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Support")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .frame(width: 110, height: 110)
                            .background(Color(.systemGray4))
                            .cornerRadius(25)
                        }
                        .padding(8)
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    // Notiifications
                    Text("Notifications")
                        .font(.headline)
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //coach
                    Button(action: {
                        rootView.rootView = .Home
                    }) {
                        HStack {
                            Image(systemName: "sportscourt")
                                .resizable()
                                .foregroundStyle(Color.black)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .padding(.top, 8)
                            Text("Travel to Athlete Section")
                            Spacer()
                            Text(">")
                        }
                        .padding(.horizontal, 20)
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
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "house.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.black)
                                .bold()
                            Text("Home")
                                .font(.caption)
                                .foregroundStyle(Color.black)
                                .bold()
                        }
                    }
                    // jobs
                    Button(action: {
                        navigateTojob = true
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "briefcase.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Jobs")
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
                        navigateTosess = true
                    }) {
                        VStack (spacing: -10){
                            Image(systemName: "doc.text")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 50)
                                .foregroundStyle(Color.gray)
                            Text("Sessions")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
                        }
                    }
                    // Account
                    Button(action: {
                        navigateToacc = true
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
        }
    }
}

#Preview {
    CoachHome()
        .environmentObject(RootViewObj())
}

//
//  CoachHome.swift
//  AthLink
//
//  Created by RyanAubrey on 12/26/24.
//

import SwiftUI

struct CoachHome: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var selectedTag = 0
    
    var body: some View {
        TabView(selection: $selectedTag) {
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
                }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .tabItem { Label("Home", systemImage: "house") }
            .tag(0)
            // Jobs
            Jobs()
                //.environmentObject(rootView)
                .tabItem {Label("Jobs", systemImage: "briefcase") }
                .tag(1)
            // Messages
            Messages()
                .environmentObject(rootView)
                .environmentObject(SearchHelp())
                .tabItem {Label("Messages", systemImage: "bell") }
                .tag(2)
            // Sessions
            EmptyView()
                //.environmentObject(rootView)
                .tabItem {Label("Sessions", systemImage: "doc.text") }
                .tag(3)
            // Account
            AccountView()
                .environmentObject(rootView)
                .tabItem {Label("Account", systemImage: "person") }
                .tag(4)
            
        }
    }
}

#Preview {
    CoachHome()
        .environmentObject(RootViewObj())
}

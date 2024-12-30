//
//  home.swift
//  AthLink
//
//  Created by RyanAubrey on 6/23/24.
//

import SwiftUI

struct home: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var isHomeHovered = false
    @State private var isSearchHovered = false
    @State private var isMessagesHovered = false
    @State private var isSessionsHovered = false
    @State private var isAccountHovered = false
    
    @State private var navigateTomess: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateToaccount: Bool = false
    
    var body: some View {
        if navigateTomess{
            Messages()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateTosess{
            Sessions()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateToaccount{
            Account()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else {
            VStack{
                // AthLink Logo
                Image("athlinklogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(8)
                
                ScrollView(.vertical) {
                    VStack {
                        Button(action: {
                            rootView.path.append("Search")
                        }) {                     ZStack {
                                HStack(alignment: .center) {
                                    Image(systemName: "magnifyingglass")
                                 .foregroundStyle(Color(.systemGray3))
                                    Text("Get started with any sport")   .foregroundStyle(Color(.systemGray3))}
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(8)
                                .background(Color(.systemGray6))
                                .cornerRadius(10.0)
                            }
                        }
                        // line
                        Rectangle().frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(8)
                        
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
                        //Safety
                        VStack {
                            Image(systemName: "shield")
                                .resizable()
                                .foregroundStyle(Color/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .padding(.top, 8)
                            Text( "Safety \n OffenderWatch screening \n on every coach.")
                                .padding(.bottom, 8)
                                .multilineTextAlignment(.center)
                        }
                        // line
                        Rectangle().frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(8)
                        //coach
                        if rootView.profile.coachAccount {
                            Button(action: {
                                rootView.rootView = .Coach
                            }) {
                                HStack {
                                    Image(systemName: "sportscourt")
                                        .resizable()
                                        .foregroundStyle(Color.black)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .padding(.top, 8)
                                    Text("Travel to Coach Section")
                                    Spacer()
                                    Text(">")
                                }
                                .padding(.horizontal, 20)
                            }
                        } else {
                            Button(action: {
                                rootView.path.append("Coach")
                            }) {
                                HStack {
                                    Image(systemName: "sportscourt")
                                        .resizable()
                                        .foregroundStyle(Color.black)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .padding(.top, 8)
                                    Text("Become a Coach")
                                    Spacer()
                                    Text(">")
                                }
                                .padding(.horizontal, 20)
                            }
                        }
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

#Preview {
    home()
        .environmentObject(RootViewObj())
        .environmentObject(SearchHelp())
}

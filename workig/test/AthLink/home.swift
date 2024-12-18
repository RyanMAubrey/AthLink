//
//  home.swift
//  AthLink
//
//  Created by RyanAubrey on 6/23/24.
//

import SwiftUI

struct home: View {
    
    @State private var path = NavigationPath()
    @StateObject var fsearch = Cond()
    @State private var navigateTomess: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateToaccount: Bool = false
    
    var body: some View {
        if navigateTomess{
            Messages()
        } else if navigateTosess{
            Sessions()
        } else if navigateToaccount{
            Account()
        } else {
            NavigationStack(path: $path){
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
                                path.append("Search")
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
                                        path.append("Satisfaction")
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
                                    Button(action: {path.append("Receive")}) {
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
                                    Button(action: {path.append("Question")}) {
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
                                    Button(action: {path.append("Support")}) {
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
                            Button(action: {
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
                                    .foregroundStyle(Color.gray)
                                    //.padding(.top, 8)
                                Text("Home")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    //.padding([.bottom, .horizontal], 8)
                            }
                        }
                        // Search
                        Button(action: {
                            path.append("Search")
                        }) {
                            VStack (spacing: -10){
                                Image(systemName: "magnifyingglass")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 50)
                                    .foregroundStyle(Color.gray)
                                    //.padding(.top, 8)
                                Text("Search")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    //.padding([.bottom, .horizontal], 8)
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
                                    //.padding(.top, 8)
                                Text("Messages")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    //.padding([.bottom, .horizontal], 8)
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
                                    //.padding(.top, 8)
                                Text("Sessions")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    //.padding([.bottom, .horizontal], 8)
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
                                    //.padding(.top, 8)
                                Text("Account")
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                                    //.padding([.bottom, .horizontal], 8)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .navigationDestination(for: String.self) { destination in
                    if destination == "Search" {
                        Search()
                            .environmentObject(fsearch)
                    } else if destination == "FSearch" {
                        FSearch()
                            .environmentObject(fsearch)
                    } else if destination == "Satisfaction" {
                        Satisfaction()
                    } else if destination == "Receive" {
                        Receive()
                    } else if destination == "Question" {
                        Question()
                    } else if destination == "Support" {
                        Support()
                    }
                }
                .onChange(of: fsearch.fSearch) {
                    if fsearch.fSearch {
                        path.removeLast()
                        path.append("FSearch")
                    } else {
                        path.removeLast()
                        path.append("Search")
                    }
                }
                .onAppear() {
                    fsearch.validZ = false
                    fsearch.zip = ""
                    fsearch.sportVal = 0
                    fsearch.fSearch = false
                }
            }
        }
    }
}

#Preview {
    home()
}

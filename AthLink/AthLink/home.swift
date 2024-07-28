//
//  home.swift
//  AthLink
//
//  Created by RyanAubrey on 6/23/24.
//

import SwiftUI

struct home: View {
    
    @StateObject var fsearch = Cond()
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
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
                    // started
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // satisfaction
                            Button(action: {
                                
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
                            .background(Color(.systemGray2))
                            .cornerRadius(10)
                            
                            
                            //money
                            Button(action: {
                                
                            }) {
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
                            .background(Color(.systemGray2))
                            .cornerRadius(10)
                            
                            //question
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Frequently Asked Questions")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .background(Color(.systemGray2))
                            .cornerRadius(10)
                            
                            //support
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Customer Support")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .background(Color(.systemGray2))
                            .cornerRadius(10)
                            
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
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
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(10)
                    
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(.top, 60)
                        .padding(.bottom, -5)

                    
                    //Spacer()
                    
                    // bottom bar
                    HStack (spacing: 20) {
                        // home
                        Button(action: {
                            path.append("home")
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
                            path.append("Messages")
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
                            path.append("Sessions")
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
                            path.append("Account")
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
                    //Spacer()
                }
            }
            .padding(8)
            .navigationDestination(for: String.self) { destination in
                if destination == "Search" {
                    Search(path: $path).environmentObject(fsearch)
                } else if destination == "FSearch" {
                    FSearch().environmentObject(fsearch)
                } else if destination == "home" {
                    home()
                } else if destination == "Messages" {
                    Messages()
                } else if destination == "Sessions" {
                    Sessions()
                } else if destination == "Account" {
                    Account()
                }
                
            }
            .onChange(of: fsearch.fSearch) { newValue in
                if !newValue {
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

#Preview {
    home()
}

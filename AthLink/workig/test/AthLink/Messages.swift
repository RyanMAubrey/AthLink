//
//  Messages.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/7/24.
// 

import SwiftUI

struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let date: String
    let imageName: String
}

struct Messages: View {
    @State private var path = NavigationPath()
    @StateObject var fsearch = Cond()
    @State private var navigateTohome: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateToaccount: Bool = false
    @State private var navigateTomess: Bool = false
    
    @State private var searchText = ""

    let interestedCoaches: [Coach] = [
        Coach(name: "Larry Smith", message: "Hi I'm...", date: "May 26, 2024", imageName: "athlinklogo"),
        Coach(name: "Jenny Lang", message: "hello", date: "May 26, 2024", imageName: "athlinklogo")
    ]

    let myCoaches: [Coach] = [
        Coach(name: "Larry Smith", message: "How is it going", date: "May 26, 2024", imageName: "athlinklogo")
    ]

    var body: some View {
        if navigateTosess{
            Sessions()
        } else if navigateTohome{
            home()
        } else if navigateToaccount{
            Account()
        }  else {
            NavigationView {
                VStack {
                    Text("Messages")
                        .font(.largeTitle)
                        .padding()

                    SearchBar(text: $searchText)

                    VStack(alignment: .leading) {
                        Text("Interested Coaches:")
                            .font(.headline)
                            .padding(.leading)

                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack {
                                ForEach(interestedCoaches.filter { searchText.isEmpty || $0.name.contains(searchText) }) { coach in
                                    CoachView(coach: coach)
                                }
                            }
                            .padding()
                        }

                        Text("My Coaches:")
                            .font(.headline)
                            .padding([.leading, .top])

                        List(myCoaches.filter { searchText.isEmpty || $0.name.contains(searchText) }) { coach in
                            MyCoachView(coach: coach)
                        }
                        .listStyle(PlainListStyle())
                    }
                    Spacer()
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(.bottom, 10)
                    // bottom bar
                    HStack (spacing: 20) {
                        // home
                        Button(action: {
                            navigateTohome = true
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


struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Search by name", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                    }
                )
                .padding(.horizontal, 10)
        }
    }
}

struct CoachView: View {
    let coach: Coach

    var body: some View {
        NavigationLink(destination: ChatView(coach: coach)) {
            VStack {
                Image(coach.imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(coach.date)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(coach.name)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(coach.message)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .lineLimit(1)
            }
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(8)
        }
    }
}

struct MyCoachView: View {
    let coach: Coach

    var body: some View {
        NavigationLink(destination: ChatView(coach: coach)) {
            HStack {
                Image(coach.imageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                VStack(alignment: .leading) {
                    Text(coach.name)
                        .font(.headline)
                    Text(coach.message)
                        .font(.subheadline)
                        .lineLimit(1)
                }
                Spacer()
                Text(coach.date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 5)
        }
    }
}

struct ChatView: View {
    let coach: Coach
    @State private var newMessage = ""
    @State private var messages: [String] = []

    var body: some View {
        VStack {
            ScrollView {
                ForEach(messages, id: \.self) { message in
                    HStack {
                        Text(message)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }

            HStack {
                TextField("Enter your message", text: $newMessage)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Button(action: {
                    if !newMessage.isEmpty {
                        messages.append(newMessage)
                        newMessage = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(coach.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    Messages()
}

//
//  Messages.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/7/24.
//

import SwiftUI


struct Messages: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State private var navigateTohome: Bool = false
    @State private var navigateTosess: Bool = false
    @State private var navigateToaccount: Bool = false
    @State private var navigateTomess: Bool = false
    @State private var searchText = ""

    let interestedCoaches: [Coach] = [
        Coach(name: "Larry Smith", message: "Hi I'm...", date: "May 26, 2024", imageName: "athlinklogo", sport: ["d"], cost: ("d","f")),
        Coach(name: "Jenny Lang", message: "hello", date: "May 26, 2024", imageName: "athlinklogo", sport: ["d"], cost: ("d","f"))
    ]

    let myCoaches: [Coach] = [
        Coach(name: "Larry Smith", message: "How is it going", date: "May 26, 2024", imageName: "athlinklogo", sport: ["d"], cost: ("d","f"))
    ]

    var body: some View {
        if navigateTosess{
            Sessions()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateTohome{
            home()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        } else if navigateToaccount{
            Account()
                .environmentObject(rootView)
                .environmentObject(fSearch)
        }  else {
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
                            Text("Home")
                                .font(.caption)
                                .foregroundStyle(Color.gray)
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
                                .foregroundStyle(Color.black)
                                .bold()
                            Text("Messages")
                                .font(.caption)
                                .foregroundStyle(Color.black)
                                .bold()                        }
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
        .environmentObject(RootViewObj())
        .environmentObject(SearchHelp())
}

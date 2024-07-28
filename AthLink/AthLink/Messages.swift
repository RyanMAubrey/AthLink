//
//  Messages.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 7/7/24.
// #TODO#: click on name to go to profile

import SwiftUI

struct Coach: Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let date: String
    let imageName: String
}

struct Messages: View {
    @State private var searchText = ""

    let interestedCoaches: [Coach] = [
        Coach(name: "Larry Smith", message: "Hi I'm...", date: "May 26, 2024", imageName: "athlinklogo"),
        Coach(name: "Jenny Lang", message: "hello", date: "May 26, 2024", imageName: "athlinklogo")
    ]

    let myCoaches: [Coach] = [
        Coach(name: "Larry Smith", message: "How is it going", date: "May 26, 2024", imageName: "athlinklogo")
    ]

    var body: some View {
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
            }
            .padding(.top, -10)
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

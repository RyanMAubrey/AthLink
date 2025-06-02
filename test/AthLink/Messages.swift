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
    @State private var searchText = ""
    
    private var interestedFiltered: [(String, Message, ProfileID)] {
        if rootView.rootView == .Coach {
               return rootView.profile.potentialAthletes.compactMap { athlete in
                   if let mess = rootView.profile.messages[athlete.id] {
                       return (athlete.fullName, mess.last!, athlete)
                   }
                   return nil
               }
           } else {
               return rootView.profile.interestedCoaches.compactMap { coach in
                   if let mess = rootView.profile.messages[coach.id] {
                       return (coach.fullName, mess.last!, coach)
                   }
                   return nil
               }
           }
        }
    
    private var myFiltered: [(String, Message, ProfileID)] {
        if rootView.rootView == .Coach {
            rootView.profile.interestedAthletes.compactMap { athlete in
                if let mess = rootView.profile.messages[athlete.id] {
                    if !mess.isEmpty {
                        return (athlete.fullName, mess.last!, athlete)
                    } else {
                        let placeholder = Message(receiver:athlete,date: Date(),mess:"")
                        return (athlete.fullName, placeholder, athlete)
                    }
                }
                return nil
            }
        } else {
            rootView.profile.myCoaches.compactMap { coach in
                if let mess = rootView.profile.messages[coach.id] {
                    if !mess.isEmpty {
                        return (coach.fullName, mess.last!, coach)
                    } else {
                        let placeholder = Message(receiver:coach,date: Date(),mess:"")
                        return (coach.fullName, placeholder, coach)
                    }
                }
                return nil
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Messages")
                .font(.largeTitle)
                .padding()
            
            SearchBar(text: $searchText)
            
            Text(rootView.rootView == .Coach ? "Messaged Athletes:":"Interested Coaches:")
                .font(.headline)
                .padding([.leading, .top])
            
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    if (!interestedFiltered.isEmpty) {
                        ForEach(interestedFiltered.filter {
                            searchText.isEmpty || $0.0.lowercased().contains(searchText.lowercased().trimmingCharacters(in: .whitespaces))
                        }, id: \.1.id) { coach in
                            CoachView(coach: coach.1, name: coach.0, id: coach.2)
                                .environmentObject(rootView)
                        }
                    }
                }
                .padding()
            }
            
            Text(rootView.rootView == .Coach ? "My Athletes:":"My Coaches:")
                .font(.headline)
                .padding([.leading, .top])
            if(!myFiltered.isEmpty) {
                List(myFiltered.filter {
                    searchText.isEmpty || $0.0.lowercased().contains(searchText.lowercased().trimmingCharacters(in: .whitespaces))
                }, id: \.1.id) { coach in
                    MyCoachView(coach: coach.1, name: coach.0, id: coach.2)
                }
                .listStyle(PlainListStyle())
            }
            Spacer()
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
    @EnvironmentObject var rootView: RootViewObj
    let coach: Message
    let name: String
    let id: ProfileID

    var body: some View {
        Button(action: {
            rootView.selectedSession = id
            print("Selected Session: \(String(describing: rootView.selectedSession))")
            rootView.path.append("MessageAccount")
        }) {
            VStack {
                Image(coach.receiver.profilePic)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                Text(coach.date.formatted())
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(name)
                    .font(.headline)
                    .foregroundColor(.black)
                Text(coach.mess)
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
    @EnvironmentObject var rootView: RootViewObj
    let coach: Message
    let name: String
    let id: ProfileID
    
    var body: some View {
        Button(action: {
            rootView.selectedSession = id
            print("Selected Session: \(String(describing: rootView.selectedSession))")
            rootView.path.append("MessageAccount")
        }) {
            if !coach.mess.isEmpty {
                HStack {
                    Image(coach.receiver.profilePic)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                        Text(coach.mess)
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text(coach.date.formatted())
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 5)
            } else {
                HStack {
                    Image(coach.receiver.profilePic)
                        .resizable()
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    Text(name)
                        .font(.headline)
                }
                .padding(.vertical, 5)
            }
        }
    }
}

//#Preview {
//    struct Preview: View {
//        @State var isCoach = false
//        var body: some View {
//            return Messages(isCoach: $isCoach)
//                .environmentObject(RootViewObj())
//                .environmentObject(SearchHelp())
//        }
//    }
//
//    return Preview()
//}
   

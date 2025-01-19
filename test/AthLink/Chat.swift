//
//  Chat.swift
//  AthLink
//
//  Created by RyanAubrey on 1/16/25.
//

import SwiftUI

struct Chat: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var icon: String = "paperplane.fill"
    @State private var newMessage = "" {
        didSet {
            if (newMessage != "") {
                icon = "paperplane"
            } else {
                icon = "paperplane.fill"
            }
        }
    }

    var body: some View {
        VStack {
            // messages
            ScrollView {
                if let selectedSession = rootView.selectedSession,
                   let messages = rootView.profile.messages[selectedSession.id] {
                    ForEach(messages, id: \.id) { message in
                        HStack {
                            if (message.receiver.id != rootView.profile.id) {
                                Spacer()
                                Text(message.mess)
                                    .padding()
                                    .background(Color(.blue))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            } else {
                                Text(message.mess)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            
            HStack {
                TextField("Enter your message", text: $newMessage)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                
                Button(action: {
                    if !newMessage.isEmpty, let selectedSession = rootView.selectedSession {
                        let newMessageObj = Message(receiver: selectedSession, date: Date(), mess: newMessage)
                        // athlete append
                        rootView.profile.messages[selectedSession.id, default: []].append(newMessageObj)
                        // coach append
                        rootView.selectedSession?.messages[rootView.profile.id, default: []].append(newMessageObj)
                        newMessage = ""
                    }
                }) {
                    Image(systemName: icon)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    rootView.path.append("CoachAccount")
                }) {
                    VStack {
                        Image(rootView.selectedSession?.profilePic ?? "athlinklogo")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .shadow(radius: 2)
                            .padding(.top)
                        Text(rootView.selectedSession?.fullName ?? "")
                            .font(.headline)
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    Chat()
        .environmentObject(RootViewObj())
}

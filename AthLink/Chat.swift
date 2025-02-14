//
//  Chat.swift
//  AthLink
//
//  Created by RyanAubrey on 1/16/25.
//

import SwiftUI

struct Chat: View {
    @EnvironmentObject var rootView: RootViewObj
    @Environment(\.dismiss) var dismiss
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
    @Binding var prevMess: String

    var body: some View {
        //custom navbar
        GeometryReader { geometry in
            ZStack {
                // Back button aligned to the left
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.headline)
                            Text("Back")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                    }
                    .frame(width: 80, alignment: .leading)
                    .padding(.leading)

                    Spacer()
                }

                // Profile image and name centered
                if let session = rootView.selectedSession {
                    Button(action: {
                        if session.coachAccount {
                            prevMess = prevMess.isEmpty ? "Chat" : "Remove"
                        }
                    }) {
                        VStack(spacing: 2) {
                            Image(session.profilePic)
                                .resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                                .shadow(radius: 2)

                            Text(session.fullName)
                                .font(.headline)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }
                }
            }
            .frame(height: geometry.safeAreaInsets.top + 50)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        }
        .frame(height: 90)
        .padding(.bottom)
            
        //Rest
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
        .navigationBarHidden(true)
        .onAppear() {
            if prevMess == "Chat" {
                prevMess = ""
            }
        }
    }
}

#Preview {
    Chat(prevMess: .constant("CoachAccount1"))
        .environmentObject(RootViewObj())
}

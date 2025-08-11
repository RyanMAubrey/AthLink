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
    // pushses session request of  start up if true
    @Binding var pushReq: Bool
    // edit button helpers
    @Binding var editMess: (Message, Int)?
    @State private var srtMess: Message?
    @State private var srtMessI: Int?
    // clicked on a session message
    @State private var selectedSessionMessage: Session? = nil
    // ui update for session adding
    @State private var reloadToggle = false
    @State private var icon: String = "paperplane.fill"
    @State private var edit: Bool = false
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
                            rootView.lastPage = rootView.lastPage.isEmpty ? "Chat" : "Remove"
                        }
                    }) {
                        VStack(spacing: 2) {
                            Image(session.imageURL)
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
                            // if it's a session request
                            if let sess = message.sess {
                                HStack {
                                    // if it's your message, push it right
                                    if message.receiver.id != rootView.profile.id { Spacer() }
                                    VStack(alignment: .leading, spacing: 4) {
                                        // Message button
                                        Button(action: {
                                            selectedSessionMessage = sess
                                        }) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text("📬 Session Request")
                                                    .font(.headline)
                                                    .foregroundColor(.black)
                                                Text("\(sess.sport.description) • \(sess.type.description)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.black)
                                                Text("When: \(sess.date.formatted(date: .abbreviated, time: .shortened))")
                                                    .foregroundColor(.black)
                                                Text("Cost: $\(Int(sess.cost))")
                                                    .foregroundColor(.black)
                                            }
                                            .padding()
                                            .background(message.receiver.id != rootView.profile.id ? Color(.blue) : Color(.systemGray5))
                                            .cornerRadius(8)
                                        }

                                        // Action Buttons
                                        HStack {
                                            // Accept logic
                                            Button(action: {
                                                // remove from my message
                                                rootView.profile.messages[selectedSession.id]?.removeAll(where: {
                                                    $0.id == message.id
                                                })
                                                // remove from their message
                                                rootView.selectedSession!.messages[rootView.profile.id]?.removeAll(where: {
                                                    $0.id == message.id
                                                })
                                                //if mess athlete
                                                if (rootView.rootView == .Coach) {
                                                    // add to my cupcoming
                                                    rootView.profile.cupcomingSessions.append(sess)
                                                    // add to their aupcoming
                                                    rootView.selectedSession!.aupcomingSessions.append(sess)
                                                    // remove from my jobRequest
                                                    rootView.profile.jobRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                    // remove from their myRequest
                                                    rootView.selectedSession!.myRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                //if mess coach
                                                } else {
                                                    // add to my aupcoming
                                                    rootView.profile.aupcomingSessions.append(sess)
                                                    //add to their cupcoming
                                                    rootView.selectedSession!.cupcomingSessions.append(sess)
                                                    // remove from my myRequest
                                                    rootView.profile.myRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                    // remove from their jobRequest
                                                    rootView.selectedSession!.jobRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                }
                                                //update UI
                                                reloadToggle.toggle()
                                            }) {
                                                Label("Accept", systemImage: "checkmark.circle")
                                                    .padding(8)
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.green.opacity(0.2))
                                                    .foregroundColor(.green)
                                                    .cornerRadius(6)
                                            }
                                            
                                            // Reject logic
                                            Button(action: {
                                                // remove from my message
                                                rootView.profile.messages[selectedSession.id]?.removeAll(where: {
                                                    $0.id == message.id
                                                })
                                                // remove from their message
                                                rootView.selectedSession!.messages[rootView.profile.id]?.removeAll(where: {
                                                    $0.id == message.id
                                                })
                                                //if messaging athlete
                                                if (rootView.rootView == .Coach) {
                                                    // remove from my jobRequest
                                                    rootView.profile.jobRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                    // remove from their myRequest
                                                    rootView.selectedSession!.myRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                //if messaging coach
                                                } else {
                                                    // remove from my myRequest
                                                    rootView.profile.myRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                    // remove from their jobRequest
                                                    rootView.selectedSession!.jobRequests.removeAll(where: {
                                                        $0.id == sess.id
                                                    })
                                                }
                                                //update UI
                                                reloadToggle.toggle()
                                            }) {
                                                Label("Reject", systemImage: "xmark.circle")
                                                    .padding(8)
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.red.opacity(0.2))
                                                    .foregroundColor(.red)
                                                    .cornerRadius(6)
                                            }
                                            
                                            // Edit logic
                                            Button(action: {
                                                // copy their session request
                                                srtMess = selectedSession.messages[rootView.profile.id]?
                                                    .filter { $0.sess != nil }
                                                    .sorted { $0.date > $1.date }.first
                                                srtMessI = selectedSession.messages[rootView.profile.id]?.firstIndex(where: {
                                                    $0 == srtMess
                                                })
                                                // delete the message from my messages
                                                rootView.profile.messages[selectedSession.id]?.remove(at: srtMessI!)
                                                // deleete the message from their messages
                                                selectedSession.messages[rootView.profile.id]?.remove(at: srtMessI!)

                                                // set binding
                                                editMess = (srtMess!, srtMessI!)
                                                //load page
                                                rootView.path.append("Request")
                                            }) {
                                                Label("Edit", systemImage: "pencil")
                                                    .padding(8)
                                                    .frame(maxWidth: .infinity)
                                                    .background(Color.blue.opacity(0.2))
                                                    .foregroundColor(.blue)
                                                    .cornerRadius(6)
                                            }
                                        }
                                        .font(.caption)
                                    }
                                }
                                .padding(.horizontal)
                            // if it's a normal message
                            } else {
                                if message.receiver.id != rootView.profile.id { Spacer() }
                                Text(message.mess)
                                    .padding()
                                    .background(message.receiver.id != rootView.profile.id ? Color(.blue) : Color(.systemGray5))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                }
            }
            
            HStack {
                // message field
                TextField("Enter your message", text: $newMessage)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                // send button
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
                // session request button
                Button(action: {
                    pushReq = true
                    rootView.path.append("Request")
                }) {
                    Image(systemName: "plus.message")
                }
            }
            .padding()
        }
        .id(reloadToggle)
        .navigationBarHidden(true)
        .onAppear() {
            if rootView.lastPage == "Chat" {
                rootView.lastPage = ""
            }
            // sets shows message 0 to off and puts into chat
            if pushReq {
                pushReq.toggle()
                if let selectedSession = rootView.selectedSession,
                    let latestSession = rootView.profile.myRequests
                     .sorted(by: { $0.req_date > $1.req_date })
                     .first {
                         let sessMess = Message(receiver: selectedSession, date: Date(), mess: "", sess: latestSession)
                         // athlete append
                         rootView.profile.messages[selectedSession.id, default: []].append(sessMess)
                         // coach append
                         selectedSession.messages[rootView.profile.id, default: []].append(sessMess)
                     }
                reloadToggle.toggle()
            }
            
            // returning from edit page
            if let em = editMess {
                // adds the new messag to my messages
                rootView.profile.messages[rootView.selectedSession!.id]?.append(em.0)
                // adds th new massage to their messages
                rootView.selectedSession!.messages[rootView.profile.id]?.append(em.0)
                editMess = nil
                reloadToggle.toggle()
            }
        }
    }
}

//#Preview {
//    Chat(pushReq: .constant(false), editMess: .constant(nil))
//        .environmentObject(RootViewObj())
//}

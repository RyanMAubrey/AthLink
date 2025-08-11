//
//  Recieve.swift
//  AthLink
//
//  Created by RyanAubrey on 7/3/24.
//

import SwiftUI

struct Receive: View {
    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 100)
                .padding(8)
                .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
            Text("Receive $80")
                .font(.system(size: 20, weight: .light, design: .serif))
        }
        ScrollView {
            VStack {
                Text("Invite others to join AthLink and you will both receive $40 in free coaching.")
                    .font(.system(size: 31))
                    .padding(8)
                //copy to clip board
                Button(action: {
                    UIPasteboard.general.string = "https://example.com"
                }) {
                    HStack {
                        Image(systemName: "doc.on.doc.fill")
                            .foregroundStyle(Color(.systemGray3))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        Spacer()
                        Text("Copy Link")
                            .font(.system(size: 25, weight: .light, design: .serif))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: 200, maxHeight: 100)
                    .padding(8)
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding(8)
                //share invite link
                Button(action: {
                    let slink = UIActivityViewController(activityItems: [URL(string: "https://example.com")!], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first {
                        window.rootViewController?.present(slink, animated: true, completion: nil)
                    }
                }) {
                    HStack {
                        Image(systemName: "bubble.fill")
                            .foregroundStyle(Color(.systemGray3))
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                        Spacer()
                        Text("Share Invite Link")
                            .font(.system(size: 25, weight: .light, design: .serif))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: 200, maxHeight: 100)
                    .padding(8)
                    .background(.blue)
                    .cornerRadius(10)
                }
                .padding(8)
                
                //terms and conditions
                NavigationLink(destination: PrivacyPolicyView()) {
                    Text("Terms and Conditions")
                        .underline()
                        .foregroundColor(.blue)
                }
                .padding(8)
            }
        }
    }
}

#Preview {
    Receive()
}
 

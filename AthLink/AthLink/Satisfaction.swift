//
//  started.swift
//  AthLink
//
//  Created by RyanAubrey on 7/3/24.
//

import SwiftUI

struct Satisfaction: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        ZStack {
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 100)
                .padding(8)
               .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
               .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
            Text("Satisfaction Gurantee")
                .font(.system(size: 20, weight: .light, design: .serif))
        }
        ScrollView {
            VStack {
                Text("You are backed by our Satisfaction Gurantee. If you are unhappy contact us and we will refund the first hour of your session.")
                    .font(.system(size: 50, weight: .light, design: .serif))
                    .multilineTextAlignment(.center)
                    .padding(8)
                Button(action: {
                    path.removeLast()
                    path.append("Support")
                }) {
                    Text("Contact us")
                        .font(.system(size: 40, weight: .light, design: .serif))
                        .multilineTextAlignment(.center)
                    }
                Text("if you have any quesitons.")
                    .font(.system(size: 40, weight: .light, design: .serif))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

#Preview {
    Satisfaction(path: .constant(NavigationPath()))
}

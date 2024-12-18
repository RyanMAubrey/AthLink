//
//  Support.swift
//  AthLink
//
//  Created by RyanAubrey on 7/3/24.
//

import SwiftUI
import MessageUI

struct Support: View {
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .padding(8)
                   .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                   .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                Text("Customer Support")
                    .font(.system(size: 20, weight: .light, design: .serif))
            }
            
            // Scrollable Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Call or email our customer support team:")
                        .font(.system(size: 22, weight: .semibold))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 10)
                    
                    // Call Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Call:")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Our team can answer any questions you may have. Give us a call at ")
                            .font(.system(size: 16))
                        + Text("111-111-1111")                             .font(.system(size: 16))                        .foregroundColor(.blue)
                        + Text(".")
                            .font(.system(size: 16))
                        
//                        Button(action: {
//                            let phoneNumber = "tel:+1234567890"
//                            if let url = URL(string: phoneNumber) {
//                                UIApplication.shared.open(url)
//                            }
//                        }) {
//                            Text("111-111-1111")
//                                .font(.system(size: 16))
//                                .foregroundColor(.blue)
//                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Email Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email:")
                            .font(.system(size: 20, weight: .semibold))
                        
                        Text("Email us at ")
                            .font(.system(size: 16))
                        + Text("example@gmail.com")
                            .font(.system(size: 16))
                            .foregroundColor(.blue)
                            .underline()
//                            .onTapGesture {
//                                let email = "mailto:example@example.com"
//                                if let url = URL(string: email) {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
                        + Text(" and we will get back as soon as possible.")
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding(.vertical, 20)
            }
        }
        .background(Color.white)
    }
}

#Preview {
    Support()
}



//
//  CoachLogin.swift
//  AthLink
//
//  Created by RyanAubrey on 12/22/24.
//

import SwiftUI

struct CoachLogin: View {
    @EnvironmentObject var rootView: RootViewObj
    
    var body: some View {
        VStack {
            Image("athlinklogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
            ScrollView(.vertical) {
                VStack {
                    VStack (alignment: .leading){
                        Text("OffenderWatch Screening (Optional)")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 2)
                        Link("Complete your screening", destination: URL(string: "https:/ww.example.com")!)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 8)
                        Text("Direct Deposit Account (Optional)")
                            .font(.headline)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 2)
                        Button(action: {
                        }) {
                            Image(systemName: "plus")
                            .foregroundColor(.blue)
                            .padding(.horizontal, 20)
                            .padding(.bottom, 2)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal, 5)
                    .padding(.top, 11)
                    Button(action: {
                        rootView.profile.coachAccount = true
                        rootView.rootView = .Coach
                    }) {
                        Text("Sign Up")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(20)
                            .padding(.horizontal, 100)
                    }
                    
                    Text("By clicking ‘Sign Up’ or using Athlink, you are agreeing to our")
                        .font(.system(size: 10))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    HStack(spacing: 4) {
                        Button(action: {
                            rootView.path.append("Terms")
                        }) {
                            Text("Terms of Service")
                                .underline()
                                .foregroundColor(.blue)
                        }
                        
                        Text("and")
                        
                        Button(action: {
                            rootView.path.append("Privacy")
                        }) {
                            Text("Privacy Policy")
                                .underline()
                                .foregroundColor(.blue)
                        }
                    }
                    .font(.system(size: 10))
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
    }
}

#Preview {
    CoachLogin()
        .environmentObject(RootViewObj())
}

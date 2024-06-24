//
//  home.swift
//  AthLink
//
//  Created by RyanAubrey on 6/23/24.
//

import SwiftUI

struct home: View {
    
    @State var searchText: String = ""
    @State var isEditing: Bool = false
    
    var body: some View {
        NavigationStack {
            // AthLink Logo
            Image("athlinklogo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 100, height: 100)
                .padding(8)

            ScrollView(.vertical) {
                VStack {
                    // SearchBar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color(.systemGray3))
                        TextField("Get started with any sport", text: $searchText)
                            .foregroundStyle(Color.primary)
                        if isEditing {
                            Button(action: {
                                self.searchText = ""
                                self.isEditing = false
                                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            }) {
                                Image(systemName: "xmark")
                                    .foregroundStyle(Color(.systemGray3))
                                }
                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .onTapGesture {
                        self.isEditing = true
                    }
                    
                    Text("Suggestions")
                    // Suggestions
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(0..<10) { index in
                                Button(action: {
                                    
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundStyle(Color(.systemGray3))
                                        .padding(8)
                                    Text("Item \(index)")
                                                                        .font(.caption)
                                                                        .foregroundStyle(Color.black)
                                                                        .padding(8)
                                    }
                           }
                            .background(Color.gray)
                        }

                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                
                    Text("Getting Started")
                    // started
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            // satisfaction
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "rosette")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Satisfaction Gurantee")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .background(Color(.systemGray2))
                            .cornerRadius(10)

                            
                            //money
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "dollarsign.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Receive $80")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .background(Color(.systemGray2))
                            .cornerRadius(10)
                            
                            //question
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "questionmark.circle")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Frequently Asked Questions")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .background(Color(.systemGray2))
                            .cornerRadius(10)
                            
                            //support
                            Button(action: {
                                
                            }) {
                                VStack {
                                    Image(systemName: "person.2.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50, height: 50)
                                        .foregroundStyle(Color.black)
                                        .padding(.top, 8)
                                    Text("Customer Support")
                                        .font(.caption)
                                        .foregroundStyle(Color.black)
                                        .padding([.bottom, .horizontal], 8)
                                }
                            }
                            .background(Color(.systemGray2))
                            .cornerRadius(10)

                        }
                    }
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //Safety
                    VStack {
                        Image(systemName: "shield")
                            .resizable()
                            .foregroundStyle(Color/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .padding(.top, 8)
                        Text( "Safety \n OffenderWatch screening \n on every coach.")
                            .padding(.bottom, 8)
                            .multilineTextAlignment(.center)
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //coach
                    Button(action: {
                    }) {
                        HStack {
                            Image(systemName: "sportscourt")
                                .resizable()
                                .foregroundStyle(Color.black)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                                .padding(.top, 8)
                            Text("Become a Coach")
                            Spacer()
                            Text(">")
                        }
                    }
                    // line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                }
            }
            .padding(8)
            }
    }
}

#Preview {
    home()
}

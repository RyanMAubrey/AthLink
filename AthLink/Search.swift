//
//  Search.swift
//  AthLink
//
//  Created by RyanAubrey on 6/24/24.
//

import SwiftUI

struct Search: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State var zMessage : String = "Enter Zip Code"
    var loc: String {
        fSearch.validZ ? "location.fill" : "location"
    }

    var body: some View {
        VStack {
            ZStack(alignment: .top) {
                VStack {
                    // SportDropDown
                    Picker(selection: $fSearch.sportVal, label: Text("Select a Sport")){
                        Text("Select a Sport").tag(0)
                        Text("Football").tag(1).foregroundColor(.black)
                        Text("Basketball").tag(2).foregroundColor(.black)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10.0)
                    .frame(maxWidth: .infinity)
                    // ZipSearchBar
                    HStack {
                        Image(systemName: loc) .foregroundStyle(Color.black)
                        TextField(zMessage, text: $fSearch.zip)
                            .foregroundStyle(Color.primary)
                        // check if valid zip
                            .onSubmit {
                                fSearch.validate()
                            }
                        if fSearch.zEditing {
                            Button(action: {
                                fSearch.zip = ""
                                fSearch.zEditing = false
                                fSearch.validZ = false
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
                        fSearch.zEditing = true
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(8)
                .background(Color(.systemGray3))
            }
            // rsearch
            VStack(alignment: .leading) {
                // recent search
                Text("Recent Search:")
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            Spacer()
        }
        .onChange(of: fSearch.zip) {
            zMessage = fSearch.validZ ? "Enter Zip Code":"Enter a Valid Zip Code"
        }
    }
}


#Preview {
    Search()
        .environmentObject(RootViewObj())
        .environmentObject(SearchHelp())
}

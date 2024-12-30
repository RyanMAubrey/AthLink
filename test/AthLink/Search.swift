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
    @State var zEditing : Bool = false
    @State var zMessage : String = "Enter Zip Code"
    var loc: String {
        fSearch.validZ ? "location.fill" : "location"
    }
    
    var body: some View {
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
                            validate()
                        }
                    if zEditing {
                        Button(action: {
                            self.fSearch.zip = ""
                            self.zEditing = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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
                    self.zEditing = true
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
    
    // validates zip code
    func validate() {
        let zipCodePattern = "^[0-9]{5}(?:-[0-9]{4})?$"
        let regex = try! NSRegularExpression(pattern: zipCodePattern)
        let range = NSRange(location: 0, length: fSearch.zip.utf16.count)
        fSearch.validZ = regex.firstMatch(in: fSearch.zip, options: [], range: range) != nil
        
        self.zEditing = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if !fSearch.validZ {
            zMessage = "Enter a Valid Zip Code"
            self.fSearch.zip = ""
        }
    }
}


#Preview {
    Search()
        .environmentObject(RootViewObj())
        .environmentObject(SearchHelp())
}

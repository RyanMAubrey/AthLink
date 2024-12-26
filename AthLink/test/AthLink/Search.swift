//
//  Search.swift
//  AthLink
//
//  Created by RyanAubrey on 6/24/24.
//

import SwiftUI

struct Search: View {
    
    @EnvironmentObject var fsearch : Cond
    @State var zEditing : Bool = false
    @State var zMessage : String = "Enter Zip Code"
    var loc: String {
        fsearch.validZ ? "location.fill" : "location"
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // SportDropDown
                Picker(selection: $fsearch.sportVal, label: Text("Select a Sport")){
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
                    TextField(zMessage, text: $fsearch.zip)
                        .foregroundStyle(Color.primary)
                    // check if valid zip
                        .onSubmit {
                            validate()
                        }
                    if zEditing {
                        Button(action: {
                            self.fsearch.zip = ""
                            self.zEditing = false
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            fsearch.validZ = false
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
        let range = NSRange(location: 0, length: fsearch.zip.utf16.count)
        fsearch.validZ = regex.firstMatch(in: fsearch.zip, options: [], range: range) != nil
        
        self.zEditing = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        if !fsearch.validZ {
            zMessage = "Enter a Valid Zip Code"
            self.fsearch.zip = ""
        }
    }
}


#Preview {
    Search()
        .environmentObject(Cond())
}

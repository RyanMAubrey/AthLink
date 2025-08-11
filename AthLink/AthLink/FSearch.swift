//
//  FSearch.swift
//  AthLink
//
//  Created by RyanAubrey on 6/24/24.
//

import SwiftUI

struct FSearch: View {
    @EnvironmentObject var rootView: RootViewObj
    @EnvironmentObject var fSearch: SearchHelp
    @State var sett : Bool = false
    @State var nEditing : Bool = false
    @State var zMessage : String = "Enter Zip Code"
    @State var name : String = ""
    @State var alg : Int = 0
    @State var selectedA : [String : [String]] = [:]
    @State var hr : Float = 30
    @State private var hisEditing = false
    @State var ca : Float = 20
    @State private var cisEditing = false
    @State var cg : Int = 0
    var loc: String {
        fSearch.validZ ? "location.fill" : "location"
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack {
                // setting button
                Button(action: {
                    sett = true
                }) {
                    HStack {
                        Spacer()
                        Image(systemName: "gear")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.black)
                    }
                }
                // Sheet
                .sheet(isPresented: $sett) {
                    VStack {
                        Form {
                            // Algorithm picker
                            Section(header: Text("Sort by:")) {
                                Picker(selection: $alg, label: Text("Picker")) {
                                    Text("Best Match").tag(1)
                                    Text("Distance").tag(2)
                                    Text("Lowest Price").tag(3)
                                    Text("Highest Price").tag(4)
                                    Text("Ratings").tag(5)
                                }
                            }
                            
                            // toggles availability for times
                            let toggleAvailability: (String, String) -> () = { day, timeSlot in
                                if selectedA[day]?.contains(timeSlot) ?? false {
                                    selectedA[day]?.removeAll(where: { $0 == timeSlot })
                                } else {
                                    selectedA[day, default: []].append(timeSlot)
                                }
                            }
                            // checks if times were already selected
                            let isSelected: (String, String) -> Bool = { day, timeSlot in
                                return selectedA[day]?.contains(timeSlot) ?? false
                            }
                            
                            // Availability
                            Section(header: Text("Availability:")) {
                                HStack {
                                    VStack {
                                        Text("6a.m.-12p.m.")
                                            .multilineTextAlignment(.center)
                                        Text("Morning")
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    VStack {
                                        Text("1p.m.-5p.m.")
                                            .multilineTextAlignment(.center)
                                        Text("Afternoon")
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    VStack {
                                        Text("6p.m.-12a.m.")
                                            .multilineTextAlignment(.center)
                                        Text("Night")
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                                .frame(maxWidth: .infinity)
                                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                                    VStack(alignment: .leading) {
                                        Text(day)
                                            .font(.headline)
                                        HStack {
                                            ForEach(["Morning", "Afternoon", "Night"], id: \.self) { timeSlot in
                                                VStack {
                                                    Button(action: {
                                                        toggleAvailability(day, timeSlot)
                                                    }) {
                                                        if isSelected(day, timeSlot) {
                                                            Image(systemName: "checkmark.square")
                                                        } else {
                                                            Image(systemName: "square")
                                                        }
                                                    }
                                                    .buttonStyle(BorderlessButtonStyle())
                                                }
                                                .frame(maxWidth: .infinity, alignment: .center)
                                            }
                                        }
                                    }
                                }
                            }
                            // hourly wage
                            Section(header: Text("Hourly Rate:")) {
                                VStack {
                                    Slider(
                                        value: $hr,
                                        in: 15...235,
                                        step: 1
                                    ) {
                                        Text("Speed")
                                    } minimumValueLabel: {
                                        Text("$15")
                                    } maximumValueLabel: {
                                        Text("$235")
                                    } onEditingChanged: { editing in
                                        hisEditing = editing
                                    }
                                    Text("$" + "\(Int(hr))")
                                        .foregroundColor(hisEditing ? .red : .blue)

                                }
                            }
                            // couch age
                            Section(header: Text("Coach Age:")) {
                                VStack {
                                    Slider(
                                        value: $ca,
                                        in: 20...78,
                                        step: 1
                                    ) {
                                        Text("Speed")
                                    } minimumValueLabel: {
                                        Text("20")
                                    } maximumValueLabel: {
                                        Text("78")
                                    } onEditingChanged: { editing in
                                        cisEditing = editing
                                    }
                                    Text("\(Int(ca))")
                                        .foregroundColor(cisEditing ? .red : .blue)

                                }
                            }
                            
                            // Coach Gender
                            Section(header: Text("Coach Gender:")) {
                                Picker(selection: $cg, label: Text("Picker")) {
                                    Text("Male").tag(1)
                                    Text("Female").tag(2)
                                }
                            }
                        }
                    }
                    .padding(40)
                }

                HStack {
                    // SportDropDown
                    Picker(selection: $fSearch.sportVal, label: Text("Select a Sport")) {
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
                        Image(systemName: loc)
                            .foregroundColor(.black)
                        TextField(zMessage, text: $fSearch.zip)
                            .foregroundColor(Color.primary)
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
                                    .foregroundColor(Color(.systemGray3))
                            }
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
                .padding(8)
                
                // name search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(.systemGray3))
                        .padding(8)
                    TextField("Enter a Coach's Name", text: $name)
                        .foregroundColor(Color.primary)
                    if nEditing {
                        Button(action: {
                            name = ""
                            nEditing = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color(.systemGray3))
                                .padding(8)
                        }
                    }
                }
                .background(Color(.systemGray6))
                .cornerRadius(10.0)
                .onTapGesture {
                    nEditing = true
                }
                .frame(maxWidth: .infinity)
            }
            .padding(8)
            .background(Color(.systemGray3))
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }
}

//#Preview {
//    FSearch()
//        .environmentObject(RootViewObj())
//        .environmentObject(SearchHelp())
//}

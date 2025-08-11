//
//  RequestSess.swift
//  AthLink
//
//  Created by RyanAubrey on 2/12/25.
//

import CoreLocation
import SwiftUI

struct RequestSess: View {
    @EnvironmentObject var rootView: RootViewObj
    // chat push toggle
    @Binding var chatTog: Bool
    @State var clickCheck: Bool = false
    @Binding var editMess: (Message, Int)?
    @State var fileImport: Bool = false
    @State private var selectedType: GroupType = .Individual
    @State private var selectedSport: Sports = .Football
    @State private var selectedDescription: String = ""
    @State private var selectedLocation: CoachLocation = CoachLocation(
        coordinate: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0),
        name: "nan"
    )
    // date
    @State private var dateChanged: Bool = false
    @State private var selectedStart: Date = Date()
    @State private var selectedEnd: Date = Calendar.current
        .date(byAdding: .hour, value: 1, to: Date())!
    @State var bounds: ClosedRange<Date>? {
        didSet {
            print("set")
        }
    }
    // created new session
    @State var madeSess: Session = Session(
        req_date: Date(),
        other: ProfileID(),
        sport: .Football,
        type: .Individual,
        typeRate: 0.00,
        date: Date(),
        finished: Date(),
        rate: 0.0,
    )

    var body: some View {
        if let session = rootView.selectedSession {
            VStack {
                //top section
                ZStack(alignment: .center) {
                    Rectangle()
                        .frame(maxWidth: .infinity, maxHeight: 150)
                        .foregroundColor(
                            Color(red: 0.4627, green: 0.8392, blue: 1.0)
                        )
                        .background(
                            Color(red: 0.4627, green: 0.8392, blue: 1.0)
                        )
                    Text(
                        "Send \(session.firstName) a request\n with your needs."
                    )
                    .bold()
                    .padding(.top, 25)
                }
                ScrollView(.vertical) {
                    //message
                    TextField(text: $selectedDescription, label: {
                        if selectedDescription.isEmpty {
                            Text("Give any request(optional)")
                        } else {
                            Text(selectedDescription)
                        }
                    })
                    .frame(maxWidth: .infinity, minHeight: 150)
                    .cornerRadius(15)
                    .border(.secondary)
                    .padding()
                    .multilineTextAlignment(.center)
                    //Button
                    VStack {
                        Text("Add attachments(optional):")
                        Button(action: {
                            fileImport = true
                        }) {
                            ZStack {
                                Rectangle()
                                    .frame(maxWidth: 80, minHeight: 75)
                                    .cornerRadius(10)
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .frame(maxWidth: 30, maxHeight: 30)
                                    .foregroundColor(.black)
                            }
                        }
                        .fileImporter(
                            isPresented: $fileImport,
                            allowedContentTypes: [.pdf, .image],
                            allowsMultipleSelection: true
                        ) { result in
                            switch result {
                            case .success(let files):
                                files.forEach { file in
                                    let gotAccess =
                                        file
                                        .startAccessingSecurityScopedResource()
                                    if !gotAccess { return }
                                    //add functionality
                                    file.stopAccessingSecurityScopedResource()
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                    //DataFields
                    VStack(alignment: .leading) {
                        Spacer()
                        //Session Start time
                        DatePicker(
                            "Seleected Start Time: ",
                            selection: $selectedStart,
                            displayedComponents: [.hourAndMinute]
                        )
                        .onChange(
                            of: selectedStart,
                            {
                                bounds =
                                    selectedStart...Calendar.current
                                    .date(byAdding: .day, value: 1, to: Date())!
                            }
                        )
                        //line
                        Rectangle().frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(8)
                        if bounds != nil {
                            //Session End time
                            DatePicker(
                                "Seleected End Time: ",
                                selection: $selectedEnd,
                                in: bounds ?? Date()...Date(),
                                displayedComponents: [.hourAndMinute]
                            )
                            //line
                            Rectangle().frame(maxWidth: .infinity)
                                .frame(height: 1)
                                .padding(8)
                        }
                        //Training Location
                        if !session.trainingLocations.isEmpty {
                            HStack {
                                Text("Session Location (optional):")
                                Picker(
                                    "Session Location",
                                    selection: $selectedLocation
                                ) {
                                    ForEach(
                                        session.trainingLocations,
                                        id: \.self
                                    ) { loc in
                                        Text(loc.name).tag(loc)
                                    }
                                }
                            }
                        }
                        //Sport
                        HStack {
                            Text("Sport:")
                            Picker("Session Type", selection: $selectedSport) {
                                ForEach(session.sport, id: \.self) { sport in
                                    Text(sport.description).tag(sport)
                                }
                            }
                        }
                        //line
                        Rectangle().frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(8)
                        //Session Type
                        HStack {
                            Text("Session Type:")
                            Picker("Session Type", selection: $selectedType) {
                                if session.individualCost != nil {
                                    Text("Individual").tag(GroupType.Individual)
                                }
                                if session.groupCost != nil {
                                    Text("Group").tag(GroupType.Group)
                                }
                            }
                        }
                        //line
                        Rectangle().frame(maxWidth: .infinity)
                            .frame(height: 1)
                            .padding(8)
                        //Submit
                        Button(action: {
                            // checks if the last page was the chat and sets push request to true
                            clickCheck = true
                            // date stuff
                            madeSess.req_date = Date()
                            madeSess.date = selectedStart
                            madeSess.finished = selectedEnd
                            // Append to coach JobRequests
                            session.jobRequests.append(madeSess)
                            // Selected type
                            madeSess.type = selectedType
                            // Calulates cost
                            if selectedType == .Individual {
                                madeSess.typeRate = session.individualCost!
                            }
                            if selectedType == .Group {
                                madeSess.typeRate = session.groupCost!
                            }
                            madeSess.sport = selectedSport
                            madeSess.location = selectedLocation
                            // if theres an edit message and replaces the old session
                            if editMess != nil {
                                editMess!.0.sess! = madeSess
                                editMess!.0.receiver = session
                            }
                            rootView.profile.myRequests.append(madeSess)
                            rootView.path.removeLast()
                        }) {
                            Text(editMess == nil ? "Submit Session Request":"Finalize Edits")
                        }
                    }
                    .padding()
                }
                Spacer()
            }
            // if this is an edited session fill in the existing info
            .onAppear(perform: {
                if let em = editMess,
                    let sess = em.0.sess {
                    selectedType = sess.type
                    selectedSport = sess.sport
                    if let loc = sess.location {
                        selectedLocation = loc
                    }
                    if let des = sess.description {
                        selectedDescription = des
                    }
                }
            })
            .onDisappear(perform: {
                if chatTog && !clickCheck {
                    chatTog = false
                }
            })
            .ignoresSafeArea()
        }
    }
}

//#Preview {
//    RequestSess(chatTog: .constant(false), editMess: .constant(nil))
//        .environmentObject(RootViewObj())
//}

//
//  CouchAccount.swift
//  AthLink
//
//  Created by RyanAubrey on 12/20/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct CouchAccount: View {
    //test:
    @State private var selectedAvailability: [String: [String]] = [:]
    
    
    @EnvironmentObject var rootView: RootViewObj
    @State private var sessionReq: Bool = false
    @State private var mapShow: CoachLocation?

    var body: some View {
        //top bar
        if let selectedSession = rootView.selectedSession {
            // Top Section
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 150)
                    .padding(8)
                    .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                    .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                HStack (alignment: .center) {
                    // Profile Image
                    Image(selectedSession.imageURL)
                        .resizable()
                        .scaledToFit()
                        .clipShape(Circle())
                        .padding(.trailing, 10)
                    // First Stack
                    VStack (alignment: .leading) {
                        Text(selectedSession.fullName)
                            .font(.headline)
                        HStack(spacing: 2) {
                            ForEach(1..<6) { index in
                                if selectedSession.rating - Float(index) >= 0  {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                } else if selectedSession.rating - Float(index) == -0.5 {
                                    Image(systemName: "star.leadinghalf.fill")
                                        .foregroundColor(.yellow)
                                } else {
                                    Image(systemName: "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        HStack {
                            Text(String(selectedSession.rating))
                            Text("(\(selectedSession.ratings))")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        if !selectedSession.personalQuote.isEmpty {
                            Text("\"\(selectedSession.personalQuote)\"")
                        }
                    }
                    .padding(.trailing)
                    // Second Stack
                    VStack(alignment: .trailing) {
                        if let individualCost = selectedSession.individualCost,
                           let groupCost = selectedSession.groupCost {
                            VStack (alignment: .leading) {
                                Text("Individual: ")
                                Text("\(individualCost)/hr").bold()
                                Text("Group: ")
                                Text("\(groupCost)/hr").bold()
                            }
                        } else if let individualCost = selectedSession.individualCost {
                            VStack (alignment: .leading) {
                                Text("Individual: ")
                                Text("\(individualCost)/hr").bold()
                            }
                        } else if let groupCost = selectedSession.groupCost {
                            VStack (alignment: .leading) {
                                Text("Group: ")
                                Text("\(groupCost)/hr").bold()
                            }
                        } else {
                            Text("Cost not available")
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 100)
            }
            .sheet(item: $mapShow) { loc in
                if let u = rootView.userCoordinate {
                    MapShow(specifiedLocation: loc, userCoordinate: u)
                } else {
                    MapShow(specifiedLocation: loc)
                }
            }
            Spacer()
            
            // Below Top Section
            ScrollView(.vertical) {
                //buttons
                VStack {
                    //Request
                    Button(action: {
                        rootView.path.append("Request")
                    }) {
                        Text("Request Session")
                            .bold()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(rootView.lastPage=="Account")
                    .padding(.bottom, 5)
                    //Message
                    Button(action: {
                        if rootView.lastPage == "Chat" {
                            rootView.lastPage = "Remove"
                        } else {
                            rootView.lastPage = "Sess"
                        }
                    }) {
                        Text("Message Coach")
                            .bold()
                    }
                    .buttonStyle(.bordered)
                    .disabled(rootView.lastPage=="Account")
                }
                .padding()
                //info
                VStack(alignment: .leading) {
                    HStack(alignment: .center) {
                        Image(systemName: "mappin.circle")
                            .padding(.bottom, 5)
                        Text("Location")
                        Spacer()
                        VStack {
                            Text("Laguna Niguel, CA")
                            Text("1500 Miles")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                    HStack {
                        Image(systemName: "person")
                            .padding(.bottom, 5)
                        Text("People Coached")
                        Spacer()
                        Text("\(selectedSession.peopleCoached)")
                    }
                    HStack {
                        Image(systemName: "clock")
                            .padding(.bottom, 5)
                        Text("Hours Coaching")
                        Spacer()
                        Text("\(selectedSession.hoursCoached)")
                    }
                    HStack {
                        Image(systemName: "phone")
                            .padding(.bottom, 5)
                        Text("Response Time")
                        Spacer()
                        Text("\(selectedSession.responseTime)hr")
                    }
                    if let cancel = selectedSession.cancellationNotice {
                        HStack {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .padding(.bottom, 5)
                            Text("Cancellation Notice")
                            Spacer()
                            Text("\(cancel)hr")
                        }
                    }
                }
                .padding([.leading,.trailing], 15)
                if !selectedSession.personalQuote.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("About")
                        .bold()
                    //About
                    Text(selectedSession.personalQuote)
                }
                if !selectedSession.coachingExperience.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("Coaching Experience")
                        .bold()
                    //Experience
                    ForEach(selectedSession.coachingExperience, id: \.self) { ach in
                        Text(ach)
                            .padding([.leading,.trailing], 5)
                    }
                }
                if !selectedSession.coachingAchievements.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("Athletic Acheivment")
                        .bold()
                    // Achievements
                    VStack(alignment: .leading) {
                        ForEach(selectedSession.coachingAchievements, id: \.self) { ach in
                            Text(ach)
                        }
                    }
                }
                // line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
                // Review
                VStack (alignment: .leading){
                    HStack {
                        Text("Reveiw")
                            .bold()
                        HStack(spacing: 2) {
                            ForEach(1..<6) { index in
                                if selectedSession.rating - Float(index) >= 0  {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.yellow)
                                } else if selectedSession.rating - Float(index) == -0.5 {
                                    Image(systemName: "star.leadinghalf.fill")
                                        .foregroundColor(.yellow)
                                } else {
                                    Image(systemName: "star")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                        Text(String(selectedSession.rating))
                        Text("(\(selectedSession.ratings))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    if let lastReview = selectedSession.reviews.last {
                        VStack(alignment: .leading) {
                            Text(lastReview.quote)
                            Text(lastReview .reviewer.fullName)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(lastReview.date.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    } else {
                        Text("No reveiws yet")
                    }
                }
                if !selectedSession.trainingLocations.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    //Training Location
                    Text("Training Locations")
                        .bold()
                    VStack(alignment: .leading) {
                        ForEach(selectedSession.trainingLocations, id:\.self ) { loc in
                            Button(action: {
                                mapShow = loc
                            }) {
                                Text(loc.name)
                            }
                        }
                    }
                }
                //Sports/Position
                if !selectedSession.sports.isEmpty {
                    //line
                    Rectangle().frame(maxWidth: .infinity)
                        .frame(height: 1)
                        .padding(8)
                    Text("Sports/Positions")
                        .bold()
                    VStack(alignment: .leading) {
                        ForEach(selectedSession.sports,  id: \.self) { sp in
                            VStack(alignment: .leading) {
                                Text("\(sp):")
                                ForEach(selectedSession.sportPositions[sp] ?? [],  id: \.self) { p in
                                    Text("\(p)")
                                }
                            }
                        }
                    }
                }
                //line
                Rectangle().frame(maxWidth: .infinity)
                    .frame(height: 1)
                    .padding(8)
                //Schedule
                Text("Avaliability")
                    .bold()
                AvailabilityGrid(selectedA: $selectedAvailability)
                    .disabled(true)
            }
            .onAppear() {
                rootView.checkLocationEnabled()
                if let mgr = rootView.locationManager {
                    print("Auth:", mgr.authorizationStatus.rawValue)
                }
                if rootView.lastPage == "Sess" {
                    rootView.lastPage = ""
                }
            }
        }
    }
    
    // Map Structure
    struct MapShow: View {
        let specifiedLocation: CoachLocation
        @State private var camera: MapCameraPosition
        @State private var userCoordinate: CLLocationCoordinate2D?

        init(specifiedLocation: CoachLocation, userCoordinate: CLLocationCoordinate2D? = nil) {
            self.specifiedLocation = specifiedLocation
            let region: MKCoordinateRegion
            if let u = userCoordinate {
                   let a = specifiedLocation.coordinate
                   let minLat = min(a.latitude,  u.latitude)
                   let maxLat = max(a.latitude,  u.latitude)
                   let minLon = min(a.longitude, u.longitude)
                   let maxLon = max(a.longitude, u.longitude)

                   let center = CLLocationCoordinate2D(
                       latitude:  (minLat + maxLat) / 2,
                       longitude: (minLon + maxLon) / 2
                   )
                   let latDelta = max((maxLat - minLat) * 1.3, 0.02)
                   let lonDelta = max((maxLon - minLon) * 1.3, 0.02)

                   region = MKCoordinateRegion(center: center,
                                               span: .init(latitudeDelta: latDelta, longitudeDelta: lonDelta))
               } else {
                   region = MKCoordinateRegion(center: specifiedLocation.coordinate,
                                               span: .init(latitudeDelta: 0.02, longitudeDelta: 0.02))
               }

            _camera = State(initialValue: .region(region))
        }

        var body: some View {
            Map(position: $camera) {
                Marker(specifiedLocation.name, coordinate: specifiedLocation.coordinate)
            }
            .ignoresSafeArea(edges: .top)
        }
    }
}

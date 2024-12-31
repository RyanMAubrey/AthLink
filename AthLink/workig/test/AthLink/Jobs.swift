//
//  Jobs.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 12/29/24.
//
// filter based on job type and card on file
// make current athletes go to texts, make postings and requests go to

import SwiftUI
import HalfASheet

struct JobItem: Identifiable {
    let id = UUID()
    let sport: String
    let sportIcon: String
    let userName: String
    let lastMessage: String
    let date: String
    let jobType: String
    let recommendedRate: Double
    let hasCardOnFile: Bool
    let distance: Double
    let rating: Double
}

struct JobsView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var fsearch: Cond
    @State private var showSettings = false
    @State var zEditing: Bool = false
    @State var nEditing: Bool = false
    @State var zMessage: String = "Enter Zip Code"
    @State var name: String = ""
    @State var alg: Int = 0
    @State var selectedA: [String: [String]] = [:]
    @State var hr: Float = 30
    @State private var hisEditing = false
    @State var ca: Float = 20
    @State private var cisEditing = false
    @State var cg: Int = 0
    
    @State private var isAvailabilityExpanded = false
    
    // Sample data
    @State private var jobItems: [JobItem] = [
        JobItem(sport: "Football", sportIcon: "football", userName: "Marry-",
                lastMessage: "Come work with me", date: "8/20/24",
                jobType: "Individual", recommendedRate: 75.0, hasCardOnFile: true,
                distance: 5.2, rating: 4.8),
        JobItem(sport: "Football", sportIcon: "football", userName: "Barry-",
                lastMessage: "Come work with me", date: "8/20/24",
                jobType: "Group", recommendedRate: 50.0, hasCardOnFile: false,
                distance: 2.1, rating: 4.2),
        JobItem(sport: "Football", sportIcon: "football", userName: "John-",
                lastMessage: "Come work with me", date: "8/21/24",
                jobType: "Individual", recommendedRate: 65.0, hasCardOnFile: true,
                distance: 3.7, rating: 4.5)
    ]
    
    // Computed property for sorted items
    var sortedItems: [JobItem] {
        switch alg {
        case 1: // Best Match
            // Complex sorting using multiple factors
            return jobItems.sorted { first, second in
                let firstScore = first.rating * 0.4 + (10 - first.distance) * 0.3 + (100 - first.recommendedRate) * 0.3
                let secondScore = second.rating * 0.4 + (10 - second.distance) * 0.3 + (100 - second.recommendedRate) * 0.3
                return firstScore > secondScore
            }
        case 2: // Distance
            return jobItems.sorted { $0.distance < $1.distance }
        case 3: // Lowest Price
            return jobItems.sorted { $0.recommendedRate < $1.recommendedRate }
        case 4: // Highest Price
            return jobItems.sorted { $0.recommendedRate > $1.recommendedRate }
        case 5: // Ratings
            return jobItems.sorted { $0.rating > $1.rating }
        default:
            return jobItems
        }
    }
    var body: some View {
        ZStack {
            VStack {
                // Tab Header
                HStack {
                    TabButton(title: "Requests", isSelected: selectedTab == 0) {
                        selectedTab = 0
                    }
                    TabButton(title: "Postings", isSelected: selectedTab == 1) {
                        selectedTab = 1
                    }
                    TabButton(title: "Current Athletes", isSelected: selectedTab == 2) {
                        selectedTab = 2
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                Divider()
                
                // Tabs
                if selectedTab == 0 {
                    RequestsView()
                } else if selectedTab == 1 {
                    PostingsView(sett: $showSettings, items: sortedItems)
                } else {
                    CurrentAthletesView()
                }
            }
           
            // HalfASheet
            HalfASheet(isPresented: $showSettings) {
                VStack {
                    Form {
                        // Algorithm picker
                        Section(header: Text("Sort by:")) {
                            Picker(selection: $alg, label: Text("Picker")) {
                                Text("Newest").tag(1)
                                Text("Distance").tag(2)
                                Text("Lowest Price").tag(3)
                                Text("Highest Price").tag(4)
                                Text("Oldest").tag(5)
                            }
                        }
                        
                        
                        /// Availability Section
                        Section(header: Text("Availability:")) {
                            HStack {
                                Text("Availability")
                                    .font(.headline)
                                Spacer()
                                Image(systemName: isAvailabilityExpanded ? "chevron.down" : "chevron.up")
                                    .rotationEffect(Angle(degrees: isAvailabilityExpanded ? 0 : -180))
                                    .onTapGesture {
                                        withAnimation {
                                            isAvailabilityExpanded.toggle()
                                        }
                                    }
                            }
                            .padding(.vertical, 5)

                            if isAvailabilityExpanded {
                                // Availability content
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
                                                        if selectedA[day]?.contains(timeSlot) ?? false {
                                                            selectedA[day]?.removeAll(where: { $0 == timeSlot })
                                                        } else {
                                                            selectedA[day, default: []].append(timeSlot)
                                                        }
                                                    }) {
                                                        if selectedA[day]?.contains(timeSlot) ?? false {
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
                        }
                        
                        // Hourly rate
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
                                Text("$\(Int(hr))")
                                    .foregroundColor(hisEditing ? .red : .blue)
                            }
                        }
                        
                        // Coach age
                        Section(header: Text("Distance:")) {
                            VStack {
                                Slider(
                                    value: $ca,
                                    in: 0...100,
                                    step: 1
                                ) {
                                    Text("Speed")
                                } minimumValueLabel: {
                                    Text("0")
                                } maximumValueLabel: {
                                    Text("100")
                                } onEditingChanged: { editing in
                                    cisEditing = editing
                                }
                                Text("\(Int(ca))")
                                    .foregroundColor(cisEditing ? .red : .blue)
                            }
                        }
        
                    }
                }
                .padding(40)
            }
            .height(.fixed(400))
            .closeButtonColor(.black)
            .backgroundColor(.white)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .blue : .gray)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color(.systemGray5) : Color.clear)
                .cornerRadius(8)
        }
    }
}

struct RequestsView: View {
    var body: some View {
        List {
            JobItemView(
                sport: "Football",
                sportIcon: "football",
                userName: "Marry-",
                lastMessage: "Hi Coach.. I want to work with you",
                date: "8/20/24",
                jobType: "Individual",
                recommendedRate: "$75/hr",
                hasCardOnFile: true
            )
            JobItemView(
                sport: "Football",
                sportIcon: "football",
                userName: "Barry-",
                lastMessage: "Hi Coach.. I want to work with you",
                date: "8/20/24",
                jobType: "Group",
                recommendedRate: "$50/hr",
                hasCardOnFile: false
            )
        }
        .navigationTitle("Requests")
    }
}

// Update PostingsView to use the model
struct PostingsView: View {
    @Binding var sett: Bool
    let items: [JobItem]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    JobItemView(
                        sport: item.sport,
                        sportIcon: item.sportIcon,
                        userName: item.userName,
                        lastMessage: item.lastMessage,
                        date: item.date,
                        jobType: item.jobType,
                        recommendedRate: "$\(Int(item.recommendedRate))/hr",
                        hasCardOnFile: item.hasCardOnFile
                    )
                }
            }
            .navigationBarItems(trailing: Button(action: {
                sett = true
            }) {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.black)
            })
        }
    }
}

struct CurrentAthletesView: View {
    var body: some View {
        List {
            JobItemView(
                sport: "Football",
                sportIcon: "football",
                userName: "Marry",
                lastMessage: "7 sessions total: $400",
                date: "",
                jobType: "",
                recommendedRate: "",
                hasCardOnFile: true
            )
            JobItemView(
                sport: "Football",
                sportIcon: "football",
                userName: "Barry",
                lastMessage: "9 sessions total: $567",
                date: "",
                jobType: "",
                recommendedRate: "",
                hasCardOnFile: false
            )
        }
        .navigationTitle("Current Athletes")
    }
}

struct JobItemView: View {
    let sport: String
    let sportIcon: String
    let userName: String
    let lastMessage: String
    let date: String
    let jobType: String
    let recommendedRate: String
    let hasCardOnFile: Bool
    
    var body: some View {
        HStack {
            // Left Column: Sport Icon and Sport Name
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: sportIcon)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                    Text(sport)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                Text(userName)
                    .font(.headline)
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Right Column: Date, Job Details, and Card Status
            VStack(alignment: .leading, spacing: 4) {
                if !date.isEmpty {
                    Text(date)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                if !jobType.isEmpty {
                    Text("Job: \(jobType)")
                        .font(.caption)
                }
                if !recommendedRate.isEmpty {
                    Text("Recommended Rate: \(recommendedRate)")
                        .font(.caption)
                }
                
                Image(systemName: "creditcard.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(hasCardOnFile ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct JobsView_Previews: PreviewProvider {
    static var previews: some View {
        JobsView()
    }
}

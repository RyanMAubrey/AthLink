//
//  Jobs.swift
//  AthLink
//
//  Created by Kellen O'Rourke on 1/19/25.

import SwiftUI

struct Jobs: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var selectedTab = 0
    
    @State private var selectedJob: Session?
    @State private var showFiltering = false
    @State private var sortBy = "Newest"
    @State private var hourlyRate: Double = 140
    @State private var distance: Double = 20
    @State private var selectedSport = "All"
    @State private var isAvailabilityExpanded = false
    
    //TESTING ONLY(QUERY SERVER FOR ACCOUNTS TO POPULATE)
    @State var jobPostings: [Session] = []

    var body: some View {
        VStack(spacing: 0) {
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
            
            if selectedTab == 0 {
                JobListView(jobs: rootView.profile.jobRequests, tab: selectedTab, pro:rootView.profile, sel:$selectedJob)
            } else if selectedTab == 1 {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showFiltering = true
                        }) {
                            Image(systemName: "gear")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.black)
                        }
                        .padding()
                        .sheet(isPresented: $showFiltering) {
                            FilterView(
                                isPresented: $showFiltering,
                                sortBy: $sortBy,
                                hourlyRate: $hourlyRate,
                                distance: $distance,
                                selectedSport: $selectedSport
                            )
                        }
                    }
                    JobListView(jobs: jobPostings, filterCriteria: getFilterCriteria(), tab:selectedTab, pro:rootView.profile, sel:$selectedJob)
                }
            } else {
                JobListView(jobs: nil, tab:selectedTab, pro:rootView.profile, sel:$selectedJob)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .fullScreenCover(item: $selectedJob) { job in
            JobDetailView(job: job, selectedJob: $selectedJob)
        }
    }
    
    private func getFilterCriteria() -> (Double, Double, String, String) {
        (hourlyRate, distance, selectedSport, sortBy)
    }
    
    private func showJobDetail(job: Session) {
        selectedJob = job
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

struct FilterView: View {
    @Binding var isPresented: Bool
    @Binding var sortBy: String
    @Binding var hourlyRate: Double
    @Binding var distance: Double
    @Binding var selectedSport: String
    
    let sortOptions = ["Newest", "Oldest", "Lowest price", "Highest price"]
    let sportOptions = ["All", "Football", "Basketball", "Baseball", "Soccer", "Tennis"]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort By")) {
                    Picker("Sort By", selection: $sortBy) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                }
                
                Section(header: Text("Filters")) {
                    VStack(alignment: .leading) {
                        Text("Maximum Hourly Rate: $\(Int(hourlyRate))")
                        Slider(value: $hourlyRate, in: 20...200, step: 5)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Maximum Distance: \(Int(distance)) miles")
                        Slider(value: $distance, in: 5...50, step: 5)
                    }
                    
                    Picker("Sport", selection: $selectedSport) {
                        ForEach(sportOptions, id: \.self) { sport in
                            Text(sport)
                        }
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarItems(
                trailing: Button("Done") {
                    isPresented = false
                }
            )
        }
    }
}



struct JobListView: View {
    let jobs: [Session]?
    var filterCriteria: (hourlyRate: Double, distance: Double, selectedSport: String, sortBy: String)?
    var tab: Int
    let pro: ProfileID
    @Binding var sel: Session?
    
    
    var filteredJobs: [Session]? {
        guard let sess = jobs else { return nil }
        guard let criteria = filterCriteria else { return jobs }

        var filtered = sess

        filtered = filtered.filter { $0.rate <= criteria.hourlyRate }

        if criteria.selectedSport != "All" {
            filtered = filtered.filter { $0.sport.description == criteria.selectedSport }
        }

        switch criteria.sortBy {
        case "Newest":
            filtered = filtered.sorted { $0.date > $1.date }
        case "Oldest":
            filtered = filtered.sorted { $0.date < $1.date }
        case "Lowest price":
            filtered = filtered.sorted { $0.rate < $1.rate }
        case "Highest price":
            filtered = filtered.sorted { $0.rate > $1.rate }
        default:
            break
        }

        return filtered
    }
    
    var body: some View {
        if let fj = filteredJobs {
            List(fj) { job in
                Button(action: {
                    sel = job
                }) {
                    JobItemView(job: job, tab: tab, pro: pro)
                }
                .buttonStyle(PlainButtonStyle())
            }
        } else {
            List(Array(pro.currentAthletes), id: \.key) { entry in
                Button(action: {
                }) {
                    CurrentAthletes(pro: (entry.key, entry.value.0, entry.value.1))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct JobDetailView: View {
    let job: Session
    @Binding var selectedJob: Session?
    @EnvironmentObject var rootView: RootViewObj

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: { selectedJob = nil }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            .padding(.top)

            VStack(spacing: 10) {
                Text(job.other.fullName)
                    .font(.title2)
                
                HStack {
                    Text(job.other.hasCardOnFile ? "\(job.other.firstName) has card on file" : "\(job.other.firstName) has no billing on file")
                    Image(systemName: "creditcard.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(job.other.hasCardOnFile ? .green : .red)
                }
                
                if let desc = job.description {
                    Text("Description: \(desc)")
                        .font(.body)
                        .multilineTextAlignment(.center)
                }

                Text("Rate: $\(Int(job.rate))/hr")
                    .font(.headline)
                
                Text(job.date.formatted(date: .numeric, time: .omitted))
                
                Text("Sport: Football")
                
                Text("Session Type: \(job.type)")
                
            }
            .padding()

            Spacer()

            if rootView.profile.jobRequests.contains(where: { $0.id == job.id }) {
                VStack(spacing: 12) {
                    Button(action: acceptRequest) {
                        Text("Accept Request")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: declineRequest) {
                        Text("Decline Request")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }

                    Button(action: { messageAthlete(oth: job.other) }) {
                        Text("Message Athlete")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .ignoresSafeArea()
    }

    private func acceptRequest() {
        if let index = rootView.profile.jobRequests.firstIndex(where: { $0.id == job.id }) {
            let acceptedJob = rootView.profile.jobRequests.remove(at: index)
            let athlete = acceptedJob.other

            if let currentValue = rootView.profile.currentAthletes[athlete] {
                let updatedSessionCount = currentValue.0 + 1
                let updatedTotal = currentValue.1 + Int(acceptedJob.cost)
                rootView.profile.currentAthletes[athlete] = (updatedSessionCount, updatedTotal)
            } else {
                rootView.profile.currentAthletes[athlete] = (1, Int(acceptedJob.cost))
            }
            selectedJob = nil  // Dismiss
        }
    }

    private func declineRequest() {
        rootView.profile.jobRequests.removeAll { $0.id == job.id }
        selectedJob = nil  // Dismiss
    }

    private func messageAthlete(oth: ProfileID) {
        rootView.selectedSession = oth
        rootView.path.append("MessageAccount")
        selectedJob = nil // Dismiss
    }
}


struct JobItemView: View {
    let job: Session
    var tab: Int
    let pro: ProfileID
    
    var body: some View {
        HStack {
            // Sport Icon and name
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: job.sf)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.gray)
                    Text(job.sport.description)
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                
                Text(job.other.fullName)
                    .font(.headline)
                if let desc = job.description {
                    Text(desc)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            // Date, job type, rate, and card status
            VStack(alignment: .trailing, spacing: 4) {
                Text(job.date.formatted(date: .numeric, time: .omitted))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("Job: \(job.type)")
                    .font(.caption)
                Text("Rate: $\(Int(job.rate))/hr")
                    .font(.caption)
                
                Image(systemName: "creditcard.fill")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(job.other.hasCardOnFile ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}

struct CurrentAthletes: View {
    let pro: (ProfileID,Int,Int)
    
    var body: some View {
        HStack {
            // Date, job type, rate, and card status
            VStack(alignment: .leading, spacing: 4) {
                Text(pro.0.fullName)
                    .font(.headline)
                Text("Sessions: \(pro.1)")
                    .font(.caption)
                Text("Total: $\(pro.2)")
                    .font(.caption)
            }
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .shadow(radius: 1)
    }
}


#Preview {
    let rootView = createTestProfiles()
    return Jobs()
        .environmentObject(rootView)
}

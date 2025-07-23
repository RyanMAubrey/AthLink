//
//  CoachCalendar.swift
//  AthLink
//
//  Created by RyanAubrey on 7/10/25.
//

import SwiftUI

struct CoachCalendar: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var selectedTag = 0
    @State private var tabType = false

    var body: some View {
        // Upcoming sessions tab
        VStack {
            // Top part
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 100)
                    .padding(8)
                    .foregroundColor(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                    .background(Color(red: 0.4627, green: 0.8392, blue: 1.0))
                Text("Sessions")
                    .font(.system(size: 20, weight: .light, design: .serif))
            }
            // Custom Tab Buttons
            HStack {
                // Upcoming button
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTag = 0
                    }
                }) {
                    VStack(spacing: 8) {
                        Text("Upcoming")
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTag == 0 ? .blue : .secondary)
                        
                        if selectedTag == 0 {
                            Color.blue
                                .frame(height: 2)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
                // Unsubmitted Button
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTag = 1
                    }
                }) {
                    VStack(spacing: 8) {
                        Text("Unsubmitted")
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTag == 1 ? .blue : .secondary)
                        
                        if selectedTag == 1 {
                            Color.blue
                                .frame(height: 2)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())

                // Submitted Button
                Button(action: {
                    withAnimation(.spring()) {
                        selectedTag = 2
                    }
                }) {
                    VStack(spacing: 8) {
                        Text("Submitted")
                            .fontWeight(.semibold)
                            .foregroundColor(selectedTag == 2 ? .blue : .secondary)
                        
                        if selectedTag == 2 {
                            Color.blue
                                .frame(height: 2)
                        } else {
                            Color.clear.frame(height: 2)
                        }
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.top)
            // Calendar section
            switch selectedTag {
            case 0:
                CalendarBody()
                    .environmentObject(rootView)
            case 1:
                CoachSession(tabType: .constant(true))
            case 2:
                CoachSession(tabType: .constant(false))
            default:
                EmptyView()
            }
        }
    }
    
    struct CalendarBody: View {
        @EnvironmentObject var rootView: RootViewObj
        @State private var currentDate: Date = Date()
        
        // Formats week
        func formatWeekRange(from week: [Date]) -> String {
            // Make sure the week array is not empty
            guard let firstDay = week.first, let lastDay = week.last else {
                return ""
            }
            let calendar = Calendar.current
            let formatter = DateFormatter()
            // Get the month and day for the first and last days of the week
            let firstMonth = calendar.component(.month, from: firstDay)
            let firstDayNum = calendar.component(.day, from: firstDay)
            let lastMonth = calendar.component(.month, from: lastDay)
            let lastDayNum = calendar.component(.day, from: lastDay)
            let year = calendar.component(.year, from: lastDay)
            
            // Check if the week is in the same month
            if firstMonth == lastMonth {
                // Case 1: Same month
                formatter.dateFormat = "MMMM" // Full month name: "July"
                let monthName = formatter.string(from: firstDay)
                return "\(monthName) \(firstDayNum) - \(lastDayNum)  \(year)"
            } else {
                // Case 2: Spans two months
                formatter.dateFormat = "MMM"
                let firstMonthName = formatter.string(from: firstDay)
                let lastMonthName = formatter.string(from: lastDay)
                return "\(firstMonthName) \(firstDayNum) - \(lastMonthName) \(lastDayNum) \(year)"
            }
        }
        
        // Finds the current weeek based on given day
        func WeekGet(day: Date = Date()) -> [Date] {
            guard let cc = Calendar.current.dateInterval(of: .weekOfYear, for: day) else {
                return []
            }
            var weekDays: [Date] = []
            for i in 0..<7 {
                if let dayCalc = Calendar.current.date(byAdding: .day, value: i, to: cc.start) {
                    weekDays.append(dayCalc)
                }
            }
            return weekDays
        }
        
//        // Adds the sections to the calendar as an overlay
//        func CreatesSession(range: [Date]) -> some View {
//            // Claculates the session in the week
//            let curentSession: [Session] = Array(rootView.profile.cupcomingSessions.filter({
//                    let first: Date = range.first ?? Date()
//                    let last: Date = Calendar.current.date(byAdding: Calendar.Component.day, value: 7, to: first)!
//                    return $0.date >= first && $0.date <= last
//                })
//            )
//            return GeometryReader { geometry in
//            }
//        }
        
        // creates calander for specific range
        func CreateCalendar(range: [Date]) -> some View {
            let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            let timeSlots = (6...22).map { "\($0 % 12 == 0 ? 12 : $0 % 12) \($0 < 12 || $0 == 24 ? "AM" : "PM")" }
            let columns: [GridItem] = [GridItem(.fixed(60))] + Array(repeating: GridItem(.flexible()), count: 7)
            
            return ScrollView([.horizontal, .vertical], showsIndicators: false) {
                LazyVGrid(columns: columns, spacing: 0) {
                    // Top Column
                    // Empty Cell Corner
                    Color.clear
                        .frame(height: 80)
                    // Top Row
                    ForEach(0..<7, id: \.self) { index in
                        let dayDate = range[index]
                        let isToday = Calendar.current.isDateInToday(dayDate)
                        
                        VStack(spacing: 8) {
                            Text(daysOfWeek[index].uppercased())
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.secondary)
                            
                            Text("\(Calendar.current.component(.day, from: dayDate))")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isToday ? .white : .primary)
                                .frame(width: 40, height: 40)
                                .background(
                                    ZStack {
                                        if isToday {
                                            Circle().fill(Color.blue)
                                                .shadow(color: .blue.opacity(0.4), radius: 5, y: 3)
                                        }
                                    }
                                )
                        }
                        .frame(minHeight: 80)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                    }

                    // Time Slots
                    ForEach(timeSlots, id: \.self) { time in
                        // Time label
                        Text(time)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                            .padding(.top, 5)
                            .padding(.trailing, 8)
                            .background(Color(.systemGray6))
                        // Empty cells
                        ForEach(0..<7, id: \.self) { dayIndex in
                            Rectangle()
                                .fill(Color(.systemBackground))
                                .frame(height: 60)
                        }
                    }
                }
                .background(Color(.systemGray4))
            }
        }
        
        // Calendar
        var body: some View {
            // Gets the current seven days
            let currentWeek = WeekGet(day: currentDate)
            VStack(spacing: 0) {
                // Top Buttons
                HStack {
                    // Left Arrow Button
                    Button(action: {
                        // Goes to the previous week by subtracting 7 days and gets that week
                        currentDate = Calendar.current.date(byAdding: .day, value: -7, to: currentDate)!
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    }
                    // Date Label
                    Spacer()
                    Text(formatWeekRange(from: currentWeek))
                        .font(.headline)
                        .fontWeight(.semibold)
                        .frame(minWidth: 150)
                    Spacer()
                    // Right Arrow Button
                    Button(action: {
                        // Goes to the next week by adding 7 days and gets that week
                        currentDate = Calendar.current.date(byAdding: .day, value: 7, to: currentDate)!
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    }
                }
                .padding()
                CreateCalendar(range: WeekGet(day: currentDate))
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
            .padding(.horizontal)
        }
    }
}


#Preview {
    CoachCalendar()
}

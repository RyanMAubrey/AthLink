import SwiftUI
import Supabase

struct CoachCalendar: View {
    @EnvironmentObject var rootView: RootViewObj
    @State private var currentDate: Date = Date()
    @State private var selectedSession: Session?

    private let hourHeight: CGFloat = 60
    private let startHour = 6
    private let endHour = 22
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    // Current week from currentDate
    private var currentWeek: [Date] {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate) else { return [] }
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: interval.start) }
    }

    // Sessions that fall within the current week
    private var weekSessions: [Session] {
        guard let first = currentWeek.first,
              let last = Calendar.current.date(byAdding: .day, value: 1, to: currentWeek.last ?? first)
        else { return [] }
        return rootView.profile.coachUpcomingSessions.filter { $0.date >= first && $0.date < last }
    }

    // Format week range header
    private var weekRangeText: String {
        guard let first = currentWeek.first, let last = currentWeek.last else { return "" }
        let cal = Calendar.current
        let fmt = DateFormatter()
        let fMonth = cal.component(.month, from: first)
        let lMonth = cal.component(.month, from: last)
        let fDay = cal.component(.day, from: first)
        let lDay = cal.component(.day, from: last)
        if fMonth == lMonth {
            fmt.dateFormat = "MMMM"
            return "\(fmt.string(from: first)) \(fDay) - \(lDay)"
        } else {
            fmt.dateFormat = "MMM"
            return "\(fmt.string(from: first)) \(fDay) - \(fmt.string(from: last)) \(lDay)"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Week navigation
            HStack {
                Button(action: { if let d = Calendar.current.date(byAdding: .day, value: -7, to: currentDate) { currentDate = d } }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                }
                Button(action: { if let d = Calendar.current.date(byAdding: .day, value: 7, to: currentDate) { currentDate = d } }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                }
                Text(weekRangeText)
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            // Calendar grid
            GeometryReader { geo in
                let timeColWidth: CGFloat = 50
                let dayWidth = (geo.size.width - timeColWidth) / 7
                let headerHeight: CGFloat = 50
                let totalHeight = headerHeight + CGFloat(endHour - startHour) * hourHeight

                ScrollView([.vertical], showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        // Grid background
                        VStack(spacing: 0) {
                            // Header row
                            HStack(spacing: 0) {
                                Color.clear.frame(width: timeColWidth, height: headerHeight)
                                ForEach(0..<7, id: \.self) { i in
                                    dayHeader(index: i, width: dayWidth)
                                        .frame(width: dayWidth, height: headerHeight)
                                }
                            }
                            // Time rows
                            ForEach(startHour..<endHour, id: \.self) { hour in
                                HStack(spacing: 0) {
                                    // Time label
                                    Text(hourLabel(hour))
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                        .frame(width: timeColWidth, height: hourHeight, alignment: .topTrailing)
                                        .padding(.trailing, 4)

                                    // Day cells
                                    ForEach(0..<7, id: \.self) { _ in
                                        Rectangle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 0.5)
                                            .frame(width: dayWidth, height: hourHeight)
                                    }
                                }
                            }
                        }

                        // Session overlays
                        ForEach(weekSessions, id: \.id) { session in
                            sessionBlock(session: session, dayWidth: dayWidth, timeColWidth: timeColWidth, headerHeight: headerHeight)
                        }
                    }
                    .frame(height: totalHeight)
                }
            }
        }
        .sheet(item: $selectedSession) { session in
            SessionInfoSheet(session: session, client: rootView.client)
        }
    }

    // MARK: - Day Header

    private func dayHeader(index: Int, width: CGFloat) -> some View {
        let date = index < currentWeek.count ? currentWeek[index] : Date()
        let isToday = Calendar.current.isDateInToday(date)
        let day = Calendar.current.component(.day, from: date)

        return VStack(spacing: 2) {
            Text(daysOfWeek[index])
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text("\(day)")
                .font(.subheadline)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 28, height: 28)
                .background(isToday ? Circle().fill(Color.blue) : nil)
        }
    }

    // MARK: - Hour Label

    private func hourLabel(_ hour: Int) -> String {
        let h = hour % 12 == 0 ? 12 : hour % 12
        let ampm = hour < 12 ? "AM" : "PM"
        return "\(h) \(ampm)"
    }

    // MARK: - Session Block

    private func sessionBlock(session: Session, dayWidth: CGFloat, timeColWidth: CGFloat, headerHeight: CGFloat) -> some View {
        let cal = Calendar.current
        let dayOfWeek = cal.component(.weekday, from: session.date) - 1 // 0=Sun
        let startComponents = cal.dateComponents([.hour, .minute], from: session.date)
        let endComponents = cal.dateComponents([.hour, .minute], from: session.finished)

        let startMinutes = (startComponents.hour ?? startHour) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? startHour) * 60 + (endComponents.minute ?? 0)
        let originMinutes = startHour * 60

        let topOffset = headerHeight + CGFloat(startMinutes - originMinutes) / 60.0 * hourHeight
        let height = max(CGFloat(endMinutes - startMinutes) / 60.0 * hourHeight, 20)
        let leftOffset = timeColWidth + CGFloat(dayOfWeek) * dayWidth

        let colors: [Color] = [.red.opacity(0.5), .blue.opacity(0.4), .green.opacity(0.4), .orange.opacity(0.4), .purple.opacity(0.4)]
        let color = colors[abs(session.id.hashValue) % colors.count]

        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm"
        let timeStr = "\(fmt.string(from: session.date))-\(fmt.string(from: session.finished))"

        return Button(action: { selectedSession = session }) {
            VStack(spacing: 1) {
                Text(session.sport.description)
                    .font(.system(size: 9, weight: .bold))
                Text(timeStr)
                    .font(.system(size: 8))
            }
            .foregroundColor(.black)
            .frame(width: dayWidth - 4, height: height)
            .background(color)
            .cornerRadius(4)
        }
        .offset(x: leftOffset + 2, y: topOffset)
    }
}

// MARK: - Session Info Sheet

struct SessionInfoSheet: View {
    let session: Session
    let client: SupabaseClient
    @Environment(\.dismiss) var dismiss
    @State private var athlete: PublicUser?

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                List {
                    if let athlete {
                        Section("Athlete") {
                            Text(athlete.fullName)
                        }
                    }
                    Section("Details") {
                        HStack {
                            Text("Sport")
                            Spacer()
                            Text(session.sport.description)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Type")
                            Spacer()
                            Text(session.type.description)
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Date")
                            Spacer()
                            Text(session.date.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Time")
                            Spacer()
                            let fmt = DateFormatter()
                            let _ = fmt.dateFormat = "h:mm a"
                            Text("\(fmt.string(from: session.date)) - \(fmt.string(from: session.finished))")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Duration")
                            Spacer()
                            Text("\(session.totalTime.0)h \(session.totalTime.1)m")
                                .foregroundColor(.gray)
                        }
                        HStack {
                            Text("Total")
                            Spacer()
                            Text(String(format: "$%.2f", session.cost))
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                        }
                    }
                    if session.location.name != "nan" {
                        Section("Location") {
                            Text(session.location.name)
                        }
                    }
                }
            }
            .navigationTitle("Session Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .task {
                do {
                    let fetched: PublicUser = try await client
                        .from("profiles")
                        .select("id, first_name, last_name, image_url, card_on_file")
                        .eq("id", value: session.other.uuidString)
                        .single()
                        .execute()
                        .value
                    athlete = fetched
                } catch {
                    print("Failed to fetch athlete:", error)
                }
            }
        }
    }
}

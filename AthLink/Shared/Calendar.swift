import SwiftUI

struct WeeklyCalendar: View {
    let sessions: [Session]
    let onSelect: (Session) -> Void

    @State private var currentDate: Date = Date()
    @State private var selectedSession: Session?

    private let hourHeight: CGFloat = 72
    private let startHour = 6
    private let endHour = 22
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    private var currentWeek: [Date] {
        guard let interval = Calendar.current.dateInterval(of: .weekOfYear, for: currentDate) else { return [] }
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: interval.start) }
    }

    private var weekSessions: [Session] {
        guard let first = currentWeek.first,
              let last = Calendar.current.date(byAdding: .day, value: 1, to: currentWeek.last ?? first)
        else { return [] }
        return sessions.filter { $0.date >= first && $0.date < last }
    }

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
            HStack(spacing: 16) {
                HStack(spacing: 12) {
                    Button(action: { if let d = Calendar.current.date(byAdding: .day, value: -7, to: currentDate) { currentDate = d } }) {
                        Image(systemName: "chevron.left")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    Button(action: { if let d = Calendar.current.date(byAdding: .day, value: 7, to: currentDate) { currentDate = d } }) {
                        Image(systemName: "chevron.right")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }

                Text(weekRangeText)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: { currentDate = Date() }) {
                    Text("Today")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            // Day headers (sticky)
            HStack(spacing: 0) {
                Color.clear.frame(width: 52, height: 56)
                ForEach(0..<7, id: \.self) { i in
                    dayHeader(index: i)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                }
            }
            .background(Color(.systemBackground))

            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)

            // Time grid
            GeometryReader { geo in
                let timeColWidth: CGFloat = 52
                let dayWidth = (geo.size.width - timeColWidth) / 7
                let totalHeight = CGFloat(endHour - startHour) * hourHeight

                ScrollView([.vertical], showsIndicators: true) {
                    ZStack(alignment: .topLeading) {
                        // Grid lines
                        VStack(spacing: 0) {
                            ForEach(startHour..<endHour, id: \.self) { hour in
                                HStack(spacing: 0) {
                                    Text(hourLabel(hour))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .frame(width: timeColWidth, height: hourHeight, alignment: .topTrailing)
                                        .padding(.trailing, 6)

                                    ForEach(0..<7, id: \.self) { _ in
                                        Rectangle()
                                            .stroke(Color.gray.opacity(0.15), lineWidth: 0.5)
                                            .frame(width: dayWidth, height: hourHeight)
                                    }
                                }
                            }
                        }

                        // Session blocks
                        ForEach(weekSessions, id: \.id) { session in
                            sessionBlock(session: session, dayWidth: dayWidth, timeColWidth: timeColWidth)
                        }
                    }
                    .frame(height: totalHeight)
                }
            }
        }
        .onChange(of: selectedSession) { _, newValue in
            if let session = newValue {
                onSelect(session)
                selectedSession = nil
            }
        }
    }

    // MARK: - Day Header

    private func dayHeader(index: Int) -> some View {
        let date = index < currentWeek.count ? currentWeek[index] : Date()
        let isToday = Calendar.current.isDateInToday(date)
        let day = Calendar.current.component(.day, from: date)

        return VStack(spacing: 4) {
            Text(daysOfWeek[index])
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isToday ? .blue : .secondary)
            Text("\(day)")
                .font(.callout)
                .fontWeight(isToday ? .bold : .regular)
                .foregroundColor(isToday ? .white : .primary)
                .frame(width: 32, height: 32)
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

    private func sessionBlock(session: Session, dayWidth: CGFloat, timeColWidth: CGFloat) -> some View {
        let cal = Calendar.current
        let dayOfWeek = cal.component(.weekday, from: session.date) - 1
        let startComponents = cal.dateComponents([.hour, .minute], from: session.date)
        let endComponents = cal.dateComponents([.hour, .minute], from: session.finished)

        let startMinutes = (startComponents.hour ?? startHour) * 60 + (startComponents.minute ?? 0)
        let endMinutes = (endComponents.hour ?? startHour) * 60 + (endComponents.minute ?? 0)
        let originMinutes = startHour * 60

        let topOffset = CGFloat(startMinutes - originMinutes) / 60.0 * hourHeight
        let height = max(CGFloat(endMinutes - startMinutes) / 60.0 * hourHeight, 28)
        let leftOffset = timeColWidth + CGFloat(dayOfWeek) * dayWidth

        let colors: [Color] = [.red, .blue, .green, .orange, .purple]
        let baseColor = colors[abs(session.id.hashValue) % colors.count]

        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm"
        let timeStr = "\(fmt.string(from: session.date))-\(fmt.string(from: session.finished))"

        return Button(action: { selectedSession = session }) {
            VStack(alignment: .leading, spacing: 2) {
                Text(session.sport.description)
                    .font(.system(size: 10, weight: .bold))
                Text(timeStr)
                    .font(.system(size: 9))
            }
            .foregroundColor(baseColor)
            .padding(.horizontal, 3)
            .padding(.vertical, 2)
            .frame(width: dayWidth - 6, height: height, alignment: .topLeading)
            .background(baseColor.opacity(0.15))
            .overlay(
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(baseColor)
                        .frame(width: 3)
                    Spacer()
                }
            )
            .cornerRadius(4)
        }
        .offset(x: leftOffset + 3, y: topOffset)
    }
}

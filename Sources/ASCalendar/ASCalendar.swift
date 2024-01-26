
import SwiftUI

public struct ASCalendar: View {
    @Environment(\.calendar) private var calendar
    var configuration: ASCalendarConfiguration
    var month: Date
    var events: [ASCalendarEvent]
    var onSelect: (Date) -> Void
    
    private var dates: [CalendarDate] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.calendar, .year, .month], from: month)),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
              let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth),
              let startDate = calendar.date(byAdding: .day, value: -startOfMonth.weekday, to: startOfMonth),
              let endDate = calendar.date(byAdding: .day, value: 42-calendar.dateComponents([.day], from: startDate, to: endOfMonth).day!, to: endOfMonth) else { return [] }
        var dates: [CalendarDate] = []
        calendar.enumerateDates(startingAfter: startDate,
                                matching: DateComponents(hour: 0, minute: 0),
                                matchingPolicy: .nextTime,
                                using: { date, _, isEnd in
            if let date {
                if date <= endDate {
                    let isSameMonth = date.year == startOfMonth.year && date.month == startOfMonth.month
                    dates.append(CalendarDate(date: date, isSameMonth: isSameMonth))
                } else {
                    isEnd = true
                }
            }
        })
        return dates
    }
    
    struct CalendarDate: Identifiable {
        var id: UUID = UUID()
        var date: Date
        var isSameMonth: Bool
    }
    
    public init(configuration: ASCalendarConfiguration = ASCalendarConfiguration(),
                month: Date,
                events: [ASCalendarEvent],
                onSelect: @escaping (Date) -> Void) {
        self.configuration = configuration
        self.month = month
        self.events = events
        self.onSelect = onSelect
    }
    
    public var body: some View {
        ZStack {
            if !events.isEmpty {
                CalendarEvents(month: month, events: events)
            }
            GeometryReader { proxy in
                let cellHeight = (proxy.size.height-configuration.spacing*5)/6
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: configuration.dateCell.minimumWidth, maximum: .infinity), spacing: 0), count: 7), spacing: configuration.spacing) {
                    ForEach(dates) { date in
                        Button(action: { onSelect(date.date) }) {
                            ASCalendarCell(date: date)
                                .frame(minHeight: max(0, cellHeight), alignment: .top)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .environment(\.ascalendarConfiguration, configuration)
    }
}

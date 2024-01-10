//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import SwiftUI

public struct ASCalendarView: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.calendarConfiguration) private var configuration
    var month: Date
    var events: [CalendarEvent]
    var onSelect: (Date) -> Void
    
    public init(month: Date, events: [CalendarEvent], onSelect: @escaping (Date) -> Void) {
        self.month = month
        self.onSelect = onSelect
        self.events = events
    }
    
    private var monthDates: [CalendarDate] {
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
    
    public var body: some View {
        ZStack {
            WeekLines(month: month, calendarEvents: events)
            GeometryReader { proxy in
                let cellHeight = (proxy.size.height-configuration.spacing*5)/6
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(minimum: configuration.dateCell.minimumWidth, maximum: .infinity), spacing: 0), count: 7), spacing: configuration.spacing) {
                    ForEach(monthDates) { date in
                        Button(action: { onSelect(date.date) }) {
                            CalendarCell(date: date)
                                .frame(minHeight: max(0, cellHeight), alignment: .top)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}


#Preview {
    ASCalendarView(month: .now,
              events: [ .init(startAt: .now, endAt: .now.addingTimeInterval(86400*5), title: "Test", color: .red),
                        .init(startAt: .now.addingTimeInterval(86400), endAt: .now.addingTimeInterval(86400*2), title: "Test2", color: .blue) ], 
              onSelect: { _ in })
}

//
//  SwiftUIView.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import SwiftUI

struct CalendarEvents: View {
    @Environment(\.ascalendarConfiguration) private var configuration
    @Environment(\.calendar) private var calendar
    var month: Date
    var events: [ASCalendarEvent]
    
    private var monthDates: [Date] {
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.calendar, .year, .month], from: month)),
              let nextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth),
              let endOfMonth = calendar.date(byAdding: .day, value: -1, to: nextMonth),
              let startDate = calendar.date(byAdding: .day, value: -startOfMonth.weekday, to: startOfMonth),
              let endDate = calendar.date(byAdding: .day, value: 42-calendar.dateComponents([.day], from: startDate, to: endOfMonth).day!, to: endOfMonth) else { return [] }
        
        var dates: [Date] = []
        calendar.enumerateDates(startingAfter: startDate,
                                matching: DateComponents(hour: 0, minute: 0),
                                matchingPolicy: .nextTime,
                                using: { date, _, isEnd in
            if let date {
                if date <= endDate {
                    dates.append(date)
                } else {
                    isEnd = true
                }
            }
        })
        return dates
    }
    private var lineDatas: [LineData] {
        var lines: [LineData] = []
        let minDates = monthDates.filter { $0.weekday == 1 }
        let maxDates = monthDates.filter { $0.weekday == 7 }
        for (minDate, maxDate) in zip(minDates, maxDates) {
            lines.append(LineData(startAt: minDate, endAt: maxDate))
        }
        lines.sort(by: { $0.startAt < $1.startAt })
        return lines
    }
    
    private struct LineData: Identifiable {
        var id: UUID = UUID()
        var startAt: Date
        var endAt: Date
    }
    
    var body: some View {
        VStack(spacing: configuration.spacing) {
            ForEach(lineDatas) { line in
                WeekEvents(events: events,
                               startAt: line.startAt,
                               endAt: line.endAt)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

struct WeekEvents: View {
    @Environment(\.ascalendarConfiguration) private var configuration
    var events: [ASCalendarEvent]
    var startAt: Date
    var endAt: Date
    
    private var weekEvents: [ASCalendarEvent] {
        events.filter { event in
            (event.startAt <= endAt && event.endAt >= startAt) || (event.startAt >= startAt && event.endAt <= endAt)
        }
    }
    
    var body: some View {
        WeekEventsLayout(startAt: startAt, endAt: endAt,
                         spacing: configuration.eventCell.spacing,
                         dateCellConfig: configuration.dateCell,
                         eventCellConfig: configuration.eventCell) {
            ForEach(weekEvents) { event in
                Text(event.title)
                    .font(configuration.eventCell.font)
                    .frame(maxWidth: .infinity, maxHeight: configuration.eventCell.height)
                    .background(.tertiary, in: RoundedRectangle(cornerRadius: configuration.eventCell.cornerRadius))
                    .foregroundStyle(Color(hex: event.hexColor))
                    .eventDate(startAt: event.startAt, endAt: event.endAt)
            }
        }
    }
}

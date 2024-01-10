//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import SwiftUI

struct WeekLines: View {
    @Environment(\.calendar) private var calendar
    var month: Date
    var calendarEvents: [CalendarEvent]
    
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
            lines.append(LineData(minDate: minDate, maxDate: maxDate))
        }
        lines.sort(by: { $0.minDate < $1.minDate })
        return lines
    }
    
    private struct LineData: Identifiable {
        var id: UUID = UUID()
        var minDate: Date
        var maxDate: Date
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(lineDatas) { line in
                WeekLine(minDate: line.minDate, maxDate: line.maxDate, calendarEvents: calendarEvents)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

fileprivate struct WeekLine: View {
    @Environment(\.calendarConfiguration) private var configuration
    var calendarEvents: [CalendarEvent]
    var minDate: Date
    var maxDate: Date
    
    init(minDate: Date, maxDate: Date, calendarEvents: [CalendarEvent]) {
        self.minDate = minDate
        self.maxDate = maxDate
        self.calendarEvents = calendarEvents
    }
    
    var body: some View {
        CalendarLineLayout(minDate: minDate, maxDate: maxDate,
                           titleHeight: configuration.dateCell.titleHeight + configuration.titleSpacing,
                           cellHeight: configuration.eventCell.height, spacing: configuration.eventCell.spacing) {
            ForEach(calendarEvents.filter { event in
                (event.startAt <= maxDate && event.endAt >= minDate) || (event.startAt >= minDate && event.endAt <= maxDate)
            }) { event in
                Text(event.title)
                    .font(configuration.eventCell.font)
                    .frame(maxWidth: .infinity, maxHeight: configuration.eventCell.height)
                    .background(.tertiary, in: RoundedRectangle(cornerRadius: configuration.eventCell.cornerRadius))
                    .foregroundStyle(event.color)
                    .calendarLayout(startAt: event.startAt, endAt: event.endAt)
            }
        }
    }
}

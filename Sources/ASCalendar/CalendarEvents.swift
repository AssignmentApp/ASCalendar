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
    var dates: [Date]
    var events: [ASCalendarEvent]
    
    private var lineDatas: [LineData] {
        var lines: [LineData] = []
        let minDates = dates.filter { $0.weekday == 1 }
        let maxDates = dates.filter { $0.weekday == 7 }
        for (minDate, maxDate) in zip(minDates, maxDates) {
            lines.append(LineData(startAt: minDate, 
                                  endAt: maxDate,
                                  events: events.filter { event in
                (event.startAt <= maxDate && event.endAt >= minDate) || (event.startAt >= minDate && event.endAt <= maxDate)
            }))
        }
        lines.sort(by: { $0.startAt < $1.startAt })
        return lines
    }
    
    struct LineData: Identifiable {
        var id: UUID = UUID()
        var startAt: Date
        var endAt: Date
        var events: [ASCalendarEvent]
    }
    
    var body: some View {
        VStack(spacing: configuration.spacing) {
            ForEach(lineDatas) { line in
                WeekEvents(weekData: line)
                    .frame(maxHeight: .infinity, alignment: .top)
            }
        }
    }
}

struct WeekEvents: View {
    @Environment(\.ascalendarConfiguration) private var configuration
    var weekData: CalendarEvents.LineData
    
    var body: some View {
        WeekEventsLayout(startAt: weekData.startAt, endAt: weekData.endAt,
                         spacing: configuration.eventCell.spacing,
                         titleSpcaing: configuration.titleSpacing,
                         dateCellConfig: configuration.dateCell,
                         eventCellConfig: configuration.eventCell) {
            ForEach(weekData.events) { event in
                Text(event.title)
                    .lineLimit(1)
                    .font(configuration.eventCell.font)
                    .frame(maxWidth: .infinity, maxHeight: configuration.eventCell.height)
                    .background(.tertiary, in: RoundedRectangle(cornerRadius: configuration.eventCell.cornerRadius))
                    .foregroundStyle(Color(hex: event.hexColor))
                    .eventDate(startAt: event.startAt, endAt: event.endAt)
            }
        }
    }
}

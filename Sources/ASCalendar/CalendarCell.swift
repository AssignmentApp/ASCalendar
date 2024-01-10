//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation
import SwiftUI

struct CalendarCell: View {
    @Environment(\.calendarConfiguration) private var configuration
    @Environment(\.calendar) private var calendar
    var date: MonthView.CalendarDate
    
    private var isSunday: Bool {
        date.date.weekday == 1
    }
    private var isSaturday: Bool {
        date.date.weekday == 7
    }
    private var isToday: Bool {
        calendar.isDateInToday(date.date)
    }
    private var fontColor: Color {
        if isToday {
            Color.accentColor
        } else if isSunday {
            Color.red
        } else if isSaturday {
            Color.blue
        } else {
            Color.primary
        }
    }
    
    init(date: MonthView.CalendarDate) {
        self.date = date
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(String(date.date.day))
                .font(configuration.dateCell.font)
                .frame(height: configuration.dateCell.titleHeight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            RoundedRectangle(cornerRadius: configuration.eventCell.cornerRadius)
                .foregroundStyle(.fill)
                .opacity(isToday ? 0.3 : 0)
        }
        .foregroundStyle(date.isSameMonth ? .primary : .tertiary)
        .foregroundStyle(fontColor)
    }
}

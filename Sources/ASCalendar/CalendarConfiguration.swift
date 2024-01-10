//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation
import SwiftUI

public struct ASCalendarConfiguration {
    
    /// 이벤트 타이틀과 이벤트 셀 사이의 공간
    var titleSpacing: CGFloat
    
    var spacing: CGFloat
    
    var eventCell: EventCellConfiguration
    
    var dateCell: DateCellConfiguration
    
    /// 이벤트셀 설정
    public struct EventCellConfiguration {
        var font: Font
        var cornerRadius: CGFloat
        var height: CGFloat
        var spacing: CGFloat
        
        public init(font: Font = .caption, cornerRadius: CGFloat = 8, height: CGFloat = 22, spacing: CGFloat = 2) {
            self.font = font
            self.cornerRadius = cornerRadius
            self.height = height
            self.spacing = spacing
        }
    }
    
    /// 날짜셀 설정
    public struct DateCellConfiguration {
        var font: Font
        var titleHeight: CGFloat
        var minimumWidth: CGFloat
        
        public init(font: Font = .body, titleHeight: CGFloat = 25, minimumWidth: CGFloat = 45) {
            self.font = font
            self.titleHeight = titleHeight
            self.minimumWidth = minimumWidth
        }
    }
    
    public init(titleSpacing: CGFloat = 3,
                spacing: CGFloat = 5,
                eventCell: EventCellConfiguration = EventCellConfiguration(),
                dateCell: DateCellConfiguration = DateCellConfiguration()) {
        self.titleSpacing = titleSpacing
        self.spacing = spacing
        self.eventCell = eventCell
        self.dateCell = dateCell
    }
}

struct CalendarConfigurationEnvironmentKey: EnvironmentKey {
    static var defaultValue: ASCalendarConfiguration = ASCalendarConfiguration()
}

extension EnvironmentValues {
    var calendarConfiguration: ASCalendarConfiguration {
        get { self[CalendarConfigurationEnvironmentKey.self] }
        set { self[CalendarConfigurationEnvironmentKey.self] = newValue }
    }
}

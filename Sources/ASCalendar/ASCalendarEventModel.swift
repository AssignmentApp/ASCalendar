//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation

public struct ASCalendarEvent: Identifiable {
    public var id: UUID = UUID()
    var startAt: Date
    var endAt: Date
    var title: String
    var hexColor: String
    
    public init(startAt: Date, endAt: Date, title: String, color: String) {
        self.startAt = startAt
        self.endAt = endAt
        self.title = title
        self.hexColor = color
    }
}

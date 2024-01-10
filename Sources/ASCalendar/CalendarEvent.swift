//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation
import SwiftUI

public struct CalendarEvent: Identifiable {
    public var id: UUID = UUID()
    var startAt: Date
    var endAt: Date
    var title: String
    var color: Color
    
    public init(startAt: Date, endAt: Date, title: String, color: Color) {
        self.startAt = startAt
        self.endAt = endAt
        self.title = title
        self.color = color
    }
}

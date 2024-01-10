//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation
import SwiftUI

extension View {
    func eventDate(startAt: Date, endAt: Date) -> some View {
        layoutValue(key: EventDateLayoutData.self, value: EventDateLayoutData(startAt: startAt, endAt: endAt))
    }
}

struct EventDateLayoutData: LayoutValueKey {
    var startAt: Date
    var endAt: Date
    
    static var defaultValue: EventDateLayoutData?
}

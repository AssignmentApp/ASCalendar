//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation

extension Date {
    
    /// 1: Sunday
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
    
    var month: Int {
        Calendar.current.component(.month, from: self)
    }
    
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
    
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }
}

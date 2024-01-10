//
//  File.swift
//  
//
//  Created by Lee Jaeho on 1/10/24.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: String) {
        let hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexStr)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        
        var color: UInt64 = 0
        
        if !scanner.scanHexInt64(&color) {
            color = 0xDED0B6
        }
        
        let r = Double((color>>16)&0xFF) / 255.0
        let g = Double((color>>8)&0xFF) / 255.0
        let b = Double(color&0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

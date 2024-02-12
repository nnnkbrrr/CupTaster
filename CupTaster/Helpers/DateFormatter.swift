//
//  DateFormatter.swift
//  CupTaster
//
//  Created by Никита Баранов on 10.07.2023.
//

import SwiftUI

extension DateFormatter {
    static var short: DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM"
        return dateFormatter
    }
    
    static var fullMonthAndYear: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
    
    static var full: DateFormatter {
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        return dateFormatter
    }
}

extension Date {
    var short: String {
        DateFormatter.short.string(from: self)
    }
    
    var fullMonthAndYear: String {
        DateFormatter.fullMonthAndYear.string(from: self)
    }
    
    var full: String {
        DateFormatter.full.string(from: self)
    }
}

extension Optional where Wrapped == Date {
    var short: String {
        if let date = self { return DateFormatter.short.string(from: date) }
        else { return "" }
    }
    
    var fullMonthAndYear: String {
        if let date = self { return DateFormatter.fullMonthAndYear.string(from: date) }
        else { return "" }
    }
}

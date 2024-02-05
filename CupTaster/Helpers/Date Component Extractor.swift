//
//  Date Component Extractor.swift
//  CupTaster
//
//  Created by Nikita on 05.02.2024.
//

import SwiftUI

class MonthAndYear: Hashable, Comparable {
    let month: Int
    let year: Int
    
    init(month: Int, year: Int) {
        self.month = month
        self.year = year
    }
    
    var dateFormatter: DateFormatter {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.locale = Locale.current
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter
    }
    
    var monthName: String {
        return dateFormatter.standaloneMonthSymbols[month - 1]
    }
    var string: String { monthName.capitalized + " \(year)" }
    
    static func == (lhs: MonthAndYear, rhs: MonthAndYear) -> Bool {
        return (lhs.month, lhs.year) == (rhs.month, rhs.year)
    }
    
    static func < (lhs: MonthAndYear, rhs: MonthAndYear) -> Bool {
        return (lhs.year, lhs.month) < (rhs.year, rhs.month)
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(string)
    }
}

extension Date {
    func get(_ components: Calendar.Component...) -> DateComponents {
        let calendar: Calendar = Calendar.current
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component) -> Int {
        let calendar: Calendar = Calendar.current
        return calendar.component(component, from: self)
    }
    
    func getMonthAndYear() -> MonthAndYear {
        return .init(month: self.get(.month), year: self.get(.year))
    }
}

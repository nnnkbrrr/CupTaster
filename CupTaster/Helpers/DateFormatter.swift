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
}

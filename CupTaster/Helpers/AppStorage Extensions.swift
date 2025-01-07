//
//  AppStorage extensions.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

// Date

extension Date: @retroactive RawRepresentable {
    fileprivate static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

extension Optional: @retroactive RawRepresentable where Wrapped == Date {
    public var rawValue: String {
        if let self {
            return Date.formatter.string(from: self)
        } else {
            return ""
        }
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? nil
    }
}

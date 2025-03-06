//
//  AppStorage extensions.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

// Date

nonisolated(unsafe) fileprivate let formatter = ISO8601DateFormatter()

extension Date: @retroactive RawRepresentable {
    public var rawValue: String {
        formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = formatter.date(from: rawValue) ?? Date()
    }
}

extension Optional: @retroactive RawRepresentable where Wrapped == Date {
    public var rawValue: String {
        if let self {
            return formatter.string(from: self)
        } else {
            return ""
        }
    }
    
    public init?(rawValue: String) {
        self = formatter.date(from: rawValue) ?? nil
    }
}

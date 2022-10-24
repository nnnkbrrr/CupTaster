//
//  EvaluationTypes.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import Foundation

enum EvaluationType: Comparable {
    case slider, radio, multiplePicker
    case cups_checkboxes, cups_multiplePicker
    case none
    
    private var sortOrder: Int {
        switch self {
        case .slider: return 0
        case .radio: return 1
        case .multiplePicker: return 2
        case .cups_checkboxes: return 3
        case .cups_multiplePicker: return 4
        case .none: return 5
        }
    }
    
    static func ==(lhs: EvaluationType, rhs: EvaluationType) -> Bool {
        return lhs.sortOrder == rhs.sortOrder
    }
}

extension EvaluationType {
    var stringValue: String {
        switch self {
        case .slider: return "slider"
        case .radio: return "radio"
        case .multiplePicker: return "multiplePicker"
        case .cups_checkboxes: return "cups_checkboxes"
        case .cups_multiplePicker: return "cups_multiplePicker"
            
        case .none: return "none"
        }
    }
}

extension String {
    var unwrappedEvaluationType: EvaluationType {
        switch self {
        case "slider": return .slider
        case "radio": return .radio
        case "multiplePicker": return .multiplePicker
        case "cups_checkboxes": return .cups_checkboxes
        case "cups_multiplePicker": return .cups_multiplePicker
            
        default: return .none
        }
    }
}

//
//  EvaluationTypes.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import Foundation

enum EvaluationType: Comparable {
    case slider, radio, checkboxes, none
    
    private var sortOrder: Int {
        switch self {
            case .slider: return 0
            case .radio: return 1
            case .checkboxes: return 2
            case .none: return 3
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
            case .checkboxes: return "checkboxes"
                
            case .none: return "none"
        }
    }
}

extension String {
    var unwrappedEvaluationType: EvaluationType {
        switch self {
            case "slider": return .slider
            case "radio": return .radio
            case "checkboxes": return .checkboxes
                
            default: return .none
        }
    }
}

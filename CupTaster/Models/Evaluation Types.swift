//
//  EvaluationTypes.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import SwiftUI

public protocol Evaluation {
    var name: String { get }
    var sortOrder: Int { get }
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16) -> CGFloat
}

class SliderEvaluation: Evaluation {
    let name: String = "Slider"
    let sortOrder: Int = 0
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16 = 0) -> CGFloat { return value }
}

class RadioEvaluation: Evaluation {
    let name: String = "Radio"
    let sortOrder: Int = 1
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16 = 0) -> CGFloat { return value }
}

class CupsCheckboxesEvaluation: Evaluation {
    let name: String = "Cups Checkboxes"
    let sortOrder: Int = 2
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16) -> CGFloat { return 10.0 - (10.0 * CGFloat(Int(value).digits.reduce(0, +))) / CGFloat(cupsCount) }
}

class UnsupportedEvaluation: Evaluation {
    let name: String = "Unsupported"
    let sortOrder: Int = Int.max
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16) -> CGFloat { return 0 }
}

extension String {
    var unwrappedEvaluation: Evaluation {
        switch self {
        case "slider": return SliderEvaluation()
        case "radio": return RadioEvaluation()
        case "cups_checkboxes": return CupsCheckboxesEvaluation()
        default: return UnsupportedEvaluation() }
    }
}

//
//  EvaluationTypes.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import SwiftUI

protocol Evaluation {
    var name: String { get }
    var sortOrder: Int { get }
    
    func getEvaluationValue(_ value: CGFloat) -> CGFloat
}

class SliderEvaluation: Evaluation {
    let name: String = "Slider"
    let sortOrder: Int = 0
    
    func getEvaluationValue(_ value: CGFloat) -> CGFloat { return value }
}

class RadioEvaluation: Evaluation {
    let name: String = "Radio"
    let sortOrder: Int = 1
    
    func getEvaluationValue(_ value: CGFloat) -> CGFloat { return value }
}

class MultiplePickerEvaluation: Evaluation {
    let name: String = "Radio"
    let sortOrder: Int = 2
    
    func getEvaluationValue(_ value: CGFloat) -> CGFloat { return value }
}

class CupsCheckboxesEvaluation: Evaluation {
    let name: String = "CupsCheckboxes"
    let sortOrder: Int = 3
    
    func getEvaluationValue(_ value: CGFloat) -> CGFloat { return CGFloat(Int(value).digits.reduce(0, +)) }
}

class CupsMultiplePickerEvaluation: Evaluation {
    let name: String = "CupsMultiplePicker"
    let sortOrder: Int = 4
    
    func getEvaluationValue(_ value: CGFloat) -> CGFloat { return value }
}

extension String {
    var unwrappedEvaluation: Evaluation {
        switch self {
        case "slider": return SliderEvaluation()
        case "radio": return RadioEvaluation()
        case "multiplePicker": return MultiplePickerEvaluation()
        case "cups_checkboxes": return CupsCheckboxesEvaluation()
        case "cups_multiplePicker": return CupsMultiplePickerEvaluation()
        default: return SliderEvaluation() }
    }
}

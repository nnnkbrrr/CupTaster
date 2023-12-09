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
    
    associatedtype EvaluationView: View
    func body(for criteria: QualityCriteria, value: Binding<Double>) -> EvaluationView
}

extension String {
    var unwrappedEvaluation: any Evaluation {
        switch self {
        case "slider": return SliderEvaluation()
        case "radio": return RadioEvaluation()
        case "cups_checkboxes": return CupsCheckboxesEvaluation()
        default: return UnsupportedEvaluation()
        }
    }
}

//
//  SCAEvaluations.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import Foundation

let SCACheckboxes: SampleEvaluation = SampleEvaluation(
    evaluationType: .checkboxes,
    defaultValue: 0
)

let SCALadder: SampleEvaluation = SampleEvaluation(
    evaluationType: .radio,
    defaultValue: 0,
    bounds: 1...5
)

let SCAGradedScale: SampleEvaluation = SampleEvaluation(
    evaluationType: .slider,
    defaultValue: 8.0,
    bounds: 6...9.75,
    step: 0.25
)


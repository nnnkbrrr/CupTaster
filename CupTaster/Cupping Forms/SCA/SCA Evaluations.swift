//
//  SCAEvaluations.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import Foundation

let SCACheckboxes: SampleEvaluation = SampleEvaluation(
    evaluationType: .checkboxes,
    defaultValue: 0,
    bounds: 0...5
)

let SCALadder: SampleEvaluation = SampleEvaluation(
    evaluationType: .radio,
    defaultValue: 0,
    bounds: 0...5
)

let SCAGradedScale: SampleEvaluation = SampleEvaluation(
    evaluationType: .slider,
    defaultValue: 7.5,
    bounds: 6...9.75,
    step: 0.25
)


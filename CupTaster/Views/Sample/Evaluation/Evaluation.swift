//
//  Cupping Forms.swift
//  CupTaster
//
//  Created by Никита on 12.07.2022.
//

import SwiftUI

class SampleEvaluation: SliderConfiguration {
    let evaluationType: String
    let defaultValue: Double
    
    init(
        evaluationType: EvaluationType,
        defaultValue: Double,
        
        bounds: ClosedRange<CGFloat> = 0...0,
        step: Double = 1.0,
        upperBoundTitle: String? = nil,
        lowerBoundTitle: String? = nil
    ) {
        self.evaluationType = evaluationType.stringValue
        self.defaultValue = defaultValue
        
        super.init(bounds: bounds, step: step, spacing: 0.25)
    }
}

//
//  Checkboxes Header View.swift
//  CupTaster
//
//  Created by Никита on 21.08.2022.
//

import SwiftUI

struct CheckboxesEvaluationValueView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        HStack {
            let cuppingCupsCount: Int = Int(qualityCriteria.group.sample.cupping.cupsCount)
            let qcRepresentationValue: String = getCheckboxesRepresentationValue(
                value: qualityCriteria.value,
                cupsCount: cuppingCupsCount
            )
            let fractionValues: [String] = Array(0...cuppingCupsCount).map {
                let value: CGFloat = 10.0 - (10.0 * CGFloat($0)) / CGFloat(cuppingCupsCount)
                switch value.truncatingRemainder(dividingBy: 1) {
                    case 0: return String(format: "%.0f", value)
                    default: return String(format: "%.1f", value)
                }
            }
            
            ForEach(fractionValues, id: \.self) { fractionValue in
                if fractionValue == qcRepresentationValue {
                    Text(fractionValue)
                        .bold()
                        .frame(width: 50)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .contentShape(Rectangle())
    }
}

func getCheckboxesRepresentationValue(value: CGFloat, cupsCount: Int) -> String {
    let value: CGFloat = 10.0 - (10.0 * CGFloat("\(value)".components(separatedBy: "1").count - 1)) / CGFloat(cupsCount)
    switch value.truncatingRemainder(dividingBy: 1) {
        case 0: return String(format: "%.0f", value)
        default: return String(format: "%.1f", value)
    }
}

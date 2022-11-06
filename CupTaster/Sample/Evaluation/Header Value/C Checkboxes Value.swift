//
//  Checkboxes Header View.swift
//  CupTaster
//
//  Created by Никита on 21.08.2022.
//

import SwiftUI

struct CupsCheckboxesEvaluationValueView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        if qualityCriteria.group.configuration.form!.title == "SCA" && qualityCriteria.group.configuration.title == "Defects" {
            SCADeffects_CheckboxesEvaluationValueView(cupsCountQC: qualityCriteria, intensityQC: qualityCriteria.group.qualityCriteria.sorted().last!)
        } else {
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
            
            HStack {
                ForEach(fractionValues, id: \.self) { fractionValue in
                    if fractionValue == qcRepresentationValue {
                        Text(fractionValue)
                            .bold()
                            .frame(width: 55)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .contentShape(Rectangle())
        }
    }
}

extension CupsCheckboxesEvaluationValueView {
    private struct SCADeffects_CheckboxesEvaluationValueView: View {
        @ObservedObject var cupsCountQC: QualityCriteria
        @ObservedObject var intensityQC: QualityCriteria
        
        var body: some View {
            let qcConfiguration: QCConfig = intensityQC.configuration!
            let cupsCount: Int = Int(intensityQC.group.sample.cupping.cupsCount)
            let cupsDigits: [Int] = Array(0...cupsCount)
            let allValues: [CGFloat] = Array(stride(
                from: qcConfiguration.lowerBound,
                through: qcConfiguration.upperBound,
                by: qcConfiguration.step
            )).flatMap { intensityValue in cupsDigits.map { CGFloat($0) * -intensityValue / CGFloat(cupsCount) * 5 }}
            let allUniqueValues: [CGFloat] = Array(Set(allValues))
            
            let selectedCupsCount: Int = Int(cupsCountQC.value).digits.reduce(0, +)
            let calculatedValue: Double = Double(selectedCupsCount) * -intensityQC.value / Double(cupsCount) * 5
            
            HStack {
                ForEach(allUniqueValues, id: \.self) { value in
                    if value == calculatedValue {
                        Text(formatValue(value: value))
                            .bold()
                            .frame(width: 55)
                            .transition(.opacity.combined(with: .scale))
                    }
                }
            }
            .animation(
                .interpolatingSpring(stiffness: 100, damping: 10),
                value: intensityQC.value
            )
            .animation(
                .interpolatingSpring(stiffness: 100, damping: 10),
                value: cupsCountQC.value
            )
            .contentShape(Rectangle())
        }
        
        func formatValue(value: CGFloat) -> String {
            if value == 0 { return "0" }
            switch value.truncatingRemainder(dividingBy: 1) {
                case 0: return String(format: "%.0f", value)
                case 0.5: return String(format: "%.1f", value)
                default: return String(format: "%.2f", value)
            }
        }
    }
}


public func getFilledCheckboxesCount(value: CGFloat) -> Int { Int(value).digits.reduce(0, +) }

fileprivate func getCheckboxesRepresentationValue(value: CGFloat, cupsCount: Int) -> String {
    let value: CGFloat = 10.0 - (10.0 * CGFloat(Int(value).digits.reduce(0, +))) / CGFloat(cupsCount)
    switch value.truncatingRemainder(dividingBy: 1) {
        case 0: return String(format: "%.0f", value)
        default: return String(format: "%.1f", value)
    }
}

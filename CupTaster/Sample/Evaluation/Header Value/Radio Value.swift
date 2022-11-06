//
//  Radio Value.swift
//  CupTaster
//
//  Created by Никита Баранов on 27.10.2022.
//

import SwiftUI

struct RadioEvaluationValueView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        if qualityCriteria.group.configuration.form!.title == "CoE" && qualityCriteria.group.configuration.title == "Defects" {
            COEDeffects_RadioEvaluationValueView(intensityQC: qualityCriteria, cupsCountQC: qualityCriteria.group.qualityCriteria.sorted().last!)
        } else {
            Text("-").bold().frame(width: 55)
        }
    }
}

extension RadioEvaluationValueView {
    private struct COEDeffects_RadioEvaluationValueView: View {
        @ObservedObject var intensityQC: QualityCriteria
        @ObservedObject var cupsCountQC: QualityCriteria
        
        var body: some View {
            let qcConfiguration: QCConfig = intensityQC.configuration!
            let cupsCount: Int = Int(intensityQC.group.sample.cupping.cupsCount)
            let cupsDigits: [Int] = Array(0...cupsCount)
            let allValues: [CGFloat] = Array(stride(
                from: qcConfiguration.lowerBound,
                through: qcConfiguration.upperBound,
                by: qcConfiguration.step
            )).flatMap { intensityValue in cupsDigits.map { intensityValue * CGFloat($0) / CGFloat(cupsCount) * 5 * -4 }}
            let allUniqueValues: [CGFloat] = Array(Set(allValues))
            
            let selectedCupsCount: Int = Int(cupsCountQC.value).digits.reduce(0, +)
            let calculatedValue: Double = intensityQC.value * Double(selectedCupsCount) / Double(cupsCount) * 5 * -4
            
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

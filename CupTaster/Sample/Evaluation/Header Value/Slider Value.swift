//
//  Slider Evaluation Header View.swift
//  CupTaster
//
//  Created by Никита on 24.07.2022.
//

import SwiftUI

struct SliderEvaluationValueView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        let allFractionValues: [CGFloat] = Array(stride(
            from: qualityCriteria.configuration!.lowerBound,
            through: qualityCriteria.configuration!.upperBound,
            by: qualityCriteria.configuration!.step
        )).map { $0 }
        
        HStack {
            ForEach(allFractionValues, id: \.self) { fractionValue in
                if fractionValue == qualityCriteria.value {
                    Text(formatValue(value: qualityCriteria.value))
                        .bold()
                        .frame(width: 55)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .animation(
            .interpolatingSpring(stiffness: 100, damping: 10),
            value: qualityCriteria.value
        )
        .contentShape(Rectangle())
    }
    
    func formatValue(value: CGFloat) -> String {
        switch value.truncatingRemainder(dividingBy: 1) {
            case 0: return String(format: "%.0f", value)
            case 0.5: return String(format: "%.1f", value)
            default: return String(format: "%.2f", value)
        }
    }
}

//
//  Slider Evaluation.swift
//  CupTaster
//
//  Created by Никита Баранов on 27.07.2023.
//

import SwiftUI

class SliderEvaluation: Evaluation {
    let name: String = "Slider"
    let sortOrder: Int = 0
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16 = 0) -> CGFloat { return value }
    
    func body(for criteria: QualityCriteria, value: Binding<Double>) -> some View {
        let config = criteria.configuration
        return SliderView(value: value, lowerBound: config.lowerBound, upperBound: config.upperBound, step: config.step)
    }
}

private struct SliderView: View {
    @Binding var value: Double
    let fractionValues: [Double]
    
    init(value: Binding<Double>, lowerBound: CGFloat, upperBound: CGFloat, step: CGFloat) {
        self._value = value
        self.fractionValues = Array(stride(from: lowerBound, through: upperBound, by: step)).map { $0 }
    }
    
    var body: some View {
        ZStack {
            TargetHorizontalScrollView(
                fractionValues,
                selection: $value,
                elementWidth: BottomSheetConfiguration.Slider.elementWidth,
                height: BottomSheetConfiguration.Slider.height,
                spacing: BottomSheetConfiguration.Slider.spacing
            ) { _ in
                Capsule()
                    .fill(.gray)
                    .frame(width: 1, height: BottomSheetConfiguration.Slider.height - 20)
            }
            
            Capsule()
                .foregroundColor(.accentColor)
                .frame(width: 4, height: BottomSheetConfiguration.Slider.height)
        }
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .contentShape(Rectangle())
    }
}

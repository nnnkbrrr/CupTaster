//
//  Slider Evaluation Header View.swift
//  CupTaster
//
//  Created by Никита on 24.07.2022.
//

import SwiftUI

struct SliderEvaluationHeaderView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        let allFractionValues: [CGFloat] =
        qualityCriteria.configuration?.sliderConfiguration.fractionValues ?? []
        
        HStack {
            ForEach(allFractionValues, id: \.self) { fractionValue in
                if fractionValue == qualityCriteria.value {
                    Text(formatValue(value: qualityCriteria.value))
                        .bold()
                        .frame(width: 50)
                        .transition(.opacity.combined(with: .scale))
                }
            }
            
            Divider()
            Text(qualityCriteria.title)
                .bold()
            Spacer()
            Button {
                withAnimation(.spring()) {
                    qualityCriteria.group.isCompleted.toggle()
                    qualityCriteria.group.objectWillChange.send()
                }
            } label: {
                Image(systemName: qualityCriteria.group.isCompleted ? "pencil" : "checkmark")
            }
        }
        .animation(
            .interpolatingSpring(stiffness: 100, damping: 10),
            value: qualityCriteria.value
        )
    }
    
    func formatValue(value: CGFloat) -> String {
        switch value.truncatingRemainder(dividingBy: 1) {
            case 0: return String(format: "%.0f", value)
            case 0.5: return String(format: "%.1f", value)
            default: return String(format: "%.2f", value)
        }
    }
}

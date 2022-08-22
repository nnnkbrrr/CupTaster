//
//  Checkboxes Header View.swift
//  CupTaster
//
//  Created by Никита on 21.08.2022.
//

import SwiftUI

struct CheckboxesEvaluationHeaderView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        HStack {
            let qcRepresentationValue: String = getCheckboxesRepresentationValue(
                value: qualityCriteria.value,
                cupsCount: Int(qualityCriteria.group.sample.cupping.cupsCount)
            )
            let cuppingCupsCount: Int = Int(qualityCriteria.group.sample.cupping.cupsCount)
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
}

//
//  Radio Evaluation.swift
//  CupTaster
//
//  Created by Никита Баранов on 27.07.2023.
//

import SwiftUI

class RadioEvaluation: Evaluation {
    let name: String = "Radio"
    let sortOrder: Int = 1
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16 = 0) -> CGFloat { return value }
    
    func body(for criteria: QualityCriteria, value: Binding<Double>) -> some View {
        let config = criteria.configuration
        return RadioView(
            value: value,
            lowerBound: config.lowerBound,
            upperBound: config.upperBound,
            lowerBoundTitle: criteria.configuration.lowerBoundTitle,
            upperBoundTitle: criteria.configuration.upperBoundTitle,
            step: config.step
        )
    }
}

private struct RadioView: View {
    @Namespace var namespace
    
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let lowerBoundTitle: String?
    let upperBoundTitle: String?
    let step: CGFloat
    
    var body: some View {
        VStack(spacing: .extraSmall) {
            if lowerBoundTitle != nil || upperBoundTitle != nil {
                HStack {
                    if let lowerBoundTitle { Text(lowerBoundTitle) }
                    Spacer()
                    if let upperBoundTitle { Text(upperBoundTitle) }
                }
                .font(.caption)
                .foregroundStyle(.gray)
            }
            
            HStack {
                let values: [Int] = Array(stride(from: lowerBound, through: upperBound, by: step)).map { Int($0) }
                
                ForEach(values, id: \.self) { value in
                    ZStack {
                        if self.value == Double(value) {
                            Capsule()
                                .foregroundColor(.backgroundSecondary)
                                .transition(.scale)
                                .matchedGeometryEffect(id: "background", in: namespace)
                        }
                        
                        Text("\(value)")
                            .bold()
                            .transition(.scale)
                            .foregroundColor(self.value == Double(value) ? .accentColor : .primary)
                            .frame(width: 40, height: 40)
                    }
                    .contentShape(Rectangle())
                    .frame(maxWidth: .infinity)
                    .onTapGesture { self.value = self.value == Double(value) ? 0 : Double(value) }
                }
            }
        }
        .frame(height: 40)
        .padding(.horizontal, 10)
        .animation(
            .interpolatingSpring(stiffness: 150, damping: 15),
            value: self.value
        )
    }
}

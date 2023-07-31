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
    private let spacing: Double = 25
    
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let step: CGFloat
    
    let fractionValues: [CGFloat]
    let fullSliderWidth: CGFloat
    @State var offset: CGFloat
    @State var tempOffset: CGFloat = 0
    
    init(value: Binding<Double>, lowerBound: CGFloat, upperBound: CGFloat, step: CGFloat) {
        self._value = value
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.step = step
        
        self.fractionValues = Array(stride(from: lowerBound, through: upperBound, by: step)).map { $0 }
        self.fullSliderWidth = self.spacing * CGFloat(fractionValues.count - 1)
        self._offset = State(initialValue: (value.wrappedValue - lowerBound) * self.spacing * (-1.0 / step))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear.frame(height: 55).overlay(alignment: .bottom) {
                HStack(alignment: .top, spacing: 0) {
                    ForEach(fractionValues, id: \.self) { fractionValue in
                        let isCeil: Bool = fractionValue.truncatingRemainder(dividingBy: 1) == 0
                        
                        VStack(spacing: 0) {
                            Capsule()
                                .fill(.gray)
                                .frame(width: isCeil ? 3 : 1, height: 20)
                            
                            if isCeil {
                                Text("\(Int(fractionValue))")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .frame(height: 20)
                            }
                        }
                        .frame(width: spacing)
                    }
                }
                .offset(x: fullSliderWidth / 2)
                .offset(x: offset + tempOffset)
            }
            
            Capsule()
                .foregroundColor(.accentColor)
                .frame(width: 4, height: 35)
        }
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .clear]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let translation = gesture.translation.width
                    let rangeValue1: CGFloat = -(offset + tempOffset) / spacing * step + lowerBound
                    let rangeValue2: CGFloat = -(offset + translation) / spacing * step + lowerBound
                    let currentRange: ClosedRange<CGFloat> = rangeValue1 < rangeValue2 ? rangeValue1...rangeValue2 : rangeValue2...rangeValue1
                    for fractionValue in fractionValues {
                        if currentRange ~= fractionValue && fractionValue != self.value {
                            self.value = fractionValue
                            generateSelectionFeedback()
                        }
                    }
                    self.tempOffset = translation
                }
                .onEnded { gesture in
                    let translation = gesture.translation.width
                    self.offset += translation
                    self.tempOffset = 0
                    withAnimation {
                        if offset > 0 {
                            self.offset = 0
                            self.value = lowerBound
                        } else if offset < -fullSliderWidth {
                            self.offset = -fullSliderWidth
                            self.value = upperBound
                        } else {
                            self.offset = (value - lowerBound) * spacing * (-1.0 / step)
                        }
                    }
                }
        )
    }
    
    private func generateSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

//
//  SliderView.swift
//  CupTaster
//
//  Created by Никита on 15.06.2022.
//

import SwiftUI

struct SliderView: View {
    @AppStorage("slider-spacing") var spacing: Double = 25.0
    
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
        
        let spacing = UserDefaults.standard.object(forKey: "slider-spacing") as? Double ?? 25
        self.fractionValues = Array(stride(from: lowerBound, through: upperBound, by: step)).map { $0 }
        self.fullSliderWidth = spacing * CGFloat(fractionValues.count - 1)
        self._offset = State(initialValue: (value.wrappedValue - lowerBound) * spacing * (-1.0 / step))
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
        .mask(LinearGradient(
            gradient: Gradient(colors: [.clear, .black, .clear]),
            startPoint: .leading,
            endPoint: .trailing
        ))
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
        .onChange(of: spacing) { newSpacing in
            self.offset = (value - lowerBound) * newSpacing * (-1.0 / step) - tempOffset
        }
    }
    
    private func generateSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

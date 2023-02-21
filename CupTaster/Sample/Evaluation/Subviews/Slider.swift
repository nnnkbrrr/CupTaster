//
//  SliderView.swift
//  CupTaster
//
//  Created by Никита on 15.06.2022.
//

import SwiftUI

struct SliderView: View {
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let step: CGFloat
    let spacing: CGFloat
    
    let fractionValues: [CGFloat]
    let fullSliderWidth: CGFloat
    @State var offset: CGFloat
    @State var tempOffset: CGFloat = 0
    
    init(value: Binding<Double>, lowerBound: CGFloat, upperBound: CGFloat, step: CGFloat, spacing: CGFloat) {
        self._value = value
        self.lowerBound = lowerBound
        self.upperBound = upperBound
        self.step = step
        self.spacing = spacing
        
        self.fractionValues = Array(stride(from: lowerBound, through: upperBound, by: step)).map { $0 }
        self.fullSliderWidth = spacing * CGFloat(fractionValues.count - 1)
        self._offset = State(initialValue: (value.wrappedValue - lowerBound) * spacing * (-1.0 / step))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
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
            
            Capsule()
                .foregroundColor(.accentColor)
                .frame(width: 3, height: 30)
        }
        .frame(maxWidth: .infinity)
        .mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .clear]),
                startPoint: .leading,
                endPoint: .trailing)
        )
        .contentShape(Rectangle())
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    let rangeValue1: CGFloat = -(offset + tempOffset) / spacing * step + lowerBound
                    let rangeValue2: CGFloat = -(offset + gesture.translation.width) / spacing * step + lowerBound
                    let currentRange: ClosedRange<CGFloat> = rangeValue1 < rangeValue2 ? rangeValue1...rangeValue2 : rangeValue2...rangeValue1
                    for fractionValue in fractionValues {
                        if currentRange ~= fractionValue {
                            self.value = fractionValue
                            generateSelectionFeedback()
                        }
                    }
                    self.tempOffset = gesture.translation.width
                }
                .onEnded { _ in
                    self.offset += tempOffset
                    self.tempOffset = 0
                    withAnimation {
                        if offset > 0 {
                            self.offset = 0
                        } else if offset < -fullSliderWidth {
                            self.offset = -fullSliderWidth
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

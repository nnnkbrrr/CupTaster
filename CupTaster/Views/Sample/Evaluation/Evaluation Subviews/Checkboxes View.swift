//
//  Checkboxes View.swift
//  CupTaster
//
//  Created by Никита on 19.07.2022.
//

import SwiftUI

struct CheckboxesView: View {
    #warning("Based on cups count")
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let step: CGFloat
    
    var body: some View {
        HStack {
            let checkboxes: [CGFloat] = Array(
                stride(
                    from: lowerBound,
                    through: upperBound,
                    by: step
                )
            )
            
            ForEach(checkboxes.dropFirst(), id: \.self) { checkbox in
                let checkboxIndex: Int = Int(checkbox - 1)
                Button {
                    let power: Double = upperBound - checkbox
                    if checkboxValue(index: checkboxIndex) {
                        value -= pow(10, power)
                    } else {
                        value += pow(10, power)
                    }
                } label: {
                    ZStack {
                        Image(systemName: checkboxValue(index: checkboxIndex) ? "cup.and.saucer" : "cup.and.saucer.fill")
                            .font(.largeTitle.weight(.ultraLight))
                            .foregroundColor(.accentColor)
                            .scaleEffect(checkboxValue(index: checkboxIndex) ? 0.8 : 1)
                            .opacity(checkboxValue(index: checkboxIndex) ? 0.5 : 1)
                        
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .rotationEffect(checkboxValue(index: checkboxIndex) ? Angle(degrees: 0) : Angle(degrees: 90))
                            .opacity(checkboxValue(index: checkboxIndex) ? 1 : 0)
                            .scaleEffect(checkboxValue(index: checkboxIndex) ? 1 : 0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .padding(.vertical, 5)
                    .animation(
                        .interpolatingSpring(stiffness: 100, damping: 10),
                        value: value
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    func checkboxValue(index: Int) -> Bool {
        let stringValue: String = String(Int(value))
        let fullBinaryString: String = String(repeating: "0", count: Int(upperBound) - stringValue.count) + stringValue
        let values: [Bool] = fullBinaryString.map { $0 == "1" }
        
        return values[index]
    }
}

//
//  MultiplePicker.swift
//  CupTaster
//
//  Created by Никита Баранов on 24.10.2022.
//

import SwiftUI

struct MultiplePickerView: View {
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let step: CGFloat
    
    var body: some View {
        HStack {
            ForEach(Array(allPickerValues.enumerated()), id: \.offset) { offset, pickerValue in
                Menu {
                    ForEach(validPickerValues, id: \.self) { validValue in
                        Button {
                            if lowerBoundIsNegative {
                                value += Double(validValue - pickerValue + abs(lowerBoundDigit)) * pow(10.0, Double(offset))
                            } else {
                                value += Double(validValue - pickerValue) * pow(10.0, Double(offset))
                            }
                        } label: {
                            Text("\(validValue)")
                        }
                    }
                } label: {
                    Text("\(pickerValue + (lowerBoundIsNegative ? lowerBoundDigit : 0))")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(10)
                }
            }
        }
    }
}

extension MultiplePickerView {
    var allPickerValues: [Int] {
        let values: [Int] = Int(value).digits
        let pickersCount: Int = Int(upperBound).digits.count
        switch values.count {
        case let count where count < pickersCount: return (Array(repeating: 0, count: (pickersCount - values.count)) + values).reversed()
        default: return values.reversed()
        }
    }
    
    var validPickerValues: [Int] {
        let lowerDigitValue: CGFloat = copysign(CGFloat(Int(lowerBound).digits.first!), lowerBound)
        let upperDigitValue: CGFloat = copysign(CGFloat(Int(upperBound).digits.first!), upperBound)
        return Array(stride(from: lowerDigitValue, through: upperDigitValue, by: step)).map { Int($0) }
    }
    
    var lowerBoundDigit: Int { validPickerValues.first! }
    
    var lowerBoundIsNegative: Bool { lowerBound.sign == .minus }
}

//
//  C MultiplePicker.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.10.2022.
//

import SwiftUI

struct CupsMultiplePickerView: View {
    @Binding var value: Double
    let lowerBound: CGFloat
    let upperBound: CGFloat
    let step: CGFloat
    
    let cuppingCupsCount: Int
    
    var body: some View {
        HStack {
            ForEach(
                Array(getAllMultiplePickerShiftedValues(value: value, cuppingCupsCount: cuppingCupsCount).enumerated()),
                id: \.offset
            ) { offset, pickerValue in
                Menu {
                    ForEach(validPickerValues, id: \.self) { validValue in
                        Button {
                            if lowerBoundIsNegative {
                                value += Double(validValue - pickerValue + abs(Int(lowerBound))) * pow(10.0, Double(offset))
                            } else {
                                value += Double(validValue - pickerValue) * pow(10.0, Double(offset))
                            }
                        } label: {
                            Text("\(validValue)")
                        }
                    }
                } label: {
                    Text("\(pickerValue + (lowerBoundIsNegative ? Int(lowerBound) : 0))")
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.gray.opacity(0.25))
                        .cornerRadius(10)
                }
            }
        }
    }
}

extension CupsMultiplePickerView {
    var validPickerValues: [Int] {
        return Array(stride(from: lowerBound, through: upperBound, by: step)).map { Int($0) }
    }
    
    var lowerBoundIsNegative: Bool { lowerBound.sign == .minus }
}



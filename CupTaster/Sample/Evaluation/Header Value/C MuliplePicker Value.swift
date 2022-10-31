//
//  C MuliplePicker Value.swift
//  CupTaster
//
//  Created by Никита Баранов on 31.10.2022.
//

import SwiftUI

struct CupsMultiplePickerValueView: View {
    @ObservedObject var qualityCriteria: QualityCriteria
    
    var body: some View {
        HStack {
            let cuppingCupsCount: Int = Int(qualityCriteria.group.sample.cupping.cupsCount)
            let lowerBound: CGFloat = qualityCriteria.configuration!.lowerBound
            
            let qcRepresentationValue: String = formatValue(value: getMultiplePickerValue(
                value: qualityCriteria.value,
                cuppingCupsCount: cuppingCupsCount,
                lowerBound: lowerBound
            ))
            
            let qcConfiguration: QCConfig = qualityCriteria.configuration!
            let fractionValues: [String] = Array(stride(
                from: qcConfiguration.lowerBound * 5,
                through: qcConfiguration.upperBound * 5,
                by: 5 / Double(cuppingCupsCount)
            )).map { formatValue(value: $0) }

            ForEach(fractionValues, id: \.self) { fractionValue in
                if fractionValue == qcRepresentationValue {
                    Text(fractionValue)
                        .bold()
                        .frame(width: 50)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .contentShape(Rectangle())
    }
    
    func formatValue(value: CGFloat) -> String {
        var formattedValue: String = String(format: "%.2f", value)
        while formattedValue.count > 1 && (formattedValue.last == "0" && formattedValue.contains(".") || formattedValue.last == ".") {
            formattedValue.removeLast()
        }
        return formattedValue
    }
}

public func getMultiplePickerValue(value: CGFloat, cuppingCupsCount: Int, lowerBound: CGFloat) -> CGFloat {
    let allValues: [Int] = getAllMultiplePickerValues(value: value, cuppingCupsCount: cuppingCupsCount, lowerBound: lowerBound)
    return CGFloat(allValues.reduce(0, +)) / CGFloat(cuppingCupsCount) * 5
}

public func getAllMultiplePickerShiftedValues(value: CGFloat, cuppingCupsCount: Int) -> [Int] {
    let values: [Int] = Int(value).digits
    switch values.count {
    case let count where count < cuppingCupsCount: return (Array(repeating: 0, count: (cuppingCupsCount - values.count)) + values).reversed()
    default: return Array(values.reversed().prefix(cuppingCupsCount))
    }
}

public func getAllMultiplePickerValues(value: CGFloat, cuppingCupsCount: Int, lowerBound: CGFloat) -> [Int] {
    if lowerBound.sign == .minus {
        return getAllMultiplePickerShiftedValues(value: value, cuppingCupsCount: cuppingCupsCount).map { $0 + Int(lowerBound) }
    } else {
        return getAllMultiplePickerShiftedValues(value: value, cuppingCupsCount: cuppingCupsCount)
    }
}

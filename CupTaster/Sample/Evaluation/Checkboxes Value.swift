//
//  Checkboxes Value.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

func getCheckboxesRepresentationValue(value: CGFloat, cupsCount: Int) -> String {
    let value: CGFloat = 10.0 - (10.0 * CGFloat("\(value)".components(separatedBy: "1").count - 1)) / CGFloat(cupsCount)
    switch value.truncatingRemainder(dividingBy: 1) {
        case 0: return String(format: "%.0f", value)
        default: return String(format: "%.1f", value)
    }
}

//
//  Cups Checkboxes.swift
//  CupTaster
//
//  Created by Никита Баранов on 27.07.2023.
//

import SwiftUI

class CupsCheckboxesEvaluation: Evaluation {
    let name: String = "Cups Checkboxes"
    let sortOrder: Int = 2
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16) -> CGFloat { return CGFloat(Int(value).digits.reduce(0, +)) }
    
    func body(for criteria: QualityCriteria, value: Binding<Double>) -> some View {
        return CupsCheckboxesView(value: value, cuppingCupsCount: criteria.group.sample.cupping.cupsCount)
    }
}

private struct CupsCheckboxesView: View {
    @Binding var value: Double
    let cuppingCupsCount: Int
    
    init(value: Binding<Double>, cuppingCupsCount: Int16) {
        self._value = value
        self.cuppingCupsCount = Int(cuppingCupsCount)
    }
    
    var body: some View {
        HStack {
            let checkboxes: [Int] = Array(1...cuppingCupsCount)
            
            ForEach(checkboxes, id: \.self) { checkbox in
                let checkboxIndex: Int = Int(checkbox - 1)
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
                .onTapGesture {
                    let power: Double = Double(cuppingCupsCount - checkbox)
                    value += pow(10, power) * (checkboxValue(index: checkboxIndex) ? -1 : 1)
                }
            }
        }
    }
    
    func checkboxValue(index: Int) -> Bool {
        let stringValue: String = String(Int(value))
        let fullBinaryString: String = String(repeating: "0", count: cuppingCupsCount - stringValue.count) + stringValue
        let values: [Bool] = fullBinaryString.map { $0 == "1" }
        
        return values[index]
    }
}

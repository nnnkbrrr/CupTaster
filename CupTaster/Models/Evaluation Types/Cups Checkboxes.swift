//
//  Cups Checkboxes.swift
//  CupTaster
//
//  Created by Никита Баранов on 27.07.2023.
//

import SwiftUI

class CupsCheckboxesEvaluation: @preconcurrency Evaluation {
    let name: String = "Cups Checkboxes"
    let sortOrder: Int = 2
    
    func getEvaluationValue(_ value: CGFloat, cupsCount: Int16) -> CGFloat { return CGFloat(Int(value).digits.reduce(0, +)) }
    
    @MainActor func body(for criteria: QualityCriteria, value: Binding<Double>) -> some View {
        return CupsCheckboxesView(
            value: value,
            lowerBoundTitle: criteria.configuration.lowerBoundTitle,
            upperBoundTitle: criteria.configuration.upperBoundTitle,
            cupsCount: criteria.group.sample.cupping.cupsCount
        )
    }
    
    // Additional
    
    static func checkboxesValues(criteria: QualityCriteria) -> [Bool] {
        return (0..<Int(criteria.group.sample.cupping.cupsCount)).map {
            (UInt8(String(Int(criteria.value)), radix: 2) ?? 0) & (1 << $0) != 0
        }.reversed()
    }
    
    static func checkboxesValues(value: Double, cupsCount: Int16) -> [Bool] {
        return (0..<Int(cupsCount)).map {
            (UInt8(String(Int(value)), radix: 2) ?? 0) & (1 << $0) != 0
        }.reversed()
    }
}

private struct CupsCheckboxesView: View {
    @Binding var value: Double
    let cupsCount: Int
    let lowerBoundTitle: String?
    let upperBoundTitle: String?
    
    init(value: Binding<Double>, lowerBoundTitle: String?, upperBoundTitle: String?, cupsCount: Int16) {
        self._value = value
        self.cupsCount = Int(cupsCount)
        
        self.lowerBoundTitle = lowerBoundTitle
        self.upperBoundTitle = upperBoundTitle
    }
    
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
            
            HStack(spacing: .extraSmall) {
                let checkboxes: [Int] = Array(1...cupsCount)
                let values: [Bool] = CupsCheckboxesEvaluation.checkboxesValues(value: self.value, cupsCount: Int16(cupsCount))
                
                ForEach(checkboxes, id: \.self) { checkbox in
                    let isActive: Bool = values[checkbox - 1]
                    
                    ZStack {
                        Image(isActive ? "cup" : "cup.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 35, height: 35)
                            .foregroundColor(.accentColor)
                            .scaleEffect(isActive ? 0.8 : 1)
                            .opacity(isActive ? 0.5 : 1)
                        
                        Image(systemName: "xmark")
                            .font(.largeTitle)
                            .foregroundColor(.accentColor)
                            .rotationEffect(isActive ? Angle(degrees: 0) : Angle(degrees: 90))
                            .opacity(isActive ? 1 : 0)
                            .scaleEffect(isActive ? 1 : 0.5)
                    }
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .animation(.interpolatingSpring(stiffness: 100, damping: 10), value: value)
                    .onTapGesture {
                        let power: Double = Double(cupsCount - checkbox)
                        value += pow(10, power) * (isActive ? -1 : 1)
                    }
                }
            }
        }
        .padding(.vertical, .small)
    }
}

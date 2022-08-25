//
//  Sample Footer.swift
//  CupTaster
//
//  Created by Никита on 22.08.2022.
//

import SwiftUI

struct SampleFooterView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    @State private var finalScore: Double? = nil
    private let iconsSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 0) {
            Button {
                sample.isFavorite.toggle()
                sample.cupping.objectWillChange.send()
                try? moc.save()
            } label: {
                Image(systemName: sample.isFavorite ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconsSize, height: iconsSize)
                    .foregroundColor(sample.isFavorite ? .red : .gray)
                    .padding(10)
                    .contentShape(Rectangle())
            }
            
            Spacer()
            
            Text("Final score: ")
            if let finalScore = finalScore {
                Text(String(format: "%.1f", finalScore))
                    .bold()
                Button {
                    self.finalScore = getScore()
                    for qcGroup in sample.qualityCriteriaGroups { qcGroup.isCompleted = true }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 44, height: 44)
                }
            } else {
                Button("calculate") {
                    self.finalScore = getScore()
                    for qcGroup in sample.qualityCriteriaGroups { qcGroup.isCompleted = true }
                }
            }
            
            Spacer()
            
            Button {
                moc.delete(sample)
                try? moc.save()
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: iconsSize, height: iconsSize)
                    .padding(10)
                    .contentShape(Rectangle())
            }
        }
        .padding()
        .frame(height: 44)
        .background(Blur(style: .systemUltraThinMaterial))
    }

    func getValues() -> [String: Double] {
        let criteria: [QualityCriteria] = sample.qualityCriteriaGroups.map { qcGroup in
            qcGroup.qualityCriteria
        }.flatMap { criteria in criteria }

        let cuppingCupsCount: Int = Int(sample.cupping.cupsCount)
        return Dictionary(uniqueKeysWithValues: criteria.map {(
            $0.group.configuration.title.filter { $0.isLetter }
            + "_" +  $0.title.filter { $0.isLetter },

            $0.configuration!.evaluationType == EvaluationType.checkboxes.stringValue ?
            Double(getCheckboxesRepresentationValue(value: $0.value, cupsCount: cuppingCupsCount))! : $0.value
        )})
    }


    func getScore() -> Double {
#warning("force unwrapping form")
        let formula: String = sample.cupping.form!.finalScoreFormula
        let expression = NSExpression(format: formula)
        let values = getValues()
        let expressionValue = expression.expressionValue(with: values, context: nil)
        return expressionValue as? Double ?? 0
    }
}

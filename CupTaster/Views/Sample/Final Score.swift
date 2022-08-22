////
////  EvaluationResult.swift
////  CupTaster
////
////  Created by Никита on 22.08.2022.
////
//
//import SwiftUI
//
//struct FinalScoreView: View {
//    @ObservedObject var sample: Sample
//
//    var body: some View {
//        HStack {
//            let finalScore: Double = (try? getScore()) ?? -1
//            Text("Final score: \(finalScore)")
//            Spacer()
//        }
//        .padding()
//        .background(.bar)
//    }
//
//    func getValues(forCriteria affectingCriteria: [String]) -> [String: Double] {
//        let criteria: [QualityCriteria] = sample.qualityCriteriaGroups.map { qcGroup in
//            qcGroup.qualityCriteria
//        }.flatMap { criteria in
//            criteria
//        }
//
//        let cuppingCupsCount: Int = Int(sample.cupping.cupsCount)
//#warning("force unwrapping configuration")
//        return Dictionary(uniqueKeysWithValues: criteria.map {(
//            affectingCriteria.contains($0.title) ? $0.title.replacingOccurrences(of: " ", with: "_") : UUID().uuidString,
//
//            $0.configuration!.evaluationType == EvaluationType.checkboxes.stringValue ?
//            Double(getCheckboxesRepresentationValue(value: $0.value, cupsCount: cuppingCupsCount))! : $0.value
//        )})
//    }
//
//    func getScore() throws -> Double {
//#warning("force unwrapping form")
//        let formula: String = sample.cupping.form!.finalScoreFormula
//        let expression = NSExpression(format: formula)
//        print(expression)
//
//        let expValues = formula.components(separatedBy: ["+", "-", "*", "/", " ", "(", ")"])
//        print(expValues)
//
//        let criteria: [QualityCriteria] = sample.qualityCriteriaGroups.map { QCGroup in
//            QCGroup.qualityCriteria
//        }.flatMap { criteria in
//            criteria
//        }
//
////        print(criteria.map{ $0.title })
//        let values = getValues(forCriteria: expValues)
//        print(values)
//        let expressionValue = expression.expressionValue(with: values, context: nil)
//        return expressionValue as? Double ?? 0
//    }
//}

//
//  Core Data Extensions.swift
//  CupTaster
//
//  Created by Никита on 16.07.2022.
//

import SwiftUI
import CoreData

#warning("все сущности выделить отдельными файлами и добавить расширения в них")

extension Cupping {
    public func getSortedSamples() -> [Sample] {
        return self.samples
            .sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
    }
}

extension Sample {
    public var isCompleted: Bool {
        return !self.qualityCriteriaGroups.contains(where: { $0.isCompleted == false } )
    }
    
    private func getValues() -> [String: Double] {
        let criteria: [QualityCriteria] = self.qualityCriteriaGroups.map { qcGroup in
            qcGroup.qualityCriteria
        }.flatMap { criteria in criteria }

        let cuppingCupsCount: Int = Int(self.cupping.cupsCount)
        return Dictionary(uniqueKeysWithValues: criteria.map {(
            $0.group.configuration.title.filter { $0.isLetter }
            + "_" +  $0.title.filter { $0.isLetter },

            $0.configuration!.evaluationType == EvaluationType.checkboxes.stringValue ?
            Double(getCheckboxesRepresentationValue(value: $0.value, cupsCount: cuppingCupsCount))! : $0.value
        )})
    }
    
    public func calculateFinalScore() {
        if let formula: String = self.cupping.form?.finalScoreFormula {
            let expression = NSExpression(format: formula)
            let values = getValues()
            let expressionValue = expression.expressionValue(with: values, context: nil)
            self.finalScore = expressionValue as? Double ?? 0
            self.cupping.objectWillChange.send()
        }
    }
}

extension CuppingForm {
    var isDeprecated: Bool {
        return !CFManager().allCFModels.contains { cfModel in
            self.title == cfModel.title && self.version == cfModel.version
        }
    }
    
    func isSelected(defaultCF_hashedID: Int) -> Bool {
        return self.id.hashValue == defaultCF_hashedID
    }
}

extension QualityCriteria: Comparable {
    public static func < (lhs: QualityCriteria, rhs: QualityCriteria) -> Bool {
        if let lhsConfiguration = lhs.configuration, let rhsConfiguration = rhs.configuration {
            return lhsConfiguration.ordinalNumber < rhsConfiguration.ordinalNumber
        } else {
            return lhs.title < rhs.title
        }
    }
}

extension QCConfig {
    var sliderConfiguration: SliderConfiguration {
        return SliderConfiguration(bounds: lowerBound...upperBound, step: step, spacing: 25)
    }
}

extension QCConfig {
    static func new(
        context: NSManagedObjectContext,
        title: String,
        evaluationType: EvaluationType,
        ordinalNumber: Int,
        bounds: Range<Double>,
        step: Double,
        value: Double,
        upperBoundTitle: String? = nil,
        lowerBoundTitle: String? = nil
    ) -> QCConfig {
        let criteria: QCConfig = QCConfig(context: context)
        criteria.title = title
        criteria.evaluationType = evaluationType.stringValue
        criteria.ordinalNumber = Int16(ordinalNumber)
        criteria.lowerBound = bounds.lowerBound
        criteria.upperBound = bounds.upperBound
        criteria.step = step
        criteria.value = value
        criteria.upperBoundTitle = upperBoundTitle
        criteria.lowerBoundTitle = lowerBoundTitle

        return criteria
    }
}

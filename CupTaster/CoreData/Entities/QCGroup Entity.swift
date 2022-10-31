//
//  QCGroup Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

@objc(QCGroup)
public class QCGroup: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCGroup> {
        return NSFetchRequest<QCGroup>(entityName: "QCGroup")
    }

    @NSManaged public var notes: String
    @NSManaged public var isCompleted: Bool
    
    @NSManaged public var configuration: QCGroupConfig
    @NSManaged public var qualityCriteria: Set<QualityCriteria>
    @NSManaged public var sample: Sample
}

extension Sample {
    public var isCompleted: Bool {
        return !self.qualityCriteriaGroups.contains(where: { $0.isCompleted == false } )
    }
    
    private func getValues() -> [String: Double] {
        let criteria: [QualityCriteria] = self.qualityCriteriaGroups.map { qcGroup in
            qcGroup.qualityCriteria
        }.flatMap { criteria in criteria }
        
        func getDictionaryValue(criteria: QualityCriteria) -> Double {
            switch criteria.configuration!.evaluationType.unwrappedEvaluationType {
            case .cups_checkboxes: return Double(getFilledCheckboxesCount(value: criteria.value))
            case .cups_multiplePicker: return Double(getMultiplePickerValue(value: criteria.value, cuppingCupsCount: Int(criteria.group.sample.cupping.cupsCount), lowerBound: criteria.configuration!.lowerBound))
            default: return criteria.value
            }
        }

        var dictionary: [String: Double] = Dictionary(uniqueKeysWithValues: criteria.map {(
            $0.group.configuration.title.filter { $0.isLetter || $0.isNumber }
            + "_" +  $0.title.filter { $0.isLetter || $0.isNumber },
            
            getDictionaryValue(criteria: $0)
        )})
        
        dictionary.updateValue(Double(self.cupping.cupsCount), forKey: "CupsCount")
        return dictionary
    }
    
    public func calculateFinalScore() {
        if let formula: String = self.cupping.form?.finalScoreFormula {
            let expression = NSExpression(format: formula)
            let values = getValues()
            let expressionValue = expression.expressionValue(with: values, context: nil)
            self.finalScore = expressionValue as? Double ?? 0
        }
    }
}

extension QCGroup {
    @objc(addQualityCriteriaObject:)
    @NSManaged public func addToQualityCriteria(_ value: QualityCriteria)

    @objc(removeQualityCriteriaObject:)
    @NSManaged public func removeFromQualityCriteria(_ value: QualityCriteria)

    @objc(addQualityCriteria:)
    @NSManaged public func addToQualityCriteria(_ values: NSSet)

    @objc(removeQualityCriteria:)
    @NSManaged public func removeFromQualityCriteria(_ values: NSSet)
}

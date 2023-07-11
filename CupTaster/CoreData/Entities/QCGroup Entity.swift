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
        #warning("map - flatmap    -->      flatmap ??")
        let criteria: [QualityCriteria] = self.qualityCriteriaGroups.flatMap({ $0.qualityCriteria })
        
        var dictionary: [String: Double] = Dictionary(uniqueKeysWithValues: criteria.map { criteria in
            (
                "qcc_\(criteria.group.configuration.ordinalNumber)_\(criteria.configuration!.ordinalNumber)",
                Double(criteria.configuration!.evaluationType.unwrappedEvaluation.getEvaluationValue(criteria.value))
            )
        })
        
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

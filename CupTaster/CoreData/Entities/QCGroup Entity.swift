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


extension QCGroup {
    public var sortedQualityCriteria: [QualityCriteria] {
        self.qualityCriteria.sorted()
    }
    
    var values: [String: Double] {
        let criteria: [QualityCriteria] = self.sortedQualityCriteria
        
        var dictionary: [String: Double] = Dictionary(uniqueKeysWithValues: criteria.map { criteria in
            ("criteria_\(criteria.configuration.ordinalNumber)", Double(criteria.formattedValue))
        })
        
        dictionary.updateValue(Double(self.sample.cupping.cupsCount), forKey: "cups_count")
        return dictionary
    }
    
    var score: Double {
        let formula: String = self.configuration.scoreFormula
        let expression = NSExpression(format: formula)
        let values = values
        let expressionValue = expression.expressionValue(with: values, context: nil)
        return expressionValue as? Double ?? 0
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

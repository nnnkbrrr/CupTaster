//
//  Sample Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//,

import CoreData

@objc(Sample)
public class Sample: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sample> {
        return NSFetchRequest<Sample>(entityName: "Sample")
    }
    
    @NSManaged public var name: String
    @NSManaged public var ordinalNumber: Int16
    @NSManaged public var isFavorite: Bool
    @NSManaged public var finalScore: Double
    
    @NSManaged public var cupping: Cupping
    @NSManaged public var generalInfo: Set<SampleGeneralInfo>
    @NSManaged public var qualityCriteriaGroups: Set<QCGroup>
    @NSManaged public var folders: Set<Folder>
}

extension Sample {
    public var sortedQCGroups: [QCGroup] {
        self.qualityCriteriaGroups.sorted { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber }
    }
}

// Calculate Final Score
extension Sample {
    public var isCompleted: Bool {
        return !self.qualityCriteriaGroups.contains(where: { $0.isCompleted == false } )
    }
    
    private func getValues() -> [String: Double] {
        let criteria: [QualityCriteria] = self.qualityCriteriaGroups.flatMap { $0.qualityCriteria }
        
        var dictionary: [String: Double] = Dictionary(uniqueKeysWithValues: criteria.map { criteria in
            ("criteria_\(criteria.group.configuration.ordinalNumber)_\(criteria.configuration.ordinalNumber)", Double(criteria.formattedValue))
        })
        
        dictionary.updateValue(Double(self.cupping.cupsCount), forKey: "cups_count")
        return dictionary
    }
    
    public func calculateFinalScore() {
        if let formula: String = self.cupping.form?.finalScoreFormula {
            let expression: NSExpression = NSExpression(format: formula)
            let values: [String : Double] = getValues()
            self.finalScore = expression.expressionValue(with: values, context: nil) as? Double ?? 0
        }
    }
}

extension Sample {
    @objc(addGeneralInfoObject:)
    @NSManaged public func addToGeneralInfo(_ value: SampleGeneralInfo)

    @objc(removeGeneralInfoObject:)
    @NSManaged public func removeFromGeneralInfo(_ value: SampleGeneralInfo)

    @objc(addGeneralInfo:)
    @NSManaged public func addToGeneralInfo(_ values: NSSet)

    @objc(removeGeneralInfo:)
    @NSManaged public func removeFromGeneralInfo(_ values: NSSet)

    @objc(addQualityCriteriaGroupsObject:)
    @NSManaged public func addToQualityCriteriaGroups(_ value: QCGroup)

    @objc(removeQualityCriteriaGroupsObject:)
    @NSManaged public func removeFromQualityCriteriaGroups(_ value: QCGroup)

    @objc(addQualityCriteriaGroups:)
    @NSManaged public func addToQualityCriteriaGroups(_ values: NSSet)

    @objc(removeQualityCriteriaGroups:)
    @NSManaged public func removeFromQualityCriteriaGroups(_ values: NSSet)
}

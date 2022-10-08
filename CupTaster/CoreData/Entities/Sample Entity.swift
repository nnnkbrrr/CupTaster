//
//  Sample Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

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

//
//  Generated Accessors.swift
//  CupTaster
//
//  Created by Никита on 13.07.2022.
//

import CoreData

extension Cupping {
    @objc(addSamplesObject:)
    @NSManaged public func addToSamples(_ value: Sample)

    @objc(removeSamplesObject:)
    @NSManaged public func removeFromSamples(_ value: Sample)

    @objc(addSamples:)
    @NSManaged public func addToSamples(_ values: NSSet)

    @objc(removeSamples:)
    @NSManaged public func removeFromSamples(_ values: NSSet)
}

extension QCGroupConfig {
    @objc(addGroupObject:)
    @NSManaged public func addToGroup(_ value: QCGroup)

    @objc(removeGroupObject:)
    @NSManaged public func removeFromGroup(_ value: QCGroup)

    @objc(addGroup:)
    @NSManaged public func addToGroup(_ values: NSSet)

    @objc(removeGroup:)
    @NSManaged public func removeFromGroup(_ values: NSSet)

    @objc(addQcConfigurationsObject:)
    @NSManaged public func addToQcConfigurations(_ value: QCConfig)

    @objc(removeQcConfigurationsObject:)
    @NSManaged public func removeFromQcConfigurations(_ value: QCConfig)

    @objc(addQcConfigurations:)
    @NSManaged public func addToQcConfigurations(_ values: NSSet)

    @objc(removeQcConfigurations:)
    @NSManaged public func removeFromQcConfigurations(_ values: NSSet)
}

extension CuppingForm {

    @objc(addCuppingsObject:)
    @NSManaged public func addToCuppings(_ value: Cupping)

    @objc(removeCuppingsObject:)
    @NSManaged public func removeFromCuppings(_ value: Cupping)

    @objc(addCuppings:)
    @NSManaged public func addToCuppings(_ values: NSSet)

    @objc(removeCuppings:)
    @NSManaged public func removeFromCuppings(_ values: NSSet)

    @objc(addQcGroupConfigurationsObject:)
    @NSManaged public func addToQcGroupConfigurations(_ value: QCGroupConfig)

    @objc(removeQcGroupConfigurationsObject:)
    @NSManaged public func removeFromQcGroupConfigurations(_ value: QCGroupConfig)

    @objc(addQcGroupConfigurations:)
    @NSManaged public func addToQcGroupConfigurations(_ values: NSSet)

    @objc(removeQcGroupConfigurations:)
    @NSManaged public func removeFromQcGroupConfigurations(_ values: NSSet)
}

extension QCConfig {
    @objc(addHintsObject:)
    @NSManaged public func addToHints(_ value: QCHint)

    @objc(removeHintsObject:)
    @NSManaged public func removeFromHints(_ value: QCHint)

    @objc(addHints:)
    @NSManaged public func addToHints(_ values: NSSet)

    @objc(removeHints:)
    @NSManaged public func removeFromHints(_ values: NSSet)
    
    @objc(addQualityCriteriaObject:)
    @NSManaged public func addToQualityCriteria(_ value: QualityCriteria)

    @objc(removeQualityCriteriaObject:)
    @NSManaged public func removeFromQualityCriteria(_ value: QualityCriteria)

    @objc(addQualityCriteria:)
    @NSManaged public func addToQualityCriteria(_ values: NSSet)

    @objc(removeQualityCriteria:)
    @NSManaged public func removeFromQualityCriteria(_ values: NSSet)
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

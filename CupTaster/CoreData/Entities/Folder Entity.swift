//
//  Folder Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 05.07.2023.
//

import Foundation
import CoreData

@objc(Folder)
public class Folder: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Folder> {
        return NSFetchRequest<Folder>(entityName: "Folder")
    }

    @NSManaged public var name: String
    @NSManaged public var ordinalNumber: Int16
    
    @NSManaged public var cuppings: Set<Cupping>
    @NSManaged public var samples: Set<Sample>
}

// MARK: Generated accessors for cuppings

extension Folder {
    @objc(addCuppingsObject:)
    @NSManaged public func addToCuppings(_ value: Cupping)

    @objc(removeCuppingsObject:)
    @NSManaged public func removeFromCuppings(_ value: Cupping)

    @objc(addCuppings:)
    @NSManaged public func addToCuppings(_ values: NSSet)

    @objc(removeCuppings:)
    @NSManaged public func removeFromCuppings(_ values: NSSet)
    
    @objc(addSamplesObject:)
    @NSManaged public func addToSamples(_ value: Sample)

    @objc(removeSamplesObject:)
    @NSManaged public func removeFromSamples(_ value: Sample)

    @objc(addSamples:)
    @NSManaged public func addToSamples(_ values: NSSet)

    @objc(removeSamples:)
    @NSManaged public func removeFromSamples(_ values: NSSet)
}

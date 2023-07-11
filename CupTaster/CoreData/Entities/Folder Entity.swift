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
    @NSManaged public var lastModifiedDate: Date?
    
    @NSManaged public var samples: Set<Sample>
}

extension Folder {
    @objc(addSamplesObject:)
    @NSManaged public func addToSamples(_ value: Sample)

    @objc(removeSamplesObject:)
    @NSManaged public func removeFromSamples(_ value: Sample)

    @objc(addSamples:)
    @NSManaged public func addToSamples(_ values: NSSet)

    @objc(removeSamples:)
    @NSManaged public func removeFromSamples(_ values: NSSet)
}

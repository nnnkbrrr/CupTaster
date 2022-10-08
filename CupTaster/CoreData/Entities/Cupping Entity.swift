//
//  Cupping.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

@objc(Cupping)
public class Cupping: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cupping> {
        return NSFetchRequest<Cupping>(entityName: "Cupping")
    }
    
    @NSManaged public var name: String
    @NSManaged public var notes: String
    @NSManaged public var date: Date
    @NSManaged public var cupsCount: Int16
    
    @NSManaged public var form: CuppingForm?
    @NSManaged public var samples: Set<Sample>
}

extension Cupping {
    public func getSortedSamples() -> [Sample] {
        return self.samples
            .sorted(by: { $0.ordinalNumber < $1.ordinalNumber })
    }
}

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

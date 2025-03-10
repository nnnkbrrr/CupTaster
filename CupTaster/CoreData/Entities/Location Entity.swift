//
//  Location Entity.swift
//  CupTaster
//
//  Created by Nikita on 15.02.2024.
//

import Foundation
import CoreData
import CoreLocation

@objc(Location)
public class Location: NSManagedObject, Identifiable {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var address: String
    @NSManaged public var horizontalAccuracy: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
    @NSManaged public var cuppings: Set<Cupping>
}

extension Location {
    var coordinates: CLLocation {
        .init(latitude: latitude, longitude: longitude)
    }
    
    func reinit(_ location: Location) {
        (self.address, self.horizontalAccuracy, self.latitude, self.longitude) =
        (location.address, location.horizontalAccuracy, location.latitude, location.longitude)
    }
}

extension Location {
    @objc(addCuppingsObject:)
    @NSManaged public func addToCuppings(_ value: Cupping)

    @objc(removeCuppingsObject:)
    @NSManaged public func removeFromCuppings(_ value: Cupping)

    @objc(addCuppings:)
    @NSManaged public func addToCuppings(_ values: NSSet)

    @objc(removeCuppings:)
    @NSManaged public func removeFromCuppings(_ values: NSSet)
}

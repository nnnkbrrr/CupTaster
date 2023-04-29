//
//  SampleGeneralInfo Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import SwiftUI
import CoreData

@objc(SampleGeneralInfo)
public class SampleGeneralInfo: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SampleGeneralInfo> {
        return NSFetchRequest<SampleGeneralInfo>(entityName: "SampleGeneralInfo")
    }
    
    @NSManaged public var title: String
    @NSManaged public var ordinalNumber: Int16
	@NSManaged public var value: String
	@NSManaged public var attachment: Data
	
	@NSManaged public var sample: Sample?
}

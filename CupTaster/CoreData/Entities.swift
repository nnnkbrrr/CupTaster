//
//  CoreData.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import CoreData

#warning("add cascade to entities deletion")

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

@objc(Sample)
public class Sample: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sample> {
        return NSFetchRequest<Sample>(entityName: "Sample")
    }
    
    @NSManaged public var ordinalNumber: Int16
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String
    
    @NSManaged public var cupping: Cupping
    @NSManaged public var generalInfo: Set<SampleGeneralInfo>
    @NSManaged public var qualityCriteriaGroups: Set<QCGroup>
}

@objc(CuppingForm)
public class CuppingForm: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CuppingForm> {
        return NSFetchRequest<CuppingForm>(entityName: "CuppingForm")
    }
    
    @NSManaged public var title: String
    @NSManaged public var finalScoreFormula: String
    @NSManaged public var version: Int16
    
    @NSManaged public var cuppings: Set<Cupping>
    @NSManaged public var qcGroupConfigurations: Set<QCGroupConfig>
}

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

@objc(QCGroupConfig)
public class QCGroupConfig: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCGroupConfig> {
        return NSFetchRequest<QCGroupConfig>(entityName: "QCGroupConfig")
    }

    @NSManaged public var title: String
    @NSManaged public var ordinalNumber: Int16
    @NSManaged public var form: CuppingForm?
    @NSManaged public var group: Set<QCGroup>
    @NSManaged public var qcConfigurations: Set<QCConfig>
}

@objc(QualityCriteria)
public class QualityCriteria: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QualityCriteria> {
        return NSFetchRequest<QualityCriteria>(entityName: "QualityCriteria")
    }

    @NSManaged public var title: String
    @NSManaged public var value: Double
    
    @NSManaged public var group: QCGroup
    @NSManaged public var configuration: QCConfig?
}

@objc(QCConfig)
public class QCConfig: QualityCriteria {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCConfig> {
        return NSFetchRequest<QCConfig>(entityName: "QCConfig")
    }

    @NSManaged public var evaluationType: String
    
    @NSManaged public var ordinalNumber: Int16
    
    @NSManaged public var lowerBound: Double
    @NSManaged public var lowerBoundTitle: String?
    @NSManaged public var step: Double
    @NSManaged public var upperBound: Double
    @NSManaged public var upperBoundTitle: String?
    
    @NSManaged public var groupConfiguration: QCGroupConfig
    @NSManaged public var hints: Set<QCHint>
    @NSManaged public var qualityCriteria: Set<QualityCriteria>
}


@objc(SampleGeneralInfo)
public class SampleGeneralInfo: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SampleGeneralInfo> {
        return NSFetchRequest<SampleGeneralInfo>(entityName: "SampleGeneralInfo")
    }
    
    @NSManaged public var title: String
    @NSManaged public var ordinalNumber: Int16
    @NSManaged public var value: String
    
    @NSManaged public var sample: Sample?
}

@objc(QCHint)
public class QCHint: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCHint> {
        return NSFetchRequest<QCHint>(entityName: "QCHint")
    }

    @NSManaged public var lowerBound: Double
    @NSManaged public var upperBound: Double
    @NSManaged public var message: String
    
    @NSManaged public var qcConfiguration: QCConfig
}

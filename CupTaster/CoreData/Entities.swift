//
//  CoreData.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
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

// MARK: Codable Entities

extension CodingUserInfoKey {
    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
}

extension JSONDecoder {
    convenience init(context: NSManagedObjectContext) {
        self.init()
        self.userInfo[.managedObjectContext] = context
    }
}

@objc(CuppingForm)
public class CuppingForm: NSManagedObject, Identifiable, Codable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CuppingForm> {
        return NSFetchRequest<CuppingForm>(entityName: "CuppingForm")
    }
    
    @NSManaged public var title: String
    @NSManaged public var finalScoreFormula: String
    @NSManaged public var version: String
    @NSManaged public var languageCode: String
    
    @NSManaged public var cuppings: Set<Cupping>
    @NSManaged public var qcGroupConfigurations: Set<QCGroupConfig>
    
    // Codable
    
    enum CodingKeys: CodingKey {
        case title, finalScoreFormula, version, languageCode
        case qcGroupConfigurations
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(finalScoreFormula, forKey: .finalScoreFormula)
        try container.encode(version, forKey: .version)
        try container.encode(languageCode, forKey: .languageCode)
        try container.encode(qcGroupConfigurations, forKey: .qcGroupConfigurations)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext
        else { fatalError("Failed to decode") }
        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        title = try values.decode(String.self, forKey: .title)
        finalScoreFormula = try values.decode(String.self, forKey: .finalScoreFormula)
        version = try values.decode(String.self, forKey: .version)
        languageCode = try values.decode(String.self, forKey: .languageCode)
        qcGroupConfigurations = try values.decode(Set<QCGroupConfig>.self, forKey: .qcGroupConfigurations)
    }
}

@objc(QCGroupConfig)
public class QCGroupConfig: NSManagedObject, Identifiable, Codable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCGroupConfig> {
        return NSFetchRequest<QCGroupConfig>(entityName: "QCGroupConfig")
    }

    @NSManaged public var title: String
    @NSManaged public var ordinalNumber: Int16
    
    @NSManaged public var form: CuppingForm?
    @NSManaged public var hint: QCGHint?
    @NSManaged public var group: Set<QCGroup>
    @NSManaged public var qcConfigurations: Set<QCConfig>

    // Codable
    
    enum CodingKeys: CodingKey {
        case title, ordinalNumber, hint, form
        case qcConfigurations
        
        case message
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(ordinalNumber, forKey: .ordinalNumber)
        try container.encode(hint, forKey: .hint)
        try container.encode(qcConfigurations, forKey: .qcConfigurations)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext
        else { fatalError("Failed to decode") }
        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        ordinalNumber = try values.decode(Int16.self, forKey: .ordinalNumber)
        hint = try values.decode(QCGHint?.self, forKey: .hint)
        
        qcConfigurations = Set(try values.decode([QCConfig].self, forKey: .qcConfigurations))
    }
}

@objc(QCConfig)
public class QCConfig: QualityCriteria, Codable {
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
    
    // Codable
    
    enum CodingKeys: CodingKey {
        case title, value, evaluationType, ordinalNumber, lowerBound, lowerBoundTitle, step, upperBound, upperBoundTitle
        case hints
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(value, forKey: .value)
        try container.encode(evaluationType, forKey: .evaluationType)
        try container.encode(ordinalNumber, forKey: .ordinalNumber)
        try container.encode(lowerBound, forKey: .lowerBound)
        try container.encode(lowerBoundTitle, forKey: .lowerBoundTitle)
        try container.encode(step, forKey: .step)
        try container.encode(upperBound, forKey: .upperBound)
        try container.encode(upperBoundTitle, forKey: .upperBoundTitle)
        try container.encode(hints, forKey: .hints)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext
        else { fatalError("Failed to decode") }
        self.init(context: context)

        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decode(String.self, forKey: .title)
        value = try values.decode(Double.self, forKey: .value)
        evaluationType = try values.decode(String.self, forKey: .evaluationType)
        ordinalNumber = try values.decode(Int16.self, forKey: .ordinalNumber)
        lowerBound = try values.decode(Double.self, forKey: .lowerBound)
        lowerBoundTitle = try values.decode(String?.self, forKey: .lowerBoundTitle)
        step = try values.decode(Double.self, forKey: .step)
        upperBound = try values.decode(Double.self, forKey: .upperBound)
        upperBoundTitle = try values.decode(String?.self, forKey: .upperBoundTitle)
        hints = try values.decode(Set<QCHint>.self, forKey: .hints)
    }
}

@objc(QCGHint)
public class QCGHint: NSManagedObject, Identifiable, Codable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCGHint> {
        return NSFetchRequest<QCGHint>(entityName: "QCGHint")
    }

    @NSManaged public var message: String?
    @NSManaged public var groupConfiguration: QCGroupConfig?
    
    // Codable
    
    enum CodingKeys: CodingKey {
        case message
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(message, forKey: .message)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext
        else { fatalError("Failed to decode") }
        self.init(context: context)
        
        message = try decoder.container(keyedBy: CodingKeys.self).decode(String?.self, forKey: .message)
    }
}

@objc(QCHint)
public class QCHint: QCGHint {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCHint> {
        return NSFetchRequest<QCHint>(entityName: "QCHint")
    }
    
    @NSManaged public var lowerBound: Double
    @NSManaged public var qcConfiguration: QCConfig?
    
    // Codable
    
    enum CodingKeys: CodingKey {
        case lowerBound, message
    }
    
    public override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lowerBound, forKey: .lowerBound)
        try container.encode(message, forKey: .message)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext
        else { fatalError("Failed to decode") }
        self.init(context: context)
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lowerBound = try values.decode(Double.self, forKey: .lowerBound)
        message = try values.decode(String.self, forKey: .message)
    }
}

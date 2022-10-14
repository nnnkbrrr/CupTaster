//
//  CuppingForm Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

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

extension CuppingForm {
    var shortDescription: String {
        return "\(self.title).v.\(self.version).\(self.languageCode)"
    }
    
    var isDeprecated: Bool {
        return !CFManager.shared.allCFModels.contains { cfModel in
            self.title == cfModel.title && self.version == cfModel.version
        }
    }
    
    var isDefault: Bool {
        return self.shortDescription == CFManager.shared.defaultCFDescription
    }
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

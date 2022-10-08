//
//  QCGroupConfig Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

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

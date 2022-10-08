//
//  QCGHint Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

@objc(QCGHint)
public class QCGHint: NSManagedObject, Identifiable, Codable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QCGHint> {
        return NSFetchRequest<QCGHint>(entityName: "QCGHint")
    }

    @NSManaged public var message: String
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
        
        message = try decoder.container(keyedBy: CodingKeys.self).decode(String.self, forKey: .message)
    }
}

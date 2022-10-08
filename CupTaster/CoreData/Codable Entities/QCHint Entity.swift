//
//  QCHint.swift
//  CupTaster
//
//  Created by Никита Баранов on 08.10.2022.
//

import CoreData

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

//
//  QCConfig Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

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

extension QCConfig {
    public var unwrappedEvaluation: any Evaluation {
        self.evaluationType.unwrappedEvaluation
    }
}

extension QCConfig {
    static func new(
        context: NSManagedObjectContext,
        title: String,
        evaluationType: any Evaluation,
        ordinalNumber: Int,
        bounds: Range<Double>,
        step: Double,
        value: Double,
        upperBoundTitle: String? = nil,
        lowerBoundTitle: String? = nil
    ) -> QCConfig {
        let criteria: QCConfig = QCConfig(context: context)
        criteria.title = title
        criteria.evaluationType = evaluationType.name
        criteria.ordinalNumber = Int16(ordinalNumber)
        criteria.lowerBound = bounds.lowerBound
        criteria.upperBound = bounds.upperBound
        criteria.step = step
        criteria.value = value
        criteria.upperBoundTitle = upperBoundTitle
        criteria.lowerBoundTitle = lowerBoundTitle

        return criteria
    }
}

extension QCConfig {
    @objc(addHintsObject:)
    @NSManaged public func addToHints(_ value: QCHint)

    @objc(removeHintsObject:)
    @NSManaged public func removeFromHints(_ value: QCHint)

    @objc(addHints:)
    @NSManaged public func addToHints(_ values: NSSet)

    @objc(removeHints:)
    @NSManaged public func removeFromHints(_ values: NSSet)
    
    @objc(addQualityCriteriaObject:)
    @NSManaged public func addToQualityCriteria(_ value: QualityCriteria)

    @objc(removeQualityCriteriaObject:)
    @NSManaged public func removeFromQualityCriteria(_ value: QualityCriteria)

    @objc(addQualityCriteria:)
    @NSManaged public func addToQualityCriteria(_ values: NSSet)

    @objc(removeQualityCriteria:)
    @NSManaged public func removeFromQualityCriteria(_ values: NSSet)
}

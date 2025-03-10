//
//  QualityCriteria Entity.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.10.2022.
//

import CoreData

@objc(QualityCriteria)
public class QualityCriteria: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QualityCriteria> {
        return NSFetchRequest<QualityCriteria>(entityName: "QualityCriteria")
    }

    @NSManaged public var title: String
    @NSManaged public var value: Double
    
    @NSManaged public var group: QCGroup
    @NSManaged public var configuration: QCConfig
}

extension QualityCriteria {
    var shortLabel: String {
        let labelWords: [String] = title.components(separatedBy: .whitespacesAndNewlines)
        
        if labelWords.count > 1 {
            return String(labelWords[0].prefix(1)) + String(labelWords[1].prefix(1))
        } else if title.count < 4 {
            return title
        } else {
            return String(title.prefix(2))
        }
    }
}

extension QualityCriteria {
    var formattedValue: Double {
        return Double(self.configuration.evaluationType.unwrappedEvaluation.getEvaluationValue(self.value, cupsCount: self.group.sample.cupping.cupsCount))
    }
}

extension QualityCriteria: Comparable {
    public static func < (lhs: QualityCriteria, rhs: QualityCriteria) -> Bool {
        return lhs.configuration.ordinalNumber < rhs.configuration.ordinalNumber
    }
}

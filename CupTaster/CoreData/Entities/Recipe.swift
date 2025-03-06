//
//  Recipe.swift
//  CupTaster
//
//  Created by Nikita on 1/10/25.
//

import Foundation
import CoreData

@objc(Recipe)
public class Recipe: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Recipe> {
        return NSFetchRequest<Recipe>(entityName: "Recipe")
    }

    @NSManaged public var name: String
    @NSManaged public var isPinned: Bool
    @NSManaged public var date: Date
    @NSManaged public var grindSize: String
    @NSManaged public var temperature: String
    @NSManaged public var coffeeAmount: String
    @NSManaged public var waterAmount: String
    @NSManaged public var notes: String
    @NSManaged public var steps: Set<RecipeStep>
}

extension Recipe {
    public var sortedSteps: [RecipeStep] {
        self.steps.sorted { $0.ordinalNumber < $1.ordinalNumber }
    }
}

// MARK: Generated accessors for steps
extension Recipe {
    @objc(addStepsObject:)
    @NSManaged public func addToSteps(_ value: RecipeStep)

    @objc(removeStepsObject:)
    @NSManaged public func removeFromSteps(_ value: RecipeStep)

    @objc(addSteps:)
    @NSManaged public func addToSteps(_ values: NSSet)

    @objc(removeSteps:)
    @NSManaged public func removeFromSteps(_ values: NSSet)
}

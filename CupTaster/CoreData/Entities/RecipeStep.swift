//
//  RecipeStep.swift
//  CupTaster
//
//  Created by Nikita on 1/10/25.
//

import Foundation
import CoreData

@objc(RecipeStep)
public class RecipeStep: NSManagedObject, Identifiable {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RecipeStep> {
        return NSFetchRequest<RecipeStep>(entityName: "RecipeStep")
    }

    @NSManaged public var ordinalNumber: Int16
    @NSManaged public var time: String
    @NSManaged public var coffeeAmount: String
    
    @NSManaged public var recipe: Recipe
}

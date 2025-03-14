//
//  Persistence Controller.swift
//  CupTaster
//
//  Created by Никита on 13.07.2022.
//

import CoreData
import CloudKit

struct PersistenceController {
    @MainActor static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    @MainActor
    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "DataModel")
        
        guard let description = container.persistentStoreDescriptions.first
        else { fatalError("Unresolved error") }
        description.cloudKitContainerOptions?.databaseScope = .private
        
        if inMemory { container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null") }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
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

// MARK: For testing

@MainActor func save(_ context: NSManagedObjectContext) {
    if TestingManager.shared.allowSaves {
        try? context.save()
    }
}

//
//  CupTasterTests.swift
//  CupTasterTests
//
//  Created by Никита on 07.09.2022.
//

import XCTest
import SwiftUI
import CoreData

class TestCoreDataStack: NSObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.url = URL(fileURLWithPath: "/dev/null")
        let container = NSPersistentContainer(name: "DataModel")
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
}

@testable import CupTaster
final class CuppingFormsTests: XCTestCase {
    private let moc = TestCoreDataStack().persistentContainer.newBackgroundContext()
    private var cuppingFormModels: [CFManager.CFModel]!
    private var cuppingForms: [CuppingForm]!
    
    override func setUpWithError() throws {
        cuppingFormModels = CFManager.shared.allCFModels
        cuppingForms = []
        for cfModel in cuppingFormModels {
            cuppingForms.append(cfModel.createCuppingForm(context: moc)!)
        }
    }
    
    func test_cuppingForm_data() {
        for cuppingForm in cuppingForms {
            XCTAssertNotNil(cuppingForm.version)
            XCTAssertGreaterThan(cuppingForm.qcGroupConfigurations.count, 0)
            for qcGroupConfiguration in cuppingForm.qcGroupConfigurations {
                XCTAssertGreaterThan(qcGroupConfiguration.qcConfigurations.count, 0)
            }
        }
    }
    
    func test_SCACuppingForm_version() {
        for cfModel in cuppingFormModels {
            let cuppingForm = cfModel.createCuppingForm(context: moc)!
            XCTAssertEqual(cfModel.version, cuppingForm.version)
        }
    }
}

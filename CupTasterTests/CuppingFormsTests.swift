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
final class SCACuppingFormTests: XCTestCase {
    private let moc = TestCoreDataStack().persistentContainer.newBackgroundContext()
    private var cuppingFormModel: CFManager.CFModel!
    private var cuppingForm: CuppingForm!
    
    override func setUpWithError() throws {
        cuppingFormModel = CFManager().sca_CFModel
        cuppingForm = cuppingFormModel.createCuppingForm(context: moc)
    }
    
    func test_SCACuppingForm_data() {
        XCTAssertNotNil(cuppingForm.version)
        XCTAssertGreaterThan(cuppingForm.qcGroupConfigurations.count, 0)
        for qcGroupConfiguration in cuppingForm.qcGroupConfigurations {
            XCTAssertGreaterThan(qcGroupConfiguration.qcConfigurations.count, 0)
        }
    }
    
    func test_SCACuppingForm_version() {
        XCTAssertEqual(cuppingFormModel.version, cuppingForm.version)
    }
}

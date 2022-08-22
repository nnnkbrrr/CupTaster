//
//  Cupping Form Model.swift
//  CupTaster
//
//  Created by Никита on 20.08.2022.
//

import SwiftUI
import CoreData

struct CuppingFormsModel {
    @AppStorage("default-cupping-form") var defaultCuppingForm: String = ""
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: true)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    
    func createSCACuppingForm(context: NSManagedObjectContext) {
        changeCurrentCuppingForm(form: SCACuppingFormModel(context: context).createSCAForm())
    }
    
    func changeCurrentCuppingForm(form: CuppingForm) {
        defaultCuppingForm = form.shortDescription
    }
    
    func getCurrentCuppingForm(cuppingForms: FetchedResults<CuppingForm>) -> CuppingForm {
        if let currentForm: CuppingForm = cuppingForms.first(where: { $0.shortDescription == defaultCuppingForm }) {
            return currentForm
        } else {
            #warning("handle mistakes?")
            changeCurrentCuppingForm(form: cuppingForms.first!)
            return cuppingForms.first!
        }
    }
}

extension CuppingForm {
    var shortDescription: String {
        return "\(self.title).cuptaster.v.\(self.version)"
    }
}

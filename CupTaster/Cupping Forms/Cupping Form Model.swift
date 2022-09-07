//
//  Cupping Form Model.swift
//  CupTaster
//
//  Created by Никита on 20.08.2022.
//

import SwiftUI
import CoreData

class CuppingFormModel {
    let title: String
    let version: String
    
    fileprivate init(title: String, version: String) {
        self.title = title
        self.version = version
    }
    
    func createCuppingForm(context: NSManagedObjectContext) {
        guard let url = Bundle.main.url(forResource: title, withExtension: "json") else { return }
        let data = try? Data(contentsOf: url)
        guard let form = try? JSONDecoder(context: context).decode(CuppingForm.self, from: data!) else { return }
        form.languageCode = Locale.current.languageCode ?? ""
        
        try? context.save()
    }
    
    func isAdded(storedCuppingForms: FetchedResults<CuppingForm>) -> Bool {
        for cuppingForm in storedCuppingForms {
            if cuppingForm.languageCode != Locale.current.languageCode { continue }
            if cuppingForm.title != self.title { continue }
            if cuppingForm.version != self.version { continue }
            return true
        }
        return false
    }
}

struct CuppingFormsModel {
    @AppStorage("default-cupping-form-hashed-id") var defaultCuppingFormHashedID: Int = 0
    public let scaCuppingFormModel: CuppingFormModel = CuppingFormModel(title: "SCA", version: "0.0")
    
    func getDefaultCuppingForm(from cuppingForms: FetchedResults<CuppingForm>) -> CuppingForm? {
        if let defaultCuppingForm = cuppingForms.first(where: { $0.id.hashValue == defaultCuppingFormHashedID }) {
            return defaultCuppingForm
        } else if let firstCuppingForm = cuppingForms.first {
            defaultCuppingFormHashedID = firstCuppingForm.id.hashValue
            return firstCuppingForm
        }
        return nil
    }
    
    func updateForms(context: NSManagedObjectContext, storedCuppingForms: FetchedResults<CuppingForm>) {
        if !scaCuppingFormModel.isAdded(storedCuppingForms: storedCuppingForms) {
            scaCuppingFormModel.createCuppingForm(context: context)
        }
    }
    
    func setDefaultCuppingForm(cuppingForm: CuppingForm) {
        defaultCuppingFormHashedID = cuppingForm.hashValue
    }
}

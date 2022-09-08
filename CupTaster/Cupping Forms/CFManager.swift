//
//  Cupping Form Model.swift
//  CupTaster
//
//  Created by Никита on 20.08.2022.
//

import SwiftUI
import CoreData


public struct CFManager {
    @AppStorage("default-cupping-form-hashed-id") var defaultCuppingFormHashedID: Int = 0
    
    let cfModel_SCA: CFModel = .init(title: "SCA", version: "beta 1.0 (8)")
    
    public func getDefaultCuppingForm(from cuppingForms: FetchedResults<CuppingForm>) -> CuppingForm? {
        if let defaultCuppingForm = cuppingForms.first(where: { $0.id.hashValue == defaultCuppingFormHashedID }) {
            return defaultCuppingForm
        } else if let firstCuppingForm = cuppingForms.first {
            defaultCuppingFormHashedID = firstCuppingForm.id.hashValue
            return firstCuppingForm
        }
        return nil
    }
    
    public func setDefaultCuppingForm(cuppingForm: CuppingForm) {
        defaultCuppingFormHashedID = cuppingForm.hashValue
    }
}

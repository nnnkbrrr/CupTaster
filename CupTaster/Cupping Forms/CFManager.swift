//
//  Cupping Form Model.swift
//  CupTaster
//
//  Created by Никита on 20.08.2022.
//

import SwiftUI
import CoreData

public class CFManager: ObservableObject {
    @AppStorage("default-cupping-form-description") var defaultCFDescription: String = ""
    
    let allCFModels: [CFModel]
    let sca_CFModel: CFModel
    
    init() {
        #warning("version - beta")
        sca_CFModel = .init(title: "SCA", version: "beta 1.0 (10.0)")
        allCFModels = [sca_CFModel]
    }
    
    public func getDefaultCuppingForm(from cuppingForms: FetchedResults<CuppingForm>) -> CuppingForm? {
        if let defaultCuppingForm = cuppingForms.first(where: { $0.description == defaultCFDescription }) {
            return defaultCuppingForm
        } else if let firstCuppingForm = cuppingForms.first {
            defaultCFDescription = firstCuppingForm.shortDescription
            return firstCuppingForm
        }
        return nil
    }
    
    public func setDefaultCuppingForm(cuppingForm: CuppingForm) {
        defaultCFDescription = cuppingForm.shortDescription
    }
}

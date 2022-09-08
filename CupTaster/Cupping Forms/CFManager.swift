//
//  Cupping Form Model.swift
//  CupTaster
//
//  Created by Никита on 20.08.2022.
//

import SwiftUI
import CoreData


public class CFManager: ObservableObject {
    @AppStorage("default-cupping-form-hashed-id") var defaultCF_hashedID: Int = 0
    
    let allCFModels: [CFModel]
    let sca_CFModel: CFModel
    
    init() {
        sca_CFModel = .init(title: "SCA", version: "beta 1.0 (8)")
        allCFModels = [sca_CFModel]
    }
    
    public func getDefaultCuppingForm(from cuppingForms: FetchedResults<CuppingForm>) -> CuppingForm? {
        if let defaultCuppingForm = cuppingForms.first(where: { $0.id.hashValue == defaultCF_hashedID }) {
            return defaultCuppingForm
        } else if let firstCuppingForm = cuppingForms.first {
            defaultCF_hashedID = firstCuppingForm.id.hashValue
            return firstCuppingForm
        }
        return nil
    }
    
    public func setDefaultCuppingForm(cuppingForm: CuppingForm) {
        defaultCF_hashedID = cuppingForm.hashValue
    }
}

//
//  Cupping Form Model.swift
//  CupTaster
//
//  Created by Никита on 20.08.2022.
//

import SwiftUI
import CoreData

public class CFManager: ObservableObject {
    @AppStorage("default-cupping-form-description") private(set) var defaultCFDescription: String = ""
    
    let allCFModels: [CFModel]
    let sca_CFModel: CFModel
    
    static let shared = CFManager()
    private init() {
#warning("version - beta")
        sca_CFModel = .init(
            title: "SCA",
            version: "beta 1.0 (10.0)",
            info: "The SCA Cupping Form is the Global Standard for cupping coffee. This form is designed and intended to be used in conjunction with the SCA Protocol for Cupping Specialty Coffee. The form and corresponding Protocol were designed specifically for Arabica coffee. In practice, though, they are widely used for scoring interspecific hybrids such as castillo, too."
        )
        allCFModels = [sca_CFModel]
    }
}

extension CFManager {
    public func setDefaultCuppingForm(cuppingForm: CuppingForm) {
        defaultCFDescription = cuppingForm.shortDescription
        self.objectWillChange.send()
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
    
    public func newerVersionsAvailability(from cuppingForms: FetchedResults<CuppingForm>) -> Int {
        var count: Int = 0
        for cfModel in allCFModels {
            let anyVersionAdded: Bool = cuppingForms.filter({
                $0.title == cfModel.title
            }).count > 0
            
            let latestVersionAdded: Bool = cuppingForms.filter({
                $0.title == cfModel.title
            }).contains(where: { $0.version == cfModel.version })
            
            if anyVersionAdded && !latestVersionAdded {
                count += 1
            }
        }
        return count
    }
    
    public func hintsAreAvailable(in cuppingForm: CuppingForm) -> Bool {
        return cuppingForm.qcGroupConfigurations.contains { $0.hint != nil }
    }
    
    public func defaultCFHintsAreAvailable(from cuppingForms: FetchedResults<CuppingForm>) -> Bool {
        guard let defaultCF: CuppingForm = self.getDefaultCuppingForm(from: cuppingForms) else { return false }
        return hintsAreAvailable(in: defaultCF)
    }
}

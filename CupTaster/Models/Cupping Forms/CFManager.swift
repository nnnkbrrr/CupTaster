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
    
    static let shared = CFManager()
    private init() {
        let SCA_en_CFModel = CFModel(title: "SCA", version: "1.1")
        let SCA_ru_CFModel = CFModel(title: "SCA на русском", version: "1.1")
        
        allCFModels = [SCA_en_CFModel, SCA_ru_CFModel]
    }
}

extension CFManager {
    public func setDefaultCuppingForm(cuppingForm: CuppingForm?) {
        if let cuppingForm {
            defaultCFDescription = cuppingForm.shortDescription
        } else {
            defaultCFDescription = ""
        }
        self.objectWillChange.send()
    }
    
    public func getDefaultCuppingForm(from cuppingForms: FetchedResults<CuppingForm>) -> CuppingForm? {
        if let defaultCuppingForm = cuppingForms.first(where: { $0.shortDescription == defaultCFDescription }) {
            return defaultCuppingForm
        } else if let firstCuppingForm = cuppingForms.first(where: { !$0.isDeprecated } ) {
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

extension CFManager {
    enum MigrationError: Error {
        case qcGroupMigrationError(String, String), qualityCriteriaMigrationError(String, String)
    }
    
    public func update(
        from initial: CuppingForm,
        to final: CuppingForm,
        context: NSManagedObjectContext,
        onSuccess: @escaping () -> ()
    ) {
        do {
            try fullMigration(from: initial, to: final)
            context.delete(initial)
            save(context)
            onSuccess()
        } catch CFManager.MigrationError.qcGroupMigrationError(let title, let message) {
            onSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAlert(title: title, message: message)
            }
        } catch CFManager.MigrationError.qualityCriteriaMigrationError(let title, let message) {
            onSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAlert(title: title, message: message)
            }
        } catch {
            onSuccess()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showAlert(title: "Error", message: "Unknown Error")
            }
        }
    }
    
    private func fullMigration(from initial: CuppingForm, to final: CuppingForm) throws {
        for cupping in initial.cuppings {
            cupping.form = final
            let finalQCGroupConfigurations: Set<QCGroupConfig> = final.qcGroupConfigurations
            
            for sample in cupping.samples {
                for qcGroup in sample.qualityCriteriaGroups {
                    if let qcGroupConfiguration: QCGroupConfig = finalQCGroupConfigurations.first(where: {
                        $0.title == qcGroup.configuration.title
                    }) {
                        qcGroup.configuration = qcGroupConfiguration
                        let finalCriteriaConfigurations: Set<QCConfig> = qcGroupConfiguration.qcConfigurations
                        
                        for criteria in qcGroup.qualityCriteria {
                            if let criteriaConfiguration: QCConfig = finalCriteriaConfigurations.first(where: {
                                $0.title == criteria.configuration.title
                            }) {
                                criteria.configuration = criteriaConfiguration
                            } else {
                                throw MigrationError.qualityCriteriaMigrationError(
                                    "Error: QC", "\(initial.title) \(initial.version) -> \(final.title) \(final.version)"
                                )
                            }
                        }
                    } else {
                        throw MigrationError.qcGroupMigrationError(
                            "Error: QCG", "\(initial.title) \(initial.version) -> \(final.title) \(final.version)"
                        )
                    }
                }
                
                sample.calculateFinalScore()
            }
        }
    }
}

//
//  CuppingForms.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI
import CoreData

struct Settings_CFSelectorFormSectionsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: CuppingForm.entity(), sortDescriptors: []) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared
    
    @AppStorage("use-cupping-hints")
    var useCuppingHints: Bool = false
    
    var body: some View {
        if cuppingForms.count > 0 {
            Section("Default cupping form") {
                ForEach(cuppingForms) { cuppingForm in
                    Button {
                        cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                    } label: {
                        let isDeprecated: Bool = cuppingForm.isDeprecated
                        Label(
                            isDeprecated ? "\(cuppingForm.shortDescription) (deprecated)" : cuppingForm.title,
                            systemImage: cuppingForm.isDefault ? "checkmark" : ""
                        )
                        .foregroundColor(isDeprecated ? .red : .accentColor)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        moc.delete(cuppingForms[index])
                        try? moc.save()
                    }
                    cfManager.setDefaultCuppingForm(cuppingForm: cuppingForms.first)
                }
            }
        }
        
        let availableCFsModels = cfManager.allCFModels.filter {
            $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil
        }
        if availableCFsModels.count > 0 {
            Section("Available cupping forms") {
                ForEach(availableCFsModels) { cfModel in
                    Button {
                        if let addedForm = cfModel.createCuppingForm(context: moc) {
                            cfManager.setDefaultCuppingForm(cuppingForm: addedForm)
                        }
                    } label: {
                        Label(cfModel.title, systemImage: "plus")
                    }
                }
            }
        }
        
#warning("hints toggle is hidden")
//        if cfManager.defaultCFDescription != "" {
//            Section {
//                if cfManager.defaultCFHintsAreAvailable(from: cuppingForms) {
//                    Toggle(isOn: $useCuppingHints) {
//                        Label("Display cupping hints", systemImage: "person.fill.questionmark")
//                    }
//                } else {
//                    Label("Hints are unavailable in this cupping form yet", systemImage: "person.fill.questionmark")
//                        .font(.caption)
//                        .foregroundColor(.gray)
//                }
//            } header: {
//                Text("Hints")
//            }
//        }
    }
}

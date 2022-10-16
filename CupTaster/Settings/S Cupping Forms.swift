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

    @AppStorage("use-cupping-hints")
    var useCuppingHints: Bool = false
    
    var body: some View {
        if cuppingForms.count > 0 {
            Section("Default cupping form") {
                ForEach(cuppingForms) { cuppingForm in
                    Button {
                        CFManager.shared.setDefaultCuppingForm(cuppingForm: cuppingForm)
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
                    #warning("alert - all cuppings will be deleted!")
                    CFManager.shared.setDefaultCuppingForm(cuppingForm: cuppingForms.first)
                }
            }
        }
        
        let availableCFsModels = CFManager.shared.allCFModels.filter {
            $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil
        }
        if availableCFsModels.count > 0 {
            Section("Available cupping forms") {
                ForEach(availableCFsModels) { cfModel in
                    Button {
                        if let addedForm = cfModel.createCuppingForm(context: moc) {
                            CFManager.shared.setDefaultCuppingForm(cuppingForm: addedForm)
                        }
                    } label: {
                        Label(cfModel.title, systemImage: "plus")
                    }
                }
            }
        }
        
        if CFManager.shared.defaultCFDescription != "" {
            Section {
                if CFManager.shared.defaultCFHintsAreAvailable(from: cuppingForms) {
                    Toggle(isOn: $useCuppingHints) {
                        Label("Display cupping hints", systemImage: "person.fill.questionmark")
                    }
                } else {
                    Label("Hints are unavailable in this cupping form", systemImage: "person.fill.questionmark")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            } header: {
                Text("Hints")
            }
        }
    }
}

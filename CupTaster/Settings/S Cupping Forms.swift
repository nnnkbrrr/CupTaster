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
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared
    
    @AppStorage("use-cupping-hints")
    var useCuppingHints: Bool = false
    
    @State var deleteAlertActive: Bool = false
    @State var deleteAlertCuppingForm: CuppingForm? = nil
    
    var body: some View {
        if cuppingForms.count > 0 {
            Section("Default cupping form") {
                ForEach(cuppingForms) { cuppingForm in
                    let isDeprecated: Bool = cuppingForm.isDeprecated
                    Button {
                        cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                    } label: {
                        Label {
                            Text(isDeprecated ? "\(cuppingForm.shortDescription) (deprecated)" : cuppingForm.title)
                        } icon: {
                            Image(systemName: "checkmark").opacity(cuppingForm.isDefault ? 1 : 0)
                        }
                    }
                    .foregroundColor(isDeprecated ? .red : .accentColor)
                }
                .onDelete { offsets in
                    let cuppingForm: CuppingForm = cuppingForms[offsets.first!]
                    if cuppingForm.cuppings.count > 0 {
                        deleteAlertActive = true
                        deleteAlertCuppingForm = cuppingForm
                    } else {
                        moc.delete(cuppingForm)
                        try? moc.save()
                    }
                    cfManager.setDefaultCuppingForm(cuppingForm: cuppingForms.first)
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete cupping form and all related cuppings?",
                isPresented: $deleteAlertActive,
                titleVisibility: .visible,
                actions: {
                    Button("Delete", role: .destructive) {
                        if let deleteAlertCuppingForm {
                            moc.delete(deleteAlertCuppingForm)
                            try? moc.save()
                        }
                        deleteAlertCuppingForm = nil
                        deleteAlertActive = false
                    }
                    Button("Cancel", role: .cancel) {
                        deleteAlertCuppingForm = nil
                        deleteAlertActive = false
                    }
                }
            )
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

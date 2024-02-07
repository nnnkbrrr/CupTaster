//
//  Setting Cupping Forms.swift
//  CupTaster
//
//  Created by Nikita on 06.02.2024.
//

import SwiftUI

struct Settings_CuppingForms: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared

    @State var deleteAlertActive: Bool = false
    @State var deleteAlertCuppingForm: CuppingForm? = nil
    var body: some View {
        Form {
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
        }
    }
}

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
    
    @Binding var cuppingFormInfo: CuppingForm?
    
    var body: some View {
        let allCFModels = CFManager.shared.allCFModels
        let addedCuppingForms = CFManager.shared.allCFModels.compactMap { $0.getCuppingForm(storedCuppingForms: cuppingForms) }
        if addedCuppingForms.count > 0 {
            Section {
                ForEach(addedCuppingForms) { cuppingForm in
                    HStack {
                        Button {
                            withAnimation {
                                cuppingFormInfo = cuppingForm
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .frame(width: 30)
                                    .opacity(cuppingForm.isSelected(defaultCFDescription: CFManager.shared.defaultCFDescription) ? 1 : 0)
                                Divider()
                                    .padding(.vertical, 5)
                                Text(cuppingForm.title)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } header: {
                Text("Added")
            }
        }
        
        let availableCFsModels = allCFModels.filter { $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil }
        if availableCFsModels.count > 0 {
            Section {
                ForEach(availableCFsModels) { cfModel in
                    HStack {
                        Button {
                            if let addedForm = cfModel.createCuppingForm(context: moc) {
                                cuppingFormInfo = addedForm
                            }
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                    .frame(width: 30)
                                Divider()
                                    .padding(.vertical, 5)
                                Text(cfModel.title)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } header: {
                Text("Available")
            }
        }
        
        let deprecatedCuppingForms = cuppingForms.filter { $0.isDeprecated }
        if deprecatedCuppingForms.count > 0 {
            Section {
                ForEach(deprecatedCuppingForms) { cuppingForm in
                    HStack {
                        Button {
                            withAnimation {
                                CFManager.shared.setDefaultCuppingForm(cuppingForm: cuppingForm)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark")
                                    .frame(width: 30)
                                    .opacity(cuppingForm.isSelected(defaultCFDescription: CFManager.shared.defaultCFDescription) ? 1 : 0)
                                Divider()
                                    .padding(.vertical, 5)
                                Text("\(cuppingForm.title) v. \(cuppingForm.version) - \(cuppingForm.languageCode)")
                                Spacer()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .onDelete { offsets in
                    for index in offsets {
                        moc.delete(cuppingForms[index])
                        try? moc.save()
                    }
                }
            } header: {
                Label("Deprecated", systemImage: "exclamationmark.triangle")
                    .foregroundColor(.red)
            }
        }
        
        Section {
            if CFManager.shared.defaultCFHintsAreAvailable(from: cuppingForms) {
                Toggle(isOn: $useCuppingHints) {
                    Label("Display hints", systemImage: "person.fill.questionmark")
                }
            } else {
                Label("Hints are unavailable in this cupping form", systemImage: "person.fill.questionmark")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

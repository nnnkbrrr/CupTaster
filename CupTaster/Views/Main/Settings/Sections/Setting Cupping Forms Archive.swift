//
//  Setting Cupping Forms Archive.swift
//  CupTaster
//
//  Created by Nikita Baranov on 17.04.2024.
//

import SwiftUI

extension Settings_CuppingFormsView {
    struct CuppingFormsArchiveView: View {
        @Environment(\.managedObjectContext) private var moc
        @FetchRequest(
            entity: CuppingForm.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
        ) var cuppingForms: FetchedResults<CuppingForm>
        @StateObject var cfManager = CFManager.shared
        
        @State var deleteAlertActive: Bool = false
        @State var cuppingFormToMigrate: CuppingForm? = nil
        
        var body: some View {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .extraSmall) {
                    SettingsSection {
                        let deprectaredCuppingForms: [CuppingForm] = cuppingForms.filter { $0.isDeprecated }
                        
                        ForEach(deprectaredCuppingForms) { cuppingForm in
                            let migrationIsAvailable: Bool = cuppingForm.title.contains("SCA")
                            
                            SwipeView {
                                SettingsButtonSection(title: cuppingForm.title) {
                                    if migrationIsAvailable {
                                        cuppingFormToMigrate = cuppingForm
                                    } else {
                                        showAlert(
                                            title: "This cupping form is no longer supported",
                                            message: "We apologize for the inconvenience. You can export all your cupping data on the main page."
                                        )
                                    }
                                } leadingContent: {
                                    Image(systemName: "exclamationmark.triangle")
                                        .foregroundStyle(migrationIsAvailable ? Color.orange : Color.red)
                                }
                                .foregroundStyle(migrationIsAvailable ? Color.orange : Color.red)
                            } trailingActions: { _ in
                                SwipeAction {
                                    if cuppingForm.cuppings.count > 0 {
                                        deleteAlertActive = true
                                    } else {
                                        moc.delete(cuppingForm)
                                        save(moc)
                                    }
                                    cfManager.setDefaultCuppingForm(cuppingForm: cuppingForms.first(where: { !$0.isDeprecated }))
                                } label: { _ in
                                    VStack(spacing: .extraSmall) {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                } background: { _ in
                                    Color.red
                                }
                            }
                            .defaultSwipeStyle()
                            .confirmationDialog(
                                "Are you sure you want to delete cupping form and all related cuppings?",
                                isPresented: $deleteAlertActive,
                                titleVisibility: .visible,
                                actions: {
                                    Button("Delete", role: .destructive) {
                                        moc.delete(cuppingForm)
                                        save(moc)
                                        deleteAlertActive = false
                                    }
                                    Button("Cancel", role: .cancel) {
                                        deleteAlertActive = false
                                    }
                                }
                            )
                        }
                    }
                    .adaptiveSizeSheet(isPresented: Binding(
                        get: { cuppingFormToMigrate != nil },
                        set: { _ in cuppingFormToMigrate = nil }
                    )) {
                        DeprectaredCuppingFormMigrationModalView(cuppingFormToMigrate: $cuppingFormToMigrate)
                    }
                }
                .padding(.small)
            }
            .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
            .navigationTitle("Archive")
            .defaultNavigationBar()
        }
    }
}

struct DeprectaredCuppingFormMigrationModalView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    
    @StateObject var cfManager = CFManager.shared
    
    @Binding var cuppingFormToMigrate: CuppingForm?
    @State var newerFormToMigrate: CuppingForm? = nil
    @State var newerCFModelToMigrate: CFManager.CFModel? = nil
    
    var body: some View {
        VStack(spacing: .large) {
            if let cuppingFormToMigrate {
                Text("A newer version of this cupping form is available")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .regular)
                
                Text("Select the form you want to upgrade to")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .regular)
                
                LazyVStack(alignment: .leading, spacing: .extraSmall) {
                    SettingsSection {
                        let notDeprecatedCuppingForms: [CuppingForm] = cuppingForms.filter { !$0.isDeprecated }
                        ForEach(notDeprecatedCuppingForms) { cuppingForm in
                            SettingsButtonSection(title: cuppingForm.title) {
                                newerFormToMigrate = cuppingForm
                                newerCFModelToMigrate = nil
                            }
                            .opacity(newerFormToMigrate == cuppingForm ? 1 : 0.5)
                        }
                        
                        let availableCuppingFormModels: [CFManager.CFModel] = cfManager.allCFModels.filter {
                            $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil
                        }
                        ForEach(availableCuppingFormModels) { cuppingFormModel in
                            SettingsButtonSection(title: cuppingFormModel.title) {
                                newerCFModelToMigrate = cuppingFormModel
                                newerFormToMigrate = nil
                            }
                            .opacity(newerCFModelToMigrate?.id == cuppingFormModel.id ? 1 : 0.5)
                        }
                    }
                }
                
                HStack(spacing: .extraSmall) {
                    Button("OK") {
                        self.cuppingFormToMigrate = nil
                        newerFormToMigrate = nil
                        newerCFModelToMigrate = nil
                    }
                    .buttonStyle(.bottomSheetBlock)
                    
                    Button("Update") {
                        if let newerFormToMigrate {
                            cfManager.update(from: cuppingFormToMigrate, to: newerFormToMigrate, context: moc) {
                                self.cuppingFormToMigrate = nil
                                self.newerFormToMigrate = nil
                                self.newerCFModelToMigrate = nil
                                cfManager.setDefaultCuppingForm(cuppingForm: newerFormToMigrate)
                            }
                        }
                        
                        if let newerCFModelToMigrate {
                            if let newerFormToMigrate = newerCFModelToMigrate.createCuppingForm(context: moc) {
                                cfManager.update(from: cuppingFormToMigrate, to: newerFormToMigrate, context: moc) {
                                    self.cuppingFormToMigrate = nil
                                    self.newerFormToMigrate = nil
                                    self.newerCFModelToMigrate = nil
                                    cfManager.setDefaultCuppingForm(cuppingForm: newerFormToMigrate)
                                }
                            }
                        }
                    }
                    .buttonStyle(.accentBottomSheetBlock)
                    .disabled(newerFormToMigrate == nil && newerCFModelToMigrate == nil)
                    .opacity(newerFormToMigrate == nil && newerCFModelToMigrate == nil ? 0.5 : 1)
                }
            } else {
                Text("Error")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .regular)
                
                Button("OK") {
                    cuppingFormToMigrate = nil
                }
                .buttonStyle(.bottomSheetBlock)
            }
        }
        .padding(.small)
    }
}

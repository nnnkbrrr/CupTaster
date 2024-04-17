//
//  Setting Cupping Forms.swift
//  CupTaster
//
//  Created by Nikita on 06.02.2024.
//

import SwiftUI

struct Settings_CuppingFormsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared
    
    @State var deleteAlertActive: Bool = false
    @State var deleteAlertCuppingForm: CuppingForm? = nil
    
    let showNavigationBar: Bool
    
    init(showNavigationBar: Bool = true) {
        self.showNavigationBar = showNavigationBar
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsSection {
                    ForEach(cuppingForms) { cuppingForm in
                        let isDeprecated: Bool = cuppingForm.isDeprecated
                        
#warning("is deprecated vs min version")
                        SwipeView {
                            SettingsButtonSection(title: cuppingForm.title) {
                                cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                            } leadingContent: {
                                Image(systemName: isDeprecated ? "exclamationmark.triangle" : "checkmark")
                                    .foregroundStyle(isDeprecated ? Color.red : Color.accentColor)
                                    .opacity(cuppingForm.isDefault || isDeprecated ? 1 : 0)
                            }
                            .foregroundStyle(isDeprecated ? Color.red : Color.primary)
                        } trailingActions: { _ in
                            SwipeAction {
                                if let newSCA: CuppingForm = cuppingForms.first(where: { $0.version == "1.1" }) {
                                    do {
                                        try cfManager.update(from: cuppingForm, to: newSCA)
                                        moc.delete(cuppingForm)
                                    } catch CFManager.MigrationError.qcGroupMigrationError(let title, let message) {
                                        showAlert(title: title, message: message)
                                    } catch CFManager.MigrationError.qualityCriteriaMigrationError(let title, let message) {
                                        showAlert(title: title, message: message)
                                    } catch {
                                        showAlert(title: "Error", message: "Unknown Error")
                                    }
                                } else {
                                    showAlert(title: "Error", message: "No available form")
                                }
                            } label: { _ in
                                VStack(spacing: .extraSmall) {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Update")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            } background: { _ in
                                Color.orange
                            }
                        }
                        .defaultSwipeStyle()
#warning("actions")
                        //.onDelete { offsets in
                        //    let cuppingForm: CuppingForm = cuppingForms[offsets.first!]
                        //    if cuppingForm.cuppings.count > 0 {
                        //        deleteAlertActive = true
                        //        deleteAlertCuppingForm = cuppingForm
                        //    } else {
                        //        moc.delete(cuppingForm)
                        //        if TestingManager.shared.allowSaves { try? moc.save() }
                        //    }
                        //    cfManager.setDefaultCuppingForm(cuppingForm: cuppingForms.first)
                        //}
                        //.confirmationDialog(
                        //    "Are you sure you want to delete cupping form and all related cuppings?",
                        //    isPresented: $deleteAlertActive,
                        //    titleVisibility: .visible,
                        //    actions: {
                        //        Button("Delete", role: .destructive) {
                        //            if let deleteAlertCuppingForm {
                        //                moc.delete(deleteAlertCuppingForm)
                        //                if TestingManager.shared.allowSaves { try? moc.save() }
                        //            }
                        //            deleteAlertCuppingForm = nil
                        //            deleteAlertActive = false
                        //        }
                        //        Button("Cancel", role: .cancel) {
                        //            deleteAlertCuppingForm = nil
                        //            deleteAlertActive = false
                        //        }
                        //    }
                        //)
                    }
                }
                
                                    let availableCuppingFormModels: [CFManager.CFModel] = cfManager.allCFModels.filter {
                                        $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil
                                    }
                
                                    if availableCuppingFormModels.count > 0 {
//                Text("TEST")
                SettingsSection("Available") {
                                                ForEach(availableCuppingFormModels) { cuppingFormModel in
//                    ForEach(cfManager.allCFModels) { cuppingFormModel in
                        Text(cuppingFormModel.title)
                        SettingsButtonSection(title: cuppingFormModel.title, systemImageName: "plus") {
                            if let cuppingForm = cuppingFormModel.createCuppingForm(context: moc) {
                                cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                            }
                        }
                    }
                }
                                    }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .modifier(NavigationBarModifier(show: showNavigationBar))
    }
    
    private struct NavigationBarModifier: ViewModifier {
        let showNavigationBar: Bool
        
        init(show showNavigationBar: Bool) {
            self.showNavigationBar = showNavigationBar
        }
        
        func body(content: Content) -> some View {
            if showNavigationBar {
                content
                    .navigationTitle("Cupping Forms")
                    .defaultNavigationBar()
            } else {
                content
            }
        }
    }
}
